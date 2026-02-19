import { Controller, Get, Query, Param, ParseIntPipe } from '@nestjs/common';
import { ProductsService } from './products.service';
import { ProductQueryDto } from './dto/product-query.dto';

@Controller('products')
export class ProductsController {
  constructor(private readonly productsService: ProductsService) {}

  @Get()
  async findAll(@Query() query: ProductQueryDto) {
    return this.productsService.findAll(query);
  }

  @Get('bestsellers')
  async findBestsellers(
    @Query('limit', ParseIntPipe) limit?: number,
    @Query('category_id', ParseIntPipe) categoryId?: number,
  ) {
    return this.productsService.findBestsellers(limit, categoryId);
  }

  @Get('featured')
  async findFeatured(@Query('limit', ParseIntPipe) limit?: number) {
    return this.productsService.findFeatured(limit);
  }

  @Get('latest')
  async findLatest(@Query('limit', ParseIntPipe) limit?: number) {
    return this.productsService.findLatest(limit);
  }

  @Get(':slug')
  async findBySlug(@Param('slug') slug: string) {
    return this.productsService.findBySlug(slug);
  }

  @Get(':id/related')
  async findRelated(
    @Param('id', ParseIntPipe) id: number,
    @Query('limit', ParseIntPipe) limit?: number,
  ) {
    return this.productsService.findRelated(id, limit);
  }
}
