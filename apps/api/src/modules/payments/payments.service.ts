import {
  BadRequestException,
  Injectable,
  InternalServerErrorException,
  Logger,
  NotFoundException,
  UnauthorizedException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { createHmac, timingSafeEqual } from 'crypto';
import { PrismaService } from '../../prisma/prisma.service';
import { InitializePaymentDto } from './dto/initialize-payment.dto';
import { CoinHistoryQueryDto } from '../users/dto/coin-history-query.dto';

interface PaystackInitResponse {
  status: boolean;
  message: string;
  data?: { authorization_url: string; access_code: string; reference: string };
}

interface PaystackChargeEvent {
  event: string;
  data: {
    reference: string;
    amount: number;
    status: string;
    customer?: { email?: string };
    metadata?: Record<string, unknown>;
  };
}

@Injectable()
export class PaymentsService {
  private readonly logger = new Logger(PaymentsService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly config: ConfigService,
  ) {}

  async initialize(firebaseUid: string, dto: InitializePaymentDto) {
    const secret = this.config.get<string>('PAYSTACK_SECRET_KEY');
    if (!secret) {
      throw new InternalServerErrorException({
        error: 'PAYSTACK_NOT_CONFIGURED',
        message: 'Payment provider is not configured',
      });
    }

    const user = await this.prisma.user.findFirst({
      where: { firebaseId: firebaseUid },
      select: { id: true, email: true },
    });
    if (!user) throw new NotFoundException({ error: 'USER_NOT_FOUND', message: 'User not found' });

    const item = await this.prisma.tbl_coin_store.findUnique({ where: { id: dto.itemId } });
    if (!item || item.status !== 1) {
      throw new NotFoundException({ error: 'ITEM_NOT_FOUND', message: 'Coin store item not found' });
    }

    // Paystack expects amount in kobo (NGN minor units) — but item.coins ≠ price.
    // Use dto.amount (in kobo) provided by client AND validated server-side.
    if (dto.amountKobo <= 0) {
      throw new BadRequestException({
        error: 'INVALID_AMOUNT',
        message: 'Amount must be positive',
      });
    }

    const email = dto.email ?? user.email;
    if (!email) {
      throw new BadRequestException({
        error: 'EMAIL_REQUIRED',
        message: 'Email is required for payment initialization',
      });
    }

    // Record a pending request first
    const reference = `mq_${user.id}_${Date.now()}`;
    await this.prisma.tbl_payment_request.create({
      data: {
        user_id: user.id,
        uid: user.id.toString(),
        payment_type: 'paystack',
        payment_address: email,
        payment_amount: (dto.amountKobo / 100).toString(),
        coin_used: item.coins.toString(),
        details: JSON.stringify({ itemId: item.id, reference }),
        status: 0,
        date: new Date(),
      },
    });

    const initRes = await this.callPaystack(secret, email, dto.amountKobo, reference, {
      userId: user.id,
      itemId: item.id,
      coins: item.coins,
    });

    if (!initRes.status || !initRes.data) {
      throw new InternalServerErrorException({
        error: 'PAYSTACK_INIT_FAILED',
        message: initRes.message || 'Failed to initialize Paystack transaction',
      });
    }

    return {
      authorizationUrl: initRes.data.authorization_url,
      accessCode: initRes.data.access_code,
      reference: initRes.data.reference,
    };
  }

  async handleWebhook(
    rawBody: Buffer | undefined,
    signature: string | undefined,
    body: Record<string, unknown>,
  ) {
    const webhookSecret =
      this.config.get<string>('PAYSTACK_WEBHOOK_SECRET') ||
      this.config.get<string>('PAYSTACK_SECRET_KEY');
    if (!webhookSecret) {
      throw new InternalServerErrorException({
        error: 'WEBHOOK_NOT_CONFIGURED',
        message: 'Webhook secret not configured',
      });
    }
    if (!signature || !rawBody) {
      throw new UnauthorizedException({
        error: 'WEBHOOK_SIGNATURE_MISSING',
        message: 'Missing signature or body',
      });
    }
    const computed = createHmac('sha512', webhookSecret).update(rawBody).digest('hex');
    const provided = Buffer.from(signature);
    const expected = Buffer.from(computed);
    if (provided.length !== expected.length || !timingSafeEqual(provided, expected)) {
      throw new UnauthorizedException({
        error: 'WEBHOOK_SIGNATURE_INVALID',
        message: 'Invalid signature',
      });
    }

    const event = body as unknown as PaystackChargeEvent;
    if (event.event !== 'charge.success') {
      // Acknowledge other events but don't process
      return { received: true, processed: false };
    }

    const ref = event.data.reference;
    const meta = event.data.metadata ?? {};
    const userId = Number(meta['userId']);
    const coins = Number(meta['coins']);
    if (!userId || !coins) {
      this.logger.warn(`Webhook missing metadata: ${ref}`);
      return { received: true, processed: false };
    }

    // Idempotency — find pending request by reference and only credit once
    await this.prisma.$transaction(async (tx) => {
      const requests = await tx.tbl_payment_request.findMany({
        where: { user_id: userId, status: 0 },
        orderBy: { id: 'desc' },
        take: 20,
      });
      const match = requests.find((r) => r.details.includes(ref));
      if (!match) {
        this.logger.warn(`No pending payment request matching ref=${ref}`);
        return;
      }
      await tx.tbl_payment_request.update({
        where: { id: match.id },
        data: { status: 1, status_date: new Date() },
      });
      await tx.user.update({ where: { id: userId }, data: { coins: { increment: coins } } });
      await tx.tracker.create({
        data: {
          userId,
          uid: userId.toString(),
          points: coins.toString(),
          type: `paystack:${ref}`,
          status: 0,
          date: new Date(),
        },
      });
    });

    return { received: true, processed: true };
  }

  async history(firebaseUid: string, q: CoinHistoryQueryDto) {
    const user = await this.prisma.user.findFirst({
      where: { firebaseId: firebaseUid },
      select: { id: true },
    });
    if (!user) throw new NotFoundException({ error: 'USER_NOT_FOUND', message: 'User not found' });

    const take = Math.min(q.limit ?? 20, 100);
    const skip = ((q.page ?? 1) - 1) * take;
    const [items, total] = await Promise.all([
      this.prisma.tbl_payment_request.findMany({
        where: { user_id: user.id },
        orderBy: { id: 'desc' },
        skip,
        take,
      }),
      this.prisma.tbl_payment_request.count({ where: { user_id: user.id } }),
    ]);
    return {
      items: items.map((p) => ({
        id: p.id,
        amount: Number(p.payment_amount),
        coins: Number(p.coin_used),
        status: p.status === 1 ? 'completed' : p.status === 2 ? 'failed' : 'pending',
        date: p.date,
      })),
      pagination: { page: q.page ?? 1, limit: take, total, pages: Math.ceil(total / take) },
    };
  }

  private async callPaystack(
    secret: string,
    email: string,
    amount: number,
    reference: string,
    metadata: Record<string, unknown>,
  ): Promise<PaystackInitResponse> {
    const res = await fetch('https://api.paystack.co/transaction/initialize', {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${secret}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ email, amount, reference, metadata }),
    });
    return (await res.json()) as PaystackInitResponse;
  }
}
