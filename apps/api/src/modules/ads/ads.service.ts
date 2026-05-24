import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { RedisService } from '../../redis/redis.service';
import { RecordImpressionDto } from './dto/record-impression.dto';

const CACHE_KEY = 'ads:banners:active';
const CACHE_TTL = 60;

@Injectable()
export class AdsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly redis: RedisService,
  ) {}

  async getActiveBanners() {
    const cached = await this.redis.get<unknown[]>(CACHE_KEY);
    if (cached) return { banners: cached, cached: true };

    const now = new Date();
    const banners = await this.prisma.sponsorBanner.findMany({
      where: {
        is_active: 1,
        startDate: { lte: now },
        endDate: { gte: now },
      },
      orderBy: [{ priority: 'desc' }, { id: 'asc' }],
      select: {
        id: true,
        sponsor_name: true,
        title: true,
        imageUrl: true,
        redirect_url: true,
        redirect_type: true,
        priority: true,
      },
    });
    await this.redis.set(CACHE_KEY, banners, CACHE_TTL);
    return { banners, cached: false };
  }

  async recordImpression(firebaseUid: string, dto: RecordImpressionDto) {
    const userId = await this.resolveUserId(firebaseUid);
    const banner = await this.prisma.sponsorBanner.findUnique({ where: { id: dto.bannerId } });
    if (!banner) {
      throw new NotFoundException({ error: 'BANNER_NOT_FOUND', message: 'Banner not found' });
    }
    await this.prisma.tbl_banner_impressions.create({
      data: {
        banner_id: dto.bannerId,
        user_id: userId,
        action: dto.action,
      },
    });
    if (dto.action === 'showed') {
      await this.prisma.sponsorBanner.update({
        where: { id: dto.bannerId },
        data: { current_impressions: { increment: 1 } },
      });
    }
    await this.redis.del(CACHE_KEY);
    return { recorded: true };
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
