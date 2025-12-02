#!/usr/bin/env python3
"""
Script to generate complete implementations for all important modules
"""

import os

# Users Module DTOs
users_dtos = {
    "update-profile.dto.ts": """import { IsString, IsOptional, Matches } from 'class-validator';

export class UpdateProfileDto {
  @IsOptional()
  @IsString()
  full_name?: string;

  @IsOptional()
  @IsString()
  @Matches(/^[0-9]{10,11}$/, { message: 'Số điện thoại không hợp lệ' })
  phone?: string;

  @IsOptional()
  @IsString()
  avatar_url?: string;
}
""",

    "change-password.dto.ts": """import { IsString, MinLength } from 'class-validator';

export class ChangePasswordDto {
  @IsString()
  current_password: string;

  @IsString()
  @MinLength(6)
  new_password: string;
}
""",

    "create-address.dto.ts": """import { IsString, IsBoolean, IsOptional, Matches } from 'class-validator';

export class CreateAddressDto {
  @IsString()
  recipient_name: string;

  @IsString()
  @Matches(/^[0-9]{10,11}$/)
  phone: string;

  @IsString()
  province: string;

  @IsString()
  district: string;

  @IsString()
  ward: string;

  @IsString()
  detail_address: string;

  @IsOptional()
  @IsBoolean()
  is_default?: boolean;
}
""",
}

# Users Service
users_service = """import { Injectable, NotFoundException, UnauthorizedException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from '../../entities/user.entity';
import { Address } from '../../entities/address.entity';
import { UpdateProfileDto } from './dto/update-profile.dto';
import { ChangePasswordDto } from './dto/change-password.dto';
import { CreateAddressDto } from './dto/create-address.dto';
import { hashPassword, comparePassword } from '../../common/utils/password.util';

@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(User)
    private userRepository: Repository<User>,
    @InjectRepository(Address)
    private addressRepository: Repository<Address>,
  ) {}

  async getProfile(userId: number) {
    const user = await this.userRepository.findOne({
      where: { userId },
      select: [
        'userId',
        'email',
        'fullName',
        'phone',
        'avatarUrl',
        'role',
        'emailVerified',
        'createdAt',
        'lastLogin',
      ],
    });

    if (!user) {
      throw new NotFoundException('Người dùng không tồn tại');
    }

    return { data: user };
  }

  async updateProfile(userId: number, updateDto: UpdateProfileDto) {
    await this.userRepository.update(userId, {
      fullName: updateDto.full_name,
      phone: updateDto.phone,
      avatarUrl: updateDto.avatar_url,
    });

    return { message: 'Cập nhật thông tin thành công' };
  }

  async changePassword(userId: number, changePasswordDto: ChangePasswordDto) {
    const user = await this.userRepository.findOne({ where: { userId } });

    if (!user) {
      throw new NotFoundException('Người dùng không tồn tại');
    }

    const isValid = await comparePassword(
      changePasswordDto.current_password,
      user.passwordHash,
    );

    if (!isValid) {
      throw new UnauthorizedException('Mật khẩu hiện tại không đúng');
    }

    user.passwordHash = await hashPassword(changePasswordDto.new_password);
    await this.userRepository.save(user);

    return { message: 'Đổi mật khẩu thành công' };
  }

  async getAddresses(userId: number) {
    const addresses = await this.addressRepository.find({
      where: { userId },
      order: { isDefault: 'DESC', createdAt: 'DESC' },
    });

    return { data: addresses };
  }

  async createAddress(userId: number, createDto: CreateAddressDto) {
    if (createDto.is_default) {
      await this.addressRepository.update({ userId }, { isDefault: false });
    }

    const address = this.addressRepository.create({
      userId,
      recipientName: createDto.recipient_name,
      phone: createDto.phone,
      province: createDto.province,
      district: createDto.district,
      ward: createDto.ward,
      detailAddress: createDto.detail_address,
      isDefault: createDto.is_default || false,
    });

    await this.addressRepository.save(address);

    return {
      message: 'Thêm địa chỉ thành công',
      data: address,
    };
  }

  async updateAddress(userId: number, addressId: number, updateDto: Partial<CreateAddressDto>) {
    const address = await this.addressRepository.findOne({
      where: { addressId, userId },
    });

    if (!address) {
      throw new NotFoundException('Địa chỉ không tồn tại');
    }

    if (updateDto.is_default) {
      await this.addressRepository.update({ userId }, { isDefault: false });
    }

    Object.assign(address, updateDto);
    await this.addressRepository.save(address);

    return { message: 'Cập nhật địa chỉ thành công' };
  }

  async deleteAddress(userId: number, addressId: number) {
    const result = await this.addressRepository.delete({ addressId, userId });

    if (result.affected === 0) {
      throw new NotFoundException('Địa chỉ không tồn tại');
    }

    return { message: 'Xóa địa chỉ thành công' };
  }

  async setDefaultAddress(userId: number, addressId: number) {
    const address = await this.addressRepository.findOne({
      where: { addressId, userId },
    });

    if (!address) {
      throw new NotFoundException('Địa chỉ không tồn tại');
    }

    await this.addressRepository.update({ userId }, { isDefault: false });
    address.isDefault = true;
    await this.addressRepository.save(address);

    return { message: 'Đã đặt làm địa chỉ mặc định' };
  }
}
"""

# Users Controller
users_controller = """import {
  Controller,
  Get,
  Put,
  Post,
  Delete,
  Body,
  Param,
  UseGuards,
  ParseIntPipe,
} from '@nestjs/common';
import { UsersService } from './users.service';
import { UpdateProfileDto } from './dto/update-profile.dto';
import { ChangePasswordDto } from './dto/change-password.dto';
import { CreateAddressDto } from './dto/create-address.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { User } from '../../entities/user.entity';

@Controller('users')
@UseGuards(JwtAuthGuard)
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get('profile')
  async getProfile(@CurrentUser() user: User) {
    return this.usersService.getProfile(user.userId);
  }

  @Put('profile')
  async updateProfile(@CurrentUser() user: User, @Body() updateDto: UpdateProfileDto) {
    return this.usersService.updateProfile(user.userId, updateDto);
  }

  @Post('change-password')
  async changePassword(@CurrentUser() user: User, @Body() changePasswordDto: ChangePasswordDto) {
    return this.usersService.changePassword(user.userId, changePasswordDto);
  }

  @Get('addresses')
  async getAddresses(@CurrentUser() user: User) {
    return this.usersService.getAddresses(user.userId);
  }

  @Post('addresses')
  async createAddress(@CurrentUser() user: User, @Body() createDto: CreateAddressDto) {
    return this.usersService.createAddress(user.userId, createDto);
  }

  @Put('addresses/:id')
  async updateAddress(
    @CurrentUser() user: User,
    @Param('id', ParseIntPipe) id: number,
    @Body() updateDto: Partial<CreateAddressDto>,
  ) {
    return this.usersService.updateAddress(user.userId, id, updateDto);
  }

  @Delete('addresses/:id')
  async deleteAddress(@CurrentUser() user: User, @Param('id', ParseIntPipe) id: number) {
    return this.usersService.deleteAddress(user.userId, id);
  }

  @Put('addresses/:id/set-default')
  async setDefaultAddress(@CurrentUser() user: User, @Param('id', ParseIntPipe) id: number) {
    return this.usersService.setDefaultAddress(user.userId, id);
  }
}
"""

# Users Module
users_module = """import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { UsersController } from './users.controller';
import { UsersService } from './users.service';
import { User } from '../../entities/user.entity';
import { Address } from '../../entities/address.entity';

@Module({
  imports: [TypeOrmModule.forFeature([User, Address])],
  controllers: [UsersController],
  providers: [UsersService],
  exports: [UsersService],
})
export class UsersModule {}
"""

# Write files
def create_file(path, content):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f"✅ Created: {path}")

# Create Users Module
print("📦 Generating Users Module...")
for filename, content in users_dtos.items():
    create_file(f"src/modules/users/dto/{filename}", content)

create_file("src/modules/users/users.service.ts", users_service)
create_file("src/modules/users/users.controller.ts", users_controller)
create_file("src/modules/users/users.module.ts", users_module)

print("\\n🎉 Users Module generated successfully!")
