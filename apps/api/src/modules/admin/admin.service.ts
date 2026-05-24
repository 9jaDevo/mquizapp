import {
  BadRequestException,
  Injectable,
  Logger,
  NotFoundException,
} from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { FirebaseService } from '../../firebase/firebase.service';
import { RedisService } from '../../redis/redis.service';
import { ListPaginationDto } from './dto/list-pagination.dto';
import { ResolveFraudDto } from './dto/resolve-fraud.dto';
import { SendNotificationDto } from './dto/send-notification.dto';
import { UpdateSettingDto } from './dto/update-setting.dto';
import { SuspendUserDto, SuspendAction } from './dto/suspend-user.dto';
import { AdjustCoinsDto } from './dto/adjust-coins.dto';
import { CreateQuestionDto } from './dto/create-question.dto';
import { UpdateQuestionDto } from './dto/update-question.dto';
import { ImportQuestionsDto } from './dto/import-questions.dto';
import { RejectAiQuestionDto } from './dto/reject-ai-question.dto';

@Injectable()
export class AdminService {
  private readonly logger = new Logger(AdminService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly firebase: FirebaseService,
    private readonly redis: RedisService,
  ) {}

  async listUsers(q: ListPaginationDto) {
    const take = Math.min(q.limit ?? 50, 200);
    const skip = ((q.page ?? 1) - 1) * take;
    const where = q.search
      ? {
          OR: [
            { name: { contains: q.search } },
            { email: { contains: q.search } },
            { mobile: { contains: q.search } },
          ],
        }
      : {};
    const [items, total] = await Promise.all([
      this.prisma.user.findMany({
        where,
        orderBy: { id: 'desc' },
        skip,
        take,
        select: {
          id: true,
          name: true,
          email: true,
          mobile: true,
          coins: true,
          countryCode: true,
          status: true,
          type: true,
          dateRegistered: true,
        },
      }),
      this.prisma.user.count({ where }),
    ]);
    return {
      items,
      pagination: { page: q.page ?? 1, limit: take, total, pages: Math.ceil(total / take) },
    };
  }

  async getUserDetails(id: number) {
    const user = await this.prisma.user.findUnique({ where: { id } });
    if (!user) throw new NotFoundException({ error: 'USER_NOT_FOUND', message: 'User not found' });
    const [lives, progress, streak] = await Promise.all([
      this.prisma.userLives.findUnique({ where: { userId: id } }),
      this.prisma.userProgress.findUnique({ where: { userId: id } }),
      this.prisma.dailyStreak.findFirst({ where: { userId: id }, orderBy: { id: 'desc' } }),
    ]);
    return { user, lives, progress, streak };
  }

  async listQuestions(q: ListPaginationDto) {
    const take = Math.min(q.limit ?? 50, 200);
    const skip = ((q.page ?? 1) - 1) * take;
    const where = q.search ? { question: { contains: q.search } } : {};
    const [items, total] = await Promise.all([
      this.prisma.question.findMany({ where, orderBy: { id: 'desc' }, skip, take }),
      this.prisma.question.count({ where }),
    ]);
    return {
      items,
      pagination: { page: q.page ?? 1, limit: take, total, pages: Math.ceil(total / take) },
    };
  }

  async listPendingAiQuestions(q: ListPaginationDto) {
    const take = Math.min(q.limit ?? 50, 200);
    const skip = ((q.page ?? 1) - 1) * take;
    const [items, total] = await Promise.all([
      this.prisma.aiQuestion.findMany({
        where: { status: 0 },
        orderBy: { id: 'desc' },
        skip,
        take,
      }),
      this.prisma.aiQuestion.count({ where: { status: 0 } }),
    ]);
    return {
      items: items.map((x) => ({ ...x, id: x.id.toString() })),
      pagination: { page: q.page ?? 1, limit: take, total, pages: Math.ceil(total / take) },
    };
  }

  async listFraudFlags(q: ListPaginationDto) {
    const take = Math.min(q.limit ?? 50, 200);
    const skip = ((q.page ?? 1) - 1) * take;
    const [items, total] = await Promise.all([
      this.prisma.fraudDetection.findMany({
        where: { resolved: 0 },
        orderBy: { id: 'desc' },
        skip,
        take,
      }),
      this.prisma.fraudDetection.count({ where: { resolved: 0 } }),
    ]);
    return {
      items,
      pagination: { page: q.page ?? 1, limit: take, total, pages: Math.ceil(total / take) },
    };
  }

  async resolveFraud(id: number, dto: ResolveFraudDto) {
    const existing = await this.prisma.fraudDetection.findUnique({ where: { id } });
    if (!existing) throw new NotFoundException({ error: 'FRAUD_NOT_FOUND', message: 'Fraud event not found' });
    return this.prisma.fraudDetection.update({
      where: { id },
      data: {
        resolved: 1,
        resolvedAt: new Date(),
        resolution_notes: dto.notes ?? null,
        action_taken: dto.action ?? 'review',
        action_date: new Date(),
      },
    });
  }

  async listPayments(q: ListPaginationDto) {
    const take = Math.min(q.limit ?? 50, 200);
    const skip = ((q.page ?? 1) - 1) * take;
    const [items, total] = await Promise.all([
      this.prisma.tbl_payment_request.findMany({
        orderBy: { id: 'desc' },
        skip,
        take,
      }),
      this.prisma.tbl_payment_request.count(),
    ]);
    return {
      items,
      pagination: { page: q.page ?? 1, limit: take, total, pages: Math.ceil(total / take) },
    };
  }

  async sendNotification(dto: SendNotificationDto) {
    // Persist for the in-app feed
    await this.prisma.tbl_notifications.create({
      data: {
        title: dto.title,
        message: dto.message,
        users: dto.userIds && dto.userIds.length > 0 ? 'specific' : 'all',
        user_id: dto.userIds?.length ? dto.userIds.join(',') : null,
        type: dto.type ?? 'general',
        type_id: dto.typeId ?? 0,
        image: dto.image ?? '',
        date_sent: new Date(),
      },
    });

    // Send via FCM
    let tokens: string[] = [];
    if (dto.userIds?.length) {
      const users = await this.prisma.user.findMany({
        where: { id: { in: dto.userIds } },
        select: { fcmId: true, webFcmId: true },
      });
      tokens = users.flatMap((u) => [u.fcmId, u.webFcmId].filter((t): t is string => Boolean(t)));
    } else {
      // Targeted "all" broadcasts use a topic to avoid pulling millions of rows
      try {
        await this.firebase.messaging().send({
          topic: 'all_users',
          notification: { title: dto.title, body: dto.message },
        });
      } catch (e) {
        this.logger.error('FCM topic send failed', e);
      }
      return { delivered: 'topic', topic: 'all_users' };
    }

    if (!tokens.length) return { delivered: 0 };

    try {
      const res = await this.firebase.messaging().sendEachForMulticast({
        tokens,
        notification: { title: dto.title, body: dto.message },
      });
      return { delivered: res.successCount, failures: res.failureCount };
    } catch (e) {
      this.logger.error('FCM multicast failed', e);
      return { delivered: 0, error: 'fcm_failed' };
    }
  }

  async suspendUser(id: number, dto: SuspendUserDto) {
    const user = await this.prisma.user.findUnique({ where: { id } });
    if (!user) throw new NotFoundException({ error: 'USER_NOT_FOUND', message: 'User not found' });

    const newStatus = dto.action === SuspendAction.SUSPEND ? 1 : 0;
    const updated = await this.prisma.user.update({
      where: { id },
      data: { status: newStatus },
      select: { id: true, name: true, email: true, status: true },
    });

    this.logger.log(
      `Admin ${dto.action} user ${id}${dto.reason ? ` — reason: ${dto.reason}` : ''}`,
    );
    return updated;
  }

  async adjustUserCoins(id: number, dto: AdjustCoinsDto) {
    const user = await this.prisma.user.findUnique({
      where: { id },
      select: { id: true, coins: true },
    });
    if (!user) throw new NotFoundException({ error: 'USER_NOT_FOUND', message: 'User not found' });

    if (user.coins + dto.amount < 0) {
      throw new BadRequestException({
        error: 'INSUFFICIENT_COINS',
        message: 'Adjustment would leave user with negative coins',
      });
    }

    return this.prisma.$transaction(async (tx) => {
      const updated = await tx.user.update({
        where: { id },
        data: { coins: { increment: dto.amount } },
        select: { id: true, coins: true },
      });
      await tx.tracker.create({
        data: {
          userId: id,
          uid: id.toString(),
          points: dto.amount.toString(),
          type: 'admin_adjustment',
          status: 0,
          date: new Date(),
        },
      });
      return {
        userId: id,
        coinsAfter: updated.coins,
        adjustment: dto.amount,
        reason: dto.reason,
      };
    });
  }

  async createQuestion(dto: CreateQuestionDto) {
    return this.prisma.question.create({
      data: {
        category: dto.category,
        subcategory: dto.subcategory,
        languageId: dto.languageId ?? 0,
        image: dto.image ?? '',
        question: dto.question,
        questionType: dto.questionType,
        optiona: dto.optiona,
        optionb: dto.optionb,
        optionc: dto.optionc,
        optiond: dto.optiond,
        optione: dto.optione ?? null,
        answer: dto.answer,
        level: dto.level,
        note: dto.note ?? '',
      },
    });
  }

  async updateQuestion(id: number, dto: UpdateQuestionDto) {
    const existing = await this.prisma.question.findUnique({ where: { id } });
    if (!existing) {
      throw new NotFoundException({ error: 'QUESTION_NOT_FOUND', message: 'Question not found' });
    }

    const data: Record<string, unknown> = {};
    if (dto.category !== undefined) data['category'] = dto.category;
    if (dto.subcategory !== undefined) data['subcategory'] = dto.subcategory;
    if (dto.languageId !== undefined) data['languageId'] = dto.languageId;
    if (dto.image !== undefined) data['image'] = dto.image;
    if (dto.question !== undefined) data['question'] = dto.question;
    if (dto.questionType !== undefined) data['questionType'] = dto.questionType;
    if (dto.optiona !== undefined) data['optiona'] = dto.optiona;
    if (dto.optionb !== undefined) data['optionb'] = dto.optionb;
    if (dto.optionc !== undefined) data['optionc'] = dto.optionc;
    if (dto.optiond !== undefined) data['optiond'] = dto.optiond;
    if (dto.optione !== undefined) data['optione'] = dto.optione;
    if (dto.answer !== undefined) data['answer'] = dto.answer;
    if (dto.level !== undefined) data['level'] = dto.level;
    if (dto.note !== undefined) data['note'] = dto.note;

    return this.prisma.question.update({ where: { id }, data });
  }

  async deleteQuestion(id: number) {
    const existing = await this.prisma.question.findUnique({ where: { id } });
    if (!existing) {
      throw new NotFoundException({ error: 'QUESTION_NOT_FOUND', message: 'Question not found' });
    }
    await this.prisma.question.delete({ where: { id } });
    return { deleted: true, id };
  }

  async importQuestions(dto: ImportQuestionsDto) {
    const result = await this.prisma.question.createMany({
      data: dto.questions.map((q) => ({
        category: q.category,
        subcategory: q.subcategory,
        languageId: q.languageId ?? 0,
        image: q.image ?? '',
        question: q.question,
        questionType: q.questionType,
        optiona: q.optiona,
        optionb: q.optionb,
        optionc: q.optionc,
        optiond: q.optiond,
        optione: q.optione ?? null,
        answer: q.answer,
        level: q.level,
        note: q.note ?? '',
      })),
    });
    return { imported: result.count };
  }

  async approveAiQuestion(id: number) {
    const ai = await this.prisma.aiQuestion.findUnique({ where: { id: BigInt(id) } });
    if (!ai) {
      throw new NotFoundException({ error: 'AI_QUESTION_NOT_FOUND', message: 'AI question not found' });
    }
    if (ai.status !== 0) {
      throw new BadRequestException({
        error: 'ALREADY_REVIEWED',
        message: 'AI question has already been reviewed',
      });
    }

    // Parse options JSON stored in ai.options (e.g. {"a":"...","b":"...","c":"...","d":"..."})
    let parsedOptions: Record<string, string> = {};
    try {
      parsedOptions = JSON.parse(ai.options) as Record<string, string>;
    } catch {
      // fallback — leave options empty and let admin fill manually
    }

    return this.prisma.$transaction(async (tx) => {
      const question = await tx.question.create({
        data: {
          category: ai.category,
          subcategory: ai.subcategory,
          languageId: ai.languageId,
          image: '',
          question: ai.question,
          questionType: ai.questionType,
          optiona: parsedOptions['a'] ?? parsedOptions['optiona'] ?? '',
          optionb: parsedOptions['b'] ?? parsedOptions['optionb'] ?? '',
          optionc: parsedOptions['c'] ?? parsedOptions['optionc'] ?? '',
          optiond: parsedOptions['d'] ?? parsedOptions['optiond'] ?? '',
          optione: parsedOptions['e'] ?? parsedOptions['optione'] ?? null,
          answer: ai.correctAnswer,
          level: ai.level,
          note: ai.note ?? '',
        },
      });

      await tx.aiQuestion.update({
        where: { id: BigInt(id) },
        data: { status: 1 },
      });

      return { approved: true, questionId: question.id };
    });
  }

  async rejectAiQuestion(id: number, dto: RejectAiQuestionDto) {
    const ai = await this.prisma.aiQuestion.findUnique({ where: { id: BigInt(id) } });
    if (!ai) {
      throw new NotFoundException({ error: 'AI_QUESTION_NOT_FOUND', message: 'AI question not found' });
    }
    if (ai.status !== 0) {
      throw new BadRequestException({
        error: 'ALREADY_REVIEWED',
        message: 'AI question has already been reviewed',
      });
    }

    const updated = await this.prisma.aiQuestion.update({
      where: { id: BigInt(id) },
      data: { status: 2, note: dto.reason ?? 'Rejected by admin' },
    });

    return { rejected: true, id: updated.id.toString() };
  }

  async listSettings() {
    const rows = await this.prisma.settings.findMany();
    return { settings: rows };
  }

  async upsertSetting(type: string, dto: UpdateSettingDto) {
    const existing = await this.prisma.settings.findFirst({ where: { type } });
    const result = existing
      ? await this.prisma.settings.update({ where: { id: existing.id }, data: { message: dto.message } })
      : await this.prisma.settings.create({ data: { type, message: dto.message } });
    await this.redis.del('config:settings:all');
    return result;
  }

  async getOverviewStats() {
    const [totalUsers, totalQuestions, totalLeagues, unresolvedFraud, paymentsToday] = await Promise.all([
      this.prisma.user.count(),
      this.prisma.question.count(),
      this.prisma.tbl_league.count({ where: { status: 1 } }),
      this.prisma.fraudDetection.count({ where: { resolved: 0 } }),
      this.prisma.tbl_payment_request.count({
        where: { date: { gte: this.startOfDay() }, status: 1 },
      }),
    ]);
    return {
      totalUsers,
      totalQuestions,
      activeLeagues: totalLeagues,
      unresolvedFraud,
      successfulPaymentsToday: paymentsToday,
    };
  }

  private startOfDay(): Date {
    const d = new Date();
    d.setHours(0, 0, 0, 0);
    return d;
  }
}
