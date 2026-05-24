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
import { ContestService } from './contest.service';
import { FirebaseAuthGuard } from '../../common/guards/firebase-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { SubmitContestDto } from './dto/submit-contest.dto';
import { LeaderboardQueryDto } from '../leaderboard/dto/leaderboard-query.dto';

@ApiTags('contest')
@ApiBearerAuth('firebase-token')
@UseGuards(FirebaseAuthGuard)
@Controller({ path: 'contests', version: '2' })
export class ContestController {
  constructor(private readonly service: ContestService) {}

  @Get()
  @ApiOperation({ summary: 'List active contests' })
  list() {
    return this.service.listActive();
  }

  @Get(':id/questions')
  @ApiOperation({ summary: "Get contest questions (answers stripped)" })
  questions(@Param('id', ParseIntPipe) id: number) {
    return this.service.getQuestions(id);
  }

  @Post(':id/submit')
  @Throttle({ default: { limit: 5, ttl: 60_000 } })
  @ApiOperation({ summary: 'Submit contest answers' })
  submit(
    @CurrentUser() user: DecodedIdToken,
    @Param('id', ParseIntPipe) id: number,
    @Body() body: SubmitContestDto,
  ) {
    return this.service.submit(user.uid, id, body);
  }

  @Get(':id/leaderboard')
  @ApiOperation({ summary: 'Contest leaderboard' })
  leaderboard(
    @Param('id', ParseIntPipe) id: number,
    @Query() q: LeaderboardQueryDto,
  ) {
    return this.service.getLeaderboard(id, q.limit ?? 50);
  }
}
