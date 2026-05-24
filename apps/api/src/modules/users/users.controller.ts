import { Body, Controller, Get, Param, ParseIntPipe, Put, Query, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import type { DecodedIdToken } from 'firebase-admin/auth';
import { UsersService } from './users.service';
import { FirebaseAuthGuard } from '../../common/guards/firebase-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { UpdateProfileDto } from './dto/update-profile.dto';
import { UpdateFcmTokenDto } from './dto/update-fcm-token.dto';
import { CoinHistoryQueryDto } from './dto/coin-history-query.dto';

@ApiTags('users')
@ApiBearerAuth('firebase-token')
@UseGuards(FirebaseAuthGuard)
@Controller({ path: 'users', version: '2' })
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get('me')
  @ApiOperation({ summary: 'Get my full profile' })
  me(@CurrentUser() user: DecodedIdToken) {
    return this.usersService.getMe(user.uid);
  }

  @Put('me')
  @ApiOperation({ summary: 'Update my profile (whitelisted fields only)' })
  updateMe(@CurrentUser() user: DecodedIdToken, @Body() dto: UpdateProfileDto) {
    return this.usersService.updateMe(user.uid, dto);
  }

  @Get('me/stats')
  @ApiOperation({ summary: 'Get my aggregate stats' })
  myStats(@CurrentUser() user: DecodedIdToken) {
    return this.usersService.getMyStats(user.uid);
  }

  @Get('me/badges')
  @ApiOperation({ summary: 'Get my earned badges' })
  myBadges(@CurrentUser() user: DecodedIdToken) {
    return this.usersService.getMyBadges(user.uid);
  }

  @Get('me/coin-history')
  @ApiOperation({ summary: 'Paginated coin transaction history' })
  myCoinHistory(@CurrentUser() user: DecodedIdToken, @Query() q: CoinHistoryQueryDto) {
    return this.usersService.getMyCoinHistory(user.uid, q);
  }

  @Put('me/fcm-token')
  @ApiOperation({ summary: 'Update FCM push token' })
  updateFcm(@CurrentUser() user: DecodedIdToken, @Body() dto: UpdateFcmTokenDto) {
    return this.usersService.updateFcmToken(user.uid, dto);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Public profile of another user' })
  publicProfile(@Param('id', ParseIntPipe) id: number) {
    return this.usersService.getPublicProfile(id);
  }
}
