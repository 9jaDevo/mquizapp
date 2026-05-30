import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { RedisService } from '../../redis/redis.service';

export type Period = 'daily' | 'weekly' | 'monthly';
export type CategoryPeriod = Period | 'alltime';

export interface LeaderboardEntry {
  rank: number;
  userId: number;
  name: string;
  profile: string | null;
  score: number;
}

const CACHE_TTL = 60; // 1 minute — leaderboards refresh often

@Injectable()
export class LeaderboardService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly redis: RedisService,
  ) {}

  async getTop(period: Period, limit: number, countryCode?: string) {
    const safeLimit = Math.min(Math.max(limit, 1), 200);
    const cc = countryCode?.toUpperCase();
    const cacheKey = `leaderboard:${period}:top:${safeLimit}${cc ? `:cc:${cc}` : ''}`;
    const cached = await this.redis.get<LeaderboardEntry[]>(cacheKey);
    if (cached) return { period, entries: cached, cached: true };

    const rows = await this.queryAggregatedTop(period, safeLimit, cc);
    await this.redis.set(cacheKey, rows, CACHE_TTL);
    return { period, entries: rows, cached: false };
  }

  async getMyRanks(firebaseUid: string) {
    const user = await this.prisma.user.findFirst({
      where: { firebaseId: firebaseUid },
      select: { id: true },
    });
    if (!user) throw new NotFoundException({ error: 'USER_NOT_FOUND', message: 'User not found' });

    const [daily, weekly, monthly] = await Promise.all([
      this.computeMyRank('daily', user.id),
      this.computeMyRank('weekly', user.id),
      this.computeMyRank('monthly', user.id),
    ]);
    return { daily, weekly, monthly };
  }

  private async queryAggregatedTop(period: Period, limit: number, cc?: string): Promise<LeaderboardEntry[]> {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    let sql: string;
    let params: unknown[];

    if (period === 'daily') {
      sql = `
        SELECT lb.user_id AS userId, SUM(lb.score) AS score, u.name, u.profile
        FROM tbl_leaderboard_daily lb
        JOIN tbl_users u ON u.id = lb.user_id
        WHERE lb.date_created >= ?${cc ? ' AND u.country_code = ?' : ''}
        GROUP BY lb.user_id, u.name, u.profile
        ORDER BY score DESC
        LIMIT ?`;
      params = [today, ...(cc ? [cc] : []), limit];
    } else if (period === 'weekly') {
      const { weekNumber, year } = this.isoWeek(new Date());
      sql = `
        SELECT lb.user_id AS userId, lb.score, u.name, u.profile
        FROM tbl_leaderboard_weekly lb
        JOIN tbl_users u ON u.id = lb.user_id
        WHERE lb.week_number = ? AND lb.year = ?${cc ? ' AND u.country_code = ?' : ''}
        ORDER BY lb.score DESC
        LIMIT ?`;
      params = [weekNumber, year, ...(cc ? [cc] : []), limit];
    } else {
      const monthStart = new Date(today.getFullYear(), today.getMonth(), 1);
      sql = `
        SELECT lb.user_id AS userId, SUM(lb.score) AS score, u.name, u.profile
        FROM tbl_leaderboard_monthly lb
        JOIN tbl_users u ON u.id = lb.user_id
        WHERE lb.date_created >= ?${cc ? ' AND u.country_code = ?' : ''}
        GROUP BY lb.user_id, u.name, u.profile
        ORDER BY score DESC
        LIMIT ?`;
      params = [monthStart, ...(cc ? [cc] : []), limit];
    }

    const raw = await this.prisma.$queryRawUnsafe<
      Array<{ userId: number; score: number | bigint | string; name: string; profile: string | null }>
    >(sql, ...params);

    return raw.map((r, idx) => ({
      rank: idx + 1,
      userId: Number(r.userId),
      name: r.name,
      profile: r.profile,
      score: Number(r.score),
    }));
  }

  private async computeMyRank(period: Period, userId: number) {
    const top = await this.queryAggregatedTop(period, 1000);
    const entry = top.find((e) => e.userId === userId);
    return entry
      ? { rank: entry.rank, score: entry.score, inTop1000: true }
      : { rank: null, score: 0, inTop1000: false };
  }

  // Category leaderboard — heuristic since per-category scoring is not tracked in dedicated tables.
  // Approach: among users who have played `categoryId` (per tbl_quiz_categories), return their
  // aggregated daily/weekly/monthly scores from the global leaderboard tables.
  async getCategoryTop(categoryId: number, period: CategoryPeriod, limit: number, countryCode?: string) {
    const safeLimit = Math.min(Math.max(limit, 1), 200);
    const cc = countryCode?.toUpperCase();
    const cacheKey = `leaderboard:category:${categoryId}:${period}:top:${safeLimit}${cc ? `:cc:${cc}` : ''}`;
    const cached = await this.redis.get<LeaderboardEntry[]>(cacheKey);
    if (cached) return { categoryId, period, entries: cached, cached: true };

    const today = new Date();
    today.setHours(0, 0, 0, 0);

    let sql: string;
    let params: unknown[];

    if (period === 'alltime') {
      sql = `
        SELECT u.id AS userId, u.score AS score, u.name, u.profile
        FROM tbl_users u
        WHERE u.id IN (
          SELECT DISTINCT qc.user_id FROM tbl_quiz_categories qc WHERE qc.category = ?
        )${cc ? ' AND u.country_code = ?' : ''}
        ORDER BY u.score DESC
        LIMIT ?`;
      params = [categoryId, ...(cc ? [cc] : []), safeLimit];
    } else if (period === 'daily') {
      sql = `
        SELECT lb.user_id AS userId, SUM(lb.score) AS score, u.name, u.profile
        FROM tbl_leaderboard_daily lb
        JOIN tbl_users u ON u.id = lb.user_id
        WHERE lb.date_created >= ?
          AND lb.user_id IN (
            SELECT DISTINCT qc.user_id FROM tbl_quiz_categories qc WHERE qc.category = ?
          )${cc ? ' AND u.country_code = ?' : ''}
        GROUP BY lb.user_id, u.name, u.profile
        ORDER BY score DESC
        LIMIT ?`;
      params = [today, categoryId, ...(cc ? [cc] : []), safeLimit];
    } else if (period === 'weekly') {
      const { weekNumber, year } = this.isoWeek(new Date());
      sql = `
        SELECT lb.user_id AS userId, lb.score, u.name, u.profile
        FROM tbl_leaderboard_weekly lb
        JOIN tbl_users u ON u.id = lb.user_id
        WHERE lb.week_number = ? AND lb.year = ?
          AND lb.user_id IN (
            SELECT DISTINCT qc.user_id FROM tbl_quiz_categories qc WHERE qc.category = ?
          )${cc ? ' AND u.country_code = ?' : ''}
        ORDER BY lb.score DESC
        LIMIT ?`;
      params = [weekNumber, year, categoryId, ...(cc ? [cc] : []), safeLimit];
    } else {
      const monthStart = new Date(today.getFullYear(), today.getMonth(), 1);
      sql = `
        SELECT lb.user_id AS userId, SUM(lb.score) AS score, u.name, u.profile
        FROM tbl_leaderboard_monthly lb
        JOIN tbl_users u ON u.id = lb.user_id
        WHERE lb.date_created >= ?
          AND lb.user_id IN (
            SELECT DISTINCT qc.user_id FROM tbl_quiz_categories qc WHERE qc.category = ?
          )${cc ? ' AND u.country_code = ?' : ''}
        GROUP BY lb.user_id, u.name, u.profile
        ORDER BY score DESC
        LIMIT ?`;
      params = [monthStart, categoryId, ...(cc ? [cc] : []), safeLimit];
    }

    const raw = await this.prisma.$queryRawUnsafe<
      Array<{ userId: number; score: number | bigint | string; name: string; profile: string | null }>
    >(sql, ...params);
    const entries: LeaderboardEntry[] = raw.map((r, idx) => ({
      rank: idx + 1,
      userId: Number(r.userId),
      name: r.name,
      profile: r.profile,
      score: Number(r.score ?? 0),
    }));
    await this.redis.set(cacheKey, entries, CACHE_TTL);
    return { categoryId, period, entries, cached: false };
  }

  private isoWeek(date: Date): { weekNumber: number; year: number } {
    const d = new Date(Date.UTC(date.getFullYear(), date.getMonth(), date.getDate()));
    const dayNum = d.getUTCDay() || 7;
    d.setUTCDate(d.getUTCDate() + 4 - dayNum);
    const yearStart = new Date(Date.UTC(d.getUTCFullYear(), 0, 1));
    const weekNumber = Math.ceil(((d.getTime() - yearStart.getTime()) / 86400000 + 1) / 7);
    return { weekNumber, year: d.getUTCFullYear() };
  }
}
