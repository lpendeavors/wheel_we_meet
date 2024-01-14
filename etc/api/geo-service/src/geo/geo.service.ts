import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';

import { UserLocation } from './model/geo.interface';

@Injectable()
export class GeoService {
  constructor(
    @InjectModel('Geo') private readonly geoModel: Model<UserLocation>,
  ) {}

  async saveUserLocation(
    locationId: string,
    latitude: number,
    longitude: number,
    locationIds: string[],
  ): Promise<string[]> {
    await this.geoModel.findOneAndUpdate(
      { locationId },
      {
        locationId,
        location: { type: 'Point', coordinates: [longitude, latitude] },
        timestamp: new Date(),
      },
      { upsert: true, new: true },
    );

    const recentTimeLimit = new Date(new Date().getTime() - 1000 * 60 * 30);

    const nearbyUsers = await this.geoModel
      .find({
        locationId: { $in: locationIds },
        timestamp: { $gte: recentTimeLimit },
        location: {
          $near: {
            $geometry: {
              type: 'Point',
              coordinates: [longitude, latitude],
            },
            $maxDistance: 50 * 1609.34,
          },
        },
      })
      .exec();

    const userIds = nearbyUsers.map((location) => location.locationId);

    return userIds.filter((id) => id !== locationId);
  }
}
