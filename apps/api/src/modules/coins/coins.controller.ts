import { Controller, Get, Query, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import type { DecodedIdToken } from 'firebase-admin/auth';
import { CoinsService } from './coins.service';
import { FirebaseAuthGuard } from '../../common/guards/firebase-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { CoinHistoryQueryDto } from '../users/dto/coin-history-query.dto';

@ApiTags('coins')
@ApiBearerAuth('firebase-token')
@UseGuards(FirebaseAuthGuard)
@Controller({ path: 'coins', version: '2' })
export class CoinsController {
  constructor(private readonly service: CoinsService) {}

  @Get('balance')
  @ApiOperation({ summary: 'My current coin balance' })
  balance(@CurrentUser() user: DecodedIdToken) {
    return this.service.getBalance(user.uid);
  }

  @Get('history')
  @ApiOperation({ summary: 'Paginated coin history' })
  history(@CurrentUser() user: DecodedIdToken, @Query() q: CoinHistoryQueryDto) {
    return this.service.getHistory(user.uid, q);
  }

  @Get('store')
  @ApiOperation({ summary: 'List available coin store items' })
  store() {
    return this.service.getStore();
  }
}
