import { IsString, IsArray, IsOptional } from 'class-validator';

export class UpdateLocationDto {
  @IsString()
  locationId: string;

  @IsString()
  latitude: string;

  @IsString()
  longitude: string;

  @IsArray()
  @IsString({ each: true })
  @IsOptional()
  locationIds?: string[];
}
