import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
  Index,
} from 'typeorm';
import { User } from './user.entity';

export enum NotificationType {
  ORDER = 'order',
  PROMOTION = 'promotion',
  SYSTEM = 'system',
  PRODUCT = 'product',
  OTHER = 'other',
}

@Entity('notifications')
export class Notification {
  @PrimaryGeneratedColumn({ name: 'notification_id' })
  notificationId: number;

  @Column({ name: 'user_id', nullable: true })
  @Index()
  userId: number;

  @Column({ length: 255 })
  title: string;

  @Column({ type: 'text' })
  message: string;

  @Column({ type: 'enum', enum: NotificationType, default: NotificationType.SYSTEM })
  type: NotificationType;

  @Column({ name: 'reference_id', nullable: true })
  referenceId: number;

  @Column({ name: 'link_url', length: 500, nullable: true })
  linkUrl: string;

  @Column({ name: 'is_read', default: false })
  @Index()
  isRead: boolean;

  @CreateDateColumn({ name: 'created_at' })
  @Index()
  createdAt: Date;

  // Relations
  @ManyToOne(() => User, (user) => user.notifications, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'user_id' })
  user: User;
}
