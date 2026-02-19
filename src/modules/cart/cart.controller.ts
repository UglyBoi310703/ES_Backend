import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Body,
  Param,
  UseGuards,
  ParseIntPipe,
} from '@nestjs/common';
import { CartService } from './cart.service';
import { AddToCartDto } from './dto/add-to-cart.dto';
import { UpdateCartDto } from './dto/update-cart.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { User } from '../../entities/user.entity';

@Controller('cart')
@UseGuards(JwtAuthGuard)
export class CartController {
  constructor(private readonly cartService: CartService) {}

  @Get()
  async getCart(@CurrentUser() user: User) {
    return this.cartService.getCart(user.userId);
  }

  @Post('add')
  async addToCart(@CurrentUser() user: User, @Body() addToCartDto: AddToCartDto) {
    return this.cartService.addToCart(user.userId, addToCartDto);
  }

  @Put(':id')
  async updateQuantity(
    @CurrentUser() user: User,
    @Param('id', ParseIntPipe) id: number,
    @Body() updateDto: UpdateCartDto,
  ) {
    return this.cartService.updateQuantity(user.userId, id, updateDto);
  }

  @Delete(':id')
  async removeItem(@CurrentUser() user: User, @Param('id', ParseIntPipe) id: number) {
    return this.cartService.removeItem(user.userId, id);
  }

  @Delete('clear')
  async clearCart(@CurrentUser() user: User) {
    return this.cartService.clearCart(user.userId);
  }
}
