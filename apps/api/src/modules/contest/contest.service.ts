import {
  BadRequestException,
  ConflictException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { SubmitContestDto } from './dto/submit-contest.dto';

@Injectable()
export class ContestService {
  constructor(private readonly prisma: PrismaService) {}

  async listActive() {
    const now = new Date();
    const contests = await this.prisma.tbl_contest.findMany({
      where: { status: 1, end_date: { gte: now } },
      orderBy: { start_date: 'asc' },
    });
    return { contests };
  }

  async getQuestions(contestId: number) {
    const contest = await this.prisma.tbl_contest.findUnique({ where: { id: contestId } });
    if (!contest) throw new NotFoundException({ error: 'CONTEST_NOT_FOUND', message: 'Contest not found' });

    const questions = await this.prisma.tbl_contest_question.findMany({
      where: { contest_id: contestId },
      orderBy: { id: 'asc' },
    });
    return {
      contestId,
      questions: questions.map((q) => ({
        id: q.id,
        image: q.image,
        text: q.question,
        type: q.question_type,
        options: {
          a: q.optiona,
          b: q.optionb,
          c: q.optionc,
          d: q.optiond,
          ...(q.optione ? { e: q.optione } : {}),
        },
      })),
    };
  }

  async submit(firebaseUid: string, contestId: number, dto: SubmitContestDto) {
    const userId = await this.resolveUserId(firebaseUid);
    const contest = await this.prisma.tbl_contest.findUnique({ where: { id: contestId } });
    if (!contest || contest.status !== 1) {
      throw new NotFoundException({ error: 'CONTEST_NOT_FOUND', message: 'Contest not active' });
    }
    if (new Date() > contest.end_date) {
      throw new BadRequestException({ error: 'CONTEST_ENDED', message: 'Contest ended' });
    }
    // One submission per user per contest
    const prior = await this.prisma.tbl_contest_leaderboard.findFirst({
      where: { contest_id: contestId, user_id: userId },
    });
    if (prior) {
      throw new ConflictException({
        error: 'ALREADY_SUBMITTED',
        message: 'Contest already submitted',
      });
    }

    const ids = dto.answers.map((a) => a.questionId);
    const questions = await this.prisma.tbl_contest_question.findMany({
      where: { id: { in: ids }, contest_id: contestId },
      select: { id: true, answer: true },
    });
    const answerById = new Map(questions.map((q) => [q.id, q.answer]));

    let correct = 0;
    for (const a of dto.answers) {
      const truth = answerById.get(a.questionId);
      if (truth && truth.trim().toLowerCase() === a.answer.trim().toLowerCase()) correct++;
    }
    const score = correct * 10;

    await this.prisma.tbl_contest_leaderboard.create({
      data: {
        user_id: userId,
        contest_id: contestId,
        questions_attended: dto.answers.length,
        correct_answers: correct,
        score,
        last_updated: new Date(),
        date_created: new Date(),
      },
    });
    return { correct, total: dto.answers.length, score };
  }

  async getLeaderboard(contestId: number, limit: number) {
    const safe = Math.min(Math.max(limit, 1), 200);
    const rows = await this.prisma.$queryRawUnsafe<
      Array<{ user_id: number; name: string; profile: string | null; score: number; correct_answers: number }>
    >(
      `SELECT lb.user_id, lb.score, lb.correct_answers, u.name, u.profile
       FROM tbl_contest_leaderboard lb
       JOIN tbl_users u ON u.id = lb.user_id
       WHERE lb.contest_id = ?
       ORDER BY lb.score DESC, lb.last_updated ASC
       LIMIT ?`,
      contestId,
      safe,
    );
    return {
      contestId,
      entries: rows.map((r, idx) => ({
        rank: idx + 1,
        userId: Number(r.user_id),
        name: r.name,
        profile: r.profile,
        score: Number(r.score),
        correct: Number(r.correct_answers),
      })),
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
