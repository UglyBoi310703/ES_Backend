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
import { User } from './user.entity';
import { Product } from './product.entity';

@Entity('wishlist')
@Unique(['userId', 'productId'])
export class Wishlist {
  @PrimaryGeneratedColumn({ name: 'wishlist_id' })
  wishlistId: number;

  @Column({ name: 'user_id' })
  @Index()
  userId: number;

  @Column({ name: 'product_id' })
  productId: number;

  @CreateDateColumn({ name: 'added_at' })
  addedAt: Date;

  // Relations
  @ManyToOne(() => User, (user) => user.wishlistItems, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'user_id' })
  user: User;

  @ManyToOne(() => Product, (product) => product.wishlistItems, {
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'product_id' })
  product: Product;
}
