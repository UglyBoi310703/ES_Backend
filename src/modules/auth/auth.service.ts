import { Injectable, UnauthorizedException, ConflictException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from '../../entities/user.entity';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
import { hashPassword, comparePassword } from '../../common/utils/password.util';

@Injectable()
export class AuthService {
  constructor(
    @InjectRepository(User)
    private userRepository: Repository<User>,
    private jwtService: JwtService,
  ) {}

  async register(registerDto: RegisterDto) {
    const { email, password, full_name, phone } = registerDto;

    // Check if email exists
    const existingUser = await this.userRepository.findOne({ where: { email } });
    if (existingUser) {
      throw new ConflictException('Email đã được sử dụng');
    }

    // Hash password
    const passwordHash = await hashPassword(password);

    // Create user
    const user = this.userRepository.create({
      email,
      passwordHash,
      fullName: full_name,
      phone,
    });

    await this.userRepository.save(user);

    // Generate tokens
    const tokens = await this.generateTokens(user);

    return {
      message: 'Đăng ký thành công. Vui lòng kiểm tra email để xác thực tài khoản.',
      data: {
        user: this.sanitizeUser(user),
        ...tokens,
      },
    };
  }

  async login(loginDto: LoginDto) {
    const { email, password } = loginDto;

    // Find user
    const user = await this.userRepository.findOne({ where: { email } });
    if (!user || !user.isActive) {
      throw new UnauthorizedException('Email hoặc mật khẩu không đúng');
    }

    // Verify password
    const isPasswordValid = await comparePassword(password, user.passwordHash);
    if (!isPasswordValid) {
      throw new UnauthorizedException('Email hoặc mật khẩu không đúng');
    }

    // Update last login
    user.lastLogin = new Date();
    await this.userRepository.save(user);

    // Generate tokens
    const tokens = await this.generateTokens(user);

    return {
      message: 'Đăng nhập thành công',
      data: {
        user: this.sanitizeUser(user),
        ...tokens,
      },
    };
  }

  async validateUser(email: string, password: string): Promise<any> {
    const user = await this.userRepository.findOne({ where: { email } });
    if (user && (await comparePassword(password, user.passwordHash))) {
      return user;
    }
    return null;
  }

  async refreshToken(refreshToken: string) {
    try {
      const payload = this.jwtService.verify(refreshToken, {
        secret: process.env.JWT_REFRESH_SECRET,
      });

      const user = await this.userRepository.findOne({ where: { userId: payload.sub } });
      if (!user || !user.isActive) {
        throw new UnauthorizedException('Invalid refresh token');
      }

      const accessToken = this.jwtService.sign({
        sub: user.userId,
        email: user.email,
        role: user.role,
      });

      return {
        data: {
          access_token: accessToken,
          expires_in: parseInt(process.env.JWT_EXPIRES_IN || '3600'),
        },
      };
    } catch (error) {
      throw new UnauthorizedException('Invalid refresh token');
    }
  }

  async forgotPassword(email: string) {
    const user = await this.userRepository.findOne({ where: { email } });
    if (!user) {
      return { message: 'Email khôi phục mật khẩu đã được gửi' };
    }

    // TODO: Generate reset token and send email
    return { message: 'Email khôi phục mật khẩu đã được gửi' };
  }

  async resetPassword(token: string, newPassword: string) {
    // TODO: Verify reset token and update password
    return { message: 'Mật khẩu đã được cập nhật' };
  }

  async verifyEmail(token: string) {
    // TODO: Verify email token and activate account
    return { message: 'Email đã được xác thực' };
  }

  private async generateTokens(user: User) {
    const payload = { sub: user.userId, email: user.email, role: user.role };

    const accessToken = this.jwtService.sign(payload);

    const refreshToken = this.jwtService.sign(payload, {
      secret: process.env.JWT_REFRESH_SECRET,
      expiresIn: process.env.JWT_REFRESH_EXPIRES_IN || '7d',
    });

    return {
      access_token: accessToken,
      refresh_token: refreshToken,
      expires_in: parseInt(process.env.JWT_EXPIRES_IN || '3600'),
    };
  }

  private sanitizeUser(user: User) {
    const { passwordHash, ...sanitized } = user;
    return sanitized;
  }
}
