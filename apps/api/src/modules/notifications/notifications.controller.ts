import { Controller, Get, HttpCode, Param, ParseIntPipe, Put, Query, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import type { DecodedIdToken } from 'firebase-admin/auth';
import { NotificationsService } from './notifications.service';
import { FirebaseAuthGuard } from '../../common/guards/firebase-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { ListNotificationsQueryDto } from './dto/list-notifications-query.dto';

@ApiTags('notifications')
@ApiBearerAuth('firebase-token')
@UseGuards(FirebaseAuthGuard)
@Controller({ path: 'notifications', version: '2' })
export class NotificationsController {
  constructor(private readonly service: NotificationsService) {}

  @Get()
  @ApiOperation({ summary: 'List notifications for current user (paginated, with isRead flag)' })
  list(@CurrentUser() user: DecodedIdToken, @Query() q: ListNotificationsQueryDto) {
    return this.service.list(user.uid, q);
  }

  @Put(':id/read')
  @HttpCode(200)
  @ApiOperation({ summary: 'Mark a notification as read' })
  markRead(@CurrentUser() user: DecodedIdToken, @Param('id', ParseIntPipe) id: number) {
    return this.service.markRead(user.uid, id);
  }
}

