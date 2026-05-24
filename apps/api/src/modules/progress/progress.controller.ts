import { Controller, Get, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import type { DecodedIdToken } from 'firebase-admin/auth';
import { ProgressService } from './progress.service';
import { FirebaseAuthGuard } from '../../common/guards/firebase-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';

@ApiTags('progress')
@ApiBearerAuth('firebase-token')
@UseGuards(FirebaseAuthGuard)
@Controller({ path: 'progress', version: '2' })
export class ProgressController {
  constructor(private readonly service: ProgressService) {}

  @Get('stages')
  @ApiOperation({ summary: 'List all progress stages (ladder)' })
  stages() {
    return this.service.listStages();
  }

  @Get('me')
  @ApiOperation({ summary: 'My current stage and progress toward next' })
  me(@CurrentUser() user: DecodedIdToken) {
    return this.service.myProgress(user.uid);
  }
}
