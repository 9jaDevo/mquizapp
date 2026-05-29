import {
  BadRequestException,
  ConflictException,
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
import { VerifyAppleIapDto } from './dto/verify-apple-iap.dto';
import { CoinHistoryQueryDto } from '../users/dto/coin-history-query.dto';

interface AppleVerifyResponse {
  status: number;
  environment?: string;
  receipt?: {
    in_app?: Array<{
      product_id?: string;
      transaction_id?: string;
      original_transaction_id?: string;
      purchase_date_ms?: string;
    }>;
  };
  latest_receipt_info?: Array<{
    product_id?: string;
    transaction_id?: string;
    original_transaction_id?: string;
  }>;
}

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

    // Use price from DB — client never controls the charged amount (security)
    if (item.priceKobo <= 0) {
      throw new BadRequestException({
        error: 'ITEM_NOT_PRICED',
        message: 'This item is not available for purchase at this time',
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
        payment_amount: (item.priceKobo / 100).toString(),
        coin_used: item.coins.toString(),
        details: JSON.stringify({ itemId: item.id, reference }),
        status: 0,
        date: new Date(),
      },
    });

    const initRes = await this.callPaystack(secret, email, item.priceKobo, reference, {
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

  async verifyPayment(firebaseUid: string, reference: string) {
    if (!reference || reference.length > 200) {
      throw new BadRequestException({ error: 'INVALID_REFERENCE', message: 'Invalid payment reference' });
    }

    const secret = this.config.get<string>('PAYSTACK_SECRET_KEY');
    if (!secret) {
      throw new InternalServerErrorException({
        error: 'PAYSTACK_NOT_CONFIGURED',
        message: 'Payment provider is not configured',
      });
    }

    const user = await this.prisma.user.findFirst({
      where: { firebaseId: firebaseUid },
      select: { id: true },
    });
    if (!user) throw new NotFoundException({ error: 'USER_NOT_FOUND', message: 'User not found' });

    // Check if this reference was already fulfilled
    const existing = await this.prisma.tbl_payment_request.findMany({
      where: { user_id: user.id },
      orderBy: { id: 'desc' },
      take: 50,
    });
    const match = existing.find((r) => r.details.includes(reference));
    if (match?.status === 1) {
      return { verified: true, alreadyProcessed: true };
    }

    // Call Paystack verify API
    const verifyRes = await fetch(
      `https://api.paystack.co/transaction/verify/${encodeURIComponent(reference)}`,
      { headers: { Authorization: `Bearer ${secret}` } },
    );

    if (!verifyRes.ok) {
      throw new InternalServerErrorException({
        error: 'PAYSTACK_VERIFY_FAILED',
        message: 'Could not verify payment with Paystack',
      });
    }

    interface PaystackVerifyResponse {
      status: boolean;
      data: { status: string; amount: number; metadata?: Record<string, unknown> };
    }
    const json = (await verifyRes.json()) as PaystackVerifyResponse;

    if (!json.status || json.data.status !== 'success') {
      return { verified: false, paystackStatus: json.data.status };
    }

    const meta = json.data.metadata ?? {};
    const coins = Number(meta['coins'] ?? 0);

    // Fulfill if we have a pending request for this user and reference
    if (match && match.status === 0 && coins > 0) {
      await this.prisma.$transaction(async (tx) => {
        await tx.tbl_payment_request.update({
          where: { id: match.id },
          data: { status: 1, status_date: new Date() },
        });
        await tx.user.update({
          where: { id: user.id },
          data: { coins: { increment: coins } },
        });
        await tx.tracker.create({
          data: {
            userId: user.id,
            uid: user.id.toString(),
            points: coins.toString(),
            type: `paystack_verify:${reference}`,
            status: 0,
            date: new Date(),
          },
        });
      });
      return { verified: true, alreadyProcessed: false, coinsAwarded: coins };
    }

    return { verified: true, alreadyProcessed: false, coinsAwarded: 0 };
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

  // ─── Apple In-App Purchase verification ───────────────────────────────
  async verifyAppleIap(firebaseUid: string, dto: VerifyAppleIapDto) {
    const user = await this.prisma.user.findFirst({
      where: { firebaseId: firebaseUid },
      select: { id: true },
    });
    if (!user) {
      throw new NotFoundException({ error: 'USER_NOT_FOUND', message: 'User not found' });
    }

    // Idempotency: tracker rows use type = `apple_iap:<transactionId>`
    const txType = `apple_iap:${dto.transactionId}`;
    const existing = await this.prisma.tracker.findFirst({
      where: { userId: user.id, type: txType },
      select: { id: true },
    });
    if (existing) {
      throw new ConflictException({
        error: 'TRANSACTION_ALREADY_PROCESSED',
        message: 'This transaction has already been credited',
      });
    }

    const item = await this.prisma.tbl_coin_store.findUnique({
      where: { product_id: dto.productId },
    });
    if (!item || item.status !== 1) {
      throw new NotFoundException({
        error: 'PRODUCT_NOT_FOUND',
        message: `Coin pack not found for productId '${dto.productId}'`,
      });
    }

    // Verify with Apple. Use production by default; fall back to sandbox on status 21007.
    const sharedSecret = this.config.get<string>('APPLE_IAP_SHARED_SECRET');
    const apple = await this.callAppleVerify(dto.receiptData, sharedSecret, false);
    let verified = apple;
    if (apple.status === 21007) {
      // Sandbox receipt sent to production endpoint — retry against sandbox.
      verified = await this.callAppleVerify(dto.receiptData, sharedSecret, true);
    }
    if (verified.status !== 0) {
      throw new BadRequestException({
        error: 'APPLE_VERIFY_FAILED',
        message: `Apple verifyReceipt returned status ${verified.status}`,
      });
    }

    // Confirm the receipt actually contains our transactionId AND productId.
    const transactions = [
      ...(verified.receipt?.in_app ?? []),
      ...(verified.latest_receipt_info ?? []),
    ];
    const match = transactions.find(
      (t) =>
        (t.transaction_id === dto.transactionId ||
          t.original_transaction_id === dto.transactionId) &&
        t.product_id === dto.productId,
    );
    if (!match) {
      throw new BadRequestException({
        error: 'TRANSACTION_NOT_IN_RECEIPT',
        message: 'transactionId/productId pair not found in verified receipt',
      });
    }

    // Credit atomically and write idempotency record.
    const coins = item.coins;
    const today = new Date();
    await this.prisma.$transaction(async (tx) => {
      // Double-check inside the transaction to defeat races.
      const dup = await tx.tracker.findFirst({
        where: { userId: user.id, type: txType },
        select: { id: true },
      });
      if (dup) {
        throw new ConflictException({
          error: 'TRANSACTION_ALREADY_PROCESSED',
          message: 'This transaction has already been credited',
        });
      }
      await tx.user.update({
        where: { id: user.id },
        data: { coins: { increment: coins } },
      });
      await tx.tracker.create({
        data: {
          userId: user.id,
          uid: user.id.toString(),
          points: coins.toString(),
          type: txType,
          status: 0,
          date: today,
        },
      });
      await tx.tbl_payment_request.create({
        data: {
          user_id: user.id,
          uid: user.id.toString(),
          payment_type: 'apple_iap',
          payment_address: dto.transactionId.slice(0, 255),
          payment_amount: (item.priceKobo / 100).toString(),
          coin_used: coins.toString(),
          details: JSON.stringify({
            productId: dto.productId,
            transactionId: dto.transactionId,
            environment: verified.environment ?? 'unknown',
          }),
          status: 1,
          status_date: today,
          date: today,
        },
      });
    });

    this.logger.log(
      `Apple IAP credited userId=${user.id} productId=${dto.productId} coins=${coins} tx=${dto.transactionId}`,
    );
    return { verified: true, coinsAwarded: coins, transactionId: dto.transactionId };
  }

  private async callAppleVerify(
    receiptData: string,
    sharedSecret: string | undefined,
    sandbox: boolean,
  ): Promise<AppleVerifyResponse> {
    const url = sandbox
      ? 'https://sandbox.itunes.apple.com/verifyReceipt'
      : 'https://buy.itunes.apple.com/verifyReceipt';
    const body: Record<string, unknown> = { 'receipt-data': receiptData };
    if (sharedSecret) body['password'] = sharedSecret;
    const res = await fetch(url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(body),
    });
    if (!res.ok) {
      throw new InternalServerErrorException({
        error: 'APPLE_VERIFY_NETWORK',
        message: `Apple verifyReceipt HTTP ${res.status}`,
      });
    }
    return (await res.json()) as AppleVerifyResponse;
  }
}
