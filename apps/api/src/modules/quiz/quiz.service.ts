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

      // Daily leaderboard entry (one row per submission)
      if (score > 0) {
        await tx.leaderboardDaily.create({
          data: { userId, score, dateCreated: new Date() },
        });
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
