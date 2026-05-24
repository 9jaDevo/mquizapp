import { Body, Controller, DefaultValuePipe, Get, ParseIntPipe, Post, Query, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { Throttle } from '@nestjs/throttler';
import type { DecodedIdToken } from 'firebase-admin/auth';
import { QuizService } from './quiz.service';
import { FirebaseAuthGuard } from '../../common/guards/firebase-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { FetchQuestionsQueryDto } from './dto/fetch-questions-query.dto';
import { SubmitQuizDto } from './dto/submit-quiz.dto';

@ApiTags('quiz')
@ApiBearerAuth('firebase-token')
@UseGuards(FirebaseAuthGuard)
@Controller({ path: 'quiz', version: '2' })
export class QuizController {
  constructor(private readonly service: QuizService) {}

  @Get('questions')
  @ApiOperation({ summary: 'Fetch questions for a quiz session (answers stripped)' })
  fetchQuestions(@CurrentUser() user: DecodedIdToken, @Query() q: FetchQuestionsQueryDto) {
    return this.service.fetchQuestions(user.uid, q);
  }

  @Post('submit')
  @Throttle({ default: { limit: 30, ttl: 60_000 } })
  @ApiOperation({ summary: 'Submit answers and receive scored results' })
  submit(@CurrentUser() user: DecodedIdToken, @Body() body: SubmitQuizDto) {
    return this.service.submitAnswers(user.uid, body);
  }

  @Get('daily-challenge')
  @ApiOperation({ summary: "Today's daily challenge questions (answers stripped)" })
  getDailyChallenge(
    @CurrentUser() user: DecodedIdToken,
    @Query('languageId', new DefaultValuePipe(1), ParseIntPipe) languageId: number,
  ) {
    return this.service.getDailyChallenge(user.uid, languageId);
  }

  @Post('daily-challenge/submit')
  @Throttle({ default: { limit: 5, ttl: 86_400_000 } })
  @ApiOperation({ summary: 'Submit daily challenge answers (once per day, server-scored)' })
  submitDailyChallenge(@CurrentUser() user: DecodedIdToken, @Body() body: SubmitQuizDto) {
    return this.service.submitDailyChallenge(user.uid, body);
  }
}
