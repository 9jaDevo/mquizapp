import {
  Body,
  Controller,
  Get,
  Param,
  ParseIntPipe,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { Throttle } from '@nestjs/throttler';
import type { DecodedIdToken } from 'firebase-admin/auth';
import { LeagueService } from './league.service';
import { FirebaseAuthGuard } from '../../common/guards/firebase-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { SubmitDailyQuizDto } from './dto/submit-daily-quiz.dto';
import { LeaderboardQueryDto } from '../leaderboard/dto/leaderboard-query.dto';

@ApiTags('league')
@ApiBearerAuth('firebase-token')
@UseGuards(FirebaseAuthGuard)
@Controller({ path: 'leagues', version: '2' })
export class LeagueController {
  constructor(private readonly service: LeagueService) {}

  @Get()
  @ApiOperation({ summary: 'List active leagues' })
  list() {
    return this.service.listActive();
  }

  @Get('me')
  @ApiOperation({ summary: 'My league memberships' })
  myLeagues(@CurrentUser() user: DecodedIdToken) {
    return this.service.myLeagues(user.uid);
  }

  @Get(':id')
  @ApiOperation({ summary: 'League details' })
  detail(@Param('id', ParseIntPipe) id: number) {
    return this.service.getLeague(id);
  }

  @Post(':id/opt-in')
  @Throttle({ default: { limit: 10, ttl: 60_000 } })
  @ApiOperation({ summary: 'Opt in to a league (free) or join (paid)' })
  optIn(@CurrentUser() user: DecodedIdToken, @Param('id', ParseIntPipe) id: number) {
    return this.service.optIn(user.uid, id);
  }

  @Get(':id/today')
  @ApiOperation({ summary: "Get today's daily quiz for the league" })
  today(@Param('id', ParseIntPipe) id: number) {
    return this.service.getTodayQuiz(id);
  }

  @Post(':id/submit')
  @Throttle({ default: { limit: 5, ttl: 60_000 } })
  @ApiOperation({ summary: "Submit today's quiz answers" })
  submit(
    @CurrentUser() user: DecodedIdToken,
    @Param('id', ParseIntPipe) id: number,
    @Body() body: SubmitDailyQuizDto,
  ) {
    return this.service.submitDailyQuiz(user.uid, id, body);
  }

  @Get(':id/leaderboard')
  @ApiOperation({ summary: 'League leaderboard (cached)' })
  leaderboard(
    @Param('id', ParseIntPipe) id: number,
    @Query() q: LeaderboardQueryDto,
  ) {
    return this.service.getLeaderboard(id, q.limit ?? 50);
  }
}
