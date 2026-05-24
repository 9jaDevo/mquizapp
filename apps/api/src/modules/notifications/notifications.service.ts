import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { RedisService } from '../../redis/redis.service';
import { ListNotificationsQueryDto } from './dto/list-notifications-query.dto';

const READ_TTL_SECONDS = 30 * 24 * 3600; // 30 days

@Injectable()
export class NotificationsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly redis: RedisService,
  ) {}

  async list(firebaseUid: string, q: ListNotificationsQueryDto) {
    const user = await this.prisma.user.findFirst({
      where: { firebaseId: firebaseUid },
      select: { id: true },
    });
    if (!user) throw new NotFoundException({ error: 'USER_NOT_FOUND', message: 'User not found' });

    const take = Math.min(q.limit ?? 20, 100);
    const skip = ((q.page ?? 1) - 1) * take;
    const [all, total] = await Promise.all([
      this.prisma.tbl_notifications.findMany({
        where: {
          OR: [{ users: 'all' }, { user_id: { contains: user.id.toString() } }],
        },
        orderBy: { id: 'desc' },
        skip,
        take,
      }),
      this.prisma.tbl_notifications.count({
        where: {
          OR: [{ users: 'all' }, { user_id: { contains: user.id.toString() } }],
        },
      }),
    ]);

    // Batch-check read status from Redis
    const readSet = new Set<number>();
    if (all.length) {
      const keys = all.map((n) => `notif:read:${user.id}:${n.id}`);
      const vals = await this.redis.getClient().mget(keys);
      vals.forEach((v, i) => {
        if (v) readSet.add(all[i].id);
      });
    }

    return {
      items: all.map((n) => ({
        id: n.id,
        title: n.title,
        message: n.message,
        type: n.type,
        typeId: n.type_id,
        image: n.image,
        dateSent: n.date_sent,
        isRead: readSet.has(n.id),
      })),
      unreadCount: all.filter((n) => !readSet.has(n.id)).length,
      pagination: { page: q.page ?? 1, limit: take, total, pages: Math.ceil(total / take) },
    };
  }

  async markRead(firebaseUid: string, notifId: number) {
    const user = await this.prisma.user.findFirst({
      where: { firebaseId: firebaseUid },
      select: { id: true },
    });
    if (!user) throw new NotFoundException({ error: 'USER_NOT_FOUND', message: 'User not found' });

    const notif = await this.prisma.tbl_notifications.findUnique({ where: { id: notifId } });
    if (!notif) {
      throw new NotFoundException({ error: 'NOTIFICATION_NOT_FOUND', message: 'Notification not found' });
    }

    // Validate this notification is addressed to the current user
    const isTargeted = notif.users === 'all' || (notif.user_id ?? '').split(',').includes(user.id.toString());
    if (!isTargeted) {
      throw new NotFoundException({ error: 'NOTIFICATION_NOT_FOUND', message: 'Notification not found' });
    }

    await this.redis.set(`notif:read:${user.id}:${notifId}`, '1', READ_TTL_SECONDS);

    return { id: notifId, read: true };
  }
}

