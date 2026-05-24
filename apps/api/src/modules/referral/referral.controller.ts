import { Body, Controller, Get, Post, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { Throttle } from '@nestjs/throttler';
import type { DecodedIdToken } from 'firebase-admin/auth';
import { ReferralService } from './referral.service';
import { FirebaseAuthGuard } from '../../common/guards/firebase-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { ApplyReferralDto } from './dto/apply-referral.dto';

@ApiTags('referral')
@ApiBearerAuth('firebase-token')
@UseGuards(FirebaseAuthGuard)
@Controller({ path: 'referral', version: '2' })
export class ReferralController {
  constructor(private readonly service: ReferralService) {}

  @Get('me')
  @ApiOperation({ summary: 'Get my referral code and stats' })
  me(@CurrentUser() user: DecodedIdToken) {
    return this.service.getMyCode(user.uid);
  }

  @Post('apply')
  @Throttle({ default: { limit: 5, ttl: 60_000 } })
  @ApiOperation({ summary: 'Apply a referrer code (one-shot, at signup)' })
  apply(@CurrentUser() user: DecodedIdToken, @Body() body: ApplyReferralDto) {
    return this.service.applyCode(user.uid, body);
  }
}
