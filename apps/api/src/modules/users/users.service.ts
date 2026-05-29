import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { UpdateProfileDto } from './dto/update-profile.dto';
import { UpdateFcmTokenDto } from './dto/update-fcm-token.dto';
import { CoinHistoryQueryDto } from './dto/coin-history-query.dto';

const LIFE_REFILL_INTERVAL_MS = 30 * 60 * 1000; // 30 minutes per life

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
        nextRefillAt:
          lives.current < lives.max
            ? new Date(lives.lastRefillAt.getTime() + LIFE_REFILL_INTERVAL_MS)
            : null,
        intervalMs: LIFE_REFILL_INTERVAL_MS,
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
    const [dailyAgg, weeklyAgg, monthlyAgg, coinSpent, coinEarned, streak, earnedRaw] = await Promise.all([
      this.prisma.leaderboardDaily.aggregate({
        where: { userId: user.id },
        _sum: { score: true, correctAnswers: true, totalAnswers: true },
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
      this.prisma.$queryRawUnsafe<Array<{ total: string }>>(
        'SELECT COALESCE(SUM(CAST(points AS UNSIGNED)), 0) as total FROM tbl_tracker WHERE user_id = ? AND status = 0',
        user.id,
      ),
    ]);

    return {
      coinsBalance: user.coins,
      quizzesPlayed: dailyAgg._count.id,
      totalScore:
        (dailyAgg._sum.score ?? 0) + (weeklyAgg._sum.score ?? 0) + (monthlyAgg._sum.score ?? 0),
      bestWeeklyScore: weeklyAgg._max.score ?? 0,
      lifetimeCoinsEarned: Number((earnedRaw as Array<{ total: string }>)[0]?.total ?? 0),
      streakCurrent: streak?.streakCount ?? 0,
      streakBest: streak?.maxStreak ?? 0,
      badgesCount: 0,
      accuracy: (dailyAgg._sum.totalAnswers ?? 0) > 0
        ? (dailyAgg._sum.correctAnswers ?? 0) / (dailyAgg._sum.totalAnswers ?? 0)
        : 0,
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

    const row: Record<string, unknown> = rows.length ? rows[0] : {};

    const BADGE_DEFS: Array<{ key: string; name: string; description: string; requirement: string }> = [
      { key: 'dashing_debut',      name: 'Dashing Debut',        description: 'First steps into the quiz arena',      requirement: 'Complete your first quiz' },
      { key: 'combat_winner',      name: 'Combat Winner',         description: 'Defeated a rival in 1v1 battle',         requirement: 'Win a 1v1 battle challenge' },
      { key: 'clash_winner',       name: 'Clash Winner',          description: 'Conquered a clash tournament',           requirement: 'Win a clash tournament' },
      { key: 'most_wanted_winner', name: 'Most Wanted Winner',    description: 'Ruled the weekly leaderboard',           requirement: 'Finish #1 on the weekly leaderboard' },
      { key: 'ultimate_player',    name: 'Ultimate Player',       description: 'Reached the top tier of play',           requirement: 'Earn 10,000 total XP' },
      { key: 'quiz_warrior',       name: 'Quiz Warrior',          description: 'Consistent quiz champion',               requirement: 'Complete 50 quizzes' },
      { key: 'super_sonic',        name: 'Super Sonic',           description: 'Lightning-fast answer machine',          requirement: 'Answer 10 questions correctly in under 30s' },
      { key: 'flashback',          name: 'Flashback',             description: 'Loyal across many sessions',             requirement: 'Play quizzes on 7 different days' },
      { key: 'brainiac',           name: 'Brainiac',              description: 'Near-perfect quiz performance',          requirement: 'Achieve 90%+ accuracy in a quiz' },
      { key: 'big_thing',          name: 'Big Thing',             description: 'Racked up serious coin earnings',        requirement: 'Earn 1,000 lifetime coins' },
      { key: 'elite',              name: 'Elite',                 description: 'Advanced through the progress map',      requirement: 'Reach Stage 5 on the progress map' },
      { key: 'thirsty',            name: 'Thirsty',               description: 'Kept the streak alive all week',        requirement: 'Maintain a 7-day login streak' },
      { key: 'power_elite',        name: 'Power Elite',           description: 'Master of the progress map',            requirement: 'Reach Stage 10 on the progress map' },
      { key: 'sharing_caring',     name: 'Sharing & Caring',      description: 'Growing the mQuiz community',           requirement: 'Invite a friend to join mQuiz' },
      { key: 'streak',             name: 'Streak',                description: 'Unstoppable — played every day',        requirement: 'Maintain a 30-day login streak' },
    ];

    const badges = BADGE_DEFS.map(({ key, name, description, requirement }, index) => ({
      id: index + 1,
      badgeId: key,
      name,
      description,
      requirement,
      isEarned: Number(row[key] ?? 0) > 0,
      earnedAt: null as Date | null,
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
      pagination: { page: q.page ?? 1, limit: take, total, totalPages: Math.ceil(total / take) },
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
