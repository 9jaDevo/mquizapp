import { UnauthorizedException, NotFoundException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { createHmac } from 'crypto';
import { PaymentsService } from './payments.service';
import { PrismaService } from '../../prisma/prisma.service';

describe('PaymentsService', () => {
  let service: PaymentsService;
  let prisma: jest.Mocked<Partial<PrismaService>>;
  let config: { get: jest.Mock };

  const WEBHOOK_SECRET = 'test-webhook-secret-1234';

  const buildRawBody = (payload: object): Buffer =>
    Buffer.from(JSON.stringify(payload));

  const signBody = (body: Buffer, secret = WEBHOOK_SECRET): Buffer =>
    Buffer.from(createHmac('sha512', secret).update(body).digest('hex'));

  beforeEach(() => {
    config = {
      get: jest.fn((key: string) => {
        if (key === 'PAYSTACK_SECRET_KEY') return WEBHOOK_SECRET;
        if (key === 'PAYSTACK_WEBHOOK_SECRET') return WEBHOOK_SECRET;
        return undefined;
      }),
    };

    prisma = {
      user: {
        findFirst: jest.fn(),
      } as unknown as PrismaService['user'],
      tbl_payment_request: {
        findMany: jest.fn().mockResolvedValue([]),
        findUnique: jest.fn().mockResolvedValue(null),
      } as unknown as PrismaService['tbl_payment_request'],
      tracker: {
        create: jest.fn().mockResolvedValue({}),
        findFirst: jest.fn().mockResolvedValue(null),
      } as unknown as PrismaService['tracker'],
      $transaction: jest.fn().mockImplementation((fn: unknown) =>
        typeof fn === 'function'
          ? fn({
              tbl_payment_request: { findMany: jest.fn().mockResolvedValue([]) },
              user: { update: jest.fn().mockResolvedValue({}) },
              tracker: { create: jest.fn().mockResolvedValue({}) },
            })
          : Promise.resolve([]),
      ),
    };

    service = new PaymentsService(
      prisma as unknown as PrismaService,
      config as unknown as ConfigService,
    );
  });

  describe('handleWebhook — HMAC-SHA512 signature validation', () => {
    const goodPayload = {
      event: 'charge.success',
      data: {
        reference: 'ref-001',
        amount: 5000,
        status: 'success',
        metadata: { userId: 1, coins: 500 },
      },
    };

    it('throws UnauthorizedException when signature is missing/empty', async () => {
      const body = buildRawBody(goodPayload);
      await expect(
        service.handleWebhook(body, '', goodPayload),
      ).rejects.toBeInstanceOf(UnauthorizedException);
    });

    it('throws UnauthorizedException when signature is wrong (forged request)', async () => {
      const body = buildRawBody(goodPayload);
      const wrongSig = signBody(body, 'wrong-secret');
      await expect(
        service.handleWebhook(body, wrongSig.toString(), goodPayload),
      ).rejects.toBeInstanceOf(UnauthorizedException);
    });

    it('accepts a valid HMAC-SHA512 signature', async () => {
      const body = buildRawBody(goodPayload);
      const sig = signBody(body).toString();
      const result = await service.handleWebhook(body, sig, goodPayload);
      expect(result).toHaveProperty('received', true);
    });

    it('returns {received:true, processed:false} for non-charge events', async () => {
      const eventPayload = { event: 'transfer.success', data: { reference: 'ref-002', amount: 0, status: 'success' } };
      const body = buildRawBody(eventPayload);
      const sig = signBody(body).toString();
      const result = await service.handleWebhook(body, sig, eventPayload);
      expect(result.received).toBe(true);
      expect(result.processed).toBe(false);
    });
  });

  describe('verifyPayment', () => {
    it('throws NotFoundException when user not found', async () => {
      (prisma.user as jest.Mocked<PrismaService['user']>).findFirst = jest
        .fn()
        .mockResolvedValueOnce(null);
      await expect(
        service.verifyPayment('unknown-uid', 'REF-001'),
      ).rejects.toBeInstanceOf(NotFoundException);
    });

    it('returns { verified: true, alreadyProcessed: true } for already-processed reference', async () => {
      (prisma.user as jest.Mocked<PrismaService['user']>).findFirst = jest
        .fn()
        .mockResolvedValueOnce({ id: 1, email: 'a@b.com' });
      // Mock tbl_payment_request to return a fulfilled request containing the reference
      (prisma as Record<string, unknown>).tbl_payment_request = {
        findMany: jest.fn().mockResolvedValueOnce([
          { id: 5, user_id: 1, status: 1, details: 'ref:ALREADY-PROCESSED-REF,coins:500' },
        ]),
      };

      const result = await service.verifyPayment('uid-1', 'ALREADY-PROCESSED-REF');
      expect(result.verified).toBe(true);
      expect(result.alreadyProcessed).toBe(true);
    });

    it('rejects reference longer than 200 chars', async () => {
      (prisma.user as jest.Mocked<PrismaService['user']>).findFirst = jest
        .fn()
        .mockResolvedValueOnce({ id: 1, email: 'a@b.com' });
      const longRef = 'x'.repeat(201);
      await expect(
        service.verifyPayment('uid-1', longRef),
      ).rejects.toThrow();
    });
  });

  describe('history', () => {
    it('throws NotFoundException when user not found', async () => {
      (prisma.user as jest.Mocked<PrismaService['user']>).findFirst = jest
        .fn()
        .mockResolvedValueOnce(null);
      await expect(
        service.history('unknown-uid', { page: 1, limit: 20 }),
      ).rejects.toBeInstanceOf(NotFoundException);
    });

    it('returns paginated payment history', async () => {
      (prisma.user as jest.Mocked<PrismaService['user']>).findFirst = jest
        .fn()
        .mockResolvedValueOnce({ id: 1 });
      (prisma as Record<string, unknown>).tbl_payment_request = {
        findMany: jest.fn().mockResolvedValue([{ id: 1, amount: 5000, status: 1 }]),
        count: jest.fn().mockResolvedValue(1),
      };

      const result = await service.history('uid-1', { page: 1, limit: 10 });
      expect(result).toHaveProperty('items');
      expect(result).toHaveProperty('pagination');
    });
  });
});
