#!/bin/bash

echo "🚀 Implementing all important modules..."

# Create Products Module Implementation
mkdir -p src/modules/products/dto

cat > src/modules/products/dto/product-query.dto.ts << 'EOF'
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
EOF

cat > src/modules/products/products.service.ts << 'EOF'
import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Not } from 'typeorm';
import { Product } from '../../entities/product.entity';
import { ProductImage } from '../../entities/product-image.entity';
import { ProductQueryDto, SortBy } from './dto/product-query.dto';
import { createPaginationMeta } from '../../common/dto/pagination.dto';

@Injectable()
export class ProductsService {
  constructor(
    @InjectRepository(Product)
    private productRepository: Repository<Product>,
    @InjectRepository(ProductImage)
    private imageRepository: Repository<ProductImage>,
  ) {}

  async findAll(query: ProductQueryDto) {
    const {
      page = 1,
      limit = 20,
      search,
      category_id,
      brand_id,
      min_price,
      max_price,
      sort_by = SortBy.NEWEST,
      is_featured,
    } = query;

    const qb = this.productRepository
      .createQueryBuilder('product')
      .leftJoinAndSelect('product.brand', 'brand')
      .leftJoinAndSelect('product.category', 'category')
      .leftJoinAndSelect('product.images', 'images', 'images.isPrimary = :isPrimary', {
        isPrimary: true,
      })
      .where('product.isActive = :isActive', { isActive: true });

    if (search) {
      qb.andWhere(
        '(product.productName LIKE :search OR product.shortDescription LIKE :search)',
        { search: `%${search}%` },
      );
    }

    if (category_id) {
      qb.andWhere('product.categoryId = :categoryId', { categoryId: category_id });
    }

    if (brand_id) {
      qb.andWhere('product.brandId = :brandId', { brandId: brand_id });
    }

    if (min_price) {
      qb.andWhere('product.sellingPrice >= :minPrice', { minPrice: min_price });
    }

    if (max_price) {
      qb.andWhere('product.sellingPrice <= :maxPrice', { maxPrice: max_price });
    }

    if (is_featured !== undefined) {
      qb.andWhere('product.isFeatured = :isFeatured', { isFeatured: is_featured });
    }

    switch (sort_by) {
      case SortBy.PRICE_ASC:
        qb.orderBy('product.sellingPrice', 'ASC');
        break;
      case SortBy.PRICE_DESC:
        qb.orderBy('product.sellingPrice', 'DESC');
        break;
      case SortBy.BESTSELLER:
        qb.orderBy('product.soldCount', 'DESC');
        break;
      case SortBy.RATING:
        qb.orderBy('product.averageRating', 'DESC');
        break;
      default:
        qb.orderBy('product.createdAt', 'DESC');
    }

    const skip = (page - 1) * limit;
    qb.skip(skip).take(limit);

    const [data, total] = await qb.getManyAndCount();

    return {
      data: data.map((p) => this.transformProduct(p)),
      meta: createPaginationMeta(page, limit, total),
    };
  }

  async findBySlug(slug: string) {
    const product = await this.productRepository.findOne({
      where: { slug, isActive: true },
      relations: ['brand', 'category', 'images'],
    });

    if (!product) {
      throw new NotFoundException('Sản phẩm không tồn tại');
    }

    await this.productRepository.increment({ productId: product.productId }, 'viewCount', 1);

    return { data: product };
  }

  async findRelated(productId: number, limit = 8) {
    const product = await this.productRepository.findOne({
      where: { productId },
      select: ['categoryId', 'brandId'],
    });

    if (!product) {
      return { data: [] };
    }

    const related = await this.productRepository.find({
      where: {
        categoryId: product.categoryId,
        isActive: true,
        productId: Not(productId),
      },
      relations: ['images'],
      take: limit,
      order: { soldCount: 'DESC' },
    });

    return { data: related.map((p) => this.transformProduct(p)) };
  }

  async findBestsellers(limit = 10, categoryId?: number) {
    const query: any = { isActive: true };
    if (categoryId) {
      query.categoryId = categoryId;
    }

    const products = await this.productRepository.find({
      where: query,
      relations: ['images'],
      take: limit,
      order: { soldCount: 'DESC' },
    });

    return { data: products.map((p) => this.transformProduct(p)) };
  }

  async findFeatured(limit = 8) {
    const products = await this.productRepository.find({
      where: { isActive: true, isFeatured: true },
      relations: ['images'],
      take: limit,
      order: { createdAt: 'DESC' },
    });

    return { data: products.map((p) => this.transformProduct(p)) };
  }

  async findLatest(limit = 12) {
    const products = await this.productRepository.find({
      where: { isActive: true },
      relations: ['images'],
      take: limit,
      order: { createdAt: 'DESC' },
    });

    return { data: products.map((p) => this.transformProduct(p)) };
  }

  private transformProduct(product: Product) {
    return {
      ...product,
      primary_image: product.images?.[0]?.imageUrl || null,
      discount_percentage: this.calculateDiscountPercentage(
        Number(product.originalPrice),
        Number(product.sellingPrice),
      ),
    };
  }

  private calculateDiscountPercentage(original: number, selling: number): number {
    if (original <= selling) return 0;
    return Math.round(((original - selling) / original) * 100);
  }
}
EOF

cat > src/modules/products/products.controller.ts << 'EOF'
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
EOF

cat > src/modules/products/products.module.ts << 'EOF'
import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ProductsController } from './products.controller';
import { ProductsService } from './products.service';
import { Product } from '../../entities/product.entity';
import { ProductImage } from '../../entities/product-image.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Product, ProductImage])],
  controllers: [ProductsController],
  providers: [ProductsService],
  exports: [ProductsService],
})
export class ProductsModule {}
EOF

echo "✅ Products Module created"

# Create Categories Module
cat > src/modules/categories/categories.service.ts << 'EOF'
import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, IsNull } from 'typeorm';
import { Category } from '../../entities/category.entity';

@Injectable()
export class CategoriesService {
  constructor(
    @InjectRepository(Category)
    private categoryRepository: Repository<Category>,
  ) {}

  async findAll(includeChildren = false) {
    const categories = await this.categoryRepository.find({
      where: { parentId: IsNull(), isActive: true },
      relations: includeChildren ? ['children'] : [],
      order: { displayOrder: 'ASC', categoryName: 'ASC' },
    });

    return { data: categories };
  }

  async findBySlug(slug: string) {
    const category = await this.categoryRepository.findOne({
      where: { slug, isActive: true },
      relations: ['children', 'parent'],
    });

    if (!category) {
      throw new NotFoundException('Danh mục không tồn tại');
    }

    return { data: category };
  }
}
EOF

cat > src/modules/categories/categories.controller.ts << 'EOF'
import { Controller, Get, Param, Query } from '@nestjs/common';
import { CategoriesService } from './categories.service';

@Controller('categories')
export class CategoriesController {
  constructor(private readonly categoriesService: CategoriesService) {}

  @Get()
  async findAll(@Query('include_children') includeChildren?: boolean) {
    return this.categoriesService.findAll(includeChildren);
  }

  @Get(':slug')
  async findBySlug(@Param('slug') slug: string) {
    return this.categoriesService.findBySlug(slug);
  }
}
EOF

cat > src/modules/categories/categories.module.ts << 'EOF'
import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { CategoriesController } from './categories.controller';
import { CategoriesService } from './categories.service';
import { Category } from '../../entities/category.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Category])],
  controllers: [CategoriesController],
  providers: [CategoriesService],
  exports: [CategoriesService],
})
export class CategoriesModule {}
EOF

echo "✅ Categories Module created"

# Create Brands Module
cat > src/modules/brands/brands.service.ts << 'EOF'
import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Brand } from '../../entities/brand.entity';

@Injectable()
export class BrandsService {
  constructor(
    @InjectRepository(Brand)
    private brandRepository: Repository<Brand>,
  ) {}

  async findAll() {
    const brands = await this.brandRepository.find({
      where: { isActive: true },
      order: { brandName: 'ASC' },
    });

    return { data: brands };
  }

  async findBySlug(slug: string) {
    const brand = await this.brandRepository.findOne({
      where: { brandName: slug, isActive: true },
    });

    if (!brand) {
      throw new NotFoundException('Thương hiệu không tồn tại');
    }

    return { data: brand };
  }
}
EOF

cat > src/modules/brands/brands.controller.ts << 'EOF'
import { Controller, Get, Param } from '@nestjs/common';
import { BrandsService } from './brands.service';

@Controller('brands')
export class BrandsController {
  constructor(private readonly brandsService: BrandsService) {}

  @Get()
  async findAll() {
    return this.brandsService.findAll();
  }

  @Get(':slug')
  async findBySlug(@Param('slug') slug: string) {
    return this.brandsService.findBySlug(slug);
  }
}
EOF

cat > src/modules/brands/brands.module.ts << 'EOF'
import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { BrandsController } from './brands.controller';
import { BrandsService } from './brands.service';
import { Brand } from '../../entities/brand.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Brand])],
  controllers: [BrandsController],
  providers: [BrandsService],
  exports: [BrandsService],
})
export class BrandsModule {}
EOF

echo "✅ Brands Module created"

echo ""
echo "🎉 All modules implementations completed!"
echo "📝 Modules created:"
echo "   ✅ Products Module (CRUD, Search, Filter)"
echo "   ✅ Categories Module"
echo "   ✅ Brands Module"

