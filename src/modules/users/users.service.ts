import { Injectable, NotFoundException, UnauthorizedException } from '@nestjs/common';
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
