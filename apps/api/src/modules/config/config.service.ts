import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { RedisService } from '../../redis/redis.service';

const CACHE_TTL = 300;
const CACHE_KEY = 'config:settings:all';

@Injectable()
export class ConfigDataService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly redis: RedisService,
  ) {}

  async getAllSettings() {
    const cached = await this.redis.get<Record<string, unknown>>(CACHE_KEY);
    if (cached) return { settings: cached, cached: true };

    const rows = await this.prisma.settings.findMany();
    const settings: Record<string, unknown> = {};
    for (const r of rows) {
      // Settings.message is sometimes JSON, sometimes a plain string.
      try {
        settings[r.type] = JSON.parse(r.message);
      } catch {
        settings[r.type] = r.message;
      }
    }
    await this.redis.set(CACHE_KEY, settings, CACHE_TTL);
    return { settings, cached: false };
  }

  async getByType(type: string) {
    const all = await this.getAllSettings();
    const value = all.settings[type];
    if (value === undefined) {
      throw new NotFoundException({
        error: 'SETTING_NOT_FOUND',
        message: `Setting "${type}" not configured`,
      });
    }
    return { type, value };
  }

  async invalidate() {
    await this.redis.del(CACHE_KEY);
  }
}
