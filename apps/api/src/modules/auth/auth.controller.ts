import { Body, Controller, Headers, HttpCode, Post } from '@nestjs/common';
import { Throttle } from '@nestjs/throttler';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { AuthService } from './auth.service';
import { Public } from '../../common/decorators/public.decorator';
import { LoginDto } from './dto/login.dto';
import { GuestDto } from './dto/guest.dto';

@ApiTags('auth')
@Controller({ path: 'auth', version: '2' })
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Public()
  @Post('login')
  @HttpCode(200)
  @Throttle({ default: { limit: 20, ttl: 60_000 } })
  @ApiBearerAuth('firebase-token')
  @ApiOperation({ summary: 'Verify Firebase token and upsert user record' })
  async login(@Headers('authorization') authHeader: string | undefined, @Body() body: LoginDto) {
    const token = extractBearer(authHeader);
    return this.authService.loginWithFirebaseToken(token, body);
  }

  @Public()
  @Post('guest')
  @HttpCode(201)
  @Throttle({ default: { limit: 10, ttl: 60_000 } })
  @ApiOperation({ summary: 'Create an anonymous guest session' })
  async guest(@Body() body: GuestDto) {
    return this.authService.createGuest(body);
  }

  @Public()
  @Post('refresh-token')
  @HttpCode(200)
  @Throttle({ default: { limit: 30, ttl: 60_000 } })
  @ApiBearerAuth('firebase-token')
  @ApiOperation({ summary: 'Verify a Firebase token is still valid' })
  async refresh(@Headers('authorization') authHeader: string | undefined) {
    const token = extractBearer(authHeader);
    return this.authService.refresh(token);
  }
}

function extractBearer(header: string | undefined): string {
  if (!header || !header.startsWith('Bearer ')) {
    throw new (require('@nestjs/common').UnauthorizedException)({
      error: 'AUTH_MISSING_TOKEN',
      message: 'Missing or malformed Authorization header',
    });
  }
  return header.slice(7).trim();
}
