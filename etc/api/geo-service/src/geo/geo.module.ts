import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';

import { GeoService } from './geo.service';
import { GeoController } from './geo.controller';
import { GeoSchema } from './model/geo.schema';

@Module({
  imports: [MongooseModule.forFeature([{ name: 'Geo', schema: GeoSchema }])],
  providers: [GeoService],
  controllers: [GeoController],
})
export class GeoModule {}
