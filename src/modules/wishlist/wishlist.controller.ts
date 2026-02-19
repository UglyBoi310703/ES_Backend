import {
  Controller,
  Get,
  Post,
  Delete,
  Body,
  Param,
  UseGuards,
  ParseIntPipe,
} from '@nestjs/common';
import { WishlistService } from './wishlist.service';
import { AddToWishlistDto } from './dto/add-to-wishlist.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { User } from '../../entities/user.entity';

@Controller('wishlist')
@UseGuards(JwtAuthGuard)
export class WishlistController {
  constructor(private readonly wishlistService: WishlistService) {}

  @Get()
  async getWishlist(@CurrentUser() user: User) {
    return this.wishlistService.getWishlist(user.userId);
  }

  @Post('add')
  async addToWishlist(@CurrentUser() user: User, @Body() dto: AddToWishlistDto) {
    return this.wishlistService.addToWishlist(user.userId, dto.product_id);
  }

  @Delete(':id')
  async removeFromWishlist(@CurrentUser() user: User, @Param('id', ParseIntPipe) id: number) {
    return this.wishlistService.removeFromWishlist(user.userId, id);
  }

  @Get('check/:productId')
  async checkInWishlist(
    @CurrentUser() user: User,
    @Param('productId', ParseIntPipe) productId: number,
  ) {
    return this.wishlistService.checkInWishlist(user.userId, productId);
  }
}
