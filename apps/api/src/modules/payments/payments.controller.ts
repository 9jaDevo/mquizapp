import {
  Body,
  Controller,
  Get,
  Headers,
  HttpCode,
  Param,
  Post,
  Query,
  Req,
  UseGuards,
} from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { Throttle } from '@nestjs/throttler';
import type { DecodedIdToken } from 'firebase-admin/auth';
import type { Request } from 'express';
import { PaymentsService } from './payments.service';
import { FirebaseAuthGuard } from '../../common/guards/firebase-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { Public } from '../../common/decorators/public.decorator';
import { InitializePaymentDto } from './dto/initialize-payment.dto';
import { CoinHistoryQueryDto } from '../users/dto/coin-history-query.dto';

@ApiTags('payments')
@Controller({ path: 'payments', version: '2' })
export class PaymentsController {
  constructor(private readonly service: PaymentsService) {}

  @ApiBearerAuth('firebase-token')
  @UseGuards(FirebaseAuthGuard)
  @Post('initialize')
  @Throttle({ default: { limit: 10, ttl: 60_000 } })
  @ApiOperation({ summary: 'Initialize a Paystack transaction to buy coins' })
  initialize(@CurrentUser() user: DecodedIdToken, @Body() body: InitializePaymentDto) {
    return this.service.initialize(user.uid, body);
  }

  @ApiBearerAuth('firebase-token')
  @UseGuards(FirebaseAuthGuard)
  @Post('verify/:reference')
  @HttpCode(200)
  @Throttle({ default: { limit: 10, ttl: 60_000 } })
  @ApiOperation({ summary: 'Verify a Paystack payment by reference and fulfill if successful' })
  verify(@CurrentUser() user: DecodedIdToken, @Param('reference') reference: string) {
    return this.service.verifyPayment(user.uid, reference);
  }

  @ApiBearerAuth('firebase-token')
  @UseGuards(FirebaseAuthGuard)
  @Get('history')
  @ApiOperation({ summary: 'My payment history' })
  history(@CurrentUser() user: DecodedIdToken, @Query() q: CoinHistoryQueryDto) {
    return this.service.history(user.uid, q);
  }

  @Public()
  @Post('webhook/paystack')
  @HttpCode(200)
  @ApiOperation({ summary: 'Paystack webhook (HMAC-SHA512 verified)' })
  async webhook(
    @Req() req: Request,
    @Headers('x-paystack-signature') signature: string,
    @Body() body: Record<string, unknown>,
  ) {
    const raw = (req as unknown as { rawBody?: Buffer }).rawBody;
    return this.service.handleWebhook(raw, signature, body);
  }
}
