import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Brand } from '../../entities/brand.entity';

@Injectable()
export class BrandsService {
  constructor(
    @InjectRepository(Brand)
    private brandRepository: Repository<Brand>,
  ) {}

  async findAll() {
    const brands = await this.brandRepository.find({
      where: { isActive: true },
      order: { brandName: 'ASC' },
    });

    return { data: brands };
  }

  async findBySlug(slug: string) {
    const brand = await this.brandRepository.findOne({
      where: { brandName: slug, isActive: true },
    });

    if (!brand) {
      throw new NotFoundException('Thương hiệu không tồn tại');
    }

    return { data: brand };
  }
}
