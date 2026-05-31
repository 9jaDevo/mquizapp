import { Body, Controller, Get, HttpCode, Post, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { Throttle } from '@nestjs/throttler';
import { PartnerService } from './partner.service';
import { RegisterPartnerDto } from './dto/register-partner.dto';
import { PartnerAuthGuard } from '../../common/guards/partner-auth.guard';
import { CurrentPartner, PartnerPrincipal } from '../../common/decorators/current-partner.decorator';
import { FirebaseAuthGuard } from '../../common/guards/firebase-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import type { DecodedIdToken } from 'firebase-admin/auth';

@ApiTags('partner-auth')
@Controller({ path: 'partner/auth', version: '2' })
export class PartnerAuthController {
  constructor(private readonly service: PartnerService) {}

  @Post('register')
  @HttpCode(201)
  @Throttle({ default: { limit: 5, ttl: 3_600_000 } })
  @ApiOperation({ summary: 'Register a new partner organisation (Free plan, auto-approved)' })
  register(@Body() dto: RegisterPartnerDto) {
    return this.service.register(dto);
  }

  /**
   * Mobile/web clients call this with a standard Firebase ID token (from
   * email+password sign-in). The server looks up the partner, verifies status,
   * then returns a CUSTOM token carrying {partnerId, partnerRole} claims.
   * The client then exchanges the custom token for a new Firebase ID token and
   * uses that ID token on all subsequent PartnerAuthGuard-protected routes.
   */
  @Post('login')
  @HttpCode(200)
  @Throttle({ default: { limit: 10, ttl: 60_000 } })
  @UseGuards(FirebaseAuthGuard)
  @ApiBearerAuth('firebase-token')
  @ApiOperation({ summary: 'Partner login — returns Firebase custom token with partner claims' })
  login(@CurrentUser() user: DecodedIdToken) {
    return this.service.login(user.uid);
  }

  @Get('me')
  @UseGuards(PartnerAuthGuard)
  @ApiBearerAuth('firebase-token')
  @ApiOperation({ summary: 'Return current partner identity from token' })
  me(@CurrentPartner() p: PartnerPrincipal) {
    return { partnerId: p.partnerId, partnerRole: p.partnerRole };
  }
}
