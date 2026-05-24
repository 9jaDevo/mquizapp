import { Injectable, Logger, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { FirebaseService } from '../../firebase/firebase.service';
import { RedisService } from '../../redis/redis.service';
import { ListPaginationDto } from './dto/list-pagination.dto';
import { ResolveFraudDto } from './dto/resolve-fraud.dto';
import { SendNotificationDto } from './dto/send-notification.dto';
import { UpdateSettingDto } from './dto/update-setting.dto';

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
