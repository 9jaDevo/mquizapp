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
  users(@Query() q: ListPaginationDto) {
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

  // ─── Questions ───────────────────────────────────────────────────────────

  @Get('questions')
  @ApiOperation({ summary: 'List questions (paginated)' })
  questions(@Query() q: ListPaginationDto) {
    return this.service.listQuestions(q);
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

  // ─── Stats ────────────────────────────────────────────────────────────────

  @Get('stats/overview')
  @ApiOperation({ summary: 'Dashboard overview statistics' })
  stats() {
    return this.service.getOverviewStats();
  }
}
