import { Injectable, NotFoundException, ConflictException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Wishlist } from '../../entities/wishlist.entity';
import { Product } from '../../entities/product.entity';

@Injectable()
export class WishlistService {
  constructor(
    @InjectRepository(Wishlist)
    private wishlistRepository: Repository<Wishlist>,
    @InjectRepository(Product)
    private productRepository: Repository<Product>,
  ) {}

  async getWishlist(userId: number) {
    const items = await this.wishlistRepository.find({
      where: { userId },
      relations: ['product', 'product.images'],
      order: { addedAt: 'DESC' },
    });

    return {
      data: items.map((item) => ({
        wishlist_id: item.wishlistId,
        product: {
          product_id: item.product.productId,
          product_name: item.product.productName,
          slug: item.product.slug,
          selling_price: item.product.sellingPrice,
          original_price: item.product.originalPrice,
          primary_image: item.product.images?.[0]?.imageUrl,
          stock_quantity: item.product.stockQuantity,
          average_rating: item.product.averageRating,
        },
        added_at: item.addedAt,
      })),
      meta: {
        total: items.length,
      },
    };
  }

  async addToWishlist(userId: number, productId: number) {
    const product = await this.productRepository.findOne({
      where: { productId, isActive: true },
    });

    if (!product) {
      throw new NotFoundException('Sản phẩm không tồn tại');
    }

    const existing = await this.wishlistRepository.findOne({
      where: { userId, productId },
    });

    if (existing) {
      throw new ConflictException('Sản phẩm đã có trong danh sách yêu thích');
    }

    const wishlistItem = this.wishlistRepository.create({
      userId,
      productId,
    });

    await this.wishlistRepository.save(wishlistItem);

    return {
      message: 'Đã thêm vào danh sách yêu thích',
      data: wishlistItem,
    };
  }

  async removeFromWishlist(userId: number, wishlistId: number) {
    const result = await this.wishlistRepository.delete({ wishlistId, userId });

    if (result.affected === 0) {
      throw new NotFoundException('Sản phẩm không có trong danh sách yêu thích');
    }

    return { message: 'Đã xóa khỏi danh sách yêu thích' };
  }

  async checkInWishlist(userId: number, productId: number) {
    const item = await this.wishlistRepository.findOne({
      where: { userId, productId },
    });

    return {
      data: {
        is_in_wishlist: !!item,
        wishlist_id: item?.wishlistId || null,
      },
    };
  }
}
