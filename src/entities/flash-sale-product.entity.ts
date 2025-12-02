import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
  Index,
  Unique,
} from 'typeorm';
import { FlashSale } from './flash-sale.entity';
import { Product } from './product.entity';

@Entity('flash_sale_products')
@Unique(['flashSaleId', 'productId'])
export class FlashSaleProduct {
  @PrimaryGeneratedColumn({ name: 'flash_sale_product_id' })
  flashSaleProductId: number;

  @Column({ name: 'flash_sale_id' })
  @Index()
  flashSaleId: number;

  @Column({ name: 'product_id' })
  @Index()
  productId: number;

  @Column({ name: 'flash_price', type: 'decimal', precision: 15, scale: 2 })
  flashPrice: number;

  @Column({ name: 'quantity_limit' })
  quantityLimit: number;

  @Column({ name: 'quantity_sold', default: 0 })
  quantitySold: number;

  @Column({ name: 'max_per_customer', default: 1 })
  maxPerCustomer: number;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  // Relations
  @ManyToOne(() => FlashSale, (flashSale) => flashSale.products, {
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'flash_sale_id' })
  flashSale: FlashSale;

  @ManyToOne(() => Product, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'product_id' })
  product: Product;
}
