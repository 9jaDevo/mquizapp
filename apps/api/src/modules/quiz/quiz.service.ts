import {
  BadRequestException,
  Injectable,
  Logger,
  NotFoundException,
} from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { FetchQuestionsQueryDto } from './dto/fetch-questions-query.dto';
import { SubmitQuizDto } from './dto/submit-quiz.dto';

const COINS_PER_CORRECT_DEFAULT = 2;
const POINTS_PER_CORRECT = 10;
const POINTS_PENALTY_WRONG = 0;
// Minimum realistic time per question in ms (used for fraud check)
const MIN_MS_PER_QUESTION = 1000;

@Injectable()
export class QuizService {
  private readonly logger = new Logger(QuizService.name);

  constructor(private readonly prisma: PrismaService) {}

  async fetchQuestions(firebaseUid: string, q: FetchQuestionsQueryDto) {
    await this.resolveUserId(firebaseUid);
    const limit = Math.min(q.limit ?? 10, 50);

    const where: Record<string, unknown> = {};
    if (q.languageId !== undefined) where.languageId = q.languageId;
    if (q.categoryId !== undefined) where.category = q.categoryId;
    if (q.subcategoryId !== undefined) where.subcategory = q.subcategoryId;
    if (q.level !== undefined) where.level = q.level;

    // Random selection for MySQL — ORDER BY RAND() LIMIT N
    // For very large tables this becomes slow; for Phase 1 it's acceptable.
    const ids = await this.prisma.$queryRawUnsafe<Array<{ id: number }>>(
      this.buildRandomIdsSql(where),
      ...this.buildRandomIdsParams(where, limit),
    );
    if (!ids.length) {
      return { questions: [], total: 0 };
    }

    const questions = await this.prisma.question.findMany({
      where: { id: { in: ids.map((r) => r.id) } },
      select: {
        id: true,
        category: true,
        subcategory: true,
        languageId: true,
        image: true,
        question: true,
        questionType: true,
        optiona: true,
        optionb: true,
        optionc: true,
        optiond: true,
        optione: true,
        level: true,
        // NOTE: `answer` is intentionally omitted — server keeps it secret
      },
    });

    return {
      questions: questions.map((q) => ({
        id: q.id,
        categoryId: q.category,
        subcategoryId: q.subcategory,
        languageId: q.languageId,
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
      total: questions.length,
    };
  }

  async submitAnswers(firebaseUid: string, body: SubmitQuizDto) {
    if (!body.answers?.length) {
      throw new BadRequestException({
        error: 'EMPTY_ANSWERS',
        message: 'No answers submitted',
      });
    }

    const userId = await this.resolveUserId(firebaseUid);
    const questionIds = body.answers.map((a) => a.questionId);
    const uniqueIds = [...new Set(questionIds)];
    if (uniqueIds.length !== questionIds.length) {
      throw new BadRequestException({
        error: 'DUPLICATE_QUESTIONS',
        message: 'Duplicate question IDs in submission',
      });
    }

    const questions = await this.prisma.question.findMany({
      where: { id: { in: uniqueIds } },
      select: { id: true, answer: true, category: true, subcategory: true },
    });
    if (questions.length !== uniqueIds.length) {
      throw new NotFoundException({
        error: 'QUESTION_NOT_FOUND',
        message: 'One or more questions do not exist',
      });
    }
    const answerById = new Map(questions.map((q) => [q.id, q.answer]));

    // Score
    const breakdown = body.answers.map((a) => {
      const correctAnswer = answerById.get(a.questionId)!;
      const isCorrect = this.normalize(a.answer) === this.normalize(correctAnswer);
      return {
        questionId: a.questionId,
        userAnswer: a.answer,
        correctAnswer,
        isCorrect,
      };
    });

    const correctCount = breakdown.filter((b) => b.isCorrect).length;
    const wrongCount = breakdown.length - correctCount;
    const score = correctCount * POINTS_PER_CORRECT - wrongCount * POINTS_PENALTY_WRONG;
    const coinsEarned = correctCount * COINS_PER_CORRECT_DEFAULT;

    // Fraud check — submission too fast given number of questions
    const totalMs = body.durationMs ?? 0;
    let fraudFlag: string | null = null;
    if (totalMs > 0 && totalMs < breakdown.length * MIN_MS_PER_QUESTION) {
      fraudFlag = 'quiz_speed';
    }

    const result = await this.prisma.$transaction(async (tx) => {
      // Atomic credit
      if (coinsEarned > 0) {
        await tx.user.update({ where: { id: userId }, data: { coins: { increment: coinsEarned } } });
        await tx.tracker.create({
          data: {
            userId,
            uid: userId.toString(),
            points: coinsEarned.toString(),
            type: 'quiz_reward',
            status: 0,
            date: new Date(),
          },
        });
      }

      // Daily + weekly + monthly leaderboard entries
      if (score > 0) {
        const _now = new Date();
        await tx.leaderboardDaily.create({
          data: { userId, score, dateCreated: _now },
        });
        const _week = this.isoWeek(_now);
        await tx.leaderboardWeekly.upsert({
          where: { userId_weekNumber_year: { userId, weekNumber: _week.weekNumber, year: _week.year } },
          update: { score: { increment: score }, lastUpdated: _now },
          create: { userId, weekNumber: _week.weekNumber, year: _week.year, score, lastUpdated: _now, dateCreated: _now },
        });
        const _monthStart = new Date(_now.getFullYear(), _now.getMonth(), 1);
        const _monthlyRow = await tx.leaderboardMonthly.findFirst({
          where: { userId, dateCreated: { gte: _monthStart } },
        });
        if (_monthlyRow) {
          await tx.leaderboardMonthly.update({
            where: { id: _monthlyRow.id },
            data: { score: { increment: score }, lastUpdated: _now },
          });
        } else {
          await tx.leaderboardMonthly.create({
            data: { userId, score, lastUpdated: _now, dateCreated: _now },
          });
        }
      }

      // Update user progress total
      await tx.userProgress.upsert({
        where: { userId },
        update: { totalScore: { increment: score } },
        create: { userId, stageNumber: 1, totalScore: score },
      });

      // Record fraud flag if triggered
      if (fraudFlag) {
        await tx.fraudDetection.create({
          data: {
            userId,
            uid: userId.toString(),
            detection_type: fraudFlag as 'quiz_speed',
            reason: `Submitted ${breakdown.length} questions in ${totalMs}ms`,
            severity: 'medium',
            action_taken: 'review',
            metadata: JSON.stringify({ durationMs: totalMs, count: breakdown.length }),
          },
        });
      }

      return {
        correctCount,
        wrongCount,
        score,
        coinsEarned,
        accuracy: breakdown.length ? Math.round((correctCount / breakdown.length) * 100) : 0,
        breakdown,
        fraudReviewed: Boolean(fraudFlag),
      };
    });

    return result;
  }

  async getDailyChallenge(firebaseUid: string, languageId = 1) {
    const userId = await this.resolveUserId(firebaseUid);
    const today = this.startOfToday();

    const dailyQuiz = await this.prisma.tbl_daily_quiz.findFirst({
      where: { language_id: languageId, date_published: today },
    });

    if (!dailyQuiz) {
      throw new NotFoundException({
        error: 'NO_DAILY_CHALLENGE',
        message: 'No daily challenge available for today',
      });
    }

    const alreadyCompleted = !!(await this.prisma.tbl_daily_quiz_user.findFirst({
      where: { user_id: userId, date: today },
    }));

    const questionIds = dailyQuiz.questions_id
      .split(',')
      .map((s) => parseInt(s.trim(), 10))
      .filter((n) => !isNaN(n) && n > 0);

    const questions = await this.prisma.question.findMany({
      where: { id: { in: questionIds } },
      select: {
        id: true,
        category: true,
        subcategory: true,
        languageId: true,
        image: true,
        question: true,
        questionType: true,
        optiona: true,
        optionb: true,
        optionc: true,
        optiond: true,
        optione: true,
        level: true,
        // answer intentionally omitted
      },
    });

    return {
      dailyQuizId: dailyQuiz.id,
      date: dailyQuiz.date_published,
      alreadyCompleted,
      questions: questions.map((q) => ({
        id: q.id,
        categoryId: q.category,
        subcategoryId: q.subcategory,
        languageId: q.languageId,
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

  async submitDailyChallenge(firebaseUid: string, body: SubmitQuizDto) {
    if (!body.answers?.length) {
      throw new BadRequestException({ error: 'EMPTY_ANSWERS', message: 'No answers submitted' });
    }

    const userId = await this.resolveUserId(firebaseUid);
    const today = this.startOfToday();

    // Idempotency — one submission per calendar day per user
    const alreadyDone = await this.prisma.tbl_daily_quiz_user.findFirst({
      where: { user_id: userId, date: today },
    });
    if (alreadyDone) {
      throw new BadRequestException({
        error: 'ALREADY_SUBMITTED',
        message: 'Daily challenge already completed today',
      });
    }

    const questionIds = body.answers.map((a) => a.questionId);
    const questions = await this.prisma.question.findMany({
      where: { id: { in: questionIds } },
      select: { id: true, answer: true },
    });
    if (questions.length !== questionIds.length) {
      throw new NotFoundException({
        error: 'QUESTION_NOT_FOUND',
        message: 'One or more questions not found',
      });
    }

    const answerById = new Map(questions.map((q) => [q.id, q.answer]));
    const breakdown = body.answers.map((a) => {
      const correctAnswer = answerById.get(a.questionId)!;
      const isCorrect = this.normalize(a.answer) === this.normalize(correctAnswer);
      return { questionId: a.questionId, isCorrect, correctAnswer };
    });

    const correctCount = breakdown.filter((b) => b.isCorrect).length;
    const score = correctCount * POINTS_PER_CORRECT;
    const coinsEarned = correctCount * COINS_PER_CORRECT_DEFAULT;

    await this.prisma.$transaction(async (tx) => {
      // Mark as done (prevents duplicate submissions today)
      await tx.tbl_daily_quiz_user.create({ data: { user_id: userId, date: today } });

      if (coinsEarned > 0) {
        await tx.user.update({
          where: { id: userId },
          data: { coins: { increment: coinsEarned } },
        });
        await tx.tracker.create({
          data: {
            userId,
            uid: userId.toString(),
            points: coinsEarned.toString(),
            type: 'daily_challenge',
            status: 0,
            date: new Date(),
          },
        });
      }

      if (score > 0) {
        const _now = new Date();
        await tx.leaderboardDaily.create({ data: { userId, score, dateCreated: _now } });
        const _week = this.isoWeek(_now);
        await tx.leaderboardWeekly.upsert({
          where: { userId_weekNumber_year: { userId, weekNumber: _week.weekNumber, year: _week.year } },
          update: { score: { increment: score }, lastUpdated: _now },
          create: { userId, weekNumber: _week.weekNumber, year: _week.year, score, lastUpdated: _now, dateCreated: _now },
        });
        const _monthStart = new Date(_now.getFullYear(), _now.getMonth(), 1);
        const _monthlyRow = await tx.leaderboardMonthly.findFirst({
          where: { userId, dateCreated: { gte: _monthStart } },
        });
        if (_monthlyRow) {
          await tx.leaderboardMonthly.update({
            where: { id: _monthlyRow.id },
            data: { score: { increment: score }, lastUpdated: _now },
          });
        } else {
          await tx.leaderboardMonthly.create({
            data: { userId, score, lastUpdated: _now, dateCreated: _now },
          });
        }
      }

      await tx.userProgress.upsert({
        where: { userId },
        update: { totalScore: { increment: score } },
        create: { userId, stageNumber: 1, totalScore: score },
      });
    });

    return {
      correctCount,
      wrongCount: body.answers.length - correctCount,
      score,
      coinsEarned,
      accuracy: body.answers.length
        ? Math.round((correctCount / body.answers.length) * 100)
        : 0,
      breakdown,
    };
  }

  private isoWeek(date: Date): { weekNumber: number; year: number } {
    const d = new Date(date);
    d.setHours(0, 0, 0, 0);
    d.setDate(d.getDate() + 3 - ((d.getDay() + 6) % 7));
    const week1 = new Date(d.getFullYear(), 0, 4);
    const weekNumber =
      1 +
      Math.round(
        ((d.getTime() - week1.getTime()) / 86400000 - 3 + ((week1.getDay() + 6) % 7)) / 7,
      );
    return { weekNumber, year: d.getFullYear() };
  }

  private startOfToday(): Date {
    const d = new Date();
    d.setHours(0, 0, 0, 0);
    return d;
  }

  private buildRandomIdsSql(where: Record<string, unknown>): string {
    const conditions: string[] = [];
    if ('languageId' in where) conditions.push('language_id = ?');
    if ('category' in where) conditions.push('category = ?');
    if ('subcategory' in where) conditions.push('subcategory = ?');
    if ('level' in where) conditions.push('level = ?');
    const whereClause = conditions.length ? `WHERE ${conditions.join(' AND ')}` : '';
    return `SELECT id FROM tbl_question ${whereClause} ORDER BY RAND() LIMIT ?`;
  }

  private buildRandomIdsParams(where: Record<string, unknown>, limit: number): unknown[] {
    const out: unknown[] = [];
    if ('languageId' in where) out.push(where.languageId);
    if ('category' in where) out.push(where.category);
    if ('subcategory' in where) out.push(where.subcategory);
    if ('level' in where) out.push(where.level);
    out.push(limit);
    return out;
  }

  private normalize(answer: string): string {
    return answer.trim().toLowerCase();
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
