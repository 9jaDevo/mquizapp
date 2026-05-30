import { Body, Controller, Get, Param, ParseIntPipe, Post, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { Throttle } from '@nestjs/throttler';
import type { DecodedIdToken } from 'firebase-admin/auth';
import { BoostersService } from './boosters.service';
import { FirebaseAuthGuard } from '../../common/guards/firebase-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { ConsumeBoosterDto } from './dto/consume-booster.dto';
import { FiftyFiftyDto } from './dto/fifty-fifty.dto';

@ApiTags('boosters')
@ApiBearerAuth('firebase-token')
@UseGuards(FirebaseAuthGuard)
@Controller({ path: 'boosters', version: '2' })
export class BoostersController {
  constructor(private readonly service: BoostersService) {}

  @Get('types')
  @ApiOperation({ summary: 'List all available booster types' })
  listTypes() {
    return this.service.listTypes();
  }

  @Get('me')
  @ApiOperation({ summary: 'My booster inventory' })
  myInventory(@CurrentUser() user: DecodedIdToken) {
    return this.service.myInventory(user.uid);
  }

  @Post(':boosterTypeId/purchase')
  @Throttle({ default: { limit: 20, ttl: 60_000 } })
  @ApiOperation({ summary: 'Purchase one booster with coins' })
  purchase(
    @CurrentUser() user: DecodedIdToken,
    @Param('boosterTypeId', ParseIntPipe) id: number,
  ) {
    return this.service.purchase(user.uid, id);
  }

  @Post('consume')
  @Throttle({ default: { limit: 60, ttl: 60_000 } })
  @ApiOperation({ summary: 'Consume one booster from inventory' })
  consume(@CurrentUser() user: DecodedIdToken, @Body() body: ConsumeBoosterDto) {
    return this.service.consume(user.uid, body.boosterTypeId);
  }

  @Post('fifty-fifty')
  @Throttle({ default: { limit: 30, ttl: 60_000 } })
  @ApiOperation({ summary: 'Apply 50/50 booster — consumes 1 and returns 2 wrong option keys to remove' })
  fiftyFifty(@CurrentUser() user: DecodedIdToken, @Body() body: FiftyFiftyDto) {
    return this.service.fiftyFifty(user.uid, body.questionId, body.boosterTypeId, body.source);
  }
}
