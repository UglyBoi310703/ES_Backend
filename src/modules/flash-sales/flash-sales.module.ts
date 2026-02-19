import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Flash-salesController } from './flash-sales.controller';
import { Flash-salesService } from './flash-sales.service';

@Module({
  imports: [TypeOrmModule.forFeature([])],
  controllers: [Flash-salesController],
  providers: [Flash-salesService],
  exports: [Flash-salesService],
})
export class Flash-salesModule {}
