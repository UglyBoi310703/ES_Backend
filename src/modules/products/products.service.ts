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
