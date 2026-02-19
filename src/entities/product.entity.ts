import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  OneToMany,
  JoinColumn,
  Index,
} from 'typeorm';
import { Brand } from './brand.entity';
import { Category } from './category.entity';
import { ProductImage } from './product-image.entity';
import { Review } from './review.entity';
import { Cart } from './cart.entity';
import { Wishlist } from './wishlist.entity';
import { OrderItem } from './order-item.entity';

@Entity('products')
export class Product {
  @PrimaryGeneratedColumn({ name: 'product_id' })
  productId: number;

  @Column({ name: 'product_name', length: 255 })
  productName: string;

  @Column({ unique: true, length: 300 })
  @Index()
  slug: string;

  @Column({ name: 'brand_id' })
  @Index()
  brandId: number;

  @Column({ name: 'category_id' })
  @Index()
  categoryId: number;

  @Column({ unique: true, length: 100 })
  sku: string;

  // Specifications
  @Column({ length: 255, nullable: true })
  cpu: string;

  @Column({ length: 100, nullable: true })
  ram: string;

  @Column({ length: 100, nullable: true })
  storage: string;

  @Column({ name: 'screen_size', length: 50, nullable: true })
  screenSize: string;

  @Column({ name: 'screen_resolution', length: 100, nullable: true })
  screenResolution: string;

  @Column({ name: 'graphics_card', length: 255, nullable: true })
  graphicsCard: string;

  @Column({ name: 'operating_system', length: 100, nullable: true })
  operatingSystem: string;

  @Column({ length: 50, nullable: true })
  weight: string;

  @Column({ length: 100, nullable: true })
  battery: string;

  @Column({ length: 100, nullable: true })
  color: string;

  // Price & Stock
  @Column({ name: 'original_price', type: 'decimal', precision: 15, scale: 2 })
  originalPrice: number;

  @Column({ name: 'selling_price', type: 'decimal', precision: 15, scale: 2 })
  @Index()
  sellingPrice: number;

  @Column({ name: 'stock_quantity', default: 0 })
  stockQuantity: number;

  // Description
  @Column({ name: 'short_description', type: 'text', nullable: true })
  shortDescription: string;

  @Column({ name: 'full_description', type: 'longtext', nullable: true })
  fullDescription: string;

  @Column({ type: 'json', nullable: true })
  specifications: any;

  // Status
  @Column({ name: 'is_active', default: true })
  isActive: boolean;

  @Column({ name: 'is_featured', default: false })
  isFeatured: boolean;

  // Statistics
  @Column({ name: 'view_count', default: 0 })
  viewCount: number;

  @Column({ name: 'sold_count', default: 0 })
  soldCount: number;

  @Column({ name: 'average_rating', type: 'decimal', precision: 3, scale: 2, default: 0 })
  averageRating: number;

  @Column({ name: 'review_count', default: 0 })
  reviewCount: number;

  @CreateDateColumn({ name: 'created_at' })
  @Index()
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;

  // Relations
  @ManyToOne(() => Brand, (brand) => brand.products, { onDelete: 'RESTRICT' })
  @JoinColumn({ name: 'brand_id' })
  brand: Brand;

  @ManyToOne(() => Category, (category) => category.products, {
    onDelete: 'RESTRICT',
  })
  @JoinColumn({ name: 'category_id' })
  category: Category;

  @OneToMany(() => ProductImage, (image) => image.product)
  images: ProductImage[];

  @OneToMany(() => Review, (review) => review.product)
  reviews: Review[];

  @OneToMany(() => Cart, (cart) => cart.product)
  cartItems: Cart[];

  @OneToMany(() => Wishlist, (wishlist) => wishlist.product)
  wishlistItems: Wishlist[];

  @OneToMany(() => OrderItem, (orderItem) => orderItem.product)
  orderItems: OrderItem[];
}
