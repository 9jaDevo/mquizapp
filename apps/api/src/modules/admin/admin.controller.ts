import {
  Body,
  Controller,
  Delete,
  Get,
  HttpCode,
  Param,
  ParseIntPipe,
  Patch,
  Post,
  Put,
  Query,
  UseGuards,
} from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { Throttle } from '@nestjs/throttler';
import { AdminService } from './admin.service';
import { FirebaseAuthGuard } from '../../common/guards/firebase-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { ListPaginationDto } from './dto/list-pagination.dto';
import { ResolveFraudDto } from './dto/resolve-fraud.dto';
import { SendNotificationDto } from './dto/send-notification.dto';
import { UpdateSettingDto } from './dto/update-setting.dto';
import { SuspendUserDto } from './dto/suspend-user.dto';
import { AdjustCoinsDto } from './dto/adjust-coins.dto';
import { CreateQuestionDto } from './dto/create-question.dto';
import { UpdateQuestionDto } from './dto/update-question.dto';
import { ImportQuestionsDto } from './dto/import-questions.dto';
import { RejectAiQuestionDto } from './dto/reject-ai-question.dto';
import { CreateCategoryDto } from './dto/create-category.dto';
import { UpdateCategoryDto } from './dto/update-category.dto';
import { ReorderCategoriesDto } from './dto/reorder-categories.dto';
import { CreateContestDto } from './dto/create-contest.dto';
import { UpdateContestDto } from './dto/update-contest.dto';
import { CreateLeagueDto } from './dto/create-league.dto';
import { UpdateLeagueDto } from './dto/update-league.dto';
import { CreateSponsorDto } from './dto/create-sponsor.dto';
import { UpdateSponsorDto } from './dto/update-sponsor.dto';
import { ListQuestionsQueryDto } from './dto/list-questions-query.dto';
import { GenerateQuestionsDto } from './dto/generate-questions.dto';
import { ApproveBatchDto } from './dto/approve-batch.dto';
import { AssignLeagueDayDto } from './dto/assign-league-day.dto';
import { AnalyticsRangeDto } from './dto/analytics-range.dto';
import { ListUsersQueryDto } from './dto/list-users-query.dto';
import { CreateSubcategoryDto } from './dto/create-subcategory.dto';
import { UpdateSubcategoryDto } from './dto/update-subcategory.dto';

@ApiTags('admin')
@ApiBearerAuth('firebase-token')
@UseGuards(FirebaseAuthGuard, RolesGuard)
@Roles('admin')
@Controller({ path: 'admin', version: '2' })
export class AdminController {
  constructor(private readonly service: AdminService) {}

  // ─── Users ───────────────────────────────────────────────────────────────

  @Get('users')
  @ApiOperation({ summary: 'List users (paginated)' })
  users(@Query() q: ListUsersQueryDto) {
    return this.service.listUsers(q);
  }

  @Get('users/:id')
  @ApiOperation({ summary: 'Get user details + lives + progress + streak' })
  userDetails(@Param('id', ParseIntPipe) id: number) {
    return this.service.getUserDetails(id);
  }

  @Patch('users/:id/suspend')
  @ApiOperation({ summary: 'Suspend or unsuspend a user account' })
  suspendUser(@Param('id', ParseIntPipe) id: number, @Body() body: SuspendUserDto) {
    return this.service.suspendUser(id, body);
  }

  @Patch('users/:id/coins')
  @ApiOperation({ summary: 'Adjust a user coin balance (add or deduct)' })
  adjustCoins(@Param('id', ParseIntPipe) id: number, @Body() body: AdjustCoinsDto) {
    return this.service.adjustUserCoins(id, body);
  }

  @Get('users/:id/fraud-flags')
  @ApiOperation({ summary: 'List fraud detection events for a single user' })
  userFraudFlags(@Param('id', ParseIntPipe) id: number, @Query() q: ListPaginationDto) {
    return this.service.listUserFraudFlags(id, q);
  }

  @Get('users/:id/badges')
  @ApiOperation({ summary: 'List a user earned badges row (gamification status)' })
  userBadges(@Param('id', ParseIntPipe) id: number) {
    return this.service.getUserBadges(id);
  }

  @Get('users/:id/coin-history')
  @ApiOperation({ summary: 'Coin transaction history for a user' })
  userCoinHistory(@Param('id', ParseIntPipe) id: number, @Query() q: ListPaginationDto) {
    return this.service.getUserCoinHistory(id, q);
  }

  // ─── Questions ───────────────────────────────────────────────────────────

  @Get('questions')
  @ApiOperation({ summary: 'List questions (paginated) with category/difficulty/AI filters' })
  questions(@Query() q: ListQuestionsQueryDto) {
    return this.service.listQuestions(q);
  }

  @Get('questions/:id')
  @ApiOperation({ summary: 'Get a single question by id' })
  getQuestion(@Param('id', ParseIntPipe) id: number) {
    return this.service.getQuestion(id);
  }

  @Post('questions')
  @Throttle({ default: { limit: 60, ttl: 60_000 } })
  @ApiOperation({ summary: 'Create a new question' })
  createQuestion(@Body() body: CreateQuestionDto) {
    return this.service.createQuestion(body);
  }

  @Put('questions/:id')
  @ApiOperation({ summary: 'Update an existing question' })
  updateQuestion(@Param('id', ParseIntPipe) id: number, @Body() body: UpdateQuestionDto) {
    return this.service.updateQuestion(id, body);
  }

  @Delete('questions/:id')
  @HttpCode(200)
  @ApiOperation({ summary: 'Delete a question (hard delete)' })
  deleteQuestion(@Param('id', ParseIntPipe) id: number) {
    return this.service.deleteQuestion(id);
  }

  @Post('questions/import')
  @Throttle({ default: { limit: 5, ttl: 60_000 } })
  @ApiOperation({ summary: 'Bulk import questions (max 500 per request)' })
  importQuestions(@Body() body: ImportQuestionsDto) {
    return this.service.importQuestions(body);
  }

  @Post('questions/generate')
  @Throttle({ default: { limit: 10, ttl: 60_000 } })
  @ApiOperation({ summary: 'AI-generate quiz questions and save to pending queue' })
  generateQuestions(@Body() body: GenerateQuestionsDto) {
    return this.service.generateQuestions(body);
  }

  @Post('questions/approve-batch')
  @HttpCode(200)
  @ApiOperation({ summary: 'Approve a batch of pending AI questions by ID' })
  approveBatch(@Body() body: ApproveBatchDto) {
    return this.service.approveAiQuestionBatch(body.questionIds);
  }

  // ─── AI Questions ─────────────────────────────────────────────────────────

  @Get('ai-questions/pending')
  @ApiOperation({ summary: 'List AI-generated questions awaiting review' })
  aiPending(@Query() q: ListPaginationDto) {
    return this.service.listPendingAiQuestions(q);
  }

  @Post('ai-questions/:id/approve')
  @HttpCode(200)
  @ApiOperation({ summary: 'Approve AI question — transfers it to the live question bank' })
  approveAiQuestion(@Param('id', ParseIntPipe) id: number) {
    return this.service.approveAiQuestion(id);
  }

  @Post('ai-questions/:id/reject')
  @HttpCode(200)
  @ApiOperation({ summary: 'Reject an AI question with optional reason' })
  rejectAiQuestion(@Param('id', ParseIntPipe) id: number, @Body() body: RejectAiQuestionDto) {
    return this.service.rejectAiQuestion(id, body);
  }

  // ─── Fraud & Payments ────────────────────────────────────────────────────

  @Get('fraud-flags')
  @ApiOperation({ summary: 'List unresolved fraud detection events' })
  fraud(@Query() q: ListPaginationDto) {
    return this.service.listFraudFlags(q);
  }

  @Patch('fraud-flags/:id/resolve')
  @ApiOperation({ summary: 'Mark a fraud event as resolved' })
  resolveFraud(@Param('id', ParseIntPipe) id: number, @Body() body: ResolveFraudDto) {
    return this.service.resolveFraud(id, body);
  }

  @Get('payments')
  @ApiOperation({ summary: 'List payment requests' })
  payments(@Query() q: ListPaginationDto) {
    return this.service.listPayments(q);
  }

  // ─── Notifications & Settings ─────────────────────────────────────────────

  @Post('notifications/send')
  @ApiOperation({ summary: 'Broadcast or targeted push notification via FCM' })
  sendNotification(@Body() body: SendNotificationDto) {
    return this.service.sendNotification(body);
  }

  @Get('settings')
  @ApiOperation({ summary: 'List all settings' })
  settings() {
    return this.service.listSettings();
  }

  @Patch('settings/:type')
  @ApiOperation({ summary: 'Update or create a setting by type' })
  updateSetting(@Param('type') type: string, @Body() body: UpdateSettingDto) {
    return this.service.upsertSetting(type, body);
  }

  // ─── Categories ───────────────────────────────────────────────────────────

  @Get('categories')
  @ApiOperation({ summary: 'List all categories' })
  listCategories() {
    return this.service.listAdminCategories();
  }

  @Post('categories')
  @Throttle({ default: { limit: 30, ttl: 60_000 } })
  @ApiOperation({ summary: 'Create a category' })
  createCategory(@Body() body: CreateCategoryDto) {
    return this.service.createCategory(body);
  }

  @Patch('categories/reorder')
  @ApiOperation({ summary: 'Reorder categories in a single transaction' })
  reorderCategories(@Body() body: ReorderCategoriesDto) {
    return this.service.reorderCategories(body);
  }

  @Patch('categories/:id')
  @ApiOperation({ summary: 'Update a category' })
  updateCategory(@Param('id', ParseIntPipe) id: number, @Body() body: UpdateCategoryDto) {
    return this.service.updateCategory(id, body);
  }

  @Delete('categories/:id')
  @HttpCode(200)
  @ApiOperation({ summary: 'Delete a category' })
  deleteCategory(@Param('id', ParseIntPipe) id: number) {
    return this.service.deleteCategory(id);
  }

  // ─── Subcategories ────────────────────────────────────────────────────────

  @Get('categories/:id/subcategories')
  @ApiOperation({ summary: 'List subcategories for a category' })
  listSubcategories(@Param('id', ParseIntPipe) id: number) {
    return this.service.listSubcategories(id);
  }

  @Post('categories/:id/subcategories')
  @ApiOperation({ summary: 'Create a subcategory under a category' })
  createSubcategory(
    @Param('id', ParseIntPipe) id: number,
    @Body() body: CreateSubcategoryDto,
  ) {
    return this.service.createSubcategory(id, body);
  }

  @Patch('categories/subcategories/:subId')
  @ApiOperation({ summary: 'Update a subcategory' })
  updateSubcategory(
    @Param('subId', ParseIntPipe) subId: number,
    @Body() body: UpdateSubcategoryDto,
  ) {
    return this.service.updateSubcategory(subId, body);
  }

  @Delete('categories/subcategories/:subId')
  @HttpCode(200)
  @ApiOperation({ summary: 'Delete a subcategory' })
  deleteSubcategory(@Param('subId', ParseIntPipe) subId: number) {
    return this.service.deleteSubcategory(subId);
  }

  // ─── Contests ─────────────────────────────────────────────────────────────

  @Get('contests')
  @ApiOperation({ summary: 'List contests (paginated)' })
  listContests(@Query() q: ListPaginationDto) {
    return this.service.listContests(q);
  }

  @Get('contests/:id')
  @ApiOperation({ summary: 'Get a contest' })
  getContest(@Param('id', ParseIntPipe) id: number) {
    return this.service.getContest(id);
  }

  @Post('contests')
  @Throttle({ default: { limit: 30, ttl: 60_000 } })
  @ApiOperation({ summary: 'Create a contest' })
  createContest(@Body() body: CreateContestDto) {
    return this.service.createContest(body);
  }

  @Put('contests/:id')
  @ApiOperation({ summary: 'Update a contest' })
  updateContest(@Param('id', ParseIntPipe) id: number, @Body() body: UpdateContestDto) {
    return this.service.updateContest(id, body);
  }

  @Delete('contests/:id')
  @HttpCode(200)
  @ApiOperation({ summary: 'Delete a contest' })
  deleteContest(@Param('id', ParseIntPipe) id: number) {
    return this.service.deleteContest(id);
  }

  @Post('contests/:id/distribute')
  @HttpCode(200)
  @Throttle({ default: { limit: 5, ttl: 60_000 } })
  @ApiOperation({ summary: 'Mark contest prizes as distributed' })
  distributeContest(@Param('id', ParseIntPipe) id: number) {
    return this.service.distributeContestPrizes(id);
  }

  // ─── Leagues ──────────────────────────────────────────────────────────────

  @Get('leagues')
  @ApiOperation({ summary: 'List leagues (paginated)' })
  listLeagues(@Query() q: ListPaginationDto) {
    return this.service.listLeagues(q);
  }

  @Get('leagues/:id')
  @ApiOperation({ summary: 'Get a league' })
  getLeague(@Param('id', ParseIntPipe) id: number) {
    return this.service.getLeague(id);
  }

  @Post('leagues')
  @Throttle({ default: { limit: 30, ttl: 60_000 } })
  @ApiOperation({ summary: 'Create a league' })
  createLeague(@Body() body: CreateLeagueDto) {
    return this.service.createLeague(body);
  }

  @Put('leagues/:id')
  @ApiOperation({ summary: 'Update a league' })
  updateLeague(@Param('id', ParseIntPipe) id: number, @Body() body: UpdateLeagueDto) {
    return this.service.updateLeague(id, body);
  }

  @Delete('leagues/:id')
  @HttpCode(200)
  @ApiOperation({ summary: 'Delete a league' })
  deleteLeague(@Param('id', ParseIntPipe) id: number) {
    return this.service.deleteLeague(id);
  }

  @Get('leagues/:id/quiz-schedule')
  @ApiOperation({ summary: 'Get quiz-day schedule for a league' })
  leagueQuizSchedule(@Param('id', ParseIntPipe) id: number) {
    return this.service.getLeagueQuizSchedule(id);
  }

  @Post('leagues/:id/assign-day')
  @Throttle({ default: { limit: 60, ttl: 60_000 } })
  @ApiOperation({ summary: 'Assign (upsert) a quiz day entry for a league' })
  assignLeagueDay(
    @Param('id', ParseIntPipe) id: number,
    @Body() body: AssignLeagueDayDto,
  ) {
    return this.service.assignLeagueDay(id, body);
  }

  // ─── Sponsors ─────────────────────────────────────────────────────────────

  @Get('sponsors')
  @ApiOperation({ summary: 'List sponsor banners (paginated)' })
  listSponsors(@Query() q: ListPaginationDto) {
    return this.service.listSponsors(q);
  }

  @Post('sponsors')
  @Throttle({ default: { limit: 30, ttl: 60_000 } })
  @ApiOperation({ summary: 'Create a sponsor banner' })
  createSponsor(@Body() body: CreateSponsorDto) {
    return this.service.createSponsor(body);
  }

  @Patch('sponsors/:id')
  @ApiOperation({ summary: 'Update a sponsor banner' })
  updateSponsor(@Param('id', ParseIntPipe) id: number, @Body() body: UpdateSponsorDto) {
    return this.service.updateSponsor(id, body);
  }

  @Delete('sponsors/:id')
  @HttpCode(200)
  @ApiOperation({ summary: 'Delete a sponsor banner' })
  deleteSponsor(@Param('id', ParseIntPipe) id: number) {
    return this.service.deleteSponsor(id);
  }

  // ─── Notifications history ────────────────────────────────────────────────

  @Get('notifications')
  @ApiOperation({ summary: 'List sent notifications (paginated)' })
  listNotifications(@Query() q: ListPaginationDto) {
    return this.service.listNotifications(q);
  }

  // ─── Stats ────────────────────────────────────────────────────────────────

  @Get('stats/overview')
  @ApiOperation({ summary: 'Dashboard overview statistics + DAU/MAU + active contests + recent fraud feed' })
  stats() {
    return this.service.getOverviewStats();
  }

  // ─── Analytics (time-series / breakdowns) ─────────────────────────────────

  @Get('analytics/user-growth')
  @ApiOperation({ summary: 'New users per day for the last N days (default 30)' })
  analyticsUserGrowth(@Query() q: AnalyticsRangeDto) {
    return this.service.analyticsUserGrowth(q.days ?? 30);
  }

  @Get('analytics/revenue')
  @ApiOperation({ summary: 'Revenue per day for the last N days (default 30)' })
  analyticsRevenue(@Query() q: AnalyticsRangeDto) {
    return this.service.analyticsRevenue(q.days ?? 30);
  }

  @Get('analytics/quiz-completions')
  @ApiOperation({ summary: 'Quiz completions per day for the last N days (default 30)' })
  analyticsCompletions(@Query() q: AnalyticsRangeDto) {
    return this.service.analyticsQuizCompletions(q.days ?? 30);
  }

  @Get('analytics/top-categories')
  @ApiOperation({ summary: 'Top 10 categories by question count' })
  analyticsTopCategories() {
    return this.service.analyticsTopCategories();
  }

  @Get('analytics/country-distribution')
  @ApiOperation({ summary: 'Top 10 countries by registered user count' })
  analyticsCountries() {
    return this.service.analyticsCountryDistribution();
  }
}
