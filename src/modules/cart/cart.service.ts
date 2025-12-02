import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Cart } from '../../entities/cart.entity';
import { Product } from '../../entities/product.entity';
import { AddToCartDto } from './dto/add-to-cart.dto';
import { UpdateCartDto } from './dto/update-cart.dto';

@Injectable()
export class CartService {
  constructor(
    @InjectRepository(Cart)
    private cartRepository: Repository<Cart>,
    @InjectRepository(Product)
    private productRepository: Repository<Product>,
  ) {}

  async getCart(userId: number) {
    const items = await this.cartRepository.find({
      where: { userId },
      relations: ['product', 'product.images'],
      order: { addedAt: 'DESC' },
    });

    const transformedItems = items.map((item) => ({
      cart_id: item.cartId,
      product: {
        product_id: item.product.productId,
        product_name: item.product.productName,
        slug: item.product.slug,
        sku: item.product.sku,
        selling_price: item.product.sellingPrice,
        primary_image: item.product.images?.[0]?.imageUrl,
        stock_quantity: item.product.stockQuantity,
        is_active: item.product.isActive,
      },
      quantity: item.quantity,
      subtotal: Number(item.product.sellingPrice) * item.quantity,
      added_at: item.addedAt,
    }));

    const subtotal = transformedItems.reduce((sum, item) => sum + item.subtotal, 0);
    const estimatedShipping = 30000;

    return {
      data: {
        items: transformedItems,
        summary: {
          total_items: items.length,
          subtotal,
          estimated_shipping: estimatedShipping,
          estimated_total: subtotal + estimatedShipping,
        },
      },
    };
  }

  async addToCart(userId: number, addToCartDto: AddToCartDto) {
    const { product_id, quantity } = addToCartDto;

    const product = await this.productRepository.findOne({
      where: { productId: product_id, isActive: true },
    });

    if (!product) {
      throw new NotFoundException('Sản phẩm không tồn tại');
    }

    if (product.stockQuantity < quantity) {
      throw new BadRequestException('Số lượng sản phẩm không đủ');
    }

    let cartItem = await this.cartRepository.findOne({
      where: { userId, productId: product_id },
    });

    if (cartItem) {
      cartItem.quantity += quantity;
      await this.cartRepository.save(cartItem);
    } else {
      cartItem = this.cartRepository.create({
        userId,
        productId: product_id,
        quantity,
      });
      await this.cartRepository.save(cartItem);
    }

    return {
      message: 'Đã thêm sản phẩm vào giỏ hàng',
      data: cartItem,
    };
  }

  async updateQuantity(userId: number, cartId: number, updateDto: UpdateCartDto) {
    const cartItem = await this.cartRepository.findOne({
      where: { cartId, userId },
      relations: ['product'],
    });

    if (!cartItem) {
      throw new NotFoundException('Sản phẩm không có trong giỏ hàng');
    }

    if (cartItem.product.stockQuantity < updateDto.quantity) {
      throw new BadRequestException('Số lượng sản phẩm không đủ');
    }

    cartItem.quantity = updateDto.quantity;
    await this.cartRepository.save(cartItem);

    return {
      message: 'Cập nhật giỏ hàng thành công',
      data: {
        cart_id: cartItem.cartId,
        quantity: cartItem.quantity,
        subtotal: Number(cartItem.product.sellingPrice) * updateDto.quantity,
      },
    };
  }

  async removeItem(userId: number, cartId: number) {
    const result = await this.cartRepository.delete({ cartId, userId });

    if (result.affected === 0) {
      throw new NotFoundException('Sản phẩm không có trong giỏ hàng');
    }

    return { message: 'Đã xóa sản phẩm khỏi giỏ hàng' };
  }

  async clearCart(userId: number) {
    await this.cartRepository.delete({ userId });
    return { message: 'Đã xóa toàn bộ giỏ hàng' };
  }
}
