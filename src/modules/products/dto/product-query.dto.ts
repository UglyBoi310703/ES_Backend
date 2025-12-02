import { IsOptional, IsInt, IsString, IsBoolean, IsEnum } from 'class-validator';
import { Type } from 'class-transformer';
import { PaginationDto } from '../../../common/dto/pagination.dto';

export enum SortBy {
  NEWEST = 'newest',
  PRICE_ASC = 'price_asc',
  PRICE_DESC = 'price_desc',
  BESTSELLER = 'bestseller',
  RATING = 'rating',
}

export class ProductQueryDto extends PaginationDto {
  @IsOptional()
  @IsString()
  search?: string;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  category_id?: number;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  brand_id?: number;

  @IsOptional()
  @Type(() => Number)
  min_price?: number;

  @IsOptional()
  @Type(() => Number)
  max_price?: number;

  @IsOptional()
  @IsEnum(SortBy)
  sort_by?: SortBy;

  @IsOptional()
  @Type(() => Boolean)
  @IsBoolean()
  is_featured?: boolean;
}
