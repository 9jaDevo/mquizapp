import {
  BadRequestException,
  ConflictException,
  Injectable,
  Logger,
  NotFoundException,
} from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { FirebaseService } from '../../firebase/firebase.service';
import { RedisService } from '../../redis/redis.service';
import { ListPaginationDto } from './dto/list-pagination.dto';
import { CreateCoinPackDto } from './dto/create-coin-pack.dto';
import { UpdateCoinPackDto } from './dto/update-coin-pack.dto';
import { CreateProgressStageDto } from './dto/create-progress-stage.dto';
import { UpdateProgressStageDto } from './dto/update-progress-stage.dto';
import { ResolveFraudDto } from './dto/resolve-fraud.dto';
import { SendNotificationDto } from './dto/send-notification.dto';
import { ScheduleNotificationDto } from './dto/schedule-notification.dto';
import { Cron } from '@nestjs/schedule';
import { UpdateSettingDto } from './dto/update-setting.dto';
import { SuspendUserDto, SuspendAction } from './dto/suspend-user.dto';
import { AdjustCoinsDto } from './dto/adjust-coins.dto';
import { CreateQuestionDto } from './dto/create-question.dto';
import { UpdateQuestionDto } from './dto/update-question.dto';
import { ImportQuestionsDto } from './dto/import-questions.dto';
import { RejectAiQuestionDto } from './dto/reject-ai-question.dto';
import { UpdateAiQuestionDto } from './dto/update-ai-question.dto';
import { CreateCategoryDto } from './dto/create-category.dto';
import { UpdateCategoryDto } from './dto/update-category.dto';
import { ReorderCategoriesDto } from './dto/reorder-categories.dto';
import { CreateContestDto } from './dto/create-contest.dto';
import { UpdateContestDto } from './dto/update-contest.dto';
import { CreateLeagueDto } from './dto/create-league.dto';
import { UpdateLeagueDto } from './dto/update-league.dto';
import { CreateSponsorDto } from './dto/create-sponsor.dto';
import { UpdateSponsorDto } from './dto/update-sponsor.dto';
import { ListQuestionsQueryDto } from './dto/list-questions-query.dto';
import { ListUsersQueryDto } from './dto/list-users-query.dto';
import { CreateSubcategoryDto } from './dto/create-subcategory.dto';
import { UpdateSubcategoryDto } from './dto/update-subcategory.dto';
import { GenerateQuestionsDto } from './dto/generate-questions.dto';
import { AdminLoginDto } from './dto/admin-login.dto';
import * as bcrypt from 'bcryptjs';
import OpenAI from 'openai';
import { PartnerService } from '../partner/partner.service';

@Injectable()
export class AdminService {
  private readonly logger = new Logger(AdminService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly firebase: FirebaseService,
    private readonly redis: RedisService,
    private readonly partnerService: PartnerService,
  ) {}

  async listUsers(q: ListUsersQueryDto) {
    const take = Math.min(q.limit ?? 50, 200);
    const skip = ((q.page ?? 1) - 1) * take;
    const where: Record<string, unknown> = {};
    if (q.search) {
      where.OR = [
        { name: { contains: q.search } },
        { email: { contains: q.search } },
        { mobile: { contains: q.search } },
      ];
    }
    if (q.status !== undefined) where.status = q.status;
    if (q.firebaseId) where.firebaseId = { contains: q.firebaseId };
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
      items: items.map((u) => ({ ...u, isBanned: u.status === 1 })),
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

  async listQuestions(q: ListQuestionsQueryDto) {
    const take = Math.min(q.limit ?? 50, 200);
    const skip = ((q.page ?? 1) - 1) * take;
    const where: Record<string, unknown> = {};
    if (q.search) where.question = { contains: q.search };
    if (q.categoryId !== undefined) where.category = q.categoryId;
    if (q.difficulty !== undefined) where.level = q.difficulty;
    if (q.isAi !== undefined) where.aiGenerated = q.isAi ? 1 : 0;
    const [items, total] = await Promise.all([
      this.prisma.question.findMany({ where, orderBy: { id: 'desc' }, skip, take }),
      this.prisma.question.count({ where }),
    ]);
    return {
      items,
      pagination: { page: q.page ?? 1, limit: take, total, pages: Math.ceil(total / take) },
    };
  }

  async getQuestion(id: number) {
    const q = await this.prisma.question.findUnique({ where: { id } });
    if (!q) throw new NotFoundException({ error: 'QUESTION_NOT_FOUND', message: 'Question not found' });
    return q;
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

  async listAiGenerationHistory(q: ListPaginationDto) {
    const take = Math.min(q.limit ?? 50, 200);
    const skip = ((q.page ?? 1) - 1) * take;
    const [items, total] = await Promise.all([
      this.prisma.aiGenerationLog.findMany({
        orderBy: { id: 'desc' },
        skip,
        take,
      }),
      this.prisma.aiGenerationLog.count(),
    ]);
    return {
      items,
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
    // Persist for the in-app feed (delivery counts updated after FCM result)
    const notif = await this.prisma.tbl_notifications.create({
      data: {
        title: dto.title,
        message: dto.message,
        users: dto.userIds && dto.userIds.length > 0 ? 'specific' : 'all',
        user_id: dto.userIds?.length ? dto.userIds.join(',') : null,
        type: dto.type ?? 'general',
        type_id: dto.typeId ?? 0,
        image: dto.image ?? '',
        date_sent: new Date(),
        delivered_count: 0,
        failed_count: 0,
      },
    });

    const updateCounts = (delivered: number, failed: number) =>
      this.prisma.tbl_notifications
        .update({ where: { id: notif.id }, data: { delivered_count: delivered, failed_count: failed } })
        .catch(() => {/* best-effort */});

    // Send via FCM
    if (dto.userIds?.length) {
      const users = await this.prisma.user.findMany({
        where: { id: { in: dto.userIds } },
        select: { fcmId: true, webFcmId: true },
      });
      const tokens = users.flatMap((u) => [u.fcmId, u.webFcmId].filter((t): t is string => Boolean(t)));
      if (!tokens.length) return { delivered: 0 };

      try {
        const res = await this.firebase.messaging().sendEachForMulticast({
          tokens,
          notification: { title: dto.title, body: dto.message },
        });
        await updateCounts(res.successCount, res.failureCount);
        return { delivered: res.successCount, failures: res.failureCount };
      } catch (e) {
        this.logger.error('FCM multicast failed', e);
        return { delivered: 0, error: 'fcm_failed' };
      }
    }

    // Broadcast via topic — no per-device counts available
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

  async scheduleNotification(dto: ScheduleNotificationDto) {
    const sendAt = new Date(dto.sendAt);
    if (sendAt <= new Date()) {
      throw new BadRequestException({ error: 'PAST_SEND_TIME', message: 'sendAt must be in the future' });
    }
    const job = await this.prisma.scheduledNotification.create({
      data: {
        title: dto.title,
        message: dto.message,
        userIds: dto.userIds?.length ? dto.userIds.join(',') : null,
        type: dto.type ?? 'general',
        typeId: dto.typeId ?? 0,
        image: dto.image ?? '',
        sendAt,
      },
    });
    return { scheduled: true, id: job.id, sendAt: job.sendAt };
  }

  async listScheduledNotifications(q: ListPaginationDto) {
    const take = Math.min(q.limit ?? 20, 100);
    const skip = ((q.page ?? 1) - 1) * take;
    const [items, total] = await Promise.all([
      this.prisma.scheduledNotification.findMany({
        where: { sendAt: { gte: new Date() } },
        orderBy: { sendAt: 'asc' },
        skip,
        take,
      }),
      this.prisma.scheduledNotification.count({ where: { sendAt: { gte: new Date() } } }),
    ]);
    return { items, total, pages: Math.ceil(total / take) };
  }

  async cancelScheduledNotification(id: number) {
    const job = await this.prisma.scheduledNotification.findUnique({ where: { id } });
    if (!job) throw new NotFoundException({ error: 'SCHEDULED_NOTIF_NOT_FOUND', message: 'Scheduled notification not found' });
    await this.prisma.scheduledNotification.delete({ where: { id } });
    return { cancelled: true };
  }

  @Cron('* * * * *')
  async processScheduledNotifications() {
    const due = await this.prisma.scheduledNotification.findMany({
      where: { sendAt: { lte: new Date() } },
      take: 50,
    });
    for (const job of due) {
      await this.prisma.scheduledNotification.delete({ where: { id: job.id } });
      const userIds = job.userIds ? job.userIds.split(',').map(Number) : undefined;
      await this.sendNotification({
        title: job.title,
        message: job.message,
        userIds: userIds?.length ? userIds : undefined,
        type: job.type,
        typeId: job.typeId,
        image: job.image || undefined,
      }).catch((e) => this.logger.error('Scheduled notification delivery failed', e));
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

  async listUserFraudFlags(userId: number, q: ListPaginationDto) {
    const take = Math.min(q.limit ?? 50, 200);
    const skip = ((q.page ?? 1) - 1) * take;
    const where = { userId };
    const [items, total] = await Promise.all([
      this.prisma.fraudDetection.findMany({
        where,
        orderBy: { id: 'desc' },
        skip,
        take,
      }),
      this.prisma.fraudDetection.count({ where }),
    ]);
    return this.paginate(items, total, q.page ?? 1, take);
  }

  async getUserBadges(userId: number) {
    const row = await this.prisma.tbl_users_badges.findFirst({ where: { user_id: userId } });
    if (!row) return { userId, badges: [] };
    type RowRec = Record<string, unknown>;
    const r = row as unknown as RowRec;
    const labels: Record<string, string> = {
      dashing_debut: 'Dashing Debut',
      combat_winner: 'Combat Winner',
      clash_winner: 'Clash Winner',
      most_wanted_winner: 'Most Wanted Winner',
      ultimate_player: 'Ultimate Player',
      quiz_warrior: 'Quiz Warrior',
      super_sonic: 'Super Sonic',
      flashback: 'Flashback',
      brainiac: 'Brainiac',
      big_thing: 'Big Thing',
      elite: 'Elite',
      thirsty: 'Thirsty',
      power_elite: 'Power Elite',
      sharing_caring: 'Sharing & Caring',
      streak: 'Streak',
    };
    const badges = Object.entries(labels)
      .map(([key, label]) => ({
        key,
        label,
        earned: Number(r[key] ?? 0) === 1,
        counter: Number(r[`${key}_counter`] ?? 0),
      }))
      .filter((b) => b.earned || b.counter > 0);
    return { userId, badges };
  }

  async getUserCoinHistory(userId: number, q: ListPaginationDto) {
    const take = Math.min(q.limit ?? 20, 100);
    const skip = ((q.page ?? 1) - 1) * take;
    const [items, total] = await Promise.all([
      this.prisma.tracker.findMany({
        where: { userId },
        orderBy: { id: 'desc' },
        skip,
        take,
      }),
      this.prisma.tracker.count({ where: { userId } }),
    ]);
    return this.paginate(
      items.map((t) => ({
        id: t.id,
        points: Number(t.points),
        type: t.type,
        status: t.status,
        date: t.date?.toISOString() ?? null,
      })),
      total,
      q.page ?? 1,
      take,
    );
  }

  // ─── Subcategories ────────────────────────────────────────────────────────

  private mapSubcategory(s: {
    id: number; maincatId: number; subcategoryName: string; slug: string | null;
    isPremium: number; status: number; coins: number; image: string | null;
    rowOrder: number; languageId: number;
  }) {
    return {
      id: s.id,
      maincatId: s.maincatId,
      name: s.subcategoryName,
      slug: s.slug,
      isPremium: s.isPremium,
      status: s.status,
      coins: s.coins,
      image: s.image,
      rowOrder: s.rowOrder,
      languageId: s.languageId,
    };
  }

  async listSubcategories(categoryId: number) {
    const items = await this.prisma.subcategory.findMany({
      where: { maincatId: categoryId },
      orderBy: [{ rowOrder: 'asc' }, { id: 'asc' }],
    });
    return { items: items.map((s) => this.mapSubcategory(s)) };
  }

  async createSubcategory(categoryId: number, dto: CreateSubcategoryDto) {
    const last = await this.prisma.subcategory.findFirst({
      where: { maincatId: categoryId },
      orderBy: { rowOrder: 'desc' },
    });
    const nextOrder = dto.rowOrder ?? (last ? last.rowOrder + 1 : 0);
    const created = await this.prisma.subcategory.create({
      data: {
        maincatId: categoryId,
        subcategoryName: dto.name,
        slug: dto.slug ?? null,
        isPremium: dto.isPremium ?? 0,
        status: dto.status ?? 1,
        coins: dto.coins ?? 0,
        image: dto.image ?? null,
        rowOrder: nextOrder,
        languageId: dto.languageId ?? 0,
      },
    });
    return this.mapSubcategory(created);
  }

  async updateSubcategory(id: number, dto: UpdateSubcategoryDto) {
    const existing = await this.prisma.subcategory.findUnique({ where: { id } });
    if (!existing) {
      throw new NotFoundException({ error: 'SUBCATEGORY_NOT_FOUND', message: 'Subcategory not found' });
    }
    const data: Record<string, unknown> = {};
    if (dto.name !== undefined) data['subcategoryName'] = dto.name;
    if (dto.slug !== undefined) data['slug'] = dto.slug;
    if (dto.isPremium !== undefined) data['isPremium'] = dto.isPremium;
    if (dto.status !== undefined) data['status'] = dto.status;
    if (dto.coins !== undefined) data['coins'] = dto.coins;
    if (dto.image !== undefined) data['image'] = dto.image;
    if (dto.rowOrder !== undefined) data['rowOrder'] = dto.rowOrder;
    if (dto.languageId !== undefined) data['languageId'] = dto.languageId;
    const updated = await this.prisma.subcategory.update({ where: { id }, data });
    return this.mapSubcategory(updated);
  }

  async deleteSubcategory(id: number) {
    const existing = await this.prisma.subcategory.findUnique({ where: { id } });
    if (!existing) {
      throw new NotFoundException({ error: 'SUBCATEGORY_NOT_FOUND', message: 'Subcategory not found' });
    }
    await this.prisma.subcategory.delete({ where: { id } });
    return { deleted: true, id };
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

  async generateQuestions(dto: GenerateQuestionsDto) {
    const apiKey = process.env.OPENAI_API_KEY;
    if (!apiKey) {
      throw new BadRequestException({
        error: 'OPENAI_NOT_CONFIGURED',
        message: 'OPENAI_API_KEY is not configured on the server',
      });
    }

    const difficultyToLevel: Record<string, number> = { easy: 1, medium: 2, hard: 3 };
    const level = difficultyToLevel[dto.difficultyLevel];

    const client = new OpenAI({ apiKey });
    const contextParts: string[] = [`topic: "${dto.topic}"`, `difficulty: ${dto.difficultyLevel}`];
    if (dto.subject) contextParts.push(`subject: ${dto.subject}`);
    if (dto.classLevel) contextParts.push(`class level: ${dto.classLevel}`);
    const prompt = `Generate exactly ${dto.count} multiple-choice quiz questions with ${contextParts.join(', ')}. Return a JSON object with a "questions" array. Each question must have: question (string), optiona, optionb, optionc, optiond (strings), answer (one of "a","b","c","d" — the correct option key), note (short explanation).`;

    const modelName = process.env.OPENAI_MODEL ?? 'gpt-4o-mini';
    let parsed: { questions: Array<{ question: string; optiona: string; optionb: string; optionc: string; optiond: string; answer: string; note?: string }> };
    let promptTokens = 0;
    let completionTokens = 0;
    let totalTokens = 0;
    try {
      const completion = await client.chat.completions.create({
        model: modelName,
        response_format: { type: 'json_object' },
        messages: [
          { role: 'system', content: 'You are a quiz question generator. Output strict JSON only.' },
          { role: 'user', content: prompt },
        ],
      });
      const content = completion.choices[0]?.message?.content ?? '{"questions":[]}';
      promptTokens = completion.usage?.prompt_tokens ?? 0;
      completionTokens = completion.usage?.completion_tokens ?? 0;
      totalTokens = completion.usage?.total_tokens ?? 0;
      parsed = JSON.parse(content);
    } catch (e) {
      this.logger.error('OpenAI generation failed', e);
      throw new BadRequestException({
        error: 'GENERATION_FAILED',
        message: e instanceof Error ? e.message : 'Failed to generate questions',
      });
    }

    if (!Array.isArray(parsed.questions) || parsed.questions.length === 0) {
      throw new BadRequestException({
        error: 'NO_QUESTIONS_GENERATED',
        message: 'AI returned no usable questions',
      });
    }

    const now = new Date();
    const created = await Promise.all(
      parsed.questions.slice(0, dto.count).map((q) =>
        this.prisma.aiQuestion.create({
          data: {
            category: dto.categoryId,
            subcategory: 0,
            level,
            question: String(q.question ?? '').slice(0, 4000),
            options: JSON.stringify({
              a: String(q.optiona ?? ''),
              b: String(q.optionb ?? ''),
              c: String(q.optionc ?? ''),
              d: String(q.optiond ?? ''),
            }),
            correctAnswer: String(q.answer ?? 'a').toLowerCase().slice(0, 50),
            note: q.note ? String(q.note).slice(0, 255) : null,
            status: 0,
            dateTime: now,
          },
        }),
      ),
    );

    await this.prisma.aiGenerationLog.create({
      data: {
        topic: dto.topic.slice(0, 255),
        categoryId: dto.categoryId,
        difficulty: dto.difficultyLevel,
        count: created.length,
        tokensUsed: totalTokens,
        promptTokens,
        completionTokens,
        model: modelName.slice(0, 64),
      },
    }).catch((e) => this.logger.warn(`Failed to write AI generation log: ${e instanceof Error ? e.message : e}`));

    return created.map((ai, i) => {
      const src = parsed.questions[i];
      return {
        id: Number(ai.id),
        category: ai.category,
        subcategory: ai.subcategory,
        languageId: ai.languageId,
        image: '',
        question: ai.question,
        questionType: ai.questionType,
        optiona: String(src.optiona ?? ''),
        optionb: String(src.optionb ?? ''),
        optionc: String(src.optionc ?? ''),
        optiond: String(src.optiond ?? ''),
        optione: null,
        answer: ai.correctAnswer,
        level: ai.level,
        note: ai.note ?? '',
      };
    });
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
          aiGenerated: 1,
        },
      });

      await tx.aiQuestion.update({
        where: { id: BigInt(id) },
        data: { status: 1 },
      });

      return { approved: true, questionId: question.id };
    });
  }

  async approveAiQuestionBatch(ids: number[]) {
    const results: Array<{ id: number; approved: boolean; questionId?: number; error?: string }> = [];
    for (const id of ids) {
      try {
        const r = await this.approveAiQuestion(id);
        results.push({ id, approved: true, questionId: r.questionId });
      } catch (e) {
        results.push({
          id,
          approved: false,
          error: e instanceof Error ? e.message : 'Failed',
        });
      }
    }
    return {
      total: ids.length,
      approved: results.filter((r) => r.approved).length,
      failed: results.filter((r) => !r.approved).length,
      results,
    };
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

  async updateAiQuestion(id: number, dto: UpdateAiQuestionDto) {
    const ai = await this.prisma.aiQuestion.findUnique({ where: { id: BigInt(id) } });
    if (!ai) {
      throw new NotFoundException({ error: 'AI_QUESTION_NOT_FOUND', message: 'AI question not found' });
    }
    if (ai.status !== 0) {
      throw new BadRequestException({ error: 'ALREADY_REVIEWED', message: 'Cannot edit a reviewed question' });
    }

    const updateData: Record<string, unknown> = {};
    if (dto.question !== undefined) updateData.question = dto.question;
    if (dto.note !== undefined) updateData.note = dto.note;
    if (dto.answer !== undefined) updateData.correctAnswer = dto.answer;

    if (
      dto.optiona !== undefined ||
      dto.optionb !== undefined ||
      dto.optionc !== undefined ||
      dto.optiond !== undefined
    ) {
      let opts: Record<string, string> = {};
      try { opts = JSON.parse(ai.options) as Record<string, string>; } catch { /* keep empty */ }
      if (dto.optiona !== undefined) opts['a'] = dto.optiona;
      if (dto.optionb !== undefined) opts['b'] = dto.optionb;
      if (dto.optionc !== undefined) opts['c'] = dto.optionc;
      if (dto.optiond !== undefined) opts['d'] = dto.optiond;
      updateData.options = JSON.stringify(opts);
    }

    if (Object.keys(updateData).length === 0) return { updated: false };
    await this.prisma.aiQuestion.update({ where: { id: BigInt(id) }, data: updateData });
    return { updated: true };
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
    const now = new Date();
    const startToday = this.startOfDay();
    const dau30Ago = new Date(now.getTime() - 1 * 24 * 60 * 60 * 1000);
    const mau30Ago = new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000);
    const [
      totalUsers,
      totalQuestions,
      totalLeagues,
      unresolvedFraud,
      paymentsToday,
      activeContests,
      pendingAi,
      dauRows,
      mauRows,
      recentFraudRaw,
    ] = await Promise.all([
      this.prisma.user.count(),
      this.prisma.question.count(),
      this.prisma.tbl_league.count({ where: { status: 1 } }),
      this.prisma.fraudDetection.count({ where: { resolved: 0 } }),
      this.prisma.tbl_payment_request.count({
        where: { date: { gte: startToday }, status: 1 },
      }),
      this.prisma.tbl_contest.count({
        where: { status: 1, end_date: { gte: now } },
      }),
      this.prisma.aiQuestion.count({ where: { status: 0 } }),
      this.prisma.tracker.groupBy({
        by: ['userId'],
        where: { date: { gte: dau30Ago } },
      }),
      this.prisma.tracker.groupBy({
        by: ['userId'],
        where: { date: { gte: mau30Ago } },
      }),
      this.prisma.fraudDetection.findMany({
        where: { resolved: 0 },
        orderBy: { id: 'desc' },
        take: 10,
        select: {
          id: true,
          userId: true,
          detection_type: true,
          severity: true,
          reason: true,
          createdAt: true,
        },
      }),
    ]);
    return {
      totalUsers,
      totalQuestions,
      activeLeagues: totalLeagues,
      activeContests,
      unresolvedFraud,
      successfulPaymentsToday: paymentsToday,
      paymentsToday,
      pendingAiQuestions: pendingAi,
      dau: dauRows.length,
      mau: mauRows.length,
      recentFraud: recentFraudRaw.map((f) => ({
        id: f.id,
        userId: f.userId,
        detectionType: f.detection_type ?? 'unknown',
        severity: f.severity ?? 'low',
        reason: f.reason,
        createdAt: f.createdAt?.toISOString() ?? null,
      })),
    };
  }

  // ─── Analytics ────────────────────────────────────────────────────

  private dateSeries(days: number): string[] {
    const out: string[] = [];
    const today = this.startOfDay();
    for (let i = days - 1; i >= 0; i--) {
      const d = new Date(today.getTime() - i * 86_400_000);
      out.push(d.toISOString().slice(0, 10));
    }
    return out;
  }

  async analyticsUserGrowth(days: number) {
    const since = new Date(this.startOfDay().getTime() - (days - 1) * 86_400_000);
    const rows = await this.prisma.$queryRawUnsafe<Array<{ day: string; count: bigint }>>(
      `SELECT DATE(date_registered) AS day, COUNT(*) AS count
         FROM tbl_users
        WHERE date_registered >= ?
        GROUP BY DATE(date_registered)
        ORDER BY day ASC`,
      since,
    );
    const map = new Map<string, number>();
    for (const r of rows) map.set(String(r.day), Number(r.count));
    return {
      series: this.dateSeries(days).map((d) => ({ date: d, count: map.get(d) ?? 0 })),
    };
  }

  async analyticsRevenue(days: number) {
    const since = new Date(this.startOfDay().getTime() - (days - 1) * 86_400_000);
    const rows = await this.prisma.$queryRawUnsafe<
      Array<{ day: string; total: string | null; count: bigint }>
    >(
      `SELECT DATE(date) AS day,
              SUM(CAST(payment_amount AS DECIMAL(12,2))) AS total,
              COUNT(*) AS count
         FROM tbl_payment_request
        WHERE date >= ? AND status = 1
        GROUP BY DATE(date)
        ORDER BY day ASC`,
      since,
    );
    const map = new Map<string, { total: number; count: number }>();
    for (const r of rows) {
      map.set(String(r.day), {
        total: Number(r.total ?? 0),
        count: Number(r.count),
      });
    }
    const series = this.dateSeries(days).map((d) => ({
      date: d,
      total: map.get(d)?.total ?? 0,
      count: map.get(d)?.count ?? 0,
    }));
    const grandTotal = series.reduce((s, r) => s + r.total, 0);
    return { series, grandTotal };
  }

  async analyticsQuizCompletions(days: number) {
    const since = new Date(this.startOfDay().getTime() - (days - 1) * 86_400_000);
    const rows = await this.prisma.$queryRawUnsafe<Array<{ day: string; count: bigint }>>(
      `SELECT DATE(date) AS day, COUNT(*) AS count
         FROM tbl_user_quiz_zone_session
        WHERE date >= ?
        GROUP BY DATE(date)
        ORDER BY day ASC`,
      since,
    );
    const map = new Map<string, number>();
    for (const r of rows) map.set(String(r.day), Number(r.count));
    return {
      series: this.dateSeries(days).map((d) => ({ date: d, count: map.get(d) ?? 0 })),
    };
  }

  async analyticsTopCategories() {
    const grouped = await this.prisma.question.groupBy({
      by: ['category'],
      _count: { _all: true },
      orderBy: { _count: { id: 'desc' } },
      take: 10,
    });
    if (grouped.length === 0) return { items: [] };
    const ids = grouped.map((g) => g.category);
    const cats = await this.prisma.category.findMany({
      where: { id: { in: ids } },
      select: { id: true, categoryName: true },
    });
    const nameMap = new Map(cats.map((c) => [c.id, c.categoryName]));
    return {
      items: grouped.map((g) => ({
        categoryId: g.category,
        name: nameMap.get(g.category) ?? `Category ${g.category}`,
        questionCount: g._count._all,
      })),
    };
  }

  async analyticsCountryDistribution() {
    const rows = await this.prisma.$queryRawUnsafe<
      Array<{ country: string | null; count: bigint }>
    >(
      `SELECT country_code AS country, COUNT(*) AS count
         FROM tbl_users
        WHERE country_code IS NOT NULL AND country_code <> ''
        GROUP BY country_code
        ORDER BY count DESC
        LIMIT 10`,
    );
    return {
      items: rows.map((r) => ({
        country: r.country ?? 'Unknown',
        count: Number(r.count),
      })),
    };
  }

  // Day 1 / Day 7 / Day 30 retention rates among cohorts registered N days ago.
  // For each cohort window, count distinct users who returned (have a quiz session) D days after signup.
  async analyticsRetention() {
    const compute = async (cohortDaysAgo: number, returnedAfterDays: number) => {
      const cohortDate = this.startOfDay();
      cohortDate.setDate(cohortDate.getDate() - cohortDaysAgo);
      const cohortEnd = new Date(cohortDate.getTime() + 86_400_000);
      const returnWindowStart = new Date(
        cohortDate.getTime() + returnedAfterDays * 86_400_000,
      );
      const returnWindowEnd = new Date(returnWindowStart.getTime() + 86_400_000);
      const rows = await this.prisma.$queryRawUnsafe<Array<{ cohort: bigint; returned: bigint }>>(
        `SELECT
           (SELECT COUNT(*) FROM tbl_users
            WHERE date_registered >= ? AND date_registered < ?) AS cohort,
           (SELECT COUNT(DISTINCT user_id) FROM tbl_user_quiz_zone_session
            WHERE user_id IN (
              SELECT id FROM tbl_users
              WHERE date_registered >= ? AND date_registered < ?
            )
            AND date >= ? AND date < ?) AS returned`,
        cohortDate, cohortEnd,
        cohortDate, cohortEnd,
        returnWindowStart, returnWindowEnd,
      );
      const c = Number(rows[0]?.cohort ?? 0);
      const r = Number(rows[0]?.returned ?? 0);
      return { cohortSize: c, returned: r, rate: c > 0 ? r / c : 0 };
    };
    const [d1, d7, d30] = await Promise.all([
      compute(1, 1),
      compute(7, 7),
      compute(30, 30),
    ]);
    return { d1, d7, d30 };
  }

  // Revenue broken down by payment provider for the last N days.
  async analyticsRevenueBreakdown(days: number) {
    const since = new Date(this.startOfDay().getTime() - (days - 1) * 86_400_000);
    const rows = await this.prisma.$queryRawUnsafe<
      Array<{ provider: string | null; total: string | null; count: bigint }>
    >(
      `SELECT payment_type AS provider,
              SUM(CAST(payment_amount AS DECIMAL(12,2))) AS total,
              COUNT(*) AS count
         FROM tbl_payment_request
        WHERE date >= ? AND status = 1
        GROUP BY payment_type
        ORDER BY total DESC`,
      since,
    );
    return {
      items: rows.map((r) => ({
        provider: r.provider ?? 'unknown',
        total: Number(r.total ?? 0),
        count: Number(r.count),
      })),
    };
  }

  private startOfDay(): Date {
    const d = new Date();
    d.setHours(0, 0, 0, 0);
    return d;
  }

  private paginate<T>(items: T[], total: number, page: number, limit: number) {
    return {
      items,
      total,
      page,
      limit,
      totalPages: Math.max(1, Math.ceil(total / limit)),
    };
  }

  // ─── Categories ───────────────────────────────────────────────────────────

  async listAdminCategories() {
    const rows = await this.prisma.category.findMany({
      orderBy: [{ rowOrder: 'asc' }, { id: 'asc' }],
    });
    const items = rows.map((c) => ({
      id: c.id,
      name: c.categoryName,
      slug: c.slug,
      type: c.type,
      isPremium: c.isPremium,
      coins: c.coins,
      image: c.image,
      rowOrder: c.rowOrder,
      languageId: c.languageId,
      status: c.status,
      isActive: c.status === 1,
      sortOrder: c.rowOrder,
      iconUrl: c.image,
      description: null,
      colorHex: null,
      createdAt: null,
      updatedAt: null,
    }));
    return { items };
  }

  async createCategory(dto: CreateCategoryDto) {
    const last = await this.prisma.category.findFirst({ orderBy: { rowOrder: 'desc' } });
    const nextOrder = dto.rowOrder ?? (last ? last.rowOrder + 1 : 0);
    const created = await this.prisma.category.create({
      data: {
        categoryName: dto.name,
        slug: dto.slug ?? null,
        type: dto.type ?? 0,
        isPremium: dto.isPremium ?? 0,
        coins: dto.coins ?? 0,
        image: dto.image ?? null,
        languageId: dto.languageId ?? 0,
        rowOrder: nextOrder,
        status: dto.status ?? 1,
      },
    });
    return {
      id: created.id,
      name: created.categoryName,
      slug: created.slug,
      type: created.type,
      isPremium: created.isPremium,
      coins: created.coins,
      image: created.image,
      rowOrder: created.rowOrder,
      languageId: created.languageId,
      status: created.status,
    };
  }

  async updateCategory(id: number, dto: UpdateCategoryDto) {
    const existing = await this.prisma.category.findUnique({ where: { id } });
    if (!existing) {
      throw new NotFoundException({ error: 'CATEGORY_NOT_FOUND', message: 'Category not found' });
    }
    const data: Record<string, unknown> = {};
    if (dto.name !== undefined) data['categoryName'] = dto.name;
    if (dto.slug !== undefined) data['slug'] = dto.slug;
    if (dto.type !== undefined) data['type'] = dto.type;
    if (dto.isPremium !== undefined) data['isPremium'] = dto.isPremium;
    if (dto.coins !== undefined) data['coins'] = dto.coins;
    if (dto.image !== undefined) data['image'] = dto.image;
    if (dto.languageId !== undefined) data['languageId'] = dto.languageId;
    if (dto.rowOrder !== undefined) data['rowOrder'] = dto.rowOrder;
    if (dto.status !== undefined) data['status'] = dto.status;
    const updated = await this.prisma.category.update({ where: { id }, data });
    // Invalidate public category cache so status change is reflected immediately
    await this.redis.del(`categories:lang:${updated.languageId}`);
    return {
      id: updated.id,
      name: updated.categoryName,
      slug: updated.slug,
      type: updated.type,
      isPremium: updated.isPremium,
      coins: updated.coins,
      image: updated.image,
      rowOrder: updated.rowOrder,
      languageId: updated.languageId,
      status: updated.status,
    };
  }

  async deleteCategory(id: number) {
    const existing = await this.prisma.category.findUnique({ where: { id } });
    if (!existing) {
      throw new NotFoundException({ error: 'CATEGORY_NOT_FOUND', message: 'Category not found' });
    }
    await this.prisma.category.delete({ where: { id } });
    return { deleted: true, id };
  }

  async reorderCategories(dto: ReorderCategoriesDto) {
    await this.prisma.$transaction(
      dto.items.map((i) =>
        this.prisma.category.update({ where: { id: i.id }, data: { rowOrder: i.rowOrder } }),
      ),
    );
    return { reordered: dto.items.length };
  }

  // ─── Contests ─────────────────────────────────────────────────────────────

  private mapContest(c: {
    id: number;
    language_id: number;
    name: string;
    description: string;
    image: string;
    entry: number;
    prize_status: number;
    status: number;
    start_date: Date;
    end_date: Date;
    date_created: Date;
  }) {
    const now = Date.now();
    const start = c.start_date.getTime();
    const end = c.end_date.getTime();
    const statusLabel =
      c.status === 0
        ? 'cancelled'
        : end < now
        ? 'ended'
        : start > now
        ? 'draft'
        : 'active';
    return {
      id: c.id,
      title: c.name,
      name: c.name,
      description: c.description,
      image: c.image,
      entry: c.entry,
      entryFee: c.entry,
      prizePool: 0,
      prizeStatus: c.prize_status,
      languageId: c.language_id,
      startDate: c.start_date.toISOString(),
      endDate: c.end_date.toISOString(),
      startTime: c.start_date.toISOString(),
      endTime: c.end_date.toISOString(),
      maxParticipants: null as number | null,
      participantCount: 0,
      status: statusLabel,
      statusCode: c.status,
      createdAt: c.date_created.toISOString(),
      updatedAt: c.date_created.toISOString(),
    };
  }

  async listContests(q: ListPaginationDto) {
    const take = Math.min(q.limit ?? 50, 200);
    const page = q.page ?? 1;
    const skip = (page - 1) * take;
    const where = q.search ? { name: { contains: q.search } } : {};
    const [rows, total] = await Promise.all([
      this.prisma.tbl_contest.findMany({ where, orderBy: { id: 'desc' }, skip, take }),
      this.prisma.tbl_contest.count({ where }),
    ]);
    return this.paginate(rows.map((r) => this.mapContest(r)), total, page, take);
  }

  async getContest(id: number) {
    const row = await this.prisma.tbl_contest.findUnique({ where: { id } });
    if (!row) {
      throw new NotFoundException({ error: 'CONTEST_NOT_FOUND', message: 'Contest not found' });
    }
    return this.mapContest(row);
  }

  async createContest(dto: CreateContestDto) {
    const start = new Date(dto.startDate);
    const end = new Date(dto.endDate);
    if (end <= start) {
      throw new BadRequestException({
        error: 'INVALID_DATE_RANGE',
        message: 'endDate must be after startDate',
      });
    }
    const row = await this.prisma.tbl_contest.create({
      data: {
        name: dto.name,
        description: dto.description,
        image: dto.image ?? '',
        entry: dto.entry,
        prize_status: dto.prizeStatus ?? 0,
        status: dto.status ?? 1,
        language_id: dto.languageId ?? 0,
        start_date: start,
        end_date: end,
        date_created: new Date(),
      },
    });
    return this.mapContest(row);
  }

  async updateContest(id: number, dto: UpdateContestDto) {
    const existing = await this.prisma.tbl_contest.findUnique({ where: { id } });
    if (!existing) {
      throw new NotFoundException({ error: 'CONTEST_NOT_FOUND', message: 'Contest not found' });
    }
    const data: Record<string, unknown> = {};
    if (dto.name !== undefined) data['name'] = dto.name;
    if (dto.description !== undefined) data['description'] = dto.description;
    if (dto.image !== undefined) data['image'] = dto.image;
    if (dto.entry !== undefined) data['entry'] = dto.entry;
    if (dto.prizeStatus !== undefined) data['prize_status'] = dto.prizeStatus;
    if (dto.status !== undefined) data['status'] = dto.status;
    if (dto.languageId !== undefined) data['language_id'] = dto.languageId;
    if (dto.startDate !== undefined) data['start_date'] = new Date(dto.startDate);
    if (dto.endDate !== undefined) data['end_date'] = new Date(dto.endDate);
    const updated = await this.prisma.tbl_contest.update({ where: { id }, data });
    return this.mapContest(updated);
  }

  async deleteContest(id: number) {
    const existing = await this.prisma.tbl_contest.findUnique({ where: { id } });
    if (!existing) {
      throw new NotFoundException({ error: 'CONTEST_NOT_FOUND', message: 'Contest not found' });
    }
    await this.prisma.tbl_contest.delete({ where: { id } });
    return { deleted: true, id };
  }

  async distributeContestPrizes(id: number) {
    const existing = await this.prisma.tbl_contest.findUnique({ where: { id } });
    if (!existing) {
      throw new NotFoundException({ error: 'CONTEST_NOT_FOUND', message: 'Contest not found' });
    }
    if (existing.prize_status === 1) {
      throw new BadRequestException({
        error: 'ALREADY_DISTRIBUTED',
        message: 'Prizes already distributed for this contest',
      });
    }
    const updated = await this.prisma.tbl_contest.update({
      where: { id },
      data: { prize_status: 1 },
    });
    this.logger.log(`Contest ${id} prizes marked as distributed`);
    return this.mapContest(updated);
  }

  async listContestQuestions(contestId: number) {
    const contest = await this.prisma.tbl_contest.findUnique({ where: { id: contestId } });
    if (!contest) throw new NotFoundException({ error: 'CONTEST_NOT_FOUND', message: 'Contest not found' });
    const qs = await this.prisma.tbl_contest_question.findMany({
      where: { contest_id: contestId },
      orderBy: { id: 'asc' },
    });
    return {
      contestId,
      total: qs.length,
      questions: qs.map((q) => ({
        id: q.id,
        text: q.question,
        type: q.question_type,
        image: q.image,
        options: { a: q.optiona, b: q.optionb, c: q.optionc, d: q.optiond, ...(q.optione ? { e: q.optione } : {}) },
        answer: q.answer,
        note: q.note,
        languageId: q.langauge_id,
      })),
    };
  }

  async addContestQuestion(contestId: number, dto: {
    question: string; optiona: string; optionb: string; optionc: string; optiond: string;
    optione?: string; answer: string; image?: string; note?: string; languageId?: number;
  }) {
    const contest = await this.prisma.tbl_contest.findUnique({ where: { id: contestId } });
    if (!contest) throw new NotFoundException({ error: 'CONTEST_NOT_FOUND', message: 'Contest not found' });
    const q = await this.prisma.tbl_contest_question.create({
      data: {
        contest_id: contestId,
        question: dto.question,
        optiona: dto.optiona,
        optionb: dto.optionb,
        optionc: dto.optionc,
        optiond: dto.optiond,
        optione: dto.optione ?? '',
        answer: dto.answer,
        image: dto.image ?? '',
        note: dto.note ?? '',
        langauge_id: dto.languageId ?? 0,
        question_type: 0,
      },
    });
    return { id: q.id, contestId, text: q.question, answer: q.answer };
  }

  async updateContestQuestion(contestId: number, qid: number, dto: {
    question: string; optiona: string; optionb: string; optionc: string; optiond: string;
    optione?: string; answer: string; image?: string; note?: string; languageId?: number;
  }) {
    const q = await this.prisma.tbl_contest_question.findFirst({ where: { id: qid, contest_id: contestId } });
    if (!q) throw new NotFoundException({ error: 'QUESTION_NOT_FOUND', message: 'Question not found' });
    const updated = await this.prisma.tbl_contest_question.update({
      where: { id: qid },
      data: {
        question: dto.question,
        optiona: dto.optiona,
        optionb: dto.optionb,
        optionc: dto.optionc,
        optiond: dto.optiond,
        optione: dto.optione ?? '',
        answer: dto.answer,
        image: dto.image ?? q.image,
        note: dto.note ?? q.note,
        langauge_id: dto.languageId ?? q.langauge_id,
      },
    });
    return { id: updated.id, contestId, text: updated.question, answer: updated.answer };
  }

  async deleteContestQuestion(contestId: number, qid: number) {
    const q = await this.prisma.tbl_contest_question.findFirst({ where: { id: qid, contest_id: contestId } });
    if (!q) throw new NotFoundException({ error: 'QUESTION_NOT_FOUND', message: 'Question not found' });
    await this.prisma.tbl_contest_question.delete({ where: { id: qid } });
    return { deleted: true, id: qid };
  }

  async listLeagueDayQuestions(leagueId: number, dayId: number) {
    const day = await this.prisma.tbl_league_daily_quiz.findFirst({ where: { id: dayId, league_id: leagueId } });
    if (!day) throw new NotFoundException({ error: 'DAY_NOT_FOUND', message: 'Daily quiz slot not found' });
    const links = await this.prisma.tbl_league_daily_quiz_questions.findMany({
      where: { daily_quiz_id: dayId },
      orderBy: { question_order: 'asc' },
    });
    if (!links.length) return { dayId, leagueId, quizDay: day.quiz_day, total: 0, questions: [] };
    const ids = links.map((l) => l.question_id);
    const qs = await this.prisma.question.findMany({
      where: { id: { in: ids } },
      select: { id: true, question: true, optiona: true, optionb: true, optionc: true, optiond: true, optione: true, answer: true, category: true, level: true },
    });
    const qMap = new Map(qs.map((q) => [q.id, q]));
    return {
      dayId,
      leagueId,
      quizDay: day.quiz_day,
      total: links.length,
      questions: links.map((l) => {
        const q = qMap.get(l.question_id);
        return {
          linkId: l.id,
          questionId: l.question_id,
          order: l.question_order,
          text: q?.question ?? '(not found)',
          answer: q?.answer,
          categoryId: q?.category,
          level: q?.level,
        };
      }),
    };
  }

  async addLeagueDayQuestions(leagueId: number, dayId: number, questionIds: number[]) {
    const day = await this.prisma.tbl_league_daily_quiz.findFirst({ where: { id: dayId, league_id: leagueId } });
    if (!day) throw new NotFoundException({ error: 'DAY_NOT_FOUND', message: 'Daily quiz slot not found' });

    // Validate all question IDs exist
    const found = await this.prisma.question.findMany({ where: { id: { in: questionIds } }, select: { id: true } });
    if (found.length !== questionIds.length) {
      throw new BadRequestException({ error: 'INVALID_QUESTIONS', message: 'One or more question IDs not found' });
    }

    // Get current max order
    const maxOrder = await this.prisma.tbl_league_daily_quiz_questions.aggregate({
      where: { daily_quiz_id: dayId },
      _max: { question_order: true },
    });
    let order = (maxOrder._max.question_order ?? 0) + 1;

    const results: number[] = [];
    for (const qId of questionIds) {
      try {
        await this.prisma.tbl_league_daily_quiz_questions.create({
          data: { daily_quiz_id: dayId, question_id: qId, question_order: order++ },
        });
        results.push(qId);
      } catch {
        // skip duplicates (unique constraint)
      }
    }
    return { dayId, added: results.length, questionIds: results };
  }

  async removeLeagueDayQuestion(leagueId: number, dayId: number, linkId: number) {
    const day = await this.prisma.tbl_league_daily_quiz.findFirst({ where: { id: dayId, league_id: leagueId } });
    if (!day) throw new NotFoundException({ error: 'DAY_NOT_FOUND', message: 'Daily quiz slot not found' });
    const link = await this.prisma.tbl_league_daily_quiz_questions.findFirst({ where: { id: linkId, daily_quiz_id: dayId } });
    if (!link) throw new NotFoundException({ error: 'LINK_NOT_FOUND', message: 'Question link not found' });
    await this.prisma.tbl_league_daily_quiz_questions.delete({ where: { id: linkId } });
    return { deleted: true, id: linkId };
  }

  async distributeLeaguePrizes(id: number) {
    const existing = await this.prisma.tbl_league.findUnique({ where: { id } });
    if (!existing) {
      throw new NotFoundException({ error: 'LEAGUE_NOT_FOUND', message: 'League not found' });
    }
    if (existing.prize_status === 1) {
      throw new BadRequestException({
        error: 'ALREADY_DISTRIBUTED',
        message: 'Prizes already distributed for this league',
      });
    }
    if (existing.end_date.getTime() > Date.now()) {
      throw new BadRequestException({
        error: 'LEAGUE_NOT_ENDED',
        message: 'Cannot distribute prizes for a league that has not ended yet',
      });
    }
    const updated = await this.prisma.tbl_league.update({
      where: { id },
      data: { prize_status: 1, date_updated: new Date() },
    });
    this.logger.log(`League ${id} prizes marked as distributed`);
    return this.mapLeague(updated);
  }

  // ─── Leagues ──────────────────────────────────────────────────────────────

  private mapLeague(l: {
    id: number;
    language_id: number;
    name: string;
    description: string | null;
    image: string | null;
    entry: number;
    prize_status: number;
    status: number;
    start_date: Date;
    end_date: Date;
    date_created: Date;
    date_updated: Date | null;
  }) {
    const now = Date.now();
    const start = l.start_date.getTime();
    const end = l.end_date.getTime();
    const statusLabel =
      l.status === 0 ? 'ended' : start > now ? 'upcoming' : end < now ? 'ended' : 'active';
    return {
      id: l.id,
      name: l.name,
      description: l.description,
      image: l.image,
      entry: l.entry,
      languageId: l.language_id,
      prizeStatus: l.prize_status,
      startDate: l.start_date.toISOString(),
      endDate: l.end_date.toISOString(),
      tier: 1,
      season: 1,
      minXp: 0,
      maxXp: null as number | null,
      iconUrl: l.image,
      colorHex: null as string | null,
      memberCount: 0,
      participantCount: 0,
      status: statusLabel,
      statusCode: l.status,
      createdAt: l.date_created.toISOString(),
      updatedAt: (l.date_updated ?? l.date_created).toISOString(),
    };
  }

  async listLeagues(q: ListPaginationDto) {
    const take = Math.min(q.limit ?? 50, 200);
    const page = q.page ?? 1;
    const skip = (page - 1) * take;
    const where = q.search ? { name: { contains: q.search } } : {};
    const [rows, total] = await Promise.all([
      this.prisma.tbl_league.findMany({ where, orderBy: { id: 'desc' }, skip, take }),
      this.prisma.tbl_league.count({ where }),
    ]);
    return this.paginate(rows.map((r) => this.mapLeague(r)), total, page, take);
  }

  async getLeagueLeaderboard(id: number, limit = 50) {
    const safeLimit = Math.min(Math.max(limit, 1), 200);
    const league = await this.prisma.tbl_league.findUnique({
      where: { id },
      select: { id: true, name: true },
    });
    if (!league) {
      throw new NotFoundException({ error: 'LEAGUE_NOT_FOUND', message: 'League not found' });
    }
    const rows = await this.prisma.$queryRawUnsafe<
      Array<{
        user_id: number;
        name: string;
        profile: string | null;
        cumulative_best_score: number;
        games_played: number;
      }>
    >(
      `SELECT lb.user_id, lb.cumulative_best_score, lb.games_played, u.name, u.profile
       FROM tbl_league_leaderboard lb
       JOIN tbl_users u ON u.id = lb.user_id
       WHERE lb.league_id = ?
       ORDER BY lb.cumulative_best_score DESC, lb.last_updated ASC
       LIMIT ?`,
      id,
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
    return { leagueId: id, leagueName: league.name, entries };
  }

  async getLeague(id: number) {
    const row = await this.prisma.tbl_league.findUnique({ where: { id } });
    if (!row) {
      throw new NotFoundException({ error: 'LEAGUE_NOT_FOUND', message: 'League not found' });
    }
    return this.mapLeague(row);
  }

  async createLeague(dto: CreateLeagueDto) {
    const start = new Date(dto.startDate);
    const end = new Date(dto.endDate);
    if (end <= start) {
      throw new BadRequestException({
        error: 'INVALID_DATE_RANGE',
        message: 'endDate must be after startDate',
      });
    }
    const row = await this.prisma.tbl_league.create({
      data: {
        name: dto.name,
        description: dto.description ?? null,
        image: dto.image ?? null,
        entry: dto.entry ?? 0,
        language_id: dto.languageId ?? 0,
        status: dto.status ?? 1,
        start_date: start,
        end_date: end,
      },
    });
    return this.mapLeague(row);
  }

  async updateLeague(id: number, dto: UpdateLeagueDto) {
    const existing = await this.prisma.tbl_league.findUnique({ where: { id } });
    if (!existing) {
      throw new NotFoundException({ error: 'LEAGUE_NOT_FOUND', message: 'League not found' });
    }
    const data: Record<string, unknown> = { date_updated: new Date() };
    if (dto.name !== undefined) data['name'] = dto.name;
    if (dto.description !== undefined) data['description'] = dto.description;
    if (dto.image !== undefined) data['image'] = dto.image;
    if (dto.entry !== undefined) data['entry'] = dto.entry;
    if (dto.status !== undefined) data['status'] = dto.status;
    if (dto.languageId !== undefined) data['language_id'] = dto.languageId;
    if (dto.startDate !== undefined) data['start_date'] = new Date(dto.startDate);
    if (dto.endDate !== undefined) data['end_date'] = new Date(dto.endDate);
    const updated = await this.prisma.tbl_league.update({ where: { id }, data });
    return this.mapLeague(updated);
  }

  async deleteLeague(id: number) {
    const existing = await this.prisma.tbl_league.findUnique({ where: { id } });
    if (!existing) {
      throw new NotFoundException({ error: 'LEAGUE_NOT_FOUND', message: 'League not found' });
    }
    await this.prisma.tbl_league.delete({ where: { id } });
    return { deleted: true, id };
  }

  async getLeagueQuizSchedule(leagueId: number) {
    const league = await this.prisma.tbl_league.findUnique({ where: { id: leagueId } });
    if (!league) {
      throw new NotFoundException({ error: 'LEAGUE_NOT_FOUND', message: 'League not found' });
    }
    const days = await this.prisma.tbl_league_daily_quiz.findMany({
      where: { league_id: leagueId },
      orderBy: { quiz_day: 'asc' },
    });
    return days.map((d) => ({
      id: d.id,
      leagueId: d.league_id,
      quizDay: d.quiz_day,
      quizDate: d.quiz_date?.toISOString().split('T')[0] ?? null,
      questionCount: d.question_count,
      dateAssigned: d.date_assigned?.toISOString() ?? null,
    }));
  }

  async assignLeagueDay(leagueId: number, dto: { quizDay: number; quizDate: string; questionCount?: number }) {
    const league = await this.prisma.tbl_league.findUnique({ where: { id: leagueId } });
    if (!league) {
      throw new NotFoundException({ error: 'LEAGUE_NOT_FOUND', message: 'League not found' });
    }
    const row = await this.prisma.tbl_league_daily_quiz.upsert({
      where: { league_id_quiz_day: { league_id: leagueId, quiz_day: dto.quizDay } },
      update: {
        quiz_date: new Date(dto.quizDate),
        question_count: dto.questionCount ?? 20,
        date_assigned: new Date(),
      },
      create: {
        league_id: leagueId,
        quiz_day: dto.quizDay,
        quiz_date: new Date(dto.quizDate),
        question_count: dto.questionCount ?? 20,
      },
    });
    return {
      id: row.id,
      leagueId: row.league_id,
      quizDay: row.quiz_day,
      quizDate: row.quiz_date?.toISOString().split('T')[0] ?? null,
      questionCount: row.question_count,
      dateAssigned: row.date_assigned?.toISOString() ?? null,
    };
  }

  // ─── Sponsors ─────────────────────────────────────────────────────────────

  private mapSponsor(s: {
    id: number;
    sponsor_name: string;
    title: string | null;
    imageUrl: string | null;
    redirect_url: string | null;
    redirect_type: string | null;
    impression_limit: number | null;
    impression_period: string | null;
    current_impressions: number | null;
    startDate: Date;
    endDate: Date;
    is_active: number | null;
    priority: number | null;
    createdAt: Date | null;
  }) {
    return {
      id: s.id,
      sponsorName: s.sponsor_name,
      name: s.sponsor_name,
      title: s.title,
      imageUrl: s.imageUrl,
      logoUrl: s.imageUrl,
      redirectUrl: s.redirect_url,
      websiteUrl: s.redirect_url,
      contactEmail: null as string | null,
      redirectType: s.redirect_type,
      impressionLimit: s.impression_limit ?? 0,
      impressionPeriod: s.impression_period,
      currentImpressions: s.current_impressions ?? 0,
      startDate: s.startDate.toISOString(),
      endDate: s.endDate.toISOString(),
      priority: s.priority ?? 0,
      isActive: (s.is_active ?? 0) === 1,
      createdAt: s.createdAt?.toISOString() ?? null,
      updatedAt: s.createdAt?.toISOString() ?? null,
    };
  }

  async listSponsors(q: ListPaginationDto) {
    const take = Math.min(q.limit ?? 50, 200);
    const page = q.page ?? 1;
    const skip = (page - 1) * take;
    const where = q.search ? { sponsor_name: { contains: q.search } } : {};
    const [rows, total] = await Promise.all([
      this.prisma.sponsorBanner.findMany({
        where,
        orderBy: [{ priority: 'desc' }, { id: 'desc' }],
        skip,
        take,
      }),
      this.prisma.sponsorBanner.count({ where }),
    ]);
    return this.paginate(rows.map((r) => this.mapSponsor(r)), total, page, take);
  }

  async createSponsor(dto: CreateSponsorDto) {
    const start = new Date(dto.startDate);
    const end = new Date(dto.endDate);
    if (end <= start) {
      throw new BadRequestException({
        error: 'INVALID_DATE_RANGE',
        message: 'endDate must be after startDate',
      });
    }
    const row = await this.prisma.sponsorBanner.create({
      data: {
        sponsor_name: dto.sponsorName,
        title: dto.title ?? null,
        imageUrl: dto.imageUrl,
        redirect_url: dto.redirectUrl ?? null,
        redirect_type: dto.redirectType ?? 'url',
        impression_limit: dto.impressionLimit ?? 0,
        impression_period: dto.impressionPeriod ?? 'daily',
        startDate: start,
        endDate: end,
        priority: dto.priority ?? 0,
        is_active: dto.isActive ?? 1,
      },
    });
    return this.mapSponsor(row);
  }

  async updateSponsor(id: number, dto: UpdateSponsorDto) {
    const existing = await this.prisma.sponsorBanner.findUnique({ where: { id } });
    if (!existing) {
      throw new NotFoundException({ error: 'SPONSOR_NOT_FOUND', message: 'Sponsor not found' });
    }
    const data: Record<string, unknown> = {};
    if (dto.sponsorName !== undefined) data['sponsor_name'] = dto.sponsorName;
    if (dto.title !== undefined) data['title'] = dto.title;
    if (dto.imageUrl !== undefined) data['imageUrl'] = dto.imageUrl;
    if (dto.redirectUrl !== undefined) data['redirect_url'] = dto.redirectUrl;
    if (dto.redirectType !== undefined) data['redirect_type'] = dto.redirectType;
    if (dto.impressionLimit !== undefined) data['impression_limit'] = dto.impressionLimit;
    if (dto.impressionPeriod !== undefined) data['impression_period'] = dto.impressionPeriod;
    if (dto.priority !== undefined) data['priority'] = dto.priority;
    if (dto.isActive !== undefined) data['is_active'] = dto.isActive;
    if (dto.startDate !== undefined) data['startDate'] = new Date(dto.startDate);
    if (dto.endDate !== undefined) data['endDate'] = new Date(dto.endDate);
    const updated = await this.prisma.sponsorBanner.update({ where: { id }, data });
    return this.mapSponsor(updated);
  }

  async deleteSponsor(id: number) {
    const existing = await this.prisma.sponsorBanner.findUnique({ where: { id } });
    if (!existing) {
      throw new NotFoundException({ error: 'SPONSOR_NOT_FOUND', message: 'Sponsor not found' });
    }
    await this.prisma.sponsorBanner.delete({ where: { id } });
    return { deleted: true, id };
  }

  // ─── Notifications history ────────────────────────────────────────────────

  async listNotifications(q: ListPaginationDto) {
    const take = Math.min(q.limit ?? 50, 200);
    const page = q.page ?? 1;
    const skip = (page - 1) * take;
    const where = q.search ? { title: { contains: q.search } } : {};
    const [rows, total] = await Promise.all([
      this.prisma.tbl_notifications.findMany({
        where,
        orderBy: { id: 'desc' },
        skip,
        take,
      }),
      this.prisma.tbl_notifications.count({ where }),
    ]);
    const items = rows.map((n) => ({
      id: n.id,
      title: n.title,
      message: n.message,
      type: n.type,
      typeId: n.type_id,
      image: n.image,
      audience: n.users,
      userIds: n.user_id,
      dateSent: n.date_sent.toISOString(),
      deliveredCount: n.delivered_count,
      failedCount: n.failed_count,
    }));
    return this.paginate(items, total, page, take);
  }

  // ─── Admin Auth (tbl_authenticate) ──────────────────────────────────────

  /**
   * Verify admin credentials against tbl_authenticate.
   * Handles PHP bcrypt ($2y$) hashes by normalising to $2b$ before comparison.
   * Returns null (never throws) so the controller can issue a generic 401.
   */
  async verifyAdminCredentials(dto: AdminLoginDto): Promise<{
    id: number;
    username: string;
    role: string;
    permissions: string;
    firebaseCustomToken: string;
  } | null> {
    try {
      const admin = await this.prisma.tbl_authenticate.findUnique({
        where: { auth_username: dto.username },
      });

      // Reject if not found or account is inactive (status !== 1)
      if (!admin || admin.status !== 1) return null;

      // PHP uses $2y$ prefix; bcryptjs expects $2b$ — they are algorithmically identical
      const hash = admin.auth_pass.replace(/^\$2y\$/, '$2b$');
      const valid = await bcrypt.compare(dto.password, hash);
      if (!valid) return null;

      // Create a Firebase custom token so the admin panel can authenticate
      // against FirebaseAuthGuard-protected NestJS endpoints.
      // UID format: admin_<auth_id> — distinct from end-user UIDs.
      const uid = `admin_${admin.auth_id}`;
      const firebaseCustomToken = await this.firebase
        .auth()
        .createCustomToken(uid, { admin: true, role: admin.role });

      return {
        id: admin.auth_id,
        username: admin.auth_username,
        role: admin.role,
        permissions: admin.permissions,
        firebaseCustomToken,
      };
    } catch (err) {
      this.logger.error('verifyAdminCredentials error', err);
      return null;
    }
  }

  // ─── Coin Store (IAP packs) ─────────────────────────────────────────────

  async listCoinPacks() {
    const rows = await this.prisma.tbl_coin_store.findMany({
      orderBy: [{ status: 'desc' }, { coins: 'asc' }, { id: 'asc' }],
    });
    return rows.map((r) => this.mapCoinPack(r));
  }

  async createCoinPack(dto: CreateCoinPackDto) {
    const productId = dto.productId?.trim() || `pack_${dto.coins}_${Date.now()}`;
    const existing = await this.prisma.tbl_coin_store.findUnique({
      where: { product_id: productId },
    });
    if (existing) {
      throw new ConflictException({
        error: 'PRODUCT_ID_EXISTS',
        message: `productId '${productId}' already exists`,
      });
    }
    const row = await this.prisma.tbl_coin_store.create({
      data: {
        title: dto.title,
        coins: dto.coins,
        priceKobo: dto.priceKobo,
        product_id: productId,
        image: dto.imageUrl ?? null,
        description: dto.description ?? '',
        type: 0,
        status: 1,
      },
    });
    return this.mapCoinPack(row);
  }

  async updateCoinPack(id: number, dto: UpdateCoinPackDto) {
    const existing = await this.prisma.tbl_coin_store.findUnique({ where: { id } });
    if (!existing) {
      throw new NotFoundException({
        error: 'COIN_PACK_NOT_FOUND',
        message: 'Coin pack not found',
      });
    }
    if (dto.productId && dto.productId !== existing.product_id) {
      const dup = await this.prisma.tbl_coin_store.findUnique({
        where: { product_id: dto.productId },
      });
      if (dup) {
        throw new ConflictException({
          error: 'PRODUCT_ID_EXISTS',
          message: `productId '${dto.productId}' already exists`,
        });
      }
    }
    const data: Record<string, unknown> = {};
    if (dto.title !== undefined) data['title'] = dto.title;
    if (dto.coins !== undefined) data['coins'] = dto.coins;
    if (dto.priceKobo !== undefined) data['priceKobo'] = dto.priceKobo;
    if (dto.productId !== undefined) data['product_id'] = dto.productId;
    if (dto.imageUrl !== undefined) data['image'] = dto.imageUrl;
    if (dto.description !== undefined) data['description'] = dto.description;
    const updated = await this.prisma.tbl_coin_store.update({ where: { id }, data });
    return this.mapCoinPack(updated);
  }

  async deleteCoinPack(id: number) {
    const existing = await this.prisma.tbl_coin_store.findUnique({ where: { id } });
    if (!existing) {
      throw new NotFoundException({
        error: 'COIN_PACK_NOT_FOUND',
        message: 'Coin pack not found',
      });
    }
    // Soft delete: status=0 preserves history of past purchases referencing this pack.
    await this.prisma.tbl_coin_store.update({ where: { id }, data: { status: 0 } });
    return { deleted: true, id };
  }

  private mapCoinPack(r: {
    id: number;
    title: string;
    coins: number;
    type: number;
    product_id: string;
    image: string | null;
    description: string;
    status: number;
    priceKobo: number;
  }) {
    return {
      id: r.id,
      title: r.title,
      coins: r.coins,
      type: r.type,
      productId: r.product_id,
      image: r.image,
      description: r.description,
      status: r.status,
      priceKobo: r.priceKobo,
    };
  }

  // ─── Progress Stages ────────────────────────────────────────────────────

  async listProgressStages() {
    return this.prisma.progressStage.findMany({
      orderBy: [{ stageNumber: 'asc' }],
    });
  }

  async createProgressStage(dto: CreateProgressStageDto) {
    try {
      return await this.prisma.progressStage.create({
        data: {
          stageNumber: dto.stageNumber,
          name: dto.name,
          minScore: dto.minScore,
          iconUrl: dto.iconUrl ?? null,
          isActive: dto.isActive ?? true,
        },
      });
    } catch (e: unknown) {
      if (
        typeof e === 'object' &&
        e !== null &&
        'code' in e &&
        (e as { code?: string }).code === 'P2002'
      ) {
        throw new ConflictException({
          error: 'STAGE_NUMBER_EXISTS',
          message: `stageNumber ${dto.stageNumber} already exists`,
        });
      }
      throw e;
    }
  }

  async updateProgressStage(id: number, dto: UpdateProgressStageDto) {
    const existing = await this.prisma.progressStage.findUnique({ where: { id } });
    if (!existing) {
      throw new NotFoundException({
        error: 'STAGE_NOT_FOUND',
        message: 'Progress stage not found',
      });
    }
    const data: Record<string, unknown> = {};
    if (dto.stageNumber !== undefined) data['stageNumber'] = dto.stageNumber;
    if (dto.name !== undefined) data['name'] = dto.name;
    if (dto.minScore !== undefined) data['minScore'] = dto.minScore;
    if (dto.iconUrl !== undefined) data['iconUrl'] = dto.iconUrl;
    if (dto.isActive !== undefined) data['isActive'] = dto.isActive;
    try {
      return await this.prisma.progressStage.update({ where: { id }, data });
    } catch (e: unknown) {
      if (
        typeof e === 'object' &&
        e !== null &&
        'code' in e &&
        (e as { code?: string }).code === 'P2002'
      ) {
        throw new ConflictException({
          error: 'STAGE_NUMBER_EXISTS',
          message: `stageNumber ${dto.stageNumber} already exists`,
        });
      }
      throw e;
    }
  }

  async deleteProgressStage(id: number) {
    const existing = await this.prisma.progressStage.findUnique({ where: { id } });
    if (!existing) {
      throw new NotFoundException({
        error: 'STAGE_NOT_FOUND',
        message: 'Progress stage not found',
      });
    }
    await this.prisma.progressStage.delete({ where: { id } });
    return { deleted: true, id };
  }

  // ─── Partner oversight (delegated to PartnerService) ─────────────────────

  adminListPartners(status?: string, plan?: string, page = 1, limit = 50) {
    return this.partnerService.adminListPartners(status, plan, page, limit);
  }

  adminGetPartner(id: number) {
    return this.partnerService.adminGetPartner(id);
  }

  adminApprovePartner(id: number) {
    return this.partnerService.adminApprovePartner(id);
  }

  adminSuspendPartner(id: number) {
    return this.partnerService.adminSuspendPartner(id);
  }

  adminOverridePlan(id: number, plan: string, expiresAt?: string) {
    return this.partnerService.adminOverridePlan(id, plan, expiresAt);
  }

  adminGetPartnerContests(id: number, page = 1, limit = 20) {
    return this.partnerService.adminGetPartnerContests(id, page, limit);
  }
}
