import { Body, Controller, Get, Post, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { Throttle } from '@nestjs/throttler';
import type { DecodedIdToken } from 'firebase-admin/auth';
import { AdsService } from './ads.service';
import { FirebaseAuthGuard } from '../../common/guards/firebase-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { RecordImpressionDto } from './dto/record-impression.dto';

@ApiTags('ads')
@ApiBearerAuth('firebase-token')
@UseGuards(FirebaseAuthGuard)
@Controller({ path: 'ads', version: '2' })
export class AdsController {
  constructor(private readonly service: AdsService) {}

  @Get('banners/active')
  @ApiOperation({ summary: 'Get currently active sponsor banners' })
  active() {
    return this.service.getActiveBanners();
  }

  @Post('impression')
  @Throttle({ default: { limit: 120, ttl: 60_000 } })
  @ApiOperation({ summary: 'Record a banner impression or click' })
  impression(@CurrentUser() user: DecodedIdToken, @Body() body: RecordImpressionDto) {
    return this.service.recordImpression(user.uid, body);
  }
}
