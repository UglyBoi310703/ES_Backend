import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, IsNull } from 'typeorm';
import { Category } from '../../entities/category.entity';

@Injectable()
export class CategoriesService {
  constructor(
    @InjectRepository(Category)
    private categoryRepository: Repository<Category>,
  ) {}

  async findAll(includeChildren = false) {
    const categories = await this.categoryRepository.find({
      where: { parentId: IsNull(), isActive: true },
      relations: includeChildren ? ['children'] : [],
      order: { displayOrder: 'ASC', categoryName: 'ASC' },
    });

    return { data: categories };
  }

  async findBySlug(slug: string) {
    const category = await this.categoryRepository.findOne({
      where: { slug, isActive: true },
      relations: ['children', 'parent'],
    });

    if (!category) {
      throw new NotFoundException('Danh mục không tồn tại');
    }

    return { data: category };
  }
}
