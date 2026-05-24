import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { CoinHistoryQueryDto } from '../users/dto/coin-history-query.dto';

@Injectable()
export class CoinsService {
  constructor(private readonly prisma: PrismaService) {}

  async getBalance(firebaseUid: string) {
    const user = await this.prisma.user.findFirst({
      where: { firebaseId: firebaseUid },
      select: { id: true, coins: true },
    });
    if (!user) throw new NotFoundException({ error: 'USER_NOT_FOUND', message: 'User not found' });
    return { coins: user.coins };
  }

  async getHistory(firebaseUid: string, q: CoinHistoryQueryDto) {
    const user = await this.prisma.user.findFirst({
      where: { firebaseId: firebaseUid },
      select: { id: true },
    });
    if (!user) throw new NotFoundException({ error: 'USER_NOT_FOUND', message: 'User not found' });

    const take = Math.min(q.limit ?? 20, 100);
    const skip = ((q.page ?? 1) - 1) * take;
    const [items, total] = await Promise.all([
      this.prisma.tracker.findMany({
        where: { userId: user.id },
        orderBy: { id: 'desc' },
        skip,
        take,
      }),
      this.prisma.tracker.count({ where: { userId: user.id } }),
    ]);
    return {
      items: items.map((t) => ({
        id: t.id,
        points: Number(t.points) || 0,
        type: t.type,
        direction: t.status === 0 ? 'earned' : 'spent',
        date: t.date,
      })),
      pagination: { page: q.page ?? 1, limit: take, total, pages: Math.ceil(total / take) },
    };
  }

  async getStore() {
    const items = await this.prisma.tbl_coin_store.findMany({
      where: { status: 1 },
      orderBy: { coins: 'asc' },
      select: { id: true, title: true, coins: true, product_id: true, image: true, description: true },
    });
    return { items };
  }
}
