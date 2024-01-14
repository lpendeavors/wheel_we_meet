import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Post,
  Query,
} from '@nestjs/common';

import { PlacesService } from './places.service';
import { AddPlaceDto } from './dto/AddPlaceDto';

@Controller('places')
export class PlacesController {
  constructor(private readonly placesService: PlacesService) {}

  @Get('nearby')
  async findNearby(
    @Query('latitude') latitude: number,
    @Query('longitude') longitude: number,
  ) {
    const maxDistance = 200 * 1609.34;
    return this.placesService.findNearby(latitude, longitude, maxDistance);
  }

  @Get(':id')
  async findOne(@Param('id') id: string) {
    return this.placesService.findOne(id);
  }

  @Post()
  async create(@Body() createPlaceDtos: AddPlaceDto[]) {
    return this.placesService.create(createPlaceDtos);
  }

  @Delete(':id')
  async delete(@Param('id') id: string) {
    return this.placesService.delete(id);
  }
}
