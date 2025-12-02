#!/bin/bash

echo "🚀 Implementing Cart, Wishlist, Orders modules..."

# Cart Module
mkdir -p src/modules/cart/dto

cat > src/modules/cart/dto/add-to-cart.dto.ts << 'EOF'
import { IsInt, Min } from 'class-validator';

export class AddToCartDto {
  @IsInt()
  product_id: number;

  @IsInt()
  @Min(1)
  quantity: number;
}
EOF

cat > src/modules/cart/dto/update-cart.dto.ts << 'EOF'
import { IsInt, Min } from 'class-validator';

export class UpdateCartDto {
  @IsInt()
  @Min(1)
  quantity: number;
}
EOF

cat > src/modules/cart/cart.service.ts << 'EOF'
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
EOF

cat > src/modules/cart/cart.controller.ts << 'EOF'
import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Body,
  Param,
  UseGuards,
  ParseIntPipe,
} from '@nestjs/common';
import { CartService } from './cart.service';
import { AddToCartDto } from './dto/add-to-cart.dto';
import { UpdateCartDto } from './dto/update-cart.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { User } from '../../entities/user.entity';

@Controller('cart')
@UseGuards(JwtAuthGuard)
export class CartController {
  constructor(private readonly cartService: CartService) {}

  @Get()
  async getCart(@CurrentUser() user: User) {
    return this.cartService.getCart(user.userId);
  }

  @Post('add')
  async addToCart(@CurrentUser() user: User, @Body() addToCartDto: AddToCartDto) {
    return this.cartService.addToCart(user.userId, addToCartDto);
  }

  @Put(':id')
  async updateQuantity(
    @CurrentUser() user: User,
    @Param('id', ParseIntPipe) id: number,
    @Body() updateDto: UpdateCartDto,
  ) {
    return this.cartService.updateQuantity(user.userId, id, updateDto);
  }

  @Delete(':id')
  async removeItem(@CurrentUser() user: User, @Param('id', ParseIntPipe) id: number) {
    return this.cartService.removeItem(user.userId, id);
  }

  @Delete('clear')
  async clearCart(@CurrentUser() user: User) {
    return this.cartService.clearCart(user.userId);
  }
}
EOF

cat > src/modules/cart/cart.module.ts << 'EOF'
import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { CartController } from './cart.controller';
import { CartService } from './cart.service';
import { Cart } from '../../entities/cart.entity';
import { Product } from '../../entities/product.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Cart, Product])],
  controllers: [CartController],
  providers: [CartService],
  exports: [CartService],
})
export class CartModule {}
EOF

echo "✅ Cart Module created"

# Wishlist Module
cat > src/modules/wishlist/dto/add-to-wishlist.dto.ts << 'EOF'
import { IsInt } from 'class-validator';

export class AddToWishlistDto {
  @IsInt()
  product_id: number;
}
EOF

cat > src/modules/wishlist/wishlist.service.ts << 'EOF'
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
EOF

cat > src/modules/wishlist/wishlist.controller.ts << 'EOF'
import {
  Controller,
  Get,
  Post,
  Delete,
  Body,
  Param,
  UseGuards,
  ParseIntPipe,
} from '@nestjs/common';
import { WishlistService } from './wishlist.service';
import { AddToWishlistDto } from './dto/add-to-wishlist.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { User } from '../../entities/user.entity';

@Controller('wishlist')
@UseGuards(JwtAuthGuard)
export class WishlistController {
  constructor(private readonly wishlistService: WishlistService) {}

  @Get()
  async getWishlist(@CurrentUser() user: User) {
    return this.wishlistService.getWishlist(user.userId);
  }

  @Post('add')
  async addToWishlist(@CurrentUser() user: User, @Body() dto: AddToWishlistDto) {
    return this.wishlistService.addToWishlist(user.userId, dto.product_id);
  }

  @Delete(':id')
  async removeFromWishlist(@CurrentUser() user: User, @Param('id', ParseIntPipe) id: number) {
    return this.wishlistService.removeFromWishlist(user.userId, id);
  }

  @Get('check/:productId')
  async checkInWishlist(
    @CurrentUser() user: User,
    @Param('productId', ParseIntPipe) productId: number,
  ) {
    return this.wishlistService.checkInWishlist(user.userId, productId);
  }
}
EOF

cat > src/modules/wishlist/wishlist.module.ts << 'EOF'
import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { WishlistController } from './wishlist.controller';
import { WishlistService } from './wishlist.service';
import { Wishlist } from '../../entities/wishlist.entity';
import { Product } from '../../entities/product.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Wishlist, Product])],
  controllers: [WishlistController],
  providers: [WishlistService],
  exports: [WishlistService],
})
export class WishlistModule {}
EOF

echo "✅ Wishlist Module created"

echo ""
echo "🎉 Cart and Wishlist modules completed!"

