import {
  BadRequestException,
  ConflictException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { RedisService } from '../../redis/redis.service';
import { SubmitDailyQuizDto } from './dto/submit-daily-quiz.dto';

const LB_CACHE_TTL = 30;
const POINTS_PER_CORRECT = 10;

@Injectable()
export class LeagueService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly redis: RedisService,
  ) {}

  async listActive() {
    const now = new Date();
    const leagues = await this.prisma.tbl_league.findMany({
      where: { status: 1, end_date: { gte: now } },
      orderBy: { start_date: 'asc' },
    });
    return { leagues };
  }

  async getLeague(id: number) {
    const league = await this.prisma.tbl_league.findUnique({ where: { id } });
    if (!league) throw new NotFoundException({ error: 'LEAGUE_NOT_FOUND', message: 'League not found' });
    const prizes = await this.prisma.tbl_league_prize.findMany({
      where: { league_id: id },
      orderBy: { top_winner: 'asc' },
    });
    return { league, prizes };
  }

  async optIn(firebaseUid: string, leagueId: number) {
    const userId = await this.resolveUserId(firebaseUid);
    const league = await this.prisma.tbl_league.findUnique({ where: { id: leagueId } });
    if (!league || league.status !== 1) {
      throw new NotFoundException({ error: 'LEAGUE_NOT_FOUND', message: 'League not active' });
    }
    if (new Date() > league.end_date) {
      throw new BadRequestException({ error: 'LEAGUE_ENDED', message: 'League has ended' });
    }

    const existing = await this.prisma.tbl_league_user.findUnique({
      where: { league_id_user_id: { league_id: leagueId, user_id: userId } },
    });
    if (existing) {
      throw new ConflictException({
        error: 'ALREADY_JOINED',
        message: 'You have already joined this league',
      });
    }

    return this.prisma.$transaction(async (tx) => {
      if (league.entry > 0) {
        const user = await tx.user.findUnique({ where: { id: userId } });
        if (!user) throw new NotFoundException({ error: 'USER_NOT_FOUND', message: 'User not found' });
        if (user.coins < league.entry) {
          throw new BadRequestException({
            error: 'INSUFFICIENT_COINS',
            message: `League entry costs ${league.entry} coins`,
          });
        }
        await tx.user.update({ where: { id: userId }, data: { coins: { decrement: league.entry } } });
        await tx.tracker.create({
          data: {
            userId,
            uid: userId.toString(),
            points: league.entry.toString(),
            type: `league_entry:${leagueId}`,
            status: 1,
            date: new Date(),
          },
        });
      }
      await tx.tbl_league_user.create({
        data: {
          league_id: leagueId,
          user_id: userId,
          status: 'joined',
          opted_in_at: new Date(),
          joined_at: new Date(),
          coins_paid: league.entry,
        },
      });
      await tx.tbl_league_leaderboard.upsert({
        where: { league_id_user_id: { league_id: leagueId, user_id: userId } },
        update: {},
        create: { league_id: leagueId, user_id: userId },
      });
      return { joined: true, coinsPaid: league.entry };
    });
  }

  async myLeagues(firebaseUid: string) {
    const userId = await this.resolveUserId(firebaseUid);
    const memberships = await this.prisma.tbl_league_user.findMany({
      where: { user_id: userId },
      orderBy: { id: 'desc' },
    });
    return { memberships };
  }

  async getTodayQuiz(leagueId: number) {
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const dq = await this.prisma.tbl_league_daily_quiz.findFirst({
      where: { league_id: leagueId, quiz_date: today },
    });
    if (!dq) {
      throw new NotFoundException({
        error: 'NO_QUIZ_TODAY',
        message: 'No quiz assigned for today yet',
      });
    }
    const links = await this.prisma.tbl_league_daily_quiz_questions.findMany({
      where: { daily_quiz_id: dq.id },
      orderBy: { question_order: 'asc' },
    });
    const ids = links.map((l) => l.question_id);
    const questions = await this.prisma.question.findMany({
      where: { id: { in: ids } },
      select: {
        id: true,
        image: true,
        question: true,
        questionType: true,
        optiona: true,
        optionb: true,
        optionc: true,
        optiond: true,
        optione: true,
        level: true,
      },
    });
    const orderMap = new Map(links.map((l, idx) => [l.question_id, idx]));
    const ordered = questions.sort((a, b) => (orderMap.get(a.id) ?? 0) - (orderMap.get(b.id) ?? 0));
    return {
      dailyQuizId: dq.id,
      quizDay: dq.quiz_day,
      questions: ordered.map((q) => ({
        id: q.id,
        image: q.image,
        text: q.question,
        type: q.questionType,
        options: {
          a: q.optiona,
          b: q.optionb,
          c: q.optionc,
          d: q.optiond,
          ...(q.optione ? { e: q.optione } : {}),
        },
        level: q.level,
      })),
    };
  }

  async submitDailyQuiz(firebaseUid: string, leagueId: number, dto: SubmitDailyQuizDto) {
    const userId = await this.resolveUserId(firebaseUid);
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    // Verify membership
    const member = await this.prisma.tbl_league_user.findUnique({
      where: { league_id_user_id: { league_id: leagueId, user_id: userId } },
    });
    if (!member) {
      throw new BadRequestException({
        error: 'NOT_JOINED',
        message: 'Join the league before submitting',
      });
    }

    const dq = await this.prisma.tbl_league_daily_quiz.findUnique({ where: { id: dto.dailyQuizId } });
    if (!dq || dq.league_id !== leagueId) {
      throw new NotFoundException({ error: 'DAILY_QUIZ_NOT_FOUND', message: 'Daily quiz not found' });
    }

    // Already submitted?
    const prior = await this.prisma.tbl_league_submission.findFirst({
      where: { league_id: leagueId, user_id: userId, quiz_day: dq.quiz_day },
    });
    if (prior) {
      throw new ConflictException({
        error: 'ALREADY_SUBMITTED',
        message: "Today's quiz already submitted",
      });
    }

    // Score
    const ids = dto.answers.map((a) => a.questionId);
    const questions = await this.prisma.question.findMany({
      where: { id: { in: ids } },
      select: { id: true, answer: true },
    });
    const answerById = new Map(questions.map((q) => [q.id, q.answer]));

    let correct = 0;
    for (const a of dto.answers) {
      const truth = answerById.get(a.questionId);
      if (truth && truth.trim().toLowerCase() === a.answer.trim().toLowerCase()) correct++;
    }
    const wrong = dto.answers.length - correct;
    const score = correct * POINTS_PER_CORRECT;

    return this.prisma.$transaction(async (tx) => {
      await tx.tbl_league_submission.create({
        data: {
          league_id: leagueId,
          user_id: userId,
          daily_quiz_id: dq.id,
          quiz_day: dq.quiz_day,
          score,
          correct_answers: correct,
          wrong_answers: wrong,
          total_questions: dto.answers.length,
          ad_shown: dto.adShown ? 1 : 0,
          submission_date: today,
        },
      });
      // Update leaderboard
      const lb = await tx.tbl_league_leaderboard.upsert({
        where: { league_id_user_id: { league_id: leagueId, user_id: userId } },
        update: {
          cumulative_best_score: { increment: score },
          games_played: { increment: 1 },
          last_updated: new Date(),
        },
        create: {
          league_id: leagueId,
          user_id: userId,
          cumulative_best_score: score,
          games_played: 1,
        },
      });
      await this.redis.del(`league:${leagueId}:leaderboard`);
      return {
        correct,
        wrong,
        score,
        cumulative: lb.cumulative_best_score,
      };
    });
  }

  async getLeaderboard(leagueId: number, limit: number) {
    const safeLimit = Math.min(Math.max(limit, 1), 200);
    const cacheKey = `league:${leagueId}:leaderboard:${safeLimit}`;
    const cached = await this.redis.get<unknown[]>(cacheKey);
    if (cached) return { leagueId, entries: cached, cached: true };

    const rows = await this.prisma.$queryRawUnsafe<
      Array<{ user_id: number; name: string; profile: string | null; cumulative_best_score: number; games_played: number }>
    >(
      `SELECT lb.user_id, lb.cumulative_best_score, lb.games_played, u.name, u.profile
       FROM tbl_league_leaderboard lb
       JOIN tbl_users u ON u.id = lb.user_id
       WHERE lb.league_id = ?
       ORDER BY lb.cumulative_best_score DESC, lb.last_updated ASC
       LIMIT ?`,
      leagueId,
      safeLimit,
    );
    const entries = rows.map((r, idx) => ({
      rank: idx + 1,
      userId: Number(r.user_id),
      name: r.name,
      profile: r.profile,
      score: Number(r.cumulative_best_score),
      gamesPlayed: Number(r.games_played),
    }));
    await this.redis.set(cacheKey, entries, LB_CACHE_TTL);
    return { leagueId, entries, cached: false };
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
