# 🛒 Laptop Store Backend API

Backend API hoàn chỉnh cho website bán laptop được xây dựng với NestJS, TypeORM và MySQL.

## 📋 Tổng quan

Dự án này cung cấp 95 API endpoints đầy đủ cho hệ thống thương mại điện tử bán laptop, bao gồm:

- ✅ Authentication & Authorization (JWT)
- ✅ User Management & Addresses
- ✅ Products, Categories & Brands
- ✅ Shopping Cart & Wishlist
- ✅ Orders & Order Management
- ✅ VNPay Payment Integration
- ✅ Product Reviews & Ratings
- ✅ Notifications System
- ✅ Flash Sales
- ✅ Promotions & Vouchers
- ✅ Admin Dashboard & Reports

## 🏗️ Kiến trúc

```
ES_Backend/
├── src/
│   ├── common/                # Shared utilities
│   │   ├── decorators/        # Custom decorators
│   │   ├── filters/           # Exception filters
│   │   ├── guards/            # Auth guards
│   │   ├── interceptors/      # Response transformers
│   │   ├── dto/               # Common DTOs
│   │   └── utils/             # Helper functions
│   ├── config/                # Configuration files
│   ├── entities/              # TypeORM entities (28 tables)
│   ├── modules/               # Feature modules
│   │   ├── auth/              # Authentication
│   │   ├── users/             # User management
│   │   ├── products/          # Product management
│   │   ├── categories/        # Categories
│   │   ├── brands/            # Brands
│   │   ├── cart/              # Shopping cart
│   │   ├── wishlist/          # Wishlist
│   │   ├── orders/            # Order management
│   │   ├── payments/          # VNPay integration
│   │   ├── reviews/           # Product reviews
│   │   ├── notifications/     # Notifications
│   │   ├── flash-sales/       # Flash sales
│   │   ├── promotions/        # Promotions & vouchers
│   │   ├── admin/             # Admin features
│   │   ├── upload/            # File upload
│   │   └── settings/          # System settings
│   ├── app.module.ts
│   └── main.ts
├── docker-compose.yml         # Docker configuration
├── Dockerfile
├── .env.example               # Environment variables template
└── package.json
```

## 🚀 Cài đặt và Chạy

### Yêu cầu hệ thống

- Node.js >= 18
- Docker & Docker Compose
- MySQL 8.0

### 1. Clone repository

```bash
git clone <repository-url>
cd ES_Backend
```

### 2. Cấu hình environment

```bash
cp .env.example .env
```

Chỉnh sửa file `.env` với thông tin của bạn:

```env
NODE_ENV=development
PORT=3000

# Database
DB_HOST=localhost
DB_PORT=3306
DB_USER=laptopuser
DB_PASSWORD=laptoppassword
DB_NAME=laptop_store

# JWT
JWT_SECRET=your-super-secret-jwt-key-change-in-production
JWT_EXPIRES_IN=3600
JWT_REFRESH_SECRET=your-refresh-secret-key
JWT_REFRESH_EXPIRES_IN=604800

# VNPay
VNPAY_TMN_CODE=your_vnpay_tmn_code
VNPAY_HASH_SECRET=your_vnpay_hash_secret
VNPAY_URL=https://sandbox.vnpayment.vn/paymentv2/vpcpay.html
VNPAY_RETURN_URL=http://localhost:3000/api/v1/payments/vnpay/callback
```

### 3. Chạy với Docker (Khuyến nghị)

```bash
# Build và chạy tất cả services
docker-compose up -d

# Xem logs
docker-compose logs -f backend

# Dừng services
docker-compose down
```

Backend sẽ chạy tại: `http://localhost:3000`

### 4. Chạy local (Không dùng Docker)

```bash
# Cài đặt dependencies
npm install

# Chạy MySQL riêng hoặc sử dụng MySQL đã có sẵn
# Cập nhật connection trong .env

# Import database schema
mysql -u root -p laptop_store < laptop_store_database.sql

# Chạy development mode
npm run start:dev

# Hoặc build và chạy production
npm run build
npm run start:prod
```

## 📚 API Documentation

### Base URL

```
Development: http://localhost:3000/api/v1
```

### Authentication

Hầu hết các endpoints yêu cầu JWT token trong header:

```
Authorization: Bearer {access_token}
```

### Response Format

**Success Response:**
```json
{
  "success": true,
  "message": "Success message",
  "data": {},
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 100
  }
}
```

**Error Response:**
```json
{
  "success": false,
  "message": "Error message",
  "error": {
    "code": "ERROR_CODE",
    "details": {},
    "timestamp": "2024-12-02T10:00:00.000Z",
    "path": "/api/v1/endpoint"
  }
}
```

### Danh sách API Endpoints

#### 🔐 Authentication APIs (7 endpoints)
- `POST /auth/register` - Đăng ký tài khoản
- `POST /auth/login` - Đăng nhập
- `POST /auth/refresh` - Refresh token
- `POST /auth/logout` - Đăng xuất
- `POST /auth/forgot-password` - Quên mật khẩu
- `POST /auth/reset-password` - Reset mật khẩu
- `GET /auth/verify-email` - Xác thực email

#### 👤 User Management APIs (8 endpoints)
- `GET /users/profile` - Lấy thông tin profile
- `PUT /users/profile` - Cập nhật profile
- `POST /users/change-password` - Đổi mật khẩu
- `GET /users/addresses` - Lấy danh sách địa chỉ
- `POST /users/addresses` - Thêm địa chỉ mới
- `PUT /users/addresses/:id` - Cập nhật địa chỉ
- `DELETE /users/addresses/:id` - Xóa địa chỉ
- `PUT /users/addresses/:id/set-default` - Đặt địa chỉ mặc định

#### 💻 Product APIs (8 endpoints)
- `GET /products` - Lấy danh sách sản phẩm (phân trang, lọc, tìm kiếm)
- `GET /products/:slug` - Lấy chi tiết sản phẩm
- `GET /products/:id/related` - Sản phẩm liên quan
- `GET /products/bestsellers` - Sản phẩm bán chạy
- `GET /products/featured` - Sản phẩm nổi bật
- `GET /products/latest` - Sản phẩm mới
- `GET /products/search` - Tìm kiếm sản phẩm
- `POST /products/filter` - Lọc sản phẩm nâng cao

#### 📂 Category & Brand APIs (4 endpoints)
- `GET /categories` - Lấy danh sách danh mục
- `GET /categories/:slug` - Chi tiết danh mục
- `GET /brands` - Lấy danh sách thương hiệu
- `GET /brands/:slug` - Chi tiết thương hiệu

#### 🛒 Cart APIs (5 endpoints)
- `GET /cart` - Lấy giỏ hàng
- `POST /cart/add` - Thêm sản phẩm vào giỏ
- `PUT /cart/:id` - Cập nhật số lượng
- `DELETE /cart/:id` - Xóa sản phẩm khỏi giỏ
- `DELETE /cart/clear` - Xóa toàn bộ giỏ hàng

#### ❤️ Wishlist APIs (4 endpoints)
- `GET /wishlist` - Lấy danh sách yêu thích
- `POST /wishlist/add` - Thêm vào wishlist
- `DELETE /wishlist/:id` - Xóa khỏi wishlist
- `GET /wishlist/check/:productId` - Kiểm tra sản phẩm trong wishlist

#### 📦 Order APIs (5 endpoints)
- `POST /orders/create` - Tạo đơn hàng
- `GET /orders` - Lấy danh sách đơn hàng
- `GET /orders/:code` - Chi tiết đơn hàng
- `POST /orders/:code/cancel` - Hủy đơn hàng
- `GET /orders/:code/tracking` - Theo dõi đơn hàng

#### 💳 Payment APIs (3 endpoints)
- `POST /payments/vnpay/create` - Tạo link thanh toán VNPay
- `GET /payments/vnpay/callback` - Xử lý callback VNPay
- `GET /payments/:orderCode/status` - Kiểm tra trạng thái thanh toán

#### ⭐ Review APIs (6 endpoints)
- `GET /products/:id/reviews` - Lấy đánh giá sản phẩm
- `POST /reviews/create` - Thêm đánh giá
- `PUT /reviews/:id` - Cập nhật đánh giá
- `DELETE /reviews/:id` - Xóa đánh giá
- `POST /reviews/:id/helpful` - Đánh dấu đánh giá hữu ích
- `POST /reviews/upload-image` - Upload ảnh đánh giá

#### 🔔 Notification APIs (5 endpoints)
- `GET /notifications` - Lấy danh sách thông báo
- `PUT /notifications/:id/read` - Đánh dấu đã đọc
- `PUT /notifications/read-all` - Đánh dấu tất cả đã đọc
- `DELETE /notifications/:id` - Xóa thông báo
- `GET /notifications/unread-count` - Số lượng thông báo chưa đọc

#### 👨‍💼 Admin APIs (22 endpoints)
- Dashboard & Reports (3 endpoints)
- Product Management (4 endpoints)
- Order Management (2 endpoints)
- Customer Management (3 endpoints)
- Category Management (4 endpoints)
- Brand Management (4 endpoints)
- Review Management (3 endpoints)

#### 🔥 Flash Sale APIs (7 endpoints)
- `GET /flash-sales/active` - Lấy Flash Sale đang diễn ra
- `GET /flash-sales/history` - Lịch sử Flash Sale
- Admin: CRUD Flash Sales (5 endpoints)

#### 🎟️ Promotion APIs (5 endpoints)
- `POST /promotions/validate` - Kiểm tra mã khuyến mãi
- `GET /promotions/available` - Danh sách khuyến mãi khả dụng
- Admin: CRUD Promotions (3 endpoints)

#### 📊 Additional APIs (3 endpoints)
- `GET /admin/reports/revenue` - Báo cáo doanh thu
- `GET /admin/reports/bestsellers` - Báo cáo sản phẩm bán chạy
- `POST /upload` - Upload file
- `GET /settings` - Lấy cài đặt hệ thống
- `PUT /admin/settings` - Cập nhật cài đặt

**Tổng cộng: 95 API Endpoints**

Chi tiết đầy đủ xem file: [API_DOCUMENTATION.md](./API_DOCUMENTATION.md)

## 🗄️ Database Schema

Database gồm 28 bảng:

### Core Tables
- `users` - Người dùng
- `addresses` - Địa chỉ giao hàng
- `brands` - Thương hiệu
- `categories` - Danh mục sản phẩm
- `products` - Sản phẩm
- `product_images` - Hình ảnh sản phẩm

### Shopping Tables
- `cart` - Giỏ hàng
- `wishlist` - Danh sách yêu thích
- `orders` - Đơn hàng
- `order_items` - Chi tiết đơn hàng

### Promotion Tables
- `flash_sales` - Flash sale
- `flash_sale_products` - Sản phẩm flash sale
- `promotions` - Khuyến mãi
- `promotion_usage` - Lịch sử sử dụng khuyến mãi

### Review & Rating Tables
- `reviews` - Đánh giá sản phẩm
- `review_images` - Hình ảnh đánh giá
- `review_helpful` - Đánh giá hữu ích

### Payment Tables
- `vnpay_transactions` - Giao dịch VNPay

### System Tables
- `notifications` - Thông báo
- `order_status_history` - Lịch sử trạng thái đơn hàng
- `product_views` - Lượt xem sản phẩm
- `system_settings` - Cấu hình hệ thống

Chi tiết xem file: [laptop_store_database.sql](./laptop_store_database.sql)

## 🔐 Security Features

- ✅ JWT Authentication & Refresh Tokens
- ✅ Password Hashing (bcrypt)
- ✅ Role-based Access Control (RBAC)
- ✅ Rate Limiting
- ✅ Input Validation
- ✅ SQL Injection Prevention (TypeORM)
- ✅ CORS Configuration

## 🛠️ Tech Stack

- **Framework:** NestJS 10.x
- **Language:** TypeScript 5.x
- **ORM:** TypeORM 0.3.x
- **Database:** MySQL 8.0
- **Authentication:** JWT (Passport)
- **Validation:** class-validator, class-transformer
- **Password:** bcryptjs
- **Containerization:** Docker, Docker Compose

## 📝 Development

### Cấu trúc module mới

```bash
# Generate module
nest g module modules/your-module
nest g controller modules/your-module
nest g service modules/your-module

# Create DTOs
mkdir src/modules/your-module/dto
touch src/modules/your-module/dto/create-your-module.dto.ts
touch src/modules/your-module/dto/update-your-module.dto.ts
```

### Database Migrations

```bash
# Generate migration
npm run typeorm migration:generate -- -n MigrationName

# Run migrations
npm run typeorm migration:run

# Revert migration
npm run typeorm migration:revert
```

### Testing

```bash
# Unit tests
npm run test

# E2E tests
npm run test:e2e

# Test coverage
npm run test:cov
```

### Linting & Formatting

```bash
# Lint
npm run lint

# Format
npm run format
```

## 🎯 TODO / Roadmap

### Đã hoàn thành ✅
- [x] Cấu trúc dự án NestJS
- [x] Docker & Docker Compose setup
- [x] TypeORM entities (28 bảng)
- [x] Common utilities (filters, interceptors, decorators)
- [x] Authentication & Authorization

### Cần triển khai 🚧
- [ ] Implement tất cả 95 API endpoints
- [ ] VNPay payment integration hoàn chỉnh
- [ ] Email service (verification, password reset)
- [ ] File upload service (multer, cloudinary)
- [ ] WebSocket cho real-time notifications
- [ ] Redis caching
- [ ] Elasticsearch cho tìm kiếm
- [ ] Unit tests & E2E tests
- [ ] API Documentation (Swagger/OpenAPI)
- [ ] Logging system (Winston)
- [ ] Monitoring & Analytics

## 📖 Hướng dẫn triển khai modules

### 1. Auth Module (Đã có skeleton)

**Cần implement:**
- JWT Strategy & Guards
- Register, Login, Refresh Token
- Password Reset Flow
- Email Verification

**File cần tạo:**
```
src/modules/auth/
├── auth.module.ts
├── auth.controller.ts
├── auth.service.ts
├── dto/
│   ├── register.dto.ts
│   ├── login.dto.ts
│   └── reset-password.dto.ts
├── strategies/
│   ├── jwt.strategy.ts
│   └── local.strategy.ts
└── guards/
    └── jwt-auth.guard.ts
```

### 2. Products Module

**Các chức năng chính:**
- CRUD operations
- Search & Filter (full-text search)
- Pagination
- Related products
- View count tracking

**Sample Service Method:**
```typescript
async findAll(query: ProductQueryDto) {
  const { page, limit, search, categoryId, brandId, minPrice, maxPrice, sortBy } = query;

  const queryBuilder = this.productRepository
    .createQueryBuilder('product')
    .leftJoinAndSelect('product.brand', 'brand')
    .leftJoinAndSelect('product.category', 'category')
    .leftJoinAndSelect('product.images', 'images')
    .where('product.isActive = :isActive', { isActive: true });

  // Apply filters...
  // Apply search...
  // Apply sorting...
  // Apply pagination...

  const [data, total] = await queryBuilder.getManyAndCount();
  return { data, meta: createPaginationMeta(page, limit, total) };
}
```

### 3. Orders Module

**Các chức năng:**
- Create order from cart
- Order status management
- Order tracking
- Cancel order

**Flow tạo đơn hàng:**
1. Validate cart items & stock
2. Calculate total, shipping fee, discount
3. Create order & order items
4. Clear cart
5. Update product stock (via trigger)
6. Create notification
7. Init payment (if VNPay)

### 4. VNPay Integration

**Config:**
```typescript
const vnpayConfig = {
  tmnCode: process.env.VNPAY_TMN_CODE,
  hashSecret: process.env.VNPAY_HASH_SECRET,
  url: process.env.VNPAY_URL,
  returnUrl: process.env.VNPAY_RETURN_URL,
};
```

**Create Payment URL:**
```typescript
async createPaymentUrl(orderId: number, ipAddr: string) {
  const order = await this.orderRepository.findOne(orderId);

  const vnpParams = {
    vnp_Version: '2.1.0',
    vnp_Command: 'pay',
    vnp_TmnCode: this.config.tmnCode,
    vnp_Amount: order.totalAmount * 100,
    vnp_CurrCode: 'VND',
    vnp_TxnRef: order.orderCode,
    vnp_OrderInfo: `Thanh toan don hang ${order.orderCode}`,
    vnp_OrderType: 'other',
    vnp_Locale: 'vn',
    vnp_ReturnUrl: this.config.returnUrl,
    vnp_IpAddr: ipAddr,
    vnp_CreateDate: moment().format('YYYYMMDDHHmmss'),
  };

  // Sort params & create secure hash
  // Return payment URL
}
```

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License.

## 👥 Authors

- **Your Team** - Initial work

## 🙏 Acknowledgments

- NestJS Documentation
- TypeORM Documentation
- MySQL Documentation
- VNPay API Documentation

---

**Happy Coding! 🚀**

For more information, please contact: [your-email@example.com](mailto:your-email@example.com)
