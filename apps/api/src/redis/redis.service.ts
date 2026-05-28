import { Inject, Injectable, Logger, OnModuleDestroy } from '@nestjs/common';
import Redis from 'ioredis';
import { REDIS_CLIENT } from './redis.constants';

@Injectable()
export class RedisService implements OnModuleDestroy {
  private readonly logger = new Logger(RedisService.name);

  constructor(@Inject(REDIS_CLIENT) private readonly client: Redis) {}

  getClient(): Redis {
    return this.client;
  }

  async get<T = unknown>(key: string): Promise<T | null> {
    try {
      const raw = await this.client.get(key);
      if (raw === null) return null;
      return JSON.parse(raw) as T;
    } catch {
      return null;
    }
  }

  async set(key: string, value: unknown, ttlSeconds?: number): Promise<void> {
    try {
      const serialized = typeof value === 'string' ? value : JSON.stringify(value);
      if (ttlSeconds && ttlSeconds > 0) {
        await this.client.set(key, serialized, 'EX', ttlSeconds);
      } else {
        await this.client.set(key, serialized);
      }
    } catch {
      // best-effort cache — log and continue
      this.logger.warn(`Redis set failed for key: ${key}`);
    }
  }

  async del(...keys: string[]): Promise<number> {
    if (keys.length === 0) return 0;
    try {
      return await this.client.del(...keys);
    } catch {
      return 0;
    }
  }

  async expire(key: string, ttlSeconds: number): Promise<void> {
    try {
      await this.client.expire(key, ttlSeconds);
    } catch {
      // best-effort
    }
  }

  async zadd(key: string, score: number, member: string): Promise<void> {
    try {
      await this.client.zadd(key, score, member);
    } catch {
      this.logger.warn(`Redis zadd failed for key: ${key}`);
    }
  }

  async zrevrange(key: string, start: number, stop: number, withScores = false): Promise<string[]> {
    try {
      return withScores
        ? this.client.zrevrange(key, start, stop, 'WITHSCORES')
        : this.client.zrevrange(key, start, stop);
    } catch {
      return [];
    }
  }

  async zrevrank(key: string, member: string): Promise<number | null> {
    try {
      return await this.client.zrevrank(key, member);
    } catch {
      return null;
    }
  }

  async onModuleDestroy(): Promise<void> {
    try {
      await this.client.quit();
    } catch {
      // ignore quit errors
    }
    this.logger.log('Redis disconnected');
  }
}
