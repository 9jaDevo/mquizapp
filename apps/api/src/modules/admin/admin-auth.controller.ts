import { Body, Controller, HttpCode, HttpStatus, Post, UnauthorizedException } from '@nestjs/common';
import { Throttle } from '@nestjs/throttler';
import { AdminService } from './admin.service';
import { AdminLoginDto } from './dto/admin-login.dto';

/**
 * Public authentication endpoint for tbl_authenticate admin users.
 * No FirebaseAuthGuard — uses bcrypt password verification against the DB.
 * Strictly rate-limited to prevent brute-force attacks.
 */
@Controller({ path: 'admin/auth', version: '2' })
export class AdminAuthController {
  constructor(private readonly service: AdminService) {}

  @Post('login')
  @HttpCode(HttpStatus.OK)
  // 5 login attempts per 5 minutes per IP — strict anti-brute-force
  @Throttle({ default: { ttl: 300_000, limit: 5 } })
  async login(@Body() body: AdminLoginDto) {
    const admin = await this.service.verifyAdminCredentials(body);
    if (!admin) throw new UnauthorizedException('Invalid credentials');
    return { success: true, data: admin, message: 'Login successful' };
  }
}
