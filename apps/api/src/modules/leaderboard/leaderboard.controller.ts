import { Controller, Get, Query, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import type { DecodedIdToken } from 'firebase-admin/auth';
import { LeaderboardService } from './leaderboard.service';
import { FirebaseAuthGuard } from '../../common/guards/firebase-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { LeaderboardQueryDto } from './dto/leaderboard-query.dto';

@ApiTags('leaderboard')
@ApiBearerAuth('firebase-token')
@UseGuards(FirebaseAuthGuard)
@Controller({ path: 'leaderboard', version: '2' })
export class LeaderboardController {
  constructor(private readonly service: LeaderboardService) {}

  @Get('daily')
  @ApiOperation({ summary: 'Top players today' })
  daily(@Query() q: LeaderboardQueryDto) {
    return this.service.getTop('daily', q.limit ?? 50);
  }

  @Get('weekly')
  @ApiOperation({ summary: 'Top players this week' })
  weekly(@Query() q: LeaderboardQueryDto) {
    return this.service.getTop('weekly', q.limit ?? 50);
  }

  @Get('monthly')
  @ApiOperation({ summary: 'Top players this month' })
  monthly(@Query() q: LeaderboardQueryDto) {
    return this.service.getTop('monthly', q.limit ?? 50);
  }

  @Get('me')
  @ApiOperation({ summary: 'My ranks across periods' })
  myRanks(@CurrentUser() user: DecodedIdToken) {
    return this.service.getMyRanks(user.uid);
  }
}
