import { IsString, IsBoolean, IsOptional, Matches } from 'class-validator';

export class CreateAddressDto {
  @IsString()
  recipient_name: string;

  @IsString()
  @Matches(/^[0-9]{10,11}$/)
  phone: string;

  @IsString()
  province: string;

  @IsString()
  district: string;

  @IsString()
  ward: string;

  @IsString()
  detail_address: string;

  @IsOptional()
  @IsBoolean()
  is_default?: boolean;
}
