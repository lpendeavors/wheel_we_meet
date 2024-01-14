import { Controller, Post, Body, HttpCode } from '@nestjs/common';
import { GeoService } from './geo.service';
import { UpdateLocationDto } from './dto/UpdateLocationDto';

@Controller('geo')
export class GeoController {
  constructor(private readonly geoService: GeoService) {}

  @HttpCode(200)
  @Post('update-location')
  async updateLocation(@Body() updateLocationDto: UpdateLocationDto) {
    return await this.geoService.saveUserLocation(
      updateLocationDto.locationId,
      +updateLocationDto.latitude,
      +updateLocationDto.longitude,
      updateLocationDto.locationIds,
    );
  }
}
