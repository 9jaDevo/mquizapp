import { Controller, Get, Post, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { Throttle } from '@nestjs/throttler';
import type { DecodedIdToken } from 'firebase-admin/auth';
import { LivesService } from './lives.service';
import { FirebaseAuthGuard } from '../../common/guards/firebase-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';

@ApiTags('lives')
@ApiBearerAuth('firebase-token')
@UseGuards(FirebaseAuthGuard)
@Controller({ path: 'lives', version: '2' })
export class LivesController {
  constructor(private readonly service: LivesService) {}

  @Get('me')
  @ApiOperation({ summary: 'Get my current lives state' })
  me(@CurrentUser() user: DecodedIdToken) {
    return this.service.getMyLives(user.uid);
  }

  @Post('consume')
  @Throttle({ default: { limit: 60, ttl: 60_000 } })
  @ApiOperation({ summary: 'Consume one life (server-authoritative)' })
  consume(@CurrentUser() user: DecodedIdToken) {
    return this.service.consumeLife(user.uid);
  }

  @Post('restore-with-coins')
  @Throttle({ default: { limit: 10, ttl: 60_000 } })
  @ApiOperation({ summary: 'Spend coins to refill lives' })
  restoreCoins(@CurrentUser() user: DecodedIdToken) {
    return this.service.restoreWithCoins(user.uid);
  }

  @Post('restore-with-ad')
  @Throttle({ default: { limit: 10, ttl: 60_000 } })
  @ApiOperation({ summary: 'Award one life after a rewarded ad' })
  restoreAd(@CurrentUser() user: DecodedIdToken) {
    return this.service.restoreWithAd(user.uid);
  }
}
