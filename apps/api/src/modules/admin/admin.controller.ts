import { Body, Controller, Get, Param, ParseIntPipe, Patch, Post, Query, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { AdminService } from './admin.service';
import { FirebaseAuthGuard } from '../../common/guards/firebase-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { ListPaginationDto } from './dto/list-pagination.dto';
import { ResolveFraudDto } from './dto/resolve-fraud.dto';
import { SendNotificationDto } from './dto/send-notification.dto';
import { UpdateSettingDto } from './dto/update-setting.dto';

@ApiTags('admin')
@ApiBearerAuth('firebase-token')
@UseGuards(FirebaseAuthGuard, RolesGuard)
@Roles('admin')
@Controller({ path: 'admin', version: '2' })
export class AdminController {
  constructor(private readonly service: AdminService) {}

  @Get('users')
  @ApiOperation({ summary: 'List users (paginated)' })
  users(@Query() q: ListPaginationDto) {
    return this.service.listUsers(q);
  }

  @Get('users/:id')
  @ApiOperation({ summary: 'Get user details' })
  userDetails(@Param('id', ParseIntPipe) id: number) {
    return this.service.getUserDetails(id);
  }

  @Get('questions')
  @ApiOperation({ summary: 'List questions (paginated)' })
  questions(@Query() q: ListPaginationDto) {
    return this.service.listQuestions(q);
  }

  @Get('ai-questions/pending')
  @ApiOperation({ summary: 'List AI-generated questions awaiting review' })
  aiPending(@Query() q: ListPaginationDto) {
    return this.service.listPendingAiQuestions(q);
  }

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

  @Get('stats/overview')
  @ApiOperation({ summary: 'Dashboard overview statistics' })
  stats() {
    return this.service.getOverviewStats();
  }
}
