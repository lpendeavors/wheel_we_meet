import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';

import { Place } from './model/places.interface';
import { AddPlaceDto } from './dto/AddPlaceDto';

@Injectable()
export class PlacesService {
  constructor(
    @InjectModel('Place') private readonly placeModel: Model<Place>,
  ) {}

  async findNearby(
    latitude: number,
    longitude: number,
    maxDistance: number,
  ): Promise<Place[]> {
    return await this.placeModel
      .aggregate([
        {
          $geoNear: {
            near: {
              type: 'Point',
              coordinates: [+longitude, +latitude],
            },
            distanceField: 'distance',
            maxDistance,
            spherical: true,
          },
        },
        {
          $sort: {
            distance: 1,
          },
        },
        {
          $project: {
            id: '$_id',
            _id: 0,
            name: 1,
            description: 1,
            address: 1,
            categories: 1,
            contact: 1,
            amenities: 1,
            parkingSpaces: 1,
            showers: 1,
            scales: 1,
            fuelLanes: 1,
            paymentsAccepted: 1,
            serviceBays: 1,
            serviceRadius: 1,
            parkingTypes: 1,
            parkingPrices: 1,
            location: 1,
            distance: 1,
          },
        },
      ])
      .exec();
  }

  async findOne(id: string): Promise<Place> {
    return await this.placeModel.findById(id).exec();
  }

  async create(createPlaceDtos: AddPlaceDto[]): Promise<void> {
    const newPlaces = createPlaceDtos.map((dto) => {
      const newPlace = new this.placeModel();
      newPlace.name = dto.name;
      newPlace.address = dto.address;
      newPlace.description = dto.description;
      newPlace.location = {
        type: 'Point',
        coordinates: [dto.longitude, dto.latitude],
      };
      newPlace.categories = dto.categories;
      newPlace.parkingSpaces = dto.parkingSpaces;
      newPlace.showers = dto.showers;

      if (dto.scales !== undefined) {
        newPlace.scales = dto.scales;
      }

      newPlace.amenities = dto.amenities;
      newPlace.amenities.forEach((amenity: string) => {
        if (amenity.toLowerCase().includes('number of showers: ')) {
          newPlace.showers = parseInt(amenity.split(': ')[1]);
          newPlace.amenities.splice(newPlace.amenities.indexOf(amenity), 1);
        } else if (amenity.toLowerCase().includes('scales')) {
          newPlace.scales = true;
        }
      });

      return newPlace;
    });

    await this.placeModel.insertMany(newPlaces);
  }

  async delete(id: string): Promise<any> {
    return this.placeModel.findByIdAndDelete(id).exec();
  }
}
