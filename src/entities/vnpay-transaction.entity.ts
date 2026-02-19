import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  JoinColumn,
  Index,
} from 'typeorm';
import { Order } from './order.entity';

export enum VNPayStatus {
  PENDING = 'pending',
  SUCCESS = 'success',
  FAILED = 'failed',
}

@Entity('vnpay_transactions')
export class VNPayTransaction {
  @PrimaryGeneratedColumn({ name: 'transaction_id' })
  transactionId: number;

  @Column({ name: 'order_id' })
  @Index()
  orderId: number;

  @Column({ name: 'vnp_txn_ref', unique: true, length: 100 })
  @Index()
  vnpTxnRef: string;

  @Column({ name: 'vnp_transaction_no', length: 100, nullable: true })
  vnpTransactionNo: string;

  @Column({ name: 'vnp_amount', type: 'bigint' })
  vnpAmount: number;

  @Column({ name: 'vnp_bank_code', length: 50, nullable: true })
  vnpBankCode: string;

  @Column({ name: 'vnp_card_type', length: 50, nullable: true })
  vnpCardType: string;

  @Column({ name: 'vnp_response_code', length: 10, nullable: true })
  vnpResponseCode: string;

  @Column({ name: 'vnp_transaction_status', length: 10, nullable: true })
  vnpTransactionStatus: string;

  @Column({ name: 'vnp_pay_date', length: 14, nullable: true })
  vnpPayDate: string;

  @Column({ name: 'vnp_secure_hash', length: 500, nullable: true })
  vnpSecureHash: string;

  @Column({ name: 'request_data', type: 'json', nullable: true })
  requestData: any;

  @Column({ name: 'response_data', type: 'json', nullable: true })
  responseData: any;

  @Column({ type: 'enum', enum: VNPayStatus, default: VNPayStatus.PENDING })
  status: VNPayStatus;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;

  // Relations
  @ManyToOne(() => Order, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'order_id' })
  order: Order;
}
