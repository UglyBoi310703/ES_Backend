import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  OneToMany,
  Index,
} from 'typeorm';
import { FlashSaleProduct } from './flash-sale-product.entity';

@Entity('flash_sales')
export class FlashSale {
  @PrimaryGeneratedColumn({ name: 'flash_sale_id' })
  flashSaleId: number;

  @Column({ length: 255 })
  title: string;

  @Column({ type: 'text', nullable: true })
  description: string;

  @Column({ name: 'start_time', type: 'timestamp' })
  @Index()
  startTime: Date;

  @Column({ name: 'end_time', type: 'timestamp' })
  @Index()
  endTime: Date;

  @Column({ name: 'is_active', default: true })
  @Index()
  isActive: boolean;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;

  // Relations
  @OneToMany(() => FlashSaleProduct, (flashSaleProduct) => flashSaleProduct.flashSale)
  products: FlashSaleProduct[];
}
