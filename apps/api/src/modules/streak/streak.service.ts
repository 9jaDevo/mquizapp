import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

// Coin reward schedule by streak day (1..7+)
const STREAK_REWARDS = [5, 10, 15, 20, 25, 30, 50];

@Injectable()
export class StreakService {
  constructor(private readonly prisma: PrismaService) {}

  async getMyStreak(firebaseUid: string) {
    const userId = await this.resolveUserId(firebaseUid);
    const streak = await this.prisma.dailyStreak.findFirst({
      where: { userId },
      orderBy: { id: 'desc' },
    });
    return {
      current: streak?.streakCount ?? 0,
      max: streak?.maxStreak ?? 0,
      coinEarnedToday: streak?.coinEarnedToday ?? 0,
      lastLoginDate: streak?.lastLoginDate ?? null,
      claimedToday: this.isToday(streak?.lastLoginDate),
    };
  }

  async claimDailyLogin(firebaseUid: string) {
    const userId = await this.resolveUserId(firebaseUid);
    const today = this.startOfDay(new Date());

    return this.prisma.$transaction(async (tx) => {
      const existing = await tx.dailyStreak.findFirst({
        where: { userId },
        orderBy: { id: 'desc' },
      });

      if (existing && this.isSameDay(existing.lastLoginDate, today)) {
        return {
          claimed: false,
          alreadyClaimed: true,
          current: existing.streakCount ?? 0,
          max: existing.maxStreak ?? 0,
          coinEarnedToday: existing.coinEarnedToday ?? 0,
        };
      }

      const yesterday = this.startOfDay(new Date(today.getTime() - 24 * 60 * 60 * 1000));
      const wasConsecutive = existing && this.isSameDay(existing.lastLoginDate, yesterday);

      const newStreakCount = wasConsecutive ? (existing!.streakCount ?? 0) + 1 : 1;
      const reward = STREAK_REWARDS[Math.min(newStreakCount - 1, STREAK_REWARDS.length - 1)];
      const newMax = Math.max(existing?.maxStreak ?? 0, newStreakCount);

      // Atomically credit coins
      await tx.user.update({ where: { id: userId }, data: { coins: { increment: reward } } });

      // tbl_tracker: status=0 means earned
      await tx.tracker.create({
        data: {
          userId,
          uid: userId.toString(),
          points: reward.toString(),
          type: 'daily_streak',
          status: 0,
          date: today,
        },
      });

      if (existing) {
        await tx.dailyStreak.update({
          where: { id: existing.id },
          data: {
            streakCount: newStreakCount,
            maxStreak: newMax,
            coinEarnedToday: reward,
            lastLoginDate: today,
          },
        });
      } else {
        await tx.dailyStreak.create({
          data: {
            userId,
            uid: userId.toString(),
            streakCount: newStreakCount,
            maxStreak: newMax,
            coinEarnedToday: reward,
            lastLoginDate: today,
          },
        });
      }

      return {
        claimed: true,
        alreadyClaimed: false,
        current: newStreakCount,
        max: newMax,
        coinEarnedToday: reward,
      };
    });
  }

  private async resolveUserId(firebaseUid: string): Promise<number> {
    const user = await this.prisma.user.findFirst({
      where: { firebaseId: firebaseUid },
      select: { id: true },
    });
    if (!user) throw new NotFoundException({ error: 'USER_NOT_FOUND', message: 'User not found' });
    return user.id;
  }

  private startOfDay(d: Date): Date {
    const out = new Date(d);
    out.setHours(0, 0, 0, 0);
    return out;
  }

  private isSameDay(a: Date | null | undefined, b: Date): boolean {
    if (!a) return false;
    return this.startOfDay(a).getTime() === b.getTime();
  }

  private isToday(d: Date | null | undefined): boolean {
    return this.isSameDay(d, this.startOfDay(new Date()));
  }
}
