import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

const LIFE_REFILL_INTERVAL_MS = 15 * 60 * 1000; // 15 minutes
const LIFE_REFILL_COST_COINS = 30;

@Injectable()
export class LivesService {
  constructor(private readonly prisma: PrismaService) {}

  async getMyLives(firebaseUid: string) {
    const userId = await this.resolveUserId(firebaseUid);
    const lives = await this.getOrCreate(userId);
    const refreshed = await this.applyPassiveRefill(lives);
    return this.toResponse(refreshed);
  }

  async consumeLife(firebaseUid: string) {
    const userId = await this.resolveUserId(firebaseUid);
    return this.prisma.$transaction(async (tx) => {
      let lives = await tx.userLives.findUnique({ where: { userId } });
      if (!lives) lives = await tx.userLives.create({ data: { userId } });
      lives = await this.applyPassiveRefillTx(tx, lives);
      if (lives.current <= 0) {
        throw new BadRequestException({
          error: 'NO_LIVES',
          message: 'No lives remaining',
        });
      }
      const updated = await tx.userLives.update({
        where: { id: lives.id },
        data: {
          current: lives.current - 1,
          // Reset refill timer when going from full to not-full
          lastRefillAt: lives.current === lives.max ? new Date() : lives.lastRefillAt,
        },
      });
      return this.toResponse(updated);
    });
  }

  async restoreWithCoins(firebaseUid: string) {
    const userId = await this.resolveUserId(firebaseUid);
    return this.prisma.$transaction(async (tx) => {
      const user = await tx.user.findUnique({ where: { id: userId } });
      if (!user) throw new NotFoundException({ error: 'USER_NOT_FOUND', message: 'User not found' });
      if (user.coins < LIFE_REFILL_COST_COINS) {
        throw new BadRequestException({
          error: 'INSUFFICIENT_COINS',
          message: `Need ${LIFE_REFILL_COST_COINS} coins`,
        });
      }
      let lives = (await tx.userLives.findUnique({ where: { userId } })) ??
        (await tx.userLives.create({ data: { userId } }));
      if (lives.current >= lives.max) {
        throw new BadRequestException({
          error: 'LIVES_FULL',
          message: 'Lives are already at maximum',
        });
      }
      await tx.user.update({
        where: { id: userId },
        data: { coins: { decrement: LIFE_REFILL_COST_COINS } },
      });
      await tx.tracker.create({
        data: {
          userId,
          uid: userId.toString(),
          points: LIFE_REFILL_COST_COINS.toString(),
          type: 'lives_refill',
          status: 1,
          date: new Date(),
        },
      });
      const updated = await tx.userLives.update({
        where: { id: lives.id },
        data: { current: lives.max, lastRefillAt: new Date() },
      });
      return { ...this.toResponse(updated), coinsSpent: LIFE_REFILL_COST_COINS };
    });
  }

  async restoreWithAd(firebaseUid: string) {
    const userId = await this.resolveUserId(firebaseUid);
    let lives = await this.getOrCreate(userId);
    lives = await this.applyPassiveRefill(lives);
    if (lives.current >= lives.max) {
      throw new BadRequestException({
        error: 'LIVES_FULL',
        message: 'Lives are already at maximum',
      });
    }
    const updated = await this.prisma.userLives.update({
      where: { id: lives.id },
      data: { current: lives.current + 1, lastRefillAt: new Date() },
    });
    return this.toResponse(updated);
  }

  private async getOrCreate(userId: number) {
    return (
      (await this.prisma.userLives.findUnique({ where: { userId } })) ??
      (await this.prisma.userLives.create({ data: { userId } }))
    );
  }

  private async applyPassiveRefill(lives: {
    id: number;
    userId: number;
    current: number;
    max: number;
    lastRefillAt: Date;
    updatedAt: Date;
  }) {
    if (lives.current >= lives.max) return lives;
    const elapsed = Date.now() - lives.lastRefillAt.getTime();
    const refills = Math.floor(elapsed / LIFE_REFILL_INTERVAL_MS);
    if (refills <= 0) return lives;
    const newCurrent = Math.min(lives.max, lives.current + refills);
    const newLastRefill = new Date(
      lives.lastRefillAt.getTime() + refills * LIFE_REFILL_INTERVAL_MS,
    );
    return this.prisma.userLives.update({
      where: { id: lives.id },
      data: { current: newCurrent, lastRefillAt: newCurrent >= lives.max ? new Date() : newLastRefill },
    });
  }

  private async applyPassiveRefillTx(
    tx: Parameters<Parameters<PrismaService['$transaction']>[0]>[0],
    lives: {
      id: number;
      userId: number;
      current: number;
      max: number;
      lastRefillAt: Date;
      updatedAt: Date;
    },
  ) {
    if (lives.current >= lives.max) return lives;
    const elapsed = Date.now() - lives.lastRefillAt.getTime();
    const refills = Math.floor(elapsed / LIFE_REFILL_INTERVAL_MS);
    if (refills <= 0) return lives;
    const newCurrent = Math.min(lives.max, lives.current + refills);
    const newLastRefill = new Date(
      lives.lastRefillAt.getTime() + refills * LIFE_REFILL_INTERVAL_MS,
    );
    return tx.userLives.update({
      where: { id: lives.id },
      data: { current: newCurrent, lastRefillAt: newCurrent >= lives.max ? new Date() : newLastRefill },
    });
  }

  private toResponse(l: {
    current: number;
    max: number;
    lastRefillAt: Date;
  }) {
    const nextRefillAt =
      l.current >= l.max
        ? null
        : new Date(l.lastRefillAt.getTime() + LIFE_REFILL_INTERVAL_MS);
    return {
      current: l.current,
      max: l.max,
      lastRefillAt: l.lastRefillAt,
      nextRefillAt,
      intervalMs: LIFE_REFILL_INTERVAL_MS,
    };
  }

  private async resolveUserId(firebaseUid: string): Promise<number> {
    const u = await this.prisma.user.findFirst({
      where: { firebaseId: firebaseUid },
      select: { id: true },
    });
    if (!u) throw new NotFoundException({ error: 'USER_NOT_FOUND', message: 'User not found' });
    return u.id;
  }
}
