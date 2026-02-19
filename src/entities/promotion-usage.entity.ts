import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
  Index,
} from 'typeorm';
import { Promotion } from './promotion.entity';
import { User } from './user.entity';

@Entity('promotion_usage')
@Index(['promotionId', 'userId'])
export class PromotionUsage {
  @PrimaryGeneratedColumn({ name: 'usage_id' })
  usageId: number;

  @Column({ name: 'promotion_id' })
  promotionId: number;

  @Column({ name: 'user_id' })
  userId: number;

  @Column({ name: 'order_id', nullable: true })
  orderId: number;

  @CreateDateColumn({ name: 'used_at' })
  usedAt: Date;

  // Relations
  @ManyToOne(() => Promotion, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'promotion_id' })
  promotion: Promotion;

  @ManyToOne(() => User, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'user_id' })
  user: User;
}
