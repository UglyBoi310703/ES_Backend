import {
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
