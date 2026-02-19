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
import { Review } from './review.entity';
import { User } from './user.entity';

@Entity('review_helpful')
@Unique(['reviewId', 'userId'])
export class ReviewHelpful {
  @PrimaryGeneratedColumn({ name: 'helpful_id' })
  helpfulId: number;

  @Column({ name: 'review_id' })
  @Index()
  reviewId: number;

  @Column({ name: 'user_id' })
  userId: number;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  // Relations
  @ManyToOne(() => Review, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'review_id' })
  review: Review;

  @ManyToOne(() => User, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'user_id' })
  user: User;
}
