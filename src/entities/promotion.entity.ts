import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  Index,
} from 'typeorm';

export enum DiscountType {
  PERCENTAGE = 'percentage',
  FIXED_AMOUNT = 'fixed_amount',
}

@Entity('promotions')
export class Promotion {
  @PrimaryGeneratedColumn({ name: 'promotion_id' })
  promotionId: number;

  @Column({ unique: true, length: 50 })
  @Index()
  code: string;

  @Column({ length: 255 })
  title: string;

  @Column({ type: 'text', nullable: true })
  description: string;

  @Column({ name: 'discount_type', type: 'enum', enum: DiscountType })
  discountType: DiscountType;

  @Column({ name: 'discount_value', type: 'decimal', precision: 15, scale: 2 })
  discountValue: number;

  @Column({
    name: 'min_order_value',
    type: 'decimal',
    precision: 15,
    scale: 2,
    default: 0,
  })
  minOrderValue: number;

  @Column({
    name: 'max_discount_amount',
    type: 'decimal',
    precision: 15,
    scale: 2,
    nullable: true,
  })
  maxDiscountAmount: number;

  @Column({ name: 'usage_limit', nullable: true })
  usageLimit: number;

  @Column({ name: 'usage_count', default: 0 })
  usageCount: number;

  @Column({ name: 'usage_per_customer', default: 1 })
  usagePerCustomer: number;

  @Column({ name: 'start_date', type: 'timestamp' })
  @Index()
  startDate: Date;

  @Column({ name: 'end_date', type: 'timestamp' })
  @Index()
  endDate: Date;

  @Column({ name: 'is_active', default: true })
  isActive: boolean;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;
}
