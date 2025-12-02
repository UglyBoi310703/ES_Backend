# API DOCUMENTATION - WEBSITE BÁN LAPTOP

## 📋 MỤC LỤC

1. [Tổng quan](#tổng-quan)
2. [Authentication APIs](#authentication-apis)
3. [User Management APIs](#user-management-apis)
4. [Product APIs](#product-apis)
5. [Category & Brand APIs](#category--brand-apis)
6. [Cart APIs](#cart-apis)
7. [Wishlist APIs](#wishlist-apis)
8. [Order APIs](#order-apis)
9. [Payment APIs](#payment-apis)
10. [Review APIs](#review-apis)
11. [Notification APIs](#notification-apis)
12. [Admin APIs](#admin-apis)
13. [Flash Sale APIs](#flash-sale-apis)
14. [Promotion APIs](#promotion-apis)

---

## 🌐 TỔNG QUAN

### Base URL
```
Production: https://api.laptopstore.com/v1
Development: http://localhost:3000/api/v1
```

### Authentication
Sử dụng JWT (JSON Web Token) trong header:
```
Authorization: Bearer {access_token}
```

### Response Format
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

### Error Response
```json
{
  "success": false,
  "message": "Error message",
  "error": {
    "code": "ERROR_CODE",
    "details": {}
  }
}
```

### HTTP Status Codes
- `200` - OK
- `201` - Created
- `400` - Bad Request
- `401` - Unauthorized
- `403` - Forbidden
- `404` - Not Found
- `422` - Unprocessable Entity
- `500` - Internal Server Error

---

## 🔐 AUTHENTICATION APIs

### 1. Đăng ký tài khoản
**POST** `/auth/register`

**Request Body:**
```json
{
  "email": "customer@example.com",
  "password": "password123",
  "full_name": "Nguyễn Văn A",
  "phone": "0901234567"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Đăng ký thành công. Vui lòng kiểm tra email để xác thực tài khoản.",
  "data": {
    "user": {
      "user_id": 1,
      "email": "customer@example.com",
      "full_name": "Nguyễn Văn A",
      "phone": "0901234567",
      "role": "customer",
      "email_verified": false
    },
    "access_token": "eyJhbGciOiJIUzI1NiIs...",
    "refresh_token": "eyJhbGciOiJIUzI1NiIs...",
    "expires_in": 3600
  }
}
```

---

### 2. Đăng nhập
**POST** `/auth/login`

**Request Body:**
```json
{
  "email": "customer@example.com",
  "password": "password123"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Đăng nhập thành công",
  "data": {
    "user": {
      "user_id": 1,
      "email": "customer@example.com",
      "full_name": "Nguyễn Văn A",
      "role": "customer",
      "avatar_url": null
    },
    "access_token": "eyJhbGciOiJIUzI1NiIs...",
    "refresh_token": "eyJhbGciOiJIUzI1NiIs...",
    "expires_in": 3600
  }
}
```

---

### 3. Refresh Token
**POST** `/auth/refresh`

**Request Body:**
```json
{
  "refresh_token": "eyJhbGciOiJIUzI1NiIs..."
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "access_token": "eyJhbGciOiJIUzI1NiIs...",
    "expires_in": 3600
  }
}
```

---

### 4. Đăng xuất
**POST** `/auth/logout`

**Headers:** `Authorization: Bearer {token}`

**Response:**
```json
{
  "success": true,
  "message": "Đăng xuất thành công"
}
```

---

### 5. Quên mật khẩu
**POST** `/auth/forgot-password`

**Request Body:**
```json
{
  "email": "customer@example.com"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Email khôi phục mật khẩu đã được gửi"
}
```

---

### 6. Reset mật khẩu
**POST** `/auth/reset-password`

**Request Body:**
```json
{
  "token": "reset_token_from_email",
  "new_password": "newpassword123"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Mật khẩu đã được cập nhật"
}
```

---

### 7. Xác thực email
**GET** `/auth/verify-email?token={verification_token}`

**Response:**
```json
{
  "success": true,
  "message": "Email đã được xác thực"
}
```

---

## 👤 USER MANAGEMENT APIs

### 8. Lấy thông tin profile
**GET** `/users/profile`

**Headers:** `Authorization: Bearer {token}`

**Response:**
```json
{
  "success": true,
  "data": {
    "user_id": 1,
    "email": "customer@example.com",
    "full_name": "Nguyễn Văn A",
    "phone": "0901234567",
    "avatar_url": "https://cdn.example.com/avatars/1.jpg",
    "role": "customer",
    "email_verified": true,
    "created_at": "2024-01-15T10:30:00Z",
    "last_login": "2024-12-02T14:20:00Z"
  }
}
```

---

### 9. Cập nhật profile
**PUT** `/users/profile`

**Headers:** `Authorization: Bearer {token}`

**Request Body:**
```json
{
  "full_name": "Nguyễn Văn B",
  "phone": "0987654321",
  "avatar_url": "https://cdn.example.com/avatars/new.jpg"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Cập nhật thông tin thành công",
  "data": {
    "user_id": 1,
    "email": "customer@example.com",
    "full_name": "Nguyễn Văn B",
    "phone": "0987654321",
    "avatar_url": "https://cdn.example.com/avatars/new.jpg"
  }
}
```

---

### 10. Đổi mật khẩu
**POST** `/users/change-password`

**Headers:** `Authorization: Bearer {token}`

**Request Body:**
```json
{
  "current_password": "oldpassword123",
  "new_password": "newpassword456"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Đổi mật khẩu thành công"
}
```

---

### 11. Lấy danh sách địa chỉ
**GET** `/users/addresses`

**Headers:** `Authorization: Bearer {token}`

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "address_id": 1,
      "recipient_name": "Nguyễn Văn A",
      "phone": "0901234567",
      "province": "Hà Nội",
      "district": "Cầu Giấy",
      "ward": "Dịch Vọng",
      "detail_address": "Số 1 Nguyễn Trãi",
      "is_default": true,
      "created_at": "2024-01-15T10:30:00Z"
    }
  ]
}
```

---

### 12. Thêm địa chỉ mới
**POST** `/users/addresses`

**Headers:** `Authorization: Bearer {token}`

**Request Body:**
```json
{
  "recipient_name": "Nguyễn Văn A",
  "phone": "0901234567",
  "province": "Hà Nội",
  "district": "Cầu Giấy",
  "ward": "Dịch Vọng",
  "detail_address": "Số 1 Nguyễn Trãi",
  "is_default": true
}
```

**Response:**
```json
{
  "success": true,
  "message": "Thêm địa chỉ thành công",
  "data": {
    "address_id": 2,
    "recipient_name": "Nguyễn Văn A",
    "phone": "0901234567",
    "province": "Hà Nội",
    "district": "Cầu Giấy",
    "ward": "Dịch Vọng",
    "detail_address": "Số 1 Nguyễn Trãi",
    "is_default": true
  }
}
```

---

### 13. Cập nhật địa chỉ
**PUT** `/users/addresses/{address_id}`

**Headers:** `Authorization: Bearer {token}`

**Request Body:**
```json
{
  "recipient_name": "Nguyễn Văn B",
  "phone": "0987654321",
  "is_default": false
}
```

**Response:**
```json
{
  "success": true,
  "message": "Cập nhật địa chỉ thành công"
}
```

---

### 14. Xóa địa chỉ
**DELETE** `/users/addresses/{address_id}`

**Headers:** `Authorization: Bearer {token}`

**Response:**
```json
{
  "success": true,
  "message": "Xóa địa chỉ thành công"
}
```

---

### 15. Đặt địa chỉ mặc định
**PUT** `/users/addresses/{address_id}/set-default`

**Headers:** `Authorization: Bearer {token}`

**Response:**
```json
{
  "success": true,
  "message": "Đã đặt làm địa chỉ mặc định"
}
```

---

## 💻 PRODUCT APIs

### 16. Lấy danh sách sản phẩm (có phân trang, lọc, tìm kiếm)
**GET** `/products`

**Query Parameters:**
```
?page=1
&limit=20
&category_id=1
&brand_id=2
&min_price=10000000
&max_price=30000000
&search=dell xps
&sort_by=price_asc|price_desc|newest|bestseller|rating
&is_featured=true
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "product_id": 1,
      "product_name": "Dell XPS 15 9530",
      "slug": "dell-xps-15-9530",
      "sku": "DELL-XPS15-001",
      "brand": {
        "brand_id": 1,
        "brand_name": "Dell",
        "logo_url": "https://cdn.example.com/brands/dell.png"
      },
      "category": {
        "category_id": 4,
        "category_name": "Laptop Mỏng Nhẹ"
      },
      "original_price": 35000000,
      "selling_price": 32000000,
      "discount_percentage": 9,
      "stock_quantity": 50,
      "primary_image": "https://cdn.example.com/products/dell-xps-1.jpg",
      "images": [
        "https://cdn.example.com/products/dell-xps-1.jpg",
        "https://cdn.example.com/products/dell-xps-2.jpg"
      ],
      "average_rating": 4.5,
      "review_count": 128,
      "sold_count": 245,
      "short_description": "Laptop cao cấp với màn hình 4K",
      "specifications": {
        "cpu": "Intel Core i7-13700H",
        "ram": "16GB DDR5",
        "storage": "512GB SSD",
        "screen_size": "15.6 inch",
        "graphics_card": "NVIDIA RTX 4050"
      },
      "is_featured": true,
      "is_in_flash_sale": false,
      "flash_sale_price": null,
      "created_at": "2024-01-15T10:30:00Z"
    }
  ],
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 150,
    "total_pages": 8
  }
}
```

---

### 17. Lấy chi tiết sản phẩm
**GET** `/products/{slug}`

**Response:**
```json
{
  "success": true,
  "data": {
    "product_id": 1,
    "product_name": "Dell XPS 15 9530",
    "slug": "dell-xps-15-9530",
    "sku": "DELL-XPS15-001",
    "brand": {
      "brand_id": 1,
      "brand_name": "Dell",
      "logo_url": "https://cdn.example.com/brands/dell.png",
      "description": "Thương hiệu laptop Dell"
    },
    "category": {
      "category_id": 4,
      "category_name": "Laptop Mỏng Nhẹ",
      "slug": "laptop-mong-nhe"
    },
    "original_price": 35000000,
    "selling_price": 32000000,
    "discount_percentage": 9,
    "stock_quantity": 50,
    "images": [
      {
        "image_id": 1,
        "image_url": "https://cdn.example.com/products/dell-xps-1.jpg",
        "is_primary": true
      },
      {
        "image_id": 2,
        "image_url": "https://cdn.example.com/products/dell-xps-2.jpg",
        "is_primary": false
      }
    ],
    "specifications": {
      "cpu": "Intel Core i7-13700H",
      "ram": "16GB DDR5",
      "storage": "512GB SSD",
      "screen_size": "15.6 inch",
      "screen_resolution": "3840x2400",
      "graphics_card": "NVIDIA RTX 4050",
      "operating_system": "Windows 11 Pro",
      "weight": "1.86 kg",
      "battery": "86Wh",
      "color": "Bạc"
    },
    "short_description": "Laptop cao cấp với màn hình 4K",
    "full_description": "<p>Mô tả chi tiết sản phẩm...</p>",
    "average_rating": 4.5,
    "review_count": 128,
    "sold_count": 245,
    "view_count": 1523,
    "is_featured": true,
    "is_active": true,
    "flash_sale": null,
    "created_at": "2024-01-15T10:30:00Z",
    "updated_at": "2024-12-01T15:20:00Z"
  }
}
```

---

### 18. Sản phẩm liên quan
**GET** `/products/{product_id}/related`

**Query Parameters:**
```
?limit=8
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "product_id": 2,
      "product_name": "Dell XPS 13 9320",
      "slug": "dell-xps-13-9320",
      "selling_price": 28000000,
      "primary_image": "https://cdn.example.com/products/dell-xps-13.jpg",
      "average_rating": 4.6,
      "review_count": 89
    }
  ]
}
```

---

### 19. Sản phẩm bán chạy
**GET** `/products/bestsellers`

**Query Parameters:**
```
?limit=10
&category_id=1
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "product_id": 5,
      "product_name": "MSI GF63 Thin",
      "slug": "msi-gf63-thin",
      "selling_price": 18000000,
      "primary_image": "https://cdn.example.com/products/msi-gf63.jpg",
      "sold_count": 523,
      "average_rating": 4.3
    }
  ]
}
```

---

### 20. Sản phẩm nổi bật
**GET** `/products/featured`

**Query Parameters:**
```
?limit=8
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "product_id": 1,
      "product_name": "Dell XPS 15 9530",
      "slug": "dell-xps-15-9530",
      "selling_price": 32000000,
      "original_price": 35000000,
      "primary_image": "https://cdn.example.com/products/dell-xps-1.jpg",
      "average_rating": 4.5,
      "review_count": 128
    }
  ]
}
```

---

### 21. Sản phẩm mới
**GET** `/products/latest`

**Query Parameters:**
```
?limit=12
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "product_id": 15,
      "product_name": "ASUS ROG Strix G16",
      "slug": "asus-rog-strix-g16",
      "selling_price": 42000000,
      "primary_image": "https://cdn.example.com/products/asus-rog.jpg",
      "is_new": true,
      "created_at": "2024-11-28T10:00:00Z"
    }
  ]
}
```

---

### 22. Tìm kiếm sản phẩm
**GET** `/products/search`

**Query Parameters:**
```
?q=laptop gaming rtx 4060
&page=1
&limit=20
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "product_id": 8,
      "product_name": "MSI Katana 15 B13V",
      "slug": "msi-katana-15-b13v",
      "selling_price": 25000000,
      "primary_image": "https://cdn.example.com/products/msi-katana.jpg",
      "specifications": {
        "cpu": "Intel Core i7-13620H",
        "graphics_card": "NVIDIA RTX 4060"
      },
      "match_score": 0.95
    }
  ],
  "meta": {
    "query": "laptop gaming rtx 4060",
    "total": 15,
    "page": 1,
    "limit": 20
  }
}
```

---

### 23. Lọc sản phẩm nâng cao
**POST** `/products/filter`

**Request Body:**
```json
{
  "category_ids": [1, 2],
  "brand_ids": [1, 4, 6],
  "price_range": {
    "min": 15000000,
    "max": 30000000
  },
  "specifications": {
    "cpu": ["Intel Core i7", "Intel Core i9"],
    "ram": ["16GB", "32GB"],
    "graphics_card": ["RTX 4060", "RTX 4070"]
  },
  "rating_min": 4.0,
  "in_stock": true,
  "sort_by": "price_asc",
  "page": 1,
  "limit": 20
}
```

**Response:**
```json
{
  "success": true,
  "data": [...],
  "meta": {
    "total": 45,
    "page": 1,
    "limit": 20,
    "filters_applied": {
      "category": 2,
      "brand": 3,
      "price": true,
      "specs": 3
    }
  }
}
```

---

## 📂 CATEGORY & BRAND APIs

### 24. Lấy danh sách danh mục
**GET** `/categories`

**Query Parameters:**
```
?include_children=true
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "category_id": 1,
      "category_name": "Laptop Gaming",
      "slug": "laptop-gaming",
      "icon_url": "https://cdn.example.com/icons/gaming.png",
      "product_count": 85,
      "children": [
        {
          "category_id": 11,
          "category_name": "Laptop Gaming RTX 4060",
          "slug": "laptop-gaming-rtx-4060",
          "product_count": 25
        }
      ]
    }
  ]
}
```

---

### 25. Lấy chi tiết danh mục
**GET** `/categories/{slug}`

**Response:**
```json
{
  "success": true,
  "data": {
    "category_id": 1,
    "category_name": "Laptop Gaming",
    "slug": "laptop-gaming",
    "description": "Laptop chuyên game với cấu hình mạnh",
    "icon_url": "https://cdn.example.com/icons/gaming.png",
    "parent_category": null,
    "children": [...],
    "product_count": 85,
    "top_brands": [
      {
        "brand_id": 6,
        "brand_name": "MSI",
        "product_count": 32
      }
    ]
  }
}
```

---

### 26. Lấy danh sách thương hiệu
**GET** `/brands`

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "brand_id": 1,
      "brand_name": "Dell",
      "slug": "dell",
      "logo_url": "https://cdn.example.com/brands/dell.png",
      "product_count": 42,
      "is_active": true
    }
  ]
}
```

---

### 27. Lấy chi tiết thương hiệu
**GET** `/brands/{slug}`

**Response:**
```json
{
  "success": true,
  "data": {
    "brand_id": 1,
    "brand_name": "Dell",
    "slug": "dell",
    "logo_url": "https://cdn.example.com/brands/dell.png",
    "description": "Thương hiệu laptop Dell",
    "product_count": 42,
    "categories": [
      {
        "category_id": 4,
        "category_name": "Laptop Mỏng Nhẹ",
        "product_count": 15
      }
    ]
  }
}
```

---

## 🛒 CART APIs

### 28. Lấy giỏ hàng
**GET** `/cart`

**Headers:** `Authorization: Bearer {token}`

**Response:**
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "cart_id": 1,
        "product": {
          "product_id": 1,
          "product_name": "Dell XPS 15 9530",
          "slug": "dell-xps-15-9530",
          "sku": "DELL-XPS15-001",
          "selling_price": 32000000,
          "primary_image": "https://cdn.example.com/products/dell-xps-1.jpg",
          "stock_quantity": 50,
          "is_active": true
        },
        "quantity": 1,
        "subtotal": 32000000,
        "added_at": "2024-12-01T10:30:00Z"
      }
    ],
    "summary": {
      "total_items": 2,
      "subtotal": 57000000,
      "estimated_shipping": 30000,
      "estimated_total": 57030000
    }
  }
}
```

---

### 29. Thêm sản phẩm vào giỏ
**POST** `/cart/add`

**Headers:** `Authorization: Bearer {token}`

**Request Body:**
```json
{
  "product_id": 1,
  "quantity": 1
}
```

**Response:**
```json
{
  "success": true,
  "message": "Đã thêm sản phẩm vào giỏ hàng",
  "data": {
    "cart_id": 1,
    "product_id": 1,
    "quantity": 1,
    "added_at": "2024-12-02T14:30:00Z"
  }
}
```

---

### 30. Cập nhật số lượng
**PUT** `/cart/{cart_id}`

**Headers:** `Authorization: Bearer {token}`

**Request Body:**
```json
{
  "quantity": 2
}
```

**Response:**
```json
{
  "success": true,
  "message": "Cập nhật giỏ hàng thành công",
  "data": {
    "cart_id": 1,
    "quantity": 2,
    "subtotal": 64000000
  }
}
```

---

### 31. Xóa sản phẩm khỏi giỏ
**DELETE** `/cart/{cart_id}`

**Headers:** `Authorization: Bearer {token}`

**Response:**
```json
{
  "success": true,
  "message": "Đã xóa sản phẩm khỏi giỏ hàng"
}
```

---

### 32. Xóa toàn bộ giỏ hàng
**DELETE** `/cart/clear`

**Headers:** `Authorization: Bearer {token}`

**Response:**
```json
{
  "success": true,
  "message": "Đã xóa toàn bộ giỏ hàng"
}
```

---

## ❤️ WISHLIST APIs

### 33. Lấy danh sách yêu thích
**GET** `/wishlist`

**Headers:** `Authorization: Bearer {token}`

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "wishlist_id": 1,
      "product": {
        "product_id": 5,
        "product_name": "MSI GF63 Thin",
        "slug": "msi-gf63-thin",
        "selling_price": 18000000,
        "original_price": 20000000,
        "primary_image": "https://cdn.example.com/products/msi-gf63.jpg",
        "stock_quantity": 25,
        "average_rating": 4.3
      },
      "added_at": "2024-11-15T10:00:00Z"
    }
  ],
  "meta": {
    "total": 5
  }
}
```

---

### 34. Thêm vào wishlist
**POST** `/wishlist/add`

**Headers:** `Authorization: Bearer {token}`

**Request Body:**
```json
{
  "product_id": 5
}
```

**Response:**
```json
{
  "success": true,
  "message": "Đã thêm vào danh sách yêu thích",
  "data": {
    "wishlist_id": 2,
    "product_id": 5,
    "added_at": "2024-12-02T14:45:00Z"
  }
}
```

---

### 35. Xóa khỏi wishlist
**DELETE** `/wishlist/{wishlist_id}`

**Headers:** `Authorization: Bearer {token}`

**Response:**
```json
{
  "success": true,
  "message": "Đã xóa khỏi danh sách yêu thích"
}
```

---

### 36. Kiểm tra sản phẩm trong wishlist
**GET** `/wishlist/check/{product_id}`

**Headers:** `Authorization: Bearer {token}`

**Response:**
```json
{
  "success": true,
  "data": {
    "is_in_wishlist": true,
    "wishlist_id": 2
  }
}
```

---

## 📦 ORDER APIs

### 37. Tạo đơn hàng
**POST** `/orders/create`

**Headers:** `Authorization: Bearer {token}`

**Request Body:**
```json
{
  "items": [
    {
      "product_id": 1,
      "quantity": 1
    }
  ],
  "shipping_address": {
    "recipient_name": "Nguyễn Văn A",
    "phone": "0901234567",
    "province": "Hà Nội",
    "district": "Cầu Giấy",
    "ward": "Dịch Vọng",
    "detail_address": "Số 1 Nguyễn Trãi"
  },
  "payment_method": "VNPay",
  "promotion_code": "LAPTOP500K",
  "customer_note": "Giao giờ hành chính"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Đặt hàng thành công",
  "data": {
    "order_id": 1,
    "order_code": "DH20241202001",
    "total_amount": 31530000,
    "payment_method": "VNPay",
    "payment_url": "https://sandbox.vnpayment.vn/paymentv2/...",
    "order_status": "pending",
    "created_at": "2024-12-02T15:00:00Z"
  }
}
```

---

### 38. Lấy danh sách đơn hàng
**GET** `/orders`

**Headers:** `Authorization: Bearer {token}`

**Query Parameters:**
```
?status=pending
&page=1
&limit=10
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "order_id": 1,
      "order_code": "DH20241202001",
      "total_amount": 31530000,
      "order_status": "confirmed",
      "payment_status": "paid",
      "payment_method": "VNPay",
      "items_count": 1,
      "ordered_at": "2024-12-02T15:00:00Z",
      "items": [
        {
          "product_name": "Dell XPS 15 9530",
          "product_image": "https://cdn.example.com/products/dell-xps-1.jpg",
          "quantity": 1,
          "total_price": 32000000
        }
      ]
    }
  ],
  "meta": {
    "page": 1,
    "limit": 10,
    "total": 25
  }
}
```

---

### 39. Lấy chi tiết đơn hàng
**GET** `/orders/{order_code}`

**Headers:** `Authorization: Bearer {token}`

**Response:**
```json
{
  "success": true,
  "data": {
    "order_id": 1,
    "order_code": "DH20241202001",
    "user": {
      "user_id": 1,
      "full_name": "Nguyễn Văn A",
      "email": "customer@example.com",
      "phone": "0901234567"
    },
    "shipping_info": {
      "recipient_name": "Nguyễn Văn A",
      "phone": "0901234567",
      "address": "Số 1 Nguyễn Trãi, Dịch Vọng, Cầu Giấy, Hà Nội"
    },
    "items": [
      {
        "order_item_id": 1,
        "product_id": 1,
        "product_name": "Dell XPS 15 9530",
        "product_image": "https://cdn.example.com/products/dell-xps-1.jpg",
        "sku": "DELL-XPS15-001",
        "quantity": 1,
        "unit_price": 32000000,
        "discount_amount": 0,
        "total_price": 32000000
      }
    ],
    "summary": {
      "subtotal": 32000000,
      "shipping_fee": 30000,
      "discount_amount": 500000,
      "total_amount": 31530000
    },
    "promotion": {
      "code": "LAPTOP500K",
      "discount_amount": 500000
    },
    "payment_method": "VNPay",
    "payment_status": "paid",
    "order_status": "confirmed",
    "customer_note": "Giao giờ hành chính",
    "timeline": [
      {
        "status": "pending",
        "timestamp": "2024-12-02T15:00:00Z",
        "note": "Đơn hàng đã được tạo"
      },
      {
        "status": "confirmed",
        "timestamp": "2024-12-02T15:30:00Z",
        "note": "Đơn hàng đã được xác nhận"
      }
    ],
    "ordered_at": "2024-12-02T15:00:00Z",
    "confirmed_at": "2024-12-02T15:30:00Z"
  }
}
```

---

### 40. Hủy đơn hàng
**POST** `/orders/{order_code}/cancel`

**Headers:** `Authorization: Bearer {token}`

**Request Body:**
```json
{
  "cancel_reason": "Đổi ý không mua nữa"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Đơn hàng đã được hủy",
  "data": {
    "order_code": "DH20241202001",
    "order_status": "cancelled",
    "cancelled_at": "2024-12-02T16:00:00Z"
  }
}
```

---

### 41. Theo dõi đơn hàng
**GET** `/orders/{order_code}/tracking`

**Response:**
```json
{
  "success": true,
  "data": {
    "order_code": "DH20241202001",
    "current_status": "shipping",
    "timeline": [
      {
        "status": "pending",
        "label": "Chờ xác nhận",
        "timestamp": "2024-12-02T15:00:00Z",
        "completed": true
      },
      {
        "status": "confirmed",
        "label": "Đã xác nhận",
        "timestamp": "2024-12-02T15:30:00Z",
        "completed": true
      },
      {
        "status": "processing",
        "label": "Đang xử lý",
        "timestamp": "2024-12-02T16:00:00Z",
        "completed": true
      },
      {
        "status": "shipping",
        "label": "Đang giao hàng",
        "timestamp": "2024-12-03T09:00:00Z",
        "completed": true,
        "note": "Đơn hàng đang trên đường giao đến bạn"
      },
      {
        "status": "delivered",
        "label": "Đã giao hàng",
        "timestamp": null,
        "completed": false
      }
    ],
    "estimated_delivery": "2024-12-05T17:00:00Z"
  }
}
```

---

## 💳 PAYMENT APIs

### 42. Tạo link thanh toán VNPay
**POST** `/payments/vnpay/create`

**Headers:** `Authorization: Bearer {token}`

**Request Body:**
```json
{
  "order_id": 1,
  "return_url": "https://laptopstore.com/payment/result"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "payment_url": "https://sandbox.vnpayment.vn/paymentv2/vpcpay.html?vnp_Amount=3153000000&...",
    "vnp_txn_ref": "DH20241202001",
    "expires_at": "2024-12-02T15:15:00Z"
  }
}
```

---

### 43. Xử lý callback VNPay (IPN)
**GET** `/payments/vnpay/callback`

**Query Parameters:**
```
?vnp_Amount=3153000000
&vnp_BankCode=NCB
&vnp_ResponseCode=00
&vnp_TransactionNo=14256879
&vnp_TxnRef=DH20241202001
&vnp_SecureHash=abc123...
```

**Response:**
```json
{
  "RspCode": "00",
  "Message": "Confirm Success"
}
```

---

### 44. Kiểm tra trạng thái thanh toán
**GET** `/payments/{order_code}/status`

**Headers:** `Authorization: Bearer {token}`

**Response:**
```json
{
  "success": true,
  "data": {
    "order_code": "DH20241202001",
    "payment_method": "VNPay",
    "payment_status": "paid",
    "transaction_no": "14256879",
    "bank_code": "NCB",
    "paid_at": "2024-12-02T15:05:30Z",
    "amount": 31530000
  }
}
```

---

## ⭐ REVIEW APIs

### 45. Lấy đánh giá sản phẩm
**GET** `/products/{product_id}/reviews`

**Query Parameters:**
```
?page=1
&limit=10
&rating=5
&sort=helpful|newest
```

**Response:**
```json
{
  "success": true,
  "data": {
    "statistics": {
      "average_rating": 4.5,
      "total_reviews": 128,
      "rating_distribution": {
        "5": 75,
        "4": 35,
        "3": 10,
        "2": 5,
        "1": 3
      }
    },
    "reviews": [
      {
        "review_id": 1,
        "user": {
          "user_id": 5,
          "full_name": "Nguyễn Văn B",
          "avatar_url": "https://cdn.example.com/avatars/5.jpg"
        },
        "rating": 5,
        "title": "Sản phẩm rất tốt",
        "comment": "Laptop chạy mượt, màn hình đẹp",
        "images": [
          "https://cdn.example.com/reviews/1-1.jpg",
          "https://cdn.example.com/reviews/1-2.jpg"
        ],
        "is_verified_purchase": true,
        "helpful_count": 15,
        "created_at": "2024-11-20T10:30:00Z"
      }
    ]
  },
  "meta": {
    "page": 1,
    "limit": 10,
    "total": 128
  }
}
```

---

### 46. Thêm đánh giá
**POST** `/reviews/create`

**Headers:** `Authorization: Bearer {token}`

**Request Body:**
```json
{
  "product_id": 1,
  "order_id": 1,
  "rating": 5,
  "title": "Sản phẩm rất tốt",
  "comment": "Laptop chạy mượt, màn hình đẹp",
  "images": [
    "https://cdn.example.com/reviews/upload-1.jpg"
  ]
}
```

**Response:**
```json
{
  "success": true,
  "message": "Đánh giá của bạn đã được gửi. Admin sẽ duyệt trong thời gian sớm nhất.",
  "data": {
    "review_id": 129,
    "product_id": 1,
    "rating": 5,
    "is_approved": false,
    "created_at": "2024-12-02T16:00:00Z"
  }
}
```

---

### 47. Cập nhật đánh giá
**PUT** `/reviews/{review_id}`

**Headers:** `Authorization: Bearer {token}`

**Request Body:**
```json
{
  "rating": 4,
  "title": "Cập nhật đánh giá",
  "comment": "Sau một thời gian dùng thì khá ổn"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Cập nhật đánh giá thành công"
}
```

---

### 48. Xóa đánh giá
**DELETE** `/reviews/{review_id}`

**Headers:** `Authorization: Bearer {token}`

**Response:**
```json
{
  "success": true,
  "message": "Đã xóa đánh giá"
}
```

---

### 49. Đánh dấu đánh giá hữu ích
**POST** `/reviews/{review_id}/helpful`

**Headers:** `Authorization: Bearer {token}`

**Response:**
```json
{
  "success": true,
  "message": "Đã đánh dấu đánh giá hữu ích",
  "data": {
    "helpful_count": 16
  }
}
```

---

### 50. Upload ảnh đánh giá
**POST** `/reviews/upload-image`

**Headers:** `Authorization: Bearer {token}`

**Request Body:** `multipart/form-data`
```
image: [file]
```

**Response:**
```json
{
  "success": true,
  "data": {
    "image_url": "https://cdn.example.com/reviews/upload-123.jpg"
  }
}
```

---

## 🔔 NOTIFICATION APIs

### 51. Lấy danh sách thông báo
**GET** `/notifications`

**Headers:** `Authorization: Bearer {token}`

**Query Parameters:**
```
?page=1
&limit=20
&is_read=false
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "notification_id": 1,
      "title": "Đơn hàng #DH20241202001 đã được xác nhận",
      "message": "Đơn hàng của bạn đã chuyển sang trạng thái: confirmed",
      "type": "order",
      "reference_id": 1,
      "link_url": "/orders/DH20241202001",
      "is_read": false,
      "created_at": "2024-12-02T15:30:00Z"
    }
  ],
  "meta": {
    "total": 15,
    "unread_count": 5,
    "page": 1,
    "limit": 20
  }
}
```

---

### 52. Đánh dấu đã đọc
**PUT** `/notifications/{notification_id}/read`

**Headers:** `Authorization: Bearer {token}`

**Response:**
```json
{
  "success": true,
  "message": "Đã đánh dấu đã đọc"
}
```

---

### 53. Đánh dấu tất cả đã đọc
**PUT** `/notifications/read-all`

**Headers:** `Authorization: Bearer {token}`

**Response:**
```json
{
  "success": true,
  "message": "Đã đánh dấu tất cả thông báo đã đọc"
}
```

---

### 54. Xóa thông báo
**DELETE** `/notifications/{notification_id}`

**Headers:** `Authorization: Bearer {token}`

**Response:**
```json
{
  "success": true,
  "message": "Đã xóa thông báo"
}
```

---

### 55. Lấy số lượng thông báo chưa đọc
**GET** `/notifications/unread-count`

**Headers:** `Authorization: Bearer {token}`

**Response:**
```json
{
  "success": true,
  "data": {
    "unread_count": 5
  }
}
```

---

## 👨‍💼 ADMIN APIs

### 56. Dashboard thống kê
**GET** `/admin/dashboard`

**Headers:** `Authorization: Bearer {admin_token}`

**Query Parameters:**
```
?period=today|week|month|year
&start_date=2024-12-01
&end_date=2024-12-31
```

**Response:**
```json
{
  "success": true,
  "data": {
    "summary": {
      "total_revenue": 250000000,
      "total_orders": 85,
      "total_customers": 45,
      "total_products": 150
    },
    "revenue_chart": [
      {
        "date": "2024-12-01",
        "revenue": 15000000,
        "orders": 8
      },
      {
        "date": "2024-12-02",
        "revenue": 22000000,
        "orders": 12
      }
    ],
    "top_products": [
      {
        "product_id": 5,
        "product_name": "MSI GF63 Thin",
        "sold_count": 25,
        "revenue": 45000000
      }
    ],
    "recent_orders": [
      {
        "order_code": "DH20241202001",
        "customer_name": "Nguyễn Văn A",
        "total_amount": 31530000,
        "status": "confirmed",
        "ordered_at": "2024-12-02T15:00:00Z"
      }
    ],
    "order_status_distribution": {
      "pending": 5,
      "confirmed": 12,
      "processing": 8,
      "shipping": 15,
      "delivered": 40,
      "cancelled": 5
    }
  }
}
```

---

### 57. Quản lý sản phẩm - Danh sách
**GET** `/admin/products`

**Headers:** `Authorization: Bearer {admin_token}`

**Query Parameters:**
```
?page=1
&limit=20
&search=dell
&category_id=1
&is_active=true
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "product_id": 1,
      "product_name": "Dell XPS 15 9530",
      "sku": "DELL-XPS15-001",
      "brand_name": "Dell",
      "category_name": "Laptop Mỏng Nhẹ",
      "selling_price": 32000000,
      "stock_quantity": 50,
      "sold_count": 245,
      "is_active": true,
      "created_at": "2024-01-15T10:30:00Z"
    }
  ],
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 150
  }
}
```

---

### 58. Thêm sản phẩm mới
**POST** `/admin/products`

**Headers:** `Authorization: Bearer {admin_token}`

**Request Body:**
```json
{
  "product_name": "Lenovo ThinkPad X1 Carbon Gen 11",
  "brand_id": 3,
  "category_id": 4,
  "sku": "LENOVO-X1-001",
  "cpu": "Intel Core i7-1365U",
  "ram": "16GB LPDDR5",
  "storage": "512GB SSD",
  "screen_size": "14 inch",
  "screen_resolution": "2880x1800",
  "graphics_card": "Intel Iris Xe",
  "operating_system": "Windows 11 Pro",
  "weight": "1.12 kg",
  "battery": "57Wh",
  "color": "Đen",
  "original_price": 42000000,
  "selling_price": 38000000,
  "stock_quantity": 30,
  "short_description": "Laptop siêu mỏng nhẹ cho doanh nhân",
  "full_description": "<p>Mô tả đầy đủ...</p>",
  "specifications": {
    "warranty": "24 tháng",
    "origin": "Trung Quốc"
  },
  "images": [
    {
      "image_url": "https://cdn.example.com/products/lenovo-x1-1.jpg",
      "is_primary": true
    },
    {
      "image_url": "https://cdn.example.com/products/lenovo-x1-2.jpg",
      "is_primary": false
    }
  ],
  "is_featured": false,
  "is_active": true
}
```

**Response:**
```json
{
  "success": true,
  "message": "Thêm sản phẩm thành công",
  "data": {
    "product_id": 151,
    "slug": "lenovo-thinkpad-x1-carbon-gen-11",
    "created_at": "2024-12-02T16:30:00Z"
  }
}
```

---

### 59. Cập nhật sản phẩm
**PUT** `/admin/products/{product_id}`

**Headers:** `Authorization: Bearer {admin_token}`

**Request Body:**
```json
{
  "selling_price": 36000000,
  "stock_quantity": 25,
  "is_featured": true
}
```

**Response:**
```json
{
  "success": true,
  "message": "Cập nhật sản phẩm thành công"
}
```

---

### 60. Xóa sản phẩm
**DELETE** `/admin/products/{product_id}`

**Headers:** `Authorization: Bearer {admin_token}`

**Response:**
```json
{
  "success": true,
  "message": "Xóa sản phẩm thành công"
}
```

---

### 61. Quản lý đơn hàng - Danh sách
**GET** `/admin/orders`

**Headers:** `Authorization: Bearer {admin_token}`

**Query Parameters:**
```
?page=1
&limit=20
&status=pending
&payment_status=paid
&search=DH20241202
&date_from=2024-12-01
&date_to=2024-12-31
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "order_id": 1,
      "order_code": "DH20241202001",
      "customer": {
        "user_id": 1,
        "full_name": "Nguyễn Văn A",
        "email": "customer@example.com",
        "phone": "0901234567"
      },
      "total_amount": 31530000,
      "payment_method": "VNPay",
      "payment_status": "paid",
      "order_status": "confirmed",
      "ordered_at": "2024-12-02T15:00:00Z"
    }
  ],
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 85
  }
}
```

---

### 62. Cập nhật trạng thái đơn hàng
**PUT** `/admin/orders/{order_id}/status`

**Headers:** `Authorization: Bearer {admin_token}`

**Request Body:**
```json
{
  "order_status": "shipping",
  "admin_note": "Đã giao cho đơn vị vận chuyển"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Cập nhật trạng thái đơn hàng thành công",
  "data": {
    "order_code": "DH20241202001",
    "old_status": "processing",
    "new_status": "shipping",
    "updated_at": "2024-12-03T09:00:00Z"
  }
}
```

---

### 63. Quản lý khách hàng - Danh sách
**GET** `/admin/customers`

**Headers:** `Authorization: Bearer {admin_token}`

**Query Parameters:**
```
?page=1
&limit=20
&search=nguyen
&is_active=true
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "user_id": 1,
      "full_name": "Nguyễn Văn A",
      "email": "customer@example.com",
      "phone": "0901234567",
      "total_orders": 5,
      "total_spent": 150000000,
      "is_active": true,
      "created_at": "2024-01-15T10:30:00Z",
      "last_order_at": "2024-12-02T15:00:00Z"
    }
  ],
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 45
  }
}
```

---

### 64. Chi tiết khách hàng
**GET** `/admin/customers/{user_id}`

**Headers:** `Authorization: Bearer {admin_token}`

**Response:**
```json
{
  "success": true,
  "data": {
    "user_id": 1,
    "full_name": "Nguyễn Văn A",
    "email": "customer@example.com",
    "phone": "0901234567",
    "avatar_url": null,
    "is_active": true,
    "email_verified": true,
    "created_at": "2024-01-15T10:30:00Z",
    "statistics": {
      "total_orders": 5,
      "completed_orders": 4,
      "cancelled_orders": 1,
      "total_spent": 150000000,
      "average_order_value": 30000000
    },
    "recent_orders": [
      {
        "order_code": "DH20241202001",
        "total_amount": 31530000,
        "status": "confirmed",
        "ordered_at": "2024-12-02T15:00:00Z"
      }
    ],
    "addresses": [
      {
        "address_id": 1,
        "recipient_name": "Nguyễn Văn A",
        "phone": "0901234567",
        "address": "Số 1 Nguyễn Trãi, Dịch Vọng, Cầu Giấy, Hà Nội",
        "is_default": true
      }
    ]
  }
}
```

---

### 65. Vô hiệu hóa/Kích hoạt khách hàng
**PUT** `/admin/customers/{user_id}/toggle-status`

**Headers:** `Authorization: Bearer {admin_token}`

**Response:**
```json
{
  "success": true,
  "message": "Cập nhật trạng thái khách hàng thành công",
  "data": {
    "user_id": 1,
    "is_active": false
  }
}
```

---

### 66. Quản lý danh mục - Danh sách
**GET** `/admin/categories`

**Headers:** `Authorization: Bearer {admin_token}`

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "category_id": 1,
      "category_name": "Laptop Gaming",
      "slug": "laptop-gaming",
      "parent_id": null,
      "product_count": 85,
      "is_active": true,
      "display_order": 1
    }
  ]
}
```

---

### 67. Thêm danh mục
**POST** `/admin/categories`

**Headers:** `Authorization: Bearer {admin_token}`

**Request Body:**
```json
{
  "category_name": "Laptop AI",
  "parent_id": null,
  "description": "Laptop tích hợp AI",
  "icon_url": "https://cdn.example.com/icons/ai.png",
  "display_order": 6,
  "is_active": true
}
```

**Response:**
```json
{
  "success": true,
  "message": "Thêm danh mục thành công",
  "data": {
    "category_id": 6,
    "slug": "laptop-ai",
    "created_at": "2024-12-02T17:00:00Z"
  }
}
```

---

### 68. Cập nhật danh mục
**PUT** `/admin/categories/{category_id}`

**Headers:** `Authorization: Bearer {admin_token}`

**Request Body:**
```json
{
  "category_name": "Laptop AI & Gaming",
  "display_order": 1
}
```

**Response:**
```json
{
  "success": true,
  "message": "Cập nhật danh mục thành công"
}
```

---

### 69. Xóa danh mục
**DELETE** `/admin/categories/{category_id}`

**Headers:** `Authorization: Bearer {admin_token}`

**Response:**
```json
{
  "success": true,
  "message": "Xóa danh mục thành công"
}
```

---

### 70. Quản lý thương hiệu - Danh sách
**GET** `/admin/brands`

**Headers:** `Authorization: Bearer {admin_token}`

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "brand_id": 1,
      "brand_name": "Dell",
      "logo_url": "https://cdn.example.com/brands/dell.png",
      "product_count": 42,
      "is_active": true
    }
  ]
}
```

---

### 71. Thêm thương hiệu
**POST** `/admin/brands`

**Headers:** `Authorization: Bearer {admin_token}`

**Request Body:**
```json
{
  "brand_name": "LG",
  "logo_url": "https://cdn.example.com/brands/lg.png",
  "description": "Thương hiệu LG Gram",
  "is_active": true
}
```

**Response:**
```json
{
  "success": true,
  "message": "Thêm thương hiệu thành công",
  "data": {
    "brand_id": 8,
    "brand_name": "LG"
  }
}
```

---

### 72. Cập nhật thương hiệu
**PUT** `/admin/brands/{brand_id}`

**Headers:** `Authorization: Bearer {admin_token}`

**Request Body:**
```json
{
  "logo_url": "https://cdn.example.com/brands/lg-new.png",
  "description": "Thương hiệu LG Gram - Laptop siêu nhẹ"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Cập nhật thương hiệu thành công"
}
```

---

### 73. Xóa thương hiệu
**DELETE** `/admin/brands/{brand_id}`

**Headers:** `Authorization: Bearer {admin_token}`

**Response:**
```json
{
  "success": true,
  "message": "Xóa thương hiệu thành công"
}
```

---

### 74. Quản lý đánh giá - Danh sách
**GET** `/admin/reviews`

**Headers:** `Authorization: Bearer {admin_token}`

**Query Parameters:**
```
?page=1
&limit=20
&is_approved=false
&product_id=1
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "review_id": 129,
      "product": {
        "product_id": 1,
        "product_name": "Dell XPS 15 9530"
      },
      "user": {
        "user_id": 5,
        "full_name": "Nguyễn Văn B"
      },
      "rating": 5,
      "title": "Sản phẩm rất tốt",
      "comment": "Laptop chạy mượt, màn hình đẹp",
      "is_approved": false,
      "created_at": "2024-12-02T16:00:00Z"
    }
  ],
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 15,
    "pending_reviews": 15
  }
}
```

---

### 75. Duyệt đánh giá
**PUT** `/admin/reviews/{review_id}/approve`

**Headers:** `Authorization: Bearer {admin_token}`

**Response:**
```json
{
  "success": true,
  "message": "Đã duyệt đánh giá"
}
```

---

### 76. Từ chối đánh giá
**PUT** `/admin/reviews/{review_id}/reject`

**Headers:** `Authorization: Bearer {admin_token}`

**Request Body:**
```json
{
  "reason": "Nội dung không phù hợp"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Đã từ chối đánh giá"
}
```

---

### 77. Xóa đánh giá
**DELETE** `/admin/reviews/{review_id}`

**Headers:** `Authorization: Bearer {admin_token}`

**Response:**
```json
{
  "success": true,
  "message": "Đã xóa đánh giá"
}
```

---

## 🔥 FLASH SALE APIs

### 78. Lấy Flash Sale đang diễn ra
**GET** `/flash-sales/active`

**Response:**
```json
{
  "success": true,
  "data": {
    "flash_sale_id": 1,
    "title": "Flash Sale 12.12",
    "description": "Giảm giá sốc các sản phẩm laptop",
    "start_time": "2024-12-12T00:00:00Z",
    "end_time": "2024-12-12T23:59:59Z",
    "time_remaining": 7200,
    "products": [
      {
        "flash_sale_product_id": 1,
        "product": {
          "product_id": 5,
          "product_name": "MSI GF63 Thin",
          "slug": "msi-gf63-thin",
          "original_price": 20000000,
          "primary_image": "https://cdn.example.com/products/msi-gf63.jpg"
        },
        "flash_price": 16000000,
        "discount_percentage": 20,
        "quantity_limit": 50,
        "quantity_sold": 23,
        "quantity_remaining": 27,
        "max_per_customer": 1,
        "progress_percentage": 46
      }
    ]
  }
}
```

---

### 79. Lấy lịch sử Flash Sale
**GET** `/flash-sales/history`

**Query Parameters:**
```
?page=1
&limit=10
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "flash_sale_id": 1,
      "title": "Flash Sale 12.12",
      "start_time": "2024-12-12T00:00:00Z",
      "end_time": "2024-12-12T23:59:59Z",
      "total_products": 15,
      "total_sold": 250,
      "status": "ended"
    }
  ],
  "meta": {
    "page": 1,
    "limit": 10,
    "total": 5
  }
}
```

---

### 80. Admin - Tạo Flash Sale
**POST** `/admin/flash-sales`

**Headers:** `Authorization: Bearer {admin_token}`

**Request Body:**
```json
{
  "title": "Flash Sale Giáng Sinh",
  "description": "Flash Sale đặc biệt mùa Giáng Sinh",
  "start_time": "2024-12-24T00:00:00Z",
  "end_time": "2024-12-25T23:59:59Z",
  "products": [
    {
      "product_id": 5,
      "flash_price": 16000000,
      "quantity_limit": 50,
      "max_per_customer": 1
    },
    {
      "product_id": 8,
      "flash_price": 22000000,
      "quantity_limit": 30,
      "max_per_customer": 2
    }
  ]
}
```

**Response:**
```json
{
  "success": true,
  "message": "Tạo Flash Sale thành công",
  "data": {
    "flash_sale_id": 2,
    "title": "Flash Sale Giáng Sinh",
    "total_products": 2,
    "created_at": "2024-12-02T17:30:00Z"
  }
}
```

---

### 81. Admin - Cập nhật Flash Sale
**PUT** `/admin/flash-sales/{flash_sale_id}`

**Headers:** `Authorization: Bearer {admin_token}`

**Request Body:**
```json
{
  "title": "Flash Sale Giáng Sinh 2024",
  "end_time": "2024-12-26T23:59:59Z"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Cập nhật Flash Sale thành công"
}
```

---

### 82. Admin - Xóa Flash Sale
**DELETE** `/admin/flash-sales/{flash_sale_id}`

**Headers:** `Authorization: Bearer {admin_token}`

**Response:**
```json
{
  "success": true,
  "message": "Xóa Flash Sale thành công"
}
```

---

### 83. Admin - Thêm sản phẩm vào Flash Sale
**POST** `/admin/flash-sales/{flash_sale_id}/products`

**Headers:** `Authorization: Bearer {admin_token}`

**Request Body:**
```json
{
  "product_id": 10,
  "flash_price": 19000000,
  "quantity_limit": 40,
  "max_per_customer": 1
}
```

**Response:**
```json
{
  "success": true,
  "message": "Thêm sản phẩm vào Flash Sale thành công"
}
```

---

### 84. Admin - Xóa sản phẩm khỏi Flash Sale
**DELETE** `/admin/flash-sales/{flash_sale_id}/products/{flash_sale_product_id}`

**Headers:** `Authorization: Bearer {admin_token}`

**Response:**
```json
{
  "success": true,
  "message": "Xóa sản phẩm khỏi Flash Sale thành công"
}
```

---

## 🎟️ PROMOTION APIs

### 85. Kiểm tra mã khuyến mãi
**POST** `/promotions/validate`

**Headers:** `Authorization: Bearer {token}`

**Request Body:**
```json
{
  "code": "LAPTOP500K",
  "order_total": 35000000
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "promotion_id": 1,
    "code": "LAPTOP500K",
    "title": "Giảm 500K cho đơn từ 10 triệu",
    "discount_type": "fixed_amount",
    "discount_value": 500000,
    "discount_amount": 500000,
    "is_valid": true,
    "remaining_uses": 75
  }
}
```

---

### 86. Lấy danh sách khuyến mãi khả dụng
**GET** `/promotions/available`

**Headers:** `Authorization: Bearer {token}`

**Query Parameters:**
```
?order_total=35000000
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "promotion_id": 1,
      "code": "LAPTOP500K",
      "title": "Giảm 500K cho đơn từ 10 triệu",
      "description": "Áp dụng cho đơn hàng từ 10.000.000đ",
      "discount_type": "fixed_amount",
      "discount_value": 500000,
      "min_order_value": 10000000,
      "end_date": "2024-12-31T23:59:59Z",
      "can_apply": true
    },
    {
      "promotion_id": 2,
      "code": "LAPTOP20",
      "title": "Giảm 20% tối đa 2 triệu",
      "discount_type": "percentage",
      "discount_value": 20,
      "max_discount_amount": 2000000,
      "min_order_value": 20000000,
      "end_date": "2024-12-31T23:59:59Z",
      "can_apply": true
    }
  ]
}
```

---

### 87. Admin - Tạo khuyến mãi
**POST** `/admin/promotions`

**Headers:** `Authorization: Bearer {admin_token}`

**Request Body:**
```json
{
  "code": "NEWYEAR2025",
  "title": "Khuyến mãi Tết 2025",
  "description": "Giảm 15% tối đa 3 triệu cho đơn từ 30 triệu",
  "discount_type": "percentage",
  "discount_value": 15,
  "min_order_value": 30000000,
  "max_discount_amount": 3000000,
  "usage_limit": 500,
  "usage_per_customer": 1,
  "start_date": "2025-01-20T00:00:00Z",
  "end_date": "2025-02-10T23:59:59Z",
  "is_active": true
}
```

**Response:**
```json
{
  "success": true,
  "message": "Tạo khuyến mãi thành công",
  "data": {
    "promotion_id": 3,
    "code": "NEWYEAR2025",
    "created_at": "2024-12-02T18:00:00Z"
  }
}
```

---

### 88. Admin - Cập nhật khuyến mãi
**PUT** `/admin/promotions/{promotion_id}`

**Headers:** `Authorization: Bearer {admin_token}`

**Request Body:**
```json
{
  "usage_limit": 1000,
  "end_date": "2025-02-15T23:59:59Z"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Cập nhật khuyến mãi thành công"
}
```

---

### 89. Admin - Xóa khuyến mãi
**DELETE** `/admin/promotions/{promotion_id}`

**Headers:** `Authorization: Bearer {admin_token}`

**Response:**
```json
{
  "success": true,
  "message": "Xóa khuyến mãi thành công"
}
```

---

### 90. Admin - Thống kê khuyến mãi
**GET** `/admin/promotions/{promotion_id}/statistics`

**Headers:** `Authorization: Bearer {admin_token}`

**Response:**
```json
{
  "success": true,
  "data": {
    "promotion_id": 1,
    "code": "LAPTOP500K",
    "usage_count": 125,
    "usage_limit": 200,
    "usage_percentage": 62.5,
    "total_discount_given": 62500000,
    "total_orders": 125,
    "total_revenue": 3875000000,
    "unique_customers": 115
  }
}
```

---

## 📊 ADDITIONAL APIs

### 91. Báo cáo doanh thu
**GET** `/admin/reports/revenue`

**Headers:** `Authorization: Bearer {admin_token}`

**Query Parameters:**
```
?start_date=2024-12-01
&end_date=2024-12-31
&group_by=day|week|month
```

**Response:**
```json
{
  "success": true,
  "data": {
    "summary": {
      "total_revenue": 250000000,
      "total_orders": 85,
      "average_order_value": 2941176,
      "total_products_sold": 95
    },
    "chart_data": [
      {
        "period": "2024-12-01",
        "revenue": 15000000,
        "orders": 8,
        "products_sold": 10
      }
    ]
  }
}
```

---

### 92. Báo cáo sản phẩm bán chạy
**GET** `/admin/reports/bestsellers`

**Headers:** `Authorization: Bearer {admin_token}`

**Query Parameters:**
```
?start_date=2024-12-01
&end_date=2024-12-31
&limit=20
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "rank": 1,
      "product_id": 5,
      "product_name": "MSI GF63 Thin",
      "quantity_sold": 25,
      "revenue": 45000000,
      "average_rating": 4.3
    }
  ]
}
```

---

### 93. Upload file
**POST** `/upload`

**Headers:** `Authorization: Bearer {token}`

**Request Body:** `multipart/form-data`
```
file: [file]
type: product|brand|category|review|avatar
```

**Response:**
```json
{
  "success": true,
  "data": {
    "file_url": "https://cdn.example.com/uploads/product-123.jpg",
    "file_name": "product-123.jpg",
    "file_size": 256000,
    "mime_type": "image/jpeg"
  }
}
```

---

### 94. Lấy cài đặt hệ thống
**GET** `/settings`

**Response:**
```json
{
  "success": true,
  "data": {
    "site_name": "Laptop Store",
    "shipping_fee": 30000,
    "free_shipping_threshold": 5000000,
    "hot_line": "1900-xxxx",
    "email": "support@laptopstore.com",
    "social_links": {
      "facebook": "https://facebook.com/laptopstore",
      "instagram": "https://instagram.com/laptopstore"
    }
  }
}
```

---

### 95. Admin - Cập nhật cài đặt
**PUT** `/admin/settings`

**Headers:** `Authorization: Bearer {admin_token}`

**Request Body:**
```json
{
  "shipping_fee": 35000,
  "free_shipping_threshold": 10000000
}
```

**Response:**
```json
{
  "success": true,
  "message": "Cập nhật cài đặt thành công"
}
```

---

## 🔒 BẢO MẬT VÀ RATE LIMITING

### Rate Limiting
```
- Authentication endpoints: 5 requests/minute
- Public endpoints: 100 requests/minute
- Authenticated endpoints: 200 requests/minute
- Admin endpoints: 500 requests/minute
```

### Security Headers
```
X-API-Version: 1.0
X-Request-ID: unique-request-id
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1638360000
```

---

## 📝 NOTES

1. **Pagination**: Tất cả API trả về danh sách đều hỗ trợ phân trang với `page` và `limit`
2. **Authentication**: Sử dụng JWT token trong header `Authorization: Bearer {token}`
3. **Error Handling**: Tất cả lỗi đều trả về format chuẩn với `success: false`
4. **Validation**: Request body sẽ được validate trước khi xử lý
5. **CORS**: API hỗ trợ CORS cho frontend domain
6. **Logging**: Tất cả requests đều được log để audit
7. **Caching**: Sử dụng Redis cache cho các endpoint public
8. **Webhooks**: Hỗ trợ webhook cho VNPay IPN callback

---

**Tổng cộng: 95 APIs** đã được thiết kế đầy đủ cho hệ thống.
