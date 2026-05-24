import { Controller, Get, Post, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import type { DecodedIdToken } from 'firebase-admin/auth';
import { StreakService } from './streak.service';
import { FirebaseAuthGuard } from '../../common/guards/firebase-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';

@ApiTags('streak')
@ApiBearerAuth('firebase-token')
@UseGuards(FirebaseAuthGuard)
@Controller({ path: 'streak', version: '2' })
export class StreakController {
  constructor(private readonly service: StreakService) {}

  @Get('me')
  @ApiOperation({ summary: 'Get my current daily streak' })
  me(@CurrentUser() user: DecodedIdToken) {
    return this.service.getMyStreak(user.uid);
  }

  @Post('claim-daily')
  @ApiOperation({ summary: 'Claim today login streak and award coins if eligible' })
  claim(@CurrentUser() user: DecodedIdToken) {
    return this.service.claimDailyLogin(user.uid);
  }
}
