import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { UpdateProfileDto } from './dto/update-profile.dto';
import { UpdateFcmTokenDto } from './dto/update-fcm-token.dto';
import { CoinHistoryQueryDto } from './dto/coin-history-query.dto';

@Injectable()
export class UsersService {
  constructor(private readonly prisma: PrismaService) {}

  async getMe(firebaseUid: string) {
    const user = await this.findByFirebaseUid(firebaseUid);
    const [lives, progress, streak] = await Promise.all([
      this.prisma.userLives.findUnique({ where: { userId: user.id } }),
      this.prisma.userProgress.findUnique({ where: { userId: user.id } }),
      this.prisma.dailyStreak.findFirst({ where: { userId: user.id }, orderBy: { id: 'desc' } }),
    ]);
    return {
      id: user.id,
      firebaseId: user.firebaseId,
      name: user.name,
      email: user.email,
      mobile: user.mobile,
      profile: user.profile,
      type: user.type,
      coins: user.coins,
      referCode: user.referCode,
      friendsCode: user.friendsCode,
      removeAds: user.removeAds === 1,
      countryCode: user.countryCode,
      countryName: user.countryName,
      appLanguage: user.appLanguage,
      dateRegistered: user.dateRegistered,
      lives: lives && {
        current: lives.current,
        max: lives.max,
        lastRefillAt: lives.lastRefillAt,
      },
      progress: progress && {
        stageNumber: progress.stageNumber,
        totalScore: progress.totalScore,
      },
      streak: streak && {
        current: streak.streakCount,
        max: streak.maxStreak,
        coinEarnedToday: streak.coinEarnedToday,
        lastLoginDate: streak.lastLoginDate,
      },
    };
  }

  async updateMe(firebaseUid: string, dto: UpdateProfileDto) {
    const user = await this.findByFirebaseUid(firebaseUid);
    const updated = await this.prisma.user.update({
      where: { id: user.id },
      data: {
        name: dto.name ?? undefined,
        profile: dto.profile ?? undefined,
        mobile: dto.mobile ?? undefined,
        appLanguage: dto.appLanguage ?? undefined,
        countryCode: dto.countryCode ?? undefined,
        countryName: dto.countryName ?? undefined,
      },
    });
    return {
      id: updated.id,
      name: updated.name,
      profile: updated.profile,
      mobile: updated.mobile,
      appLanguage: updated.appLanguage,
      countryCode: updated.countryCode,
      countryName: updated.countryName,
    };
  }

  async getPublicProfile(id: number) {
    const user = await this.prisma.user.findUnique({
      where: { id },
      select: { id: true, name: true, profile: true, countryCode: true, dateRegistered: true, coins: true },
    });
    if (!user) throw new NotFoundException({ error: 'USER_NOT_FOUND', message: 'User not found' });
    return user;
  }

  async getMyStats(firebaseUid: string) {
    const user = await this.findByFirebaseUid(firebaseUid);
    const [dailyAgg, weeklyAgg, monthlyAgg, coinSpent, coinEarned, streak] = await Promise.all([
      this.prisma.leaderboardDaily.aggregate({
        where: { userId: user.id },
        _sum: { score: true },
        _count: { id: true },
      }),
      this.prisma.leaderboardWeekly.aggregate({
        where: { userId: user.id },
        _sum: { score: true },
        _max: { score: true },
      }),
      this.prisma.leaderboardMonthly.aggregate({
        where: { userId: user.id },
        _sum: { score: true },
      }),
      this.prisma.tracker.aggregate({
        where: { userId: user.id, status: 0 },
        _count: { id: true },
      }),
      this.prisma.tracker.aggregate({
        where: { userId: user.id, status: 1 },
        _count: { id: true },
      }),
      this.prisma.dailyStreak.findFirst({
        where: { userId: user.id },
        orderBy: { id: 'desc' },
      }),
    ]);

    return {
      currentCoins: user.coins,
      totalQuizzesPlayed: dailyAgg._count.id,
      allTimeScore:
        (dailyAgg._sum.score ?? 0) + (weeklyAgg._sum.score ?? 0) + (monthlyAgg._sum.score ?? 0),
      bestWeeklyScore: weeklyAgg._max.score ?? 0,
      coinTransactionsEarned: coinSpent._count?.id ?? 0,
      coinTransactionsSpent: coinEarned._count?.id ?? 0,
      currentStreak: streak?.streakCount ?? 0,
      maxStreak: streak?.maxStreak ?? 0,
    };
  }

  async getMyBadges(firebaseUid: string) {
    const user = await this.findByFirebaseUid(firebaseUid);
    // tbl_users_badges introspected as raw model — use raw query for portability
    const badges = await this.prisma.$queryRawUnsafe<
      Array<{ id: number; badge_id: number; badge_name: string | null; earned_at: Date | null }>
    >(
      `SELECT ub.id, ub.badge_id, b.badge_name, ub.created_at AS earned_at
       FROM tbl_users_badges ub
       LEFT JOIN tbl_badges b ON b.id = ub.badge_id
       WHERE ub.user_id = ?
       ORDER BY ub.id DESC`,
      user.id,
    );
    return { badges };
  }

  async getMyCoinHistory(firebaseUid: string, q: CoinHistoryQueryDto) {
    const user = await this.findByFirebaseUid(firebaseUid);
    const take = Math.min(q.limit ?? 20, 100);
    const skip = ((q.page ?? 1) - 1) * take;
    const [items, total] = await Promise.all([
      this.prisma.tracker.findMany({
        where: { userId: user.id },
        orderBy: { id: 'desc' },
        skip,
        take,
        select: { id: true, points: true, type: true, status: true, date: true },
      }),
      this.prisma.tracker.count({ where: { userId: user.id } }),
    ]);
    return {
      items: items.map((t) => ({
        id: t.id,
        points: Number(t.points) || 0,
        type: t.type,
        direction: t.status === 0 ? 'earned' : 'spent',
        date: t.date,
      })),
      pagination: { page: q.page ?? 1, limit: take, total, pages: Math.ceil(total / take) },
    };
  }

  async updateFcmToken(firebaseUid: string, dto: UpdateFcmTokenDto) {
    const user = await this.findByFirebaseUid(firebaseUid);
    await this.prisma.user.update({
      where: { id: user.id },
      data: {
        fcmId: dto.platform === 'web' ? undefined : dto.token,
        webFcmId: dto.platform === 'web' ? dto.token : undefined,
      },
    });
    return { updated: true };
  }

  private async findByFirebaseUid(firebaseUid: string) {
    const user = await this.prisma.user.findFirst({ where: { firebaseId: firebaseUid } });
    if (!user) {
      throw new NotFoundException({
        error: 'USER_NOT_FOUND',
        message: 'No user record for this Firebase UID',
      });
    }
    return user;
  }
}
