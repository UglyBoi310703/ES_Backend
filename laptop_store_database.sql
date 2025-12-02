-- =============================================
-- DATABASE SCHEMA: LAPTOP E-COMMERCE WEBSITE
-- =============================================

-- Bảng người dùng (Users)
CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    avatar_url VARCHAR(500),
    role ENUM('customer', 'admin') DEFAULT 'customer',
    is_active BOOLEAN DEFAULT TRUE,
    email_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_login TIMESTAMP NULL,
    INDEX idx_email (email),
    INDEX idx_role (role)
);

-- Bảng địa chỉ giao hàng
CREATE TABLE addresses (
    address_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    recipient_name VARCHAR(255) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    province VARCHAR(100) NOT NULL,
    district VARCHAR(100) NOT NULL,
    ward VARCHAR(100) NOT NULL,
    detail_address TEXT NOT NULL,
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id)
);

-- Bảng thương hiệu
CREATE TABLE brands (
    brand_id INT PRIMARY KEY AUTO_INCREMENT,
    brand_name VARCHAR(100) UNIQUE NOT NULL,
    logo_url VARCHAR(500),
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_brand_name (brand_name)
);

-- Bảng danh mục sản phẩm
CREATE TABLE categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(100) NOT NULL,
    slug VARCHAR(150) UNIQUE NOT NULL,
    parent_id INT NULL,
    description TEXT,
    icon_url VARCHAR(500),
    display_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (parent_id) REFERENCES categories(category_id) ON DELETE SET NULL,
    INDEX idx_slug (slug),
    INDEX idx_parent_id (parent_id)
);

-- Bảng sản phẩm
CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(255) NOT NULL,
    slug VARCHAR(300) UNIQUE NOT NULL,
    brand_id INT NOT NULL,
    category_id INT NOT NULL,
    sku VARCHAR(100) UNIQUE NOT NULL,
    
    -- Thông số kỹ thuật
    cpu VARCHAR(255),
    ram VARCHAR(100),
    storage VARCHAR(100),
    screen_size VARCHAR(50),
    screen_resolution VARCHAR(100),
    graphics_card VARCHAR(255),
    operating_system VARCHAR(100),
    weight VARCHAR(50),
    battery VARCHAR(100),
    color VARCHAR(100),
    
    -- Giá và số lượng
    original_price DECIMAL(15, 2) NOT NULL,
    selling_price DECIMAL(15, 2) NOT NULL,
    stock_quantity INT DEFAULT 0,
    
    -- Mô tả
    short_description TEXT,
    full_description LONGTEXT,
    specifications JSON,
    
    -- Trạng thái
    is_active BOOLEAN DEFAULT TRUE,
    is_featured BOOLEAN DEFAULT FALSE,
    
    -- Thống kê
    view_count INT DEFAULT 0,
    sold_count INT DEFAULT 0,
    average_rating DECIMAL(3, 2) DEFAULT 0,
    review_count INT DEFAULT 0,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (brand_id) REFERENCES brands(brand_id) ON DELETE RESTRICT,
    FOREIGN KEY (category_id) REFERENCES categories(category_id) ON DELETE RESTRICT,
    INDEX idx_slug (slug),
    INDEX idx_brand_id (brand_id),
    INDEX idx_category_id (category_id),
    INDEX idx_selling_price (selling_price),
    INDEX idx_created_at (created_at),
    FULLTEXT idx_search (product_name, short_description)
);

-- Bảng hình ảnh sản phẩm
CREATE TABLE product_images (
    image_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT NOT NULL,
    image_url VARCHAR(500) NOT NULL,
    is_primary BOOLEAN DEFAULT FALSE,
    display_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE,
    INDEX idx_product_id (product_id)
);

-- Bảng Flash Sale
CREATE TABLE flash_sales (
    flash_sale_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_time_range (start_time, end_time),
    INDEX idx_is_active (is_active)
);

-- Bảng sản phẩm Flash Sale
CREATE TABLE flash_sale_products (
    flash_sale_product_id INT PRIMARY KEY AUTO_INCREMENT,
    flash_sale_id INT NOT NULL,
    product_id INT NOT NULL,
    flash_price DECIMAL(15, 2) NOT NULL,
    quantity_limit INT NOT NULL,
    quantity_sold INT DEFAULT 0,
    max_per_customer INT DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (flash_sale_id) REFERENCES flash_sales(flash_sale_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE,
    UNIQUE KEY unique_flash_product (flash_sale_id, product_id),
    INDEX idx_flash_sale_id (flash_sale_id),
    INDEX idx_product_id (product_id)
);

-- Bảng khuyến mãi/Voucher
CREATE TABLE promotions (
    promotion_id INT PRIMARY KEY AUTO_INCREMENT,
    code VARCHAR(50) UNIQUE NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    discount_type ENUM('percentage', 'fixed_amount') NOT NULL,
    discount_value DECIMAL(15, 2) NOT NULL,
    
    -- Điều kiện áp dụng
    min_order_value DECIMAL(15, 2) DEFAULT 0,
    max_discount_amount DECIMAL(15, 2) NULL,
    
    -- Giới hạn sử dụng
    usage_limit INT NULL,
    usage_count INT DEFAULT 0,
    usage_per_customer INT DEFAULT 1,
    
    -- Thời gian
    start_date TIMESTAMP NOT NULL,
    end_date TIMESTAMP NOT NULL,
    
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_code (code),
    INDEX idx_date_range (start_date, end_date)
);

-- Bảng lịch sử sử dụng voucher
CREATE TABLE promotion_usage (
    usage_id INT PRIMARY KEY AUTO_INCREMENT,
    promotion_id INT NOT NULL,
    user_id INT NOT NULL,
    order_id INT NULL,
    used_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (promotion_id) REFERENCES promotions(promotion_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    INDEX idx_promotion_user (promotion_id, user_id)
);

-- Bảng giỏ hàng
CREATE TABLE cart (
    cart_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE,
    UNIQUE KEY unique_cart_item (user_id, product_id),
    INDEX idx_user_id (user_id)
);

-- Bảng danh sách yêu thích (Wishlist)
CREATE TABLE wishlist (
    wishlist_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    product_id INT NOT NULL,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE,
    UNIQUE KEY unique_wishlist_item (user_id, product_id),
    INDEX idx_user_id (user_id)
);

-- Bảng đơn hàng
CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    order_code VARCHAR(50) UNIQUE NOT NULL,
    
    -- Thông tin người nhận
    recipient_name VARCHAR(255) NOT NULL,
    recipient_phone VARCHAR(20) NOT NULL,
    shipping_province VARCHAR(100) NOT NULL,
    shipping_district VARCHAR(100) NOT NULL,
    shipping_ward VARCHAR(100) NOT NULL,
    shipping_address TEXT NOT NULL,
    
    -- Giá trị đơn hàng
    subtotal DECIMAL(15, 2) NOT NULL,
    shipping_fee DECIMAL(15, 2) DEFAULT 0,
    discount_amount DECIMAL(15, 2) DEFAULT 0,
    total_amount DECIMAL(15, 2) NOT NULL,
    
    -- Voucher
    promotion_id INT NULL,
    promotion_code VARCHAR(50) NULL,
    
    -- Thanh toán
    payment_method ENUM('COD', 'VNPay', 'banking') NOT NULL,
    payment_status ENUM('pending', 'paid', 'failed', 'refunded') DEFAULT 'pending',
    
    -- Trạng thái đơn hàng
    order_status ENUM('pending', 'confirmed', 'processing', 'shipping', 'delivered', 'cancelled', 'returned') DEFAULT 'pending',
    
    -- Ghi chú
    customer_note TEXT NULL,
    admin_note TEXT NULL,
    cancel_reason TEXT NULL,
    
    -- Thời gian
    ordered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    confirmed_at TIMESTAMP NULL,
    shipped_at TIMESTAMP NULL,
    delivered_at TIMESTAMP NULL,
    cancelled_at TIMESTAMP NULL,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE RESTRICT,
    FOREIGN KEY (promotion_id) REFERENCES promotions(promotion_id) ON DELETE SET NULL,
    INDEX idx_user_id (user_id),
    INDEX idx_order_code (order_code),
    INDEX idx_order_status (order_status),
    INDEX idx_payment_status (payment_status),
    INDEX idx_ordered_at (ordered_at)
);

-- Bảng chi tiết đơn hàng
CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    product_image VARCHAR(500),
    sku VARCHAR(100),
    quantity INT NOT NULL,
    unit_price DECIMAL(15, 2) NOT NULL,
    discount_amount DECIMAL(15, 2) DEFAULT 0,
    total_price DECIMAL(15, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE RESTRICT,
    INDEX idx_order_id (order_id)
);

-- Bảng thanh toán VNPay
CREATE TABLE vnpay_transactions (
    transaction_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    vnp_txn_ref VARCHAR(100) UNIQUE NOT NULL,
    vnp_transaction_no VARCHAR(100),
    vnp_amount BIGINT NOT NULL,
    vnp_bank_code VARCHAR(50),
    vnp_card_type VARCHAR(50),
    vnp_response_code VARCHAR(10),
    vnp_transaction_status VARCHAR(10),
    vnp_pay_date VARCHAR(14),
    vnp_secure_hash VARCHAR(500),
    request_data JSON,
    response_data JSON,
    status ENUM('pending', 'success', 'failed') DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    INDEX idx_order_id (order_id),
    INDEX idx_vnp_txn_ref (vnp_txn_ref)
);

-- Bảng đánh giá sản phẩm
CREATE TABLE reviews (
    review_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT NOT NULL,
    user_id INT NOT NULL,
    order_id INT NULL,
    rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    title VARCHAR(255),
    comment TEXT,
    is_verified_purchase BOOLEAN DEFAULT FALSE,
    is_approved BOOLEAN DEFAULT FALSE,
    helpful_count INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE SET NULL,
    INDEX idx_product_id (product_id),
    INDEX idx_user_id (user_id),
    INDEX idx_rating (rating)
);

-- Bảng hình ảnh đánh giá
CREATE TABLE review_images (
    review_image_id INT PRIMARY KEY AUTO_INCREMENT,
    review_id INT NOT NULL,
    image_url VARCHAR(500) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (review_id) REFERENCES reviews(review_id) ON DELETE CASCADE,
    INDEX idx_review_id (review_id)
);

-- Bảng phản hồi hữu ích của đánh giá
CREATE TABLE review_helpful (
    helpful_id INT PRIMARY KEY AUTO_INCREMENT,
    review_id INT NOT NULL,
    user_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (review_id) REFERENCES reviews(review_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    UNIQUE KEY unique_helpful (review_id, user_id),
    INDEX idx_review_id (review_id)
);

-- Bảng thông báo
CREATE TABLE notifications (
    notification_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NULL, -- NULL = thông báo cho tất cả
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    type ENUM('order', 'promotion', 'system', 'product', 'other') DEFAULT 'system',
    reference_id INT NULL, -- ID đơn hàng, sản phẩm liên quan
    link_url VARCHAR(500),
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_is_read (is_read),
    INDEX idx_created_at (created_at)
);

-- Bảng lịch sử thay đổi trạng thái đơn hàng
CREATE TABLE order_status_history (
    history_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    old_status ENUM('pending', 'confirmed', 'processing', 'shipping', 'delivered', 'cancelled', 'returned'),
    new_status ENUM('pending', 'confirmed', 'processing', 'shipping', 'delivered', 'cancelled', 'returned') NOT NULL,
    note TEXT,
    changed_by INT NULL, -- user_id của admin thay đổi
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (changed_by) REFERENCES users(user_id) ON DELETE SET NULL,
    INDEX idx_order_id (order_id)
);

-- Bảng lịch sử xem sản phẩm
CREATE TABLE product_views (
    view_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT NOT NULL,
    user_id INT NULL,
    ip_address VARCHAR(45),
    user_agent TEXT,
    viewed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL,
    INDEX idx_product_id (product_id),
    INDEX idx_viewed_at (viewed_at)
);

-- Bảng cấu hình hệ thống
CREATE TABLE system_settings (
    setting_id INT PRIMARY KEY AUTO_INCREMENT,
    setting_key VARCHAR(100) UNIQUE NOT NULL,
    setting_value TEXT,
    setting_type ENUM('string', 'number', 'boolean', 'json') DEFAULT 'string',
    description TEXT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_setting_key (setting_key)
);

-- =============================================
-- INSERT DỮ LIỆU MẪU
-- =============================================

-- Tạo tài khoản admin mặc định (password: admin123 - đã hash)
INSERT INTO users (email, password_hash, full_name, role, email_verified) VALUES
('admin@laptopstore.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Administrator', 'admin', TRUE);

-- Thêm thương hiệu mẫu
INSERT INTO brands (brand_name, description) VALUES
('Dell', 'Thương hiệu laptop Dell - Chất lượng và độ bền cao'),
('HP', 'Thương hiệu laptop HP - Đa dạng sản phẩm cho mọi nhu cầu'),
('Lenovo', 'Thương hiệu laptop Lenovo - Hiệu năng mạnh mẽ'),
('ASUS', 'Thương hiệu laptop ASUS - Gaming và đồ họa chuyên nghiệp'),
('Acer', 'Thương hiệu laptop Acer - Giá cả phải chăng'),
('MSI', 'Thương hiệu laptop MSI - Chuyên gaming cao cấp'),
('Apple', 'Thương hiệu MacBook - Sang trọng và hiệu năng vượt trội');

-- Thêm danh mục mẫu
INSERT INTO categories (category_name, slug, description) VALUES
('Laptop Gaming', 'laptop-gaming', 'Laptop dành cho game thủ với cấu hình mạnh'),
('Laptop Văn Phòng', 'laptop-van-phong', 'Laptop phù hợp cho công việc văn phòng'),
('Laptop Đồ Họa', 'laptop-do-hoa', 'Laptop chuyên đồ họa và thiết kế'),
('Laptop Mỏng Nhẹ', 'laptop-mong-nhe', 'Laptop siêu mỏng nhẹ, dễ mang theo'),
('MacBook', 'macbook', 'Dòng MacBook của Apple');

-- Thêm cấu hình hệ thống mẫu
INSERT INTO system_settings (setting_key, setting_value, setting_type, description) VALUES
('site_name', 'Laptop Store', 'string', 'Tên website'),
('shipping_fee', '30000', 'number', 'Phí vận chuyển mặc định'),
('free_shipping_threshold', '5000000', 'number', 'Giá trị đơn hàng miễn phí ship'),
('vnpay_enabled', 'true', 'boolean', 'Bật/tắt thanh toán VNPay'),
('hot_line', '1900-xxxx', 'string', 'Số hotline hỗ trợ');

-- =============================================
-- TRIGGERS
-- =============================================

-- Trigger cập nhật rating trung bình của sản phẩm
DELIMITER //
CREATE TRIGGER update_product_rating_after_review_insert
AFTER INSERT ON reviews
FOR EACH ROW
BEGIN
    UPDATE products p
    SET 
        average_rating = (
            SELECT AVG(rating) 
            FROM reviews 
            WHERE product_id = NEW.product_id AND is_approved = TRUE
        ),
        review_count = (
            SELECT COUNT(*) 
            FROM reviews 
            WHERE product_id = NEW.product_id AND is_approved = TRUE
        )
    WHERE p.product_id = NEW.product_id;
END//

CREATE TRIGGER update_product_rating_after_review_update
AFTER UPDATE ON reviews
FOR EACH ROW
BEGIN
    UPDATE products p
    SET 
        average_rating = (
            SELECT AVG(rating) 
            FROM reviews 
            WHERE product_id = NEW.product_id AND is_approved = TRUE
        ),
        review_count = (
            SELECT COUNT(*) 
            FROM reviews 
            WHERE product_id = NEW.product_id AND is_approved = TRUE
        )
    WHERE p.product_id = NEW.product_id;
END//

-- Trigger giảm số lượng tồn kho khi đơn hàng được xác nhận
CREATE TRIGGER decrease_stock_on_order_confirm
AFTER UPDATE ON orders
FOR EACH ROW
BEGIN
    IF NEW.order_status = 'confirmed' AND OLD.order_status != 'confirmed' THEN
        UPDATE products p
        INNER JOIN order_items oi ON p.product_id = oi.product_id
        SET p.stock_quantity = p.stock_quantity - oi.quantity,
            p.sold_count = p.sold_count + oi.quantity
        WHERE oi.order_id = NEW.order_id;
    END IF;
END//

-- Trigger tạo thông báo khi đơn hàng thay đổi trạng thái
CREATE TRIGGER notify_order_status_change
AFTER UPDATE ON orders
FOR EACH ROW
BEGIN
    IF NEW.order_status != OLD.order_status THEN
        INSERT INTO notifications (user_id, title, message, type, reference_id)
        VALUES (
            NEW.user_id,
            CONCAT('Đơn hàng #', NEW.order_code, ' đã thay đổi trạng thái'),
            CONCAT('Đơn hàng của bạn đã chuyển sang trạng thái: ', NEW.order_status),
            'order',
            NEW.order_id
        );
        
        INSERT INTO order_status_history (order_id, old_status, new_status)
        VALUES (NEW.order_id, OLD.order_status, NEW.order_status);
    END IF;
END//

DELIMITER ;

-- =============================================
-- VIEWS HỮU ÍCH
-- =============================================

-- View thống kê sản phẩm bán chạy
CREATE VIEW view_bestselling_products AS
SELECT 
    p.product_id,
    p.product_name,
    p.selling_price,
    p.sold_count,
    p.average_rating,
    b.brand_name,
    c.category_name
FROM products p
JOIN brands b ON p.brand_id = b.brand_id
JOIN categories c ON p.category_id = c.category_id
WHERE p.is_active = TRUE
ORDER BY p.sold_count DESC;

-- View thống kê doanh thu
CREATE VIEW view_revenue_statistics AS
SELECT 
    DATE(ordered_at) as order_date,
    COUNT(*) as total_orders,
    SUM(total_amount) as total_revenue,
    AVG(total_amount) as average_order_value,
    SUM(CASE WHEN payment_status = 'paid' THEN 1 ELSE 0 END) as paid_orders
FROM orders
WHERE order_status NOT IN ('cancelled', 'returned')
GROUP BY DATE(ordered_at);

-- =============================================
-- INDEXES BỔ SUNG ĐỂ TỐI ƯU PERFORMANCE
-- =============================================

-- Composite indexes cho các truy vấn phổ biến
CREATE INDEX idx_product_active_price ON products(is_active, selling_price);
CREATE INDEX idx_product_category_active ON products(category_id, is_active);
CREATE INDEX idx_order_user_status ON orders(user_id, order_status);
CREATE INDEX idx_notification_user_read ON notifications(user_id, is_read, created_at);
