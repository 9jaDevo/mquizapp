import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { ListNotificationsQueryDto } from './dto/list-notifications-query.dto';

@Injectable()
export class NotificationsService {
  constructor(private readonly prisma: PrismaService) {}

  async list(firebaseUid: string, q: ListNotificationsQueryDto) {
    const user = await this.prisma.user.findFirst({
      where: { firebaseId: firebaseUid },
      select: { id: true },
    });
    if (!user) throw new NotFoundException({ error: 'USER_NOT_FOUND', message: 'User not found' });

    const take = Math.min(q.limit ?? 20, 100);
    const skip = ((q.page ?? 1) - 1) * take;
    // tbl_notifications targets all OR specific user(s). user_id is a CSV LongText.
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
    return {
      items: all.map((n) => ({
        id: n.id,
        title: n.title,
        message: n.message,
        type: n.type,
        typeId: n.type_id,
        image: n.image,
        dateSent: n.date_sent,
      })),
      pagination: { page: q.page ?? 1, limit: take, total, pages: Math.ceil(total / take) },
    };
  }
}
