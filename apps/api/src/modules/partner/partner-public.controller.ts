import {
  Body,
  Controller,
  Get,
  HttpCode,
  Param,
  ParseIntPipe,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { Throttle } from '@nestjs/throttler';
import { PartnerService } from './partner.service';
import { FirebaseAuthGuard } from '../../common/guards/firebase-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { SubmitPartnerContestDto, JoinWithCodeDto } from './dto/submit-partner-contest.dto';
import type { DecodedIdToken } from 'firebase-admin/auth';

/**
 * Public endpoints for mQuiz mobile users to discover and participate
 * in partner-hosted contests. Uses standard FirebaseAuthGuard (not PartnerAuthGuard).
 */
@ApiTags('partner-contests-public')
@ApiBearerAuth('firebase-token')
@UseGuards(FirebaseAuthGuard)
@Throttle({ default: { limit: 60, ttl: 60_000 } })
@Controller({ path: 'contests/partner', version: '2' })
export class PartnerPublicController {
  constructor(private readonly service: PartnerService) {}

  @Get()
  @ApiOperation({ summary: 'List public partner contests' })
  listPublic(
    @Query('search') search?: string,
    @Query('status') status?: string,
    @Query('page') page?: string,
    @Query('limit') limit?: string,
  ) {
    return this.service.listPublicContests(search, status, parseInt(page ?? '1'), parseInt(limit ?? '20'));
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get partner contest detail' })
  getContest(
    @Param('id', ParseIntPipe) id: number,
    @CurrentUser() user: DecodedIdToken,
  ) {
    // We need the DB userId to check isParticipated
    // Pass uid; service will resolve to numeric userId via prisma lookup
    return this.service.getPublicContestByFirebaseUid(id, user.uid);
  }

  @Post('join-code')
  @HttpCode(200)
  @ApiOperation({ summary: 'Look up a contest by invite code' })
  joinWithCode(@Body() dto: JoinWithCodeDto) {
    return this.service.lookupByCode(dto.code);
  }

  @Post(':id/join')
  @HttpCode(200)
  @ApiOperation({ summary: 'Join a partner contest' })
  join(
    @Param('id', ParseIntPipe) id: number,
    @CurrentUser() user: DecodedIdToken,
  ) {
    return this.service.joinContestByFirebaseUid(id, user.uid);
  }

  @Get(':id/questions')
  @ApiOperation({ summary: 'Get contest questions (requires participation)' })
  getQuestions(
    @Param('id', ParseIntPipe) id: number,
    @CurrentUser() user: DecodedIdToken,
  ) {
    return this.service.getQuestionsForFirebaseUid(id, user.uid);
  }

  @Post(':id/submit')
  @HttpCode(200)
  @ApiOperation({ summary: 'Submit answers for a partner contest' })
  submit(
    @Param('id', ParseIntPipe) id: number,
    @CurrentUser() user: DecodedIdToken,
    @Body() dto: SubmitPartnerContestDto,
  ) {
    return this.service.submitContestByFirebaseUid(id, user.uid, dto);
  }

  @Get(':id/leaderboard')
  @ApiOperation({ summary: 'Public leaderboard for a partner contest' })
  leaderboard(@Param('id', ParseIntPipe) id: number) {
    return this.service.getPublicLeaderboard(id);
  }
}
