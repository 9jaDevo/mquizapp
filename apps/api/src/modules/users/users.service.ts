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
      this.prisma.userLives.findUnique({ where: { userId: user.id } }).catch(() => null),
      this.prisma.userProgress.findUnique({ where: { userId: user.id } }).catch(() => null),
      this.prisma.dailyStreak.findFirst({ where: { userId: user.id }, orderBy: { id: 'desc' } }).catch(() => null),
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
    // tbl_users_badges uses a flat schema (one column per badge type).
    // Select only the integer flag columns — avoid thirsty_date/streak_date which
    // may contain MySQL zero dates (0000-00-00) that Prisma cannot parse.
    const rows = await this.prisma.$queryRawUnsafe<Array<Record<string, unknown>>>(
      `SELECT user_id,
              dashing_debut, combat_winner, clash_winner, most_wanted_winner,
              ultimate_player, quiz_warrior, super_sonic, flashback, brainiac,
              big_thing, elite, thirsty, power_elite, sharing_caring, streak
       FROM tbl_users_badges WHERE user_id = ? LIMIT 1`,
      user.id,
    );

    if (!rows.length) {
      return { badges: [] };
    }

    const row = rows[0];
    const BADGE_KEYS: Array<{ key: string; label: string }> = [
      { key: 'dashing_debut',      label: 'Dashing Debut' },
      { key: 'combat_winner',      label: 'Combat Winner' },
      { key: 'clash_winner',       label: 'Clash Winner' },
      { key: 'most_wanted_winner', label: 'Most Wanted Winner' },
      { key: 'ultimate_player',    label: 'Ultimate Player' },
      { key: 'quiz_warrior',       label: 'Quiz Warrior' },
      { key: 'super_sonic',        label: 'Super Sonic' },
      { key: 'flashback',          label: 'Flashback' },
      { key: 'brainiac',           label: 'Brainiac' },
      { key: 'big_thing',          label: 'Big Thing' },
      { key: 'elite',              label: 'Elite' },
      { key: 'thirsty',            label: 'Thirsty' },
      { key: 'power_elite',        label: 'Power Elite' },
      { key: 'sharing_caring',     label: 'Sharing & Caring' },
      { key: 'streak',             label: 'Streak' },
    ];

    const badges = BADGE_KEYS
      .filter(({ key }) => Number(row[key]) > 0)
      .map(({ key, label }, index) => ({
        id: index + 1,
        badge_id: key,
        badge_name: label,
        earned_at: null as Date | null,
      }));

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
