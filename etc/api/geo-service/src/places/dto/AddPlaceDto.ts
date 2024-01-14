import {
  IsString,
  IsOptional,
  IsNumber,
  IsBoolean,
  IsArray,
  ValidateNested,
  IsLatitude,
  IsLongitude,
  IsNotEmpty,
} from 'class-validator';
import { Type } from 'class-transformer';

export class AddPlaceDto {
  @IsString()
  @IsNotEmpty()
  name: string;

  @IsString()
  @IsOptional()
  description?: string;

  @IsString()
  @IsOptional()
  address?: string;

  @IsString()
  @IsOptional()
  highway?: string;

  @IsString()
  @IsOptional()
  exit?: string;

  @IsArray()
  @IsString({ each: true })
  @IsOptional()
  categories?: string[];

  @ValidateNested({ each: true })
  @Type(() => ContactDto)
  @IsOptional()
  contact?: ContactDto[];

  @IsArray()
  @IsString({ each: true })
  @IsOptional()
  amenities?: string[];

  @IsNumber()
  @IsOptional()
  parkingSpaces?: number;

  @IsNumber()
  @IsOptional()
  showers?: number;

  @IsBoolean()
  @IsOptional()
  scales?: boolean;

  @IsNumber()
  @IsOptional()
  fuelLanes?: number;

  @IsArray()
  @IsString({ each: true })
  @IsOptional()
  paymentsAccepted?: string[];

  @IsNumber()
  @IsOptional()
  serviceBays?: number;

  @IsNumber()
  @IsOptional()
  serviceRadius?: number;

  @IsArray()
  @IsString({ each: true })
  @IsOptional()
  parkingTypes?: string[];

  @ValidateNested()
  @Type(() => PricingDto)
  @IsOptional()
  pricing?: PricingDto;

  @IsLatitude()
  @IsOptional()
  latitude?: number;

  @IsLongitude()
  @IsOptional()
  longitude?: number;
}

class ContactDto {
  @IsString()
  @IsOptional()
  phone?: string;
}

class PricingDto {
  @IsNumber()
  @IsOptional()
  monthly?: number;

  @IsNumber()
  @IsOptional()
  daily?: number;

  @IsNumber()
  @IsOptional()
  weekly?: number;
}
