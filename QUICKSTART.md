# 🚀 Quick Start Guide - Laptop Store Backend

## ⚡ Cách nhanh nhất để chạy dự án

### 1. Clone và cài đặt

```bash
# Clone repository (nếu chưa có)
git clone <your-repo-url>
cd ES_Backend

# Checkout branch
git checkout claude/build-laptop-backend-01Cw3vUoZRP1PAWVPcMVVhh1

# Copy environment variables
cp .env.example .env
# Hoặc dùng file .env đã có sẵn
```

### 2. Chạy với Docker (Khuyến nghị ⭐)

```bash
# Start tất cả services (MySQL + Backend)
docker-compose up -d

# Xem logs
docker-compose logs -f backend

# Dừng services
docker-compose down
```

Backend sẽ chạy tại: **http://localhost:3000/api/v1**

### 3. Test API

```bash
# Health check (khi backend đã chạy)
curl http://localhost:3000/api/v1/products

# Hoặc mở browser
http://localhost:3000/api/v1/categories
```

## 📦 Cấu trúc dự án đã hoàn thành

```
✅ NestJS Project Setup
✅ Docker & Docker Compose Configuration
✅ 19 TypeORM Entities (28 database tables)
✅ 16 Feature Modules:
   - auth (Authentication & JWT)
   - users (User Management & Addresses)
   - products (Product Management)
   - categories (Category Management)
   - brands (Brand Management)
   - cart (Shopping Cart)
   - wishlist (Wishlist)
   - orders (Order Management)
   - payments (VNPay Integration)
   - reviews (Product Reviews)
   - notifications (Notification System)
   - flash-sales (Flash Sales)
   - promotions (Promotions & Vouchers)
   - admin (Admin Dashboard & Reports)
   - upload (File Upload)
   - settings (System Settings)

✅ Common Utilities:
   - Exception filters
   - Response interceptors
   - Auth decorators & guards
   - Pagination helpers
   - Password & slug utilities
```

## 📝 Tài liệu

### Tài liệu chính
- **[README.md](./README.md)** - Tài liệu tổng quan dự án
- **[API_DOCUMENTATION.md](./API_DOCUMENTATION.md)** - 95 API endpoints chi tiết
- **[IMPLEMENTATION_GUIDE.md](./IMPLEMENTATION_GUIDE.md)** - Hướng dẫn implement từng module
- **[laptop_store_database.sql](./laptop_store_database.sql)** - Database schema

### Các file quan trọng
- **[.env](./.env)** - Environment variables (đã cấu hình sẵn)
- **[docker-compose.yml](./docker-compose.yml)** - Docker configuration
- **[package.json](./package.json)** - Dependencies

## 🔨 Development Workflow

### Chạy local (không dùng Docker)

```bash
# 1. Cài dependencies
npm install

# 2. Start MySQL riêng hoặc dùng MySQL có sẵn
# Cập nhật connection string trong .env nếu cần

# 3. Import database
mysql -u root -p laptop_store < laptop_store_database.sql

# 4. Run development mode
npm run start:dev

# 5. Build production
npm run build
npm run start:prod
```

### Implement một module mới

Ví dụ: Implement Auth Module

```bash
# 1. Tạo DTOs
mkdir src/modules/auth/dto
touch src/modules/auth/dto/register.dto.ts
touch src/modules/auth/dto/login.dto.ts

# 2. Implement service (business logic)
# Mở file: src/modules/auth/auth.service.ts

# 3. Implement controller (routes)
# Mở file: src/modules/auth/auth.controller.ts

# 4. Tham khảo IMPLEMENTATION_GUIDE.md để biết chi tiết
```

## 🎯 Các module cần implement

### ✅ Đã có cấu trúc cơ bản
Tất cả 16 modules đã có file .module.ts, .controller.ts, .service.ts

### 📝 Cần implement business logic

Theo thứ tự ưu tiên:

1. **Auth Module** ⭐ (Quan trọng nhất)
   - Register, Login, JWT
   - Xem IMPLEMENTATION_GUIDE.md section 1

2. **Users Module** ⭐
   - Profile management
   - Address management

3. **Products Module** ⭐
   - CRUD operations
   - Search & filter

4. **Cart Module**
   - Add/Update/Remove items

5. **Orders Module**
   - Create order flow
   - Order management

6. **Payments Module** (VNPay)
   - Payment URL generation
   - Callback handling

7. Các modules còn lại...

## 📊 Database

### Connection Info (Docker)
- **Host:** localhost (hoặc mysql khi trong Docker network)
- **Port:** 3306
- **User:** laptopuser
- **Password:** laptoppassword
- **Database:** laptop_store

### Import dữ liệu mẫu

File `laptop_store_database.sql` đã bao gồm:
- ✅ Schema 28 bảng
- ✅ Triggers tự động
- ✅ Views thống kê
- ✅ Dữ liệu mẫu (admin user, brands, categories, settings)

Được import tự động khi chạy Docker lần đầu.

## 🐛 Troubleshooting

### Backend không khởi động

```bash
# Check logs
docker-compose logs backend

# Restart
docker-compose restart backend
```

### MySQL connection failed

```bash
# Check MySQL status
docker-compose ps

# Check MySQL logs
docker-compose logs mysql

# Restart MySQL
docker-compose restart mysql
```

### Port 3000 đã được sử dụng

```bash
# Đổi port trong .env
PORT=3001

# Hoặc stop process đang dùng port 3000
lsof -ti:3000 | xargs kill -9
```

## 📞 Support

Nếu gặp vấn đề, kiểm tra:
1. Docker đã chạy chưa
2. File .env có đúng không
3. MySQL đã khởi động chưa
4. Port 3000 và 3306 có bị chiếm không

## 🎉 Next Steps

1. **Chạy dự án** - Dùng Docker Compose
2. **Đọc IMPLEMENTATION_GUIDE.md** - Để hiểu cách implement từng module
3. **Implement Auth Module** - Module quan trọng nhất
4. **Test APIs** - Dùng Postman hoặc curl
5. **Implement các modules khác** - Theo API_DOCUMENTATION.md

---

**Chúc bạn code vui vẻ! 🚀**

Có câu hỏi? Tham khảo [README.md](./README.md) hoặc [IMPLEMENTATION_GUIDE.md](./IMPLEMENTATION_GUIDE.md)
