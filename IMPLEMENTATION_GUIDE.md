# 🔧 Implementation Guide - Laptop Store Backend

Hướng dẫn chi tiết để implement 95 API endpoints cho hệ thống.

## 📁 Cấu trúc Module Chuẩn

Mỗi module nên có cấu trúc sau:

```
src/modules/example/
├── example.module.ts          # Module definition
├── example.controller.ts      # Controller (routes)
├── example.service.ts         # Business logic
├── dto/
│   ├── create-example.dto.ts  # DTO for creation
│   ├── update-example.dto.ts  # DTO for update
│   └── query-example.dto.ts   # DTO for queries
└── interfaces/
    └── example.interface.ts   # Type definitions (optional)
```

## 🔐 1. AUTH MODULE - Complete Implementation

### auth.module.ts
```typescript
import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { PassportModule } from '@nestjs/passport';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';
import { JwtStrategy } from './strategies/jwt.strategy';
import { LocalStrategy } from './strategies/local.strategy';
import { User } from '@entities/user.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([User]),
    PassportModule,
    JwtModule.register({
      secret: process.env.JWT_SECRET,
      signOptions: { expiresIn: process.env.JWT_EXPIRES_IN || '3600s' },
    }),
  ],
  controllers: [AuthController],
  providers: [AuthService, JwtStrategy, LocalStrategy],
  exports: [AuthService],
})
export class AuthModule {}
```

### auth.service.ts
```typescript
import { Injectable, UnauthorizedException, ConflictException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from '@entities/user.entity';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
import { hashPassword, comparePassword } from '@common/utils/password.util';

@Injectable()
export class AuthService {
  constructor(
    @InjectRepository(User)
    private userRepository: Repository<User>,
    private jwtService: JwtService,
  ) {}

  async register(registerDto: RegisterDto) {
    const { email, password, fullName, phone } = registerDto;

    // Check if email exists
    const existingUser = await this.userRepository.findOne({ where: { email } });
    if (existingUser) {
      throw new ConflictException('Email đã được sử dụng');
    }

    // Hash password
    const passwordHash = await hashPassword(password);

    // Create user
    const user = this.userRepository.create({
      email,
      passwordHash,
      fullName,
      phone,
    });

    await this.userRepository.save(user);

    // Generate tokens
    const tokens = await this.generateTokens(user);

    return {
      message: 'Đăng ký thành công. Vui lòng kiểm tra email để xác thực tài khoản.',
      data: {
        user: this.sanitizeUser(user),
        ...tokens,
      },
    };
  }

  async login(loginDto: LoginDto) {
    const { email, password } = loginDto;

    // Find user
    const user = await this.userRepository.findOne({ where: { email } });
    if (!user || !user.isActive) {
      throw new UnauthorizedException('Email hoặc mật khẩu không đúng');
    }

    // Verify password
    const isPasswordValid = await comparePassword(password, user.passwordHash);
    if (!isPasswordValid) {
      throw new UnauthorizedException('Email hoặc mật khẩu không đúng');
    }

    // Update last login
    user.lastLogin = new Date();
    await this.userRepository.save(user);

    // Generate tokens
    const tokens = await this.generateTokens(user);

    return {
      message: 'Đăng nhập thành công',
      data: {
        user: this.sanitizeUser(user),
        ...tokens,
      },
    };
  }

  async refreshToken(refreshToken: string) {
    try {
      const payload = this.jwtService.verify(refreshToken, {
        secret: process.env.JWT_REFRESH_SECRET,
      });

      const user = await this.userRepository.findOne({ where: { userId: payload.sub } });
      if (!user || !user.isActive) {
        throw new UnauthorizedException('Invalid refresh token');
      }

      const accessToken = this.jwtService.sign({
        sub: user.userId,
        email: user.email,
        role: user.role,
      });

      return {
        data: {
          access_token: accessToken,
          expires_in: parseInt(process.env.JWT_EXPIRES_IN || '3600'),
        },
      };
    } catch (error) {
      throw new UnauthorizedException('Invalid refresh token');
    }
  }

  async forgotPassword(email: string) {
    const user = await this.userRepository.findOne({ where: { email } });
    if (!user) {
      // Don't reveal if email exists
      return { message: 'Email khôi phục mật khẩu đã được gửi' };
    }

    // TODO: Generate reset token and send email
    // const resetToken = this.generateResetToken();
    // await this.emailService.sendPasswordResetEmail(user.email, resetToken);

    return { message: 'Email khôi phục mật khẩu đã được gửi' };
  }

  async resetPassword(token: string, newPassword: string) {
    // TODO: Verify reset token
    // const userId = await this.verifyResetToken(token);
    // const user = await this.userRepository.findOne({ where: { userId } });

    // Hash new password
    // const passwordHash = await hashPassword(newPassword);
    // user.passwordHash = passwordHash;
    // await this.userRepository.save(user);

    return { message: 'Mật khẩu đã được cập nhật' };
  }

  async verifyEmail(token: string) {
    // TODO: Verify email token and activate account
    return { message: 'Email đã được xác thực' };
  }

  private async generateTokens(user: User) {
    const payload = { sub: user.userId, email: user.email, role: user.role };

    const accessToken = this.jwtService.sign(payload);

    const refreshToken = this.jwtService.sign(payload, {
      secret: process.env.JWT_REFRESH_SECRET,
      expiresIn: process.env.JWT_REFRESH_EXPIRES_IN || '7d',
    });

    return {
      access_token: accessToken,
      refresh_token: refreshToken,
      expires_in: parseInt(process.env.JWT_EXPIRES_IN || '3600'),
    };
  }

  private sanitizeUser(user: User) {
    const { passwordHash, ...sanitized } = user;
    return sanitized;
  }
}
```

### auth.controller.ts
```typescript
import { Controller, Post, Body, Get, Query, UseGuards } from '@nestjs/common';
import { AuthService } from './auth.service';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
import { RefreshTokenDto } from './dto/refresh-token.dto';
import { ForgotPasswordDto } from './dto/forgot-password.dto';
import { ResetPasswordDto } from './dto/reset-password.dto';
import { JwtAuthGuard } from './guards/jwt-auth.guard';

@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('register')
  async register(@Body() registerDto: RegisterDto) {
    return this.authService.register(registerDto);
  }

  @Post('login')
  async login(@Body() loginDto: LoginDto) {
    return this.authService.login(loginDto);
  }

  @Post('refresh')
  async refresh(@Body() refreshTokenDto: RefreshTokenDto) {
    return this.authService.refreshToken(refreshTokenDto.refresh_token);
  }

  @Post('logout')
  @UseGuards(JwtAuthGuard)
  async logout() {
    // In a real app, you might want to blacklist the token
    return { message: 'Đăng xuất thành công' };
  }

  @Post('forgot-password')
  async forgotPassword(@Body() forgotPasswordDto: ForgotPasswordDto) {
    return this.authService.forgotPassword(forgotPasswordDto.email);
  }

  @Post('reset-password')
  async resetPassword(@Body() resetPasswordDto: ResetPasswordDto) {
    return this.authService.resetPassword(
      resetPasswordDto.token,
      resetPasswordDto.new_password,
    );
  }

  @Get('verify-email')
  async verifyEmail(@Query('token') token: string) {
    return this.authService.verifyEmail(token);
  }
}
```

### DTOs

**dto/register.dto.ts**
```typescript
import { IsEmail, IsString, MinLength, IsOptional, Matches } from 'class-validator';

export class RegisterDto {
  @IsEmail({}, { message: 'Email không hợp lệ' })
  email: string;

  @IsString()
  @MinLength(6, { message: 'Mật khẩu phải có ít nhất 6 ký tự' })
  password: string;

  @IsString()
  @MinLength(2, { message: 'Họ tên phải có ít nhất 2 ký tự' })
  full_name: string;

  @IsOptional()
  @IsString()
  @Matches(/^[0-9]{10,11}$/, { message: 'Số điện thoại không hợp lệ' })
  phone?: string;
}
```

**dto/login.dto.ts**
```typescript
import { IsEmail, IsString } from 'class-validator';

export class LoginDto {
  @IsEmail()
  email: string;

  @IsString()
  password: string;
}
```

### Strategies

**strategies/jwt.strategy.ts**
```typescript
import { Injectable, UnauthorizedException } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from '@entities/user.entity';

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(
    @InjectRepository(User)
    private userRepository: Repository<User>,
  ) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: process.env.JWT_SECRET,
    });
  }

  async validate(payload: any) {
    const user = await this.userRepository.findOne({
      where: { userId: payload.sub },
    });

    if (!user || !user.isActive) {
      throw new UnauthorizedException();
    }

    return user;
  }
}
```

**guards/jwt-auth.guard.ts**
```typescript
import { Injectable, ExecutionContext } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { Reflector } from '@nestjs/core';

@Injectable()
export class JwtAuthGuard extends AuthGuard('jwt') {
  constructor(private reflector: Reflector) {
    super();
  }

  canActivate(context: ExecutionContext) {
    return super.canActivate(context);
  }
}
```

## 👤 2. USERS MODULE

### users.service.ts - Sample Methods
```typescript
@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(User)
    private userRepository: Repository<User>,
    @InjectRepository(Address)
    private addressRepository: Repository<Address>,
  ) {}

  async getProfile(userId: number) {
    const user = await this.userRepository.findOne({
      where: { userId },
      select: ['userId', 'email', 'fullName', 'phone', 'avatarUrl', 'role', 'emailVerified', 'createdAt', 'lastLogin'],
    });

    return { data: user };
  }

  async updateProfile(userId: number, updateDto: UpdateProfileDto) {
    await this.userRepository.update(userId, updateDto);
    return { message: 'Cập nhật thông tin thành công' };
  }

  async changePassword(userId: number, currentPassword: string, newPassword: string) {
    const user = await this.userRepository.findOne({ where: { userId } });

    const isValid = await comparePassword(currentPassword, user.passwordHash);
    if (!isValid) {
      throw new UnauthorizedException('Mật khẩu hiện tại không đúng');
    }

    user.passwordHash = await hashPassword(newPassword);
    await this.userRepository.save(user);

    return { message: 'Đổi mật khẩu thành công' };
  }

  async getAddresses(userId: number) {
    const addresses = await this.addressRepository.find({
      where: { userId },
      order: { isDefault: 'DESC', createdAt: 'DESC' },
    });

    return { data: addresses };
  }

  async createAddress(userId: number, createDto: CreateAddressDto) {
    // If this is default address, unset others
    if (createDto.is_default) {
      await this.addressRepository.update({ userId }, { isDefault: false });
    }

    const address = this.addressRepository.create({
      userId,
      ...createDto,
    });

    await this.addressRepository.save(address);

    return {
      message: 'Thêm địa chỉ thành công',
      data: address,
    };
  }

  // ... more methods
}
```

## 💻 3. PRODUCTS MODULE

### products.service.ts - Key Methods
```typescript
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
      sort_by = 'newest',
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

    // Search
    if (search) {
      qb.andWhere(
        '(product.productName LIKE :search OR product.shortDescription LIKE :search)',
        { search: `%${search}%` },
      );
    }

    // Filters
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

    // Sorting
    switch (sort_by) {
      case 'price_asc':
        qb.orderBy('product.sellingPrice', 'ASC');
        break;
      case 'price_desc':
        qb.orderBy('product.sellingPrice', 'DESC');
        break;
      case 'bestseller':
        qb.orderBy('product.soldCount', 'DESC');
        break;
      case 'rating':
        qb.orderBy('product.averageRating', 'DESC');
        break;
      default:
        qb.orderBy('product.createdAt', 'DESC');
    }

    // Pagination
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

    // Increment view count
    await this.productRepository.increment({ productId: product.productId }, 'viewCount', 1);

    return { data: product };
  }

  async findRelated(productId: number, limit = 8) {
    const product = await this.productRepository.findOne({
      where: { productId },
      select: ['categoryId', 'brandId'],
    });

    const related = await this.productRepository.find({
      where: {
        categoryId: product.categoryId,
        isActive: true,
        productId: Not(productId),
      },
      take: limit,
      order: { soldCount: 'DESC' },
    });

    return { data: related };
  }

  private transformProduct(product: Product) {
    return {
      ...product,
      primary_image: product.images?.[0]?.imageUrl || null,
      discount_percentage: this.calculateDiscountPercentage(
        product.originalPrice,
        product.sellingPrice,
      ),
    };
  }

  private calculateDiscountPercentage(original: number, selling: number): number {
    if (original <= selling) return 0;
    return Math.round(((original - selling) / original) * 100);
  }
}
```

## 🛒 4. CART MODULE

### cart.service.ts - Implementation
```typescript
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
    const estimatedShipping = 30000; // From settings

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

  async addToCart(userId: number, productId: number, quantity: number) {
    // Check product exists and has stock
    const product = await this.productRepository.findOne({
      where: { productId, isActive: true },
    });

    if (!product) {
      throw new NotFoundException('Sản phẩm không tồn tại');
    }

    if (product.stockQuantity < quantity) {
      throw new BadRequestException('Số lượng sản phẩm không đủ');
    }

    // Check if already in cart
    let cartItem = await this.cartRepository.findOne({
      where: { userId, productId },
    });

    if (cartItem) {
      cartItem.quantity += quantity;
      await this.cartRepository.save(cartItem);
    } else {
      cartItem = this.cartRepository.create({
        userId,
        productId,
        quantity,
      });
      await this.cartRepository.save(cartItem);
    }

    return {
      message: 'Đã thêm sản phẩm vào giỏ hàng',
      data: cartItem,
    };
  }

  async updateQuantity(userId: number, cartId: number, quantity: number) {
    const cartItem = await this.cartRepository.findOne({
      where: { cartId, userId },
      relations: ['product'],
    });

    if (!cartItem) {
      throw new NotFoundException('Sản phẩm không có trong giỏ hàng');
    }

    if (cartItem.product.stockQuantity < quantity) {
      throw new BadRequestException('Số lượng sản phẩm không đủ');
    }

    cartItem.quantity = quantity;
    await this.cartRepository.save(cartItem);

    return {
      message: 'Cập nhật giỏ hàng thành công',
      data: {
        cart_id: cartItem.cartId,
        quantity: cartItem.quantity,
        subtotal: Number(cartItem.product.sellingPrice) * quantity,
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
```

## 📦 5. ORDERS MODULE

### orders.service.ts - Create Order Flow
```typescript
@Injectable()
export class OrdersService {
  constructor(
    @InjectRepository(Order)
    private orderRepository: Repository<Order>,
    @InjectRepository(OrderItem)
    private orderItemRepository: Repository<OrderItem>,
    @InjectRepository(Cart)
    private cartRepository: Repository<Cart>,
    @InjectRepository(Product)
    private productRepository: Repository<Product>,
    @InjectRepository(Promotion)
    private promotionRepository: Repository<Promotion>,
  ) {}

  async createOrder(userId: number, createOrderDto: CreateOrderDto) {
    const { items, shipping_address, payment_method, promotion_code, customer_note } =
      createOrderDto;

    // 1. Validate products and calculate totals
    let subtotal = 0;
    const orderItems = [];

    for (const item of items) {
      const product = await this.productRepository.findOne({
        where: { productId: item.product_id, isActive: true },
        relations: ['images'],
      });

      if (!product) {
        throw new NotFoundException(`Sản phẩm ID ${item.product_id} không tồn tại`);
      }

      if (product.stockQuantity < item.quantity) {
        throw new BadRequestException(
          `Sản phẩm "${product.productName}" không đủ số lượng`,
        );
      }

      const itemTotal = Number(product.sellingPrice) * item.quantity;
      subtotal += itemTotal;

      orderItems.push({
        productId: product.productId,
        productName: product.productName,
        productImage: product.images?.[0]?.imageUrl,
        sku: product.sku,
        quantity: item.quantity,
        unitPrice: product.sellingPrice,
        discountAmount: 0,
        totalPrice: itemTotal,
      });
    }

    // 2. Calculate shipping fee (from settings or based on location)
    const shippingFee = 30000;

    // 3. Apply promotion
    let discountAmount = 0;
    let promotionId = null;

    if (promotion_code) {
      const promotion = await this.validatePromotion(promotion_code, userId, subtotal);
      if (promotion) {
        promotionId = promotion.promotionId;
        discountAmount = this.calculateDiscount(promotion, subtotal);
      }
    }

    // 4. Calculate total
    const totalAmount = subtotal + shippingFee - discountAmount;

    // 5. Generate order code
    const orderCode = await this.generateOrderCode();

    // 6. Create order
    const order = this.orderRepository.create({
      userId,
      orderCode,
      recipientName: shipping_address.recipient_name,
      recipientPhone: shipping_address.phone,
      shippingProvince: shipping_address.province,
      shippingDistrict: shipping_address.district,
      shippingWard: shipping_address.ward,
      shippingAddress: shipping_address.detail_address,
      subtotal,
      shippingFee,
      discountAmount,
      totalAmount,
      promotionId,
      promotionCode: promotion_code,
      paymentMethod: payment_method,
      customerNote: customer_note,
    });

    await this.orderRepository.save(order);

    // 7. Create order items
    for (const itemData of orderItems) {
      const orderItem = this.orderItemRepository.create({
        orderId: order.orderId,
        ...itemData,
      });
      await this.orderItemRepository.save(orderItem);
    }

    // 8. Clear cart
    await this.cartRepository.delete({ userId });

    // 9. Generate payment URL if VNPay
    let paymentUrl = null;
    if (payment_method === 'VNPay') {
      // TODO: Generate VNPay payment URL
      // paymentUrl = await this.vnpayService.createPaymentUrl(order.orderId);
    }

    return {
      message: 'Đặt hàng thành công',
      data: {
        order_id: order.orderId,
        order_code: order.orderCode,
        total_amount: order.totalAmount,
        payment_method: order.paymentMethod,
        payment_url: paymentUrl,
        order_status: order.orderStatus,
        created_at: order.orderedAt,
      },
    };
  }

  private async validatePromotion(code: string, userId: number, orderValue: number) {
    const promotion = await this.promotionRepository.findOne({
      where: {
        code,
        isActive: true,
      },
    });

    if (!promotion) {
      throw new BadRequestException('Mã khuyến mãi không hợp lệ');
    }

    const now = new Date();
    if (now < promotion.startDate || now > promotion.endDate) {
      throw new BadRequestException('Mã khuyến mãi đã hết hạn');
    }

    if (promotion.minOrderValue > orderValue) {
      throw new BadRequestException(
        `Đơn hàng phải từ ${promotion.minOrderValue.toLocaleString()}đ trở lên`,
      );
    }

    if (promotion.usageLimit && promotion.usageCount >= promotion.usageLimit) {
      throw new BadRequestException('Mã khuyến mãi đã hết lượt sử dụng');
    }

    // Check user usage
    // TODO: Check promotion_usage table

    return promotion;
  }

  private calculateDiscount(promotion: Promotion, subtotal: number): number {
    if (promotion.discountType === DiscountType.FIXED_AMOUNT) {
      return Number(promotion.discountValue);
    } else {
      let discount = (subtotal * Number(promotion.discountValue)) / 100;
      if (promotion.maxDiscountAmount && discount > Number(promotion.maxDiscountAmount)) {
        discount = Number(promotion.maxDiscountAmount);
      }
      return discount;
    }
  }

  private async generateOrderCode(): Promise<string> {
    const date = new Date();
    const dateStr = date.toISOString().slice(0, 10).replace(/-/g, '');
    const count = await this.orderRepository.count({
      where: {
        orderedAt: Between(
          new Date(date.setHours(0, 0, 0, 0)),
          new Date(date.setHours(23, 59, 59, 999)),
        ),
      },
    });
    return `DH${dateStr}${(count + 1).toString().padStart(3, '0')}`;
  }
}
```

## 🎯 Module Implementation Checklist

### ✅ Completed
- [x] Auth Module
- [x] Users Module (partial)
- [x] Products Module (partial)
- [x] Cart Module
- [x] Orders Module (partial)

### 📝 To Implement

#### Categories Module
- GET /categories
- GET /categories/:slug

#### Brands Module
- GET /brands
- GET /brands/:slug

#### Wishlist Module
- GET /wishlist
- POST /wishlist/add
- DELETE /wishlist/:id
- GET /wishlist/check/:productId

#### Payments Module (VNPay)
- POST /payments/vnpay/create
- GET /payments/vnpay/callback
- GET /payments/:orderCode/status

#### Reviews Module
- GET /products/:id/reviews
- POST /reviews/create
- PUT /reviews/:id
- DELETE /reviews/:id
- POST /reviews/:id/helpful
- POST /reviews/upload-image

#### Notifications Module
- GET /notifications
- PUT /notifications/:id/read
- PUT /notifications/read-all
- DELETE /notifications/:id
- GET /notifications/unread-count

#### Flash Sales Module
- GET /flash-sales/active
- GET /flash-sales/history
- Admin CRUD endpoints

#### Promotions Module
- POST /promotions/validate
- GET /promotions/available
- Admin CRUD endpoints

#### Admin Module
- Dashboard & statistics
- Product management
- Order management
- Customer management
- Category/Brand management
- Review management
- Reports

#### Settings Module
- GET /settings
- PUT /admin/settings

#### Upload Module
- POST /upload (multipart/form-data)

## 🔧 Quick Commands

```bash
# Generate a new module
nest g module modules/example
nest g controller modules/example
nest g service modules/example

# Create DTO
mkdir -p src/modules/example/dto
touch src/modules/example/dto/create-example.dto.ts

# Run development
npm run start:dev

# Build
npm run build

# Run with Docker
docker-compose up -d
```

## 📚 Resources

- [NestJS Documentation](https://docs.nestjs.com)
- [TypeORM Documentation](https://typeorm.io)
- [Class Validator](https://github.com/typestack/class-validator)
- [VNPay API](https://sandbox.vnpayment.vn/apis/)

---

**Happy Coding! 🚀**
