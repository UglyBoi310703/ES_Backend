import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
  Index,
} from 'typeorm';
import { Order } from './order.entity';
import { Product } from './product.entity';

@Entity('order_items')
export class OrderItem {
  @PrimaryGeneratedColumn({ name: 'order_item_id' })
  orderItemId: number;

  @Column({ name: 'order_id' })
  @Index()
  orderId: number;

  @Column({ name: 'product_id' })
  productId: number;

  @Column({ name: 'product_name', length: 255 })
  productName: string;

  @Column({ name: 'product_image', length: 500, nullable: true })
  productImage: string;

  @Column({ length: 100, nullable: true })
  sku: string;

  @Column()
  quantity: number;

  @Column({ name: 'unit_price', type: 'decimal', precision: 15, scale: 2 })
  unitPrice: number;

  @Column({ name: 'discount_amount', type: 'decimal', precision: 15, scale: 2, default: 0 })
  discountAmount: number;

  @Column({ name: 'total_price', type: 'decimal', precision: 15, scale: 2 })
  totalPrice: number;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  // Relations
  @ManyToOne(() => Order, (order) => order.items, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'order_id' })
  order: Order;

  @ManyToOne(() => Product, (product) => product.orderItems, {
    onDelete: 'RESTRICT',
  })
  @JoinColumn({ name: 'product_id' })
  product: Product;
}
