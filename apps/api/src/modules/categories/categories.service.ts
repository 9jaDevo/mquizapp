import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { RedisService } from '../../redis/redis.service';
import { ListCategoriesQueryDto } from './dto/list-categories-query.dto';

const CACHE_TTL = 300; // 5 minutes

@Injectable()
export class CategoriesService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly redis: RedisService,
  ) {}

  async listCategories(q: ListCategoriesQueryDto) {
    const cacheKey = q.languageId !== undefined
      ? `categories:lang:${q.languageId}`
      : `categories:all`;
    const cached = await this.redis.get<unknown[]>(cacheKey);
    if (cached) return { categories: cached, cached: true };

    const langFilter = q.languageId !== undefined ? { languageId: q.languageId } : {};
    const categories = await this.prisma.category.findMany({
      where: { ...langFilter, status: 1 },
      orderBy: [{ rowOrder: 'asc' }, { id: 'asc' }],
      select: {
        id: true,
        categoryName: true,
        slug: true,
        type: true,
        isPremium: true,
        coins: true,
        image: true,
        rowOrder: true,
      },
    }).catch(() =>
      // Fallback: status column may not yet exist in the legacy DB schema
      this.prisma.category.findMany({
        where: { ...langFilter },
        orderBy: [{ rowOrder: 'asc' }, { id: 'asc' }],
        select: {
          id: true,
          categoryName: true,
          slug: true,
          type: true,
          isPremium: true,
          coins: true,
          image: true,
          rowOrder: true,
        },
      }),
    );
    await this.redis.set(cacheKey, categories, CACHE_TTL);
    return { categories, cached: false };
  }

  async listSubcategories(categoryId: number, q: ListCategoriesQueryDto) {
    const cacheKey = q.languageId !== undefined
      ? `subcategories:lang:${q.languageId}:cat:${categoryId}`
      : `subcategories:cat:${categoryId}`;
    const cached = await this.redis.get<unknown[]>(cacheKey);
    if (cached) return { subcategories: cached, cached: true };

    const langFilter = q.languageId !== undefined ? { languageId: q.languageId } : {};
    const subcategories = await this.prisma.subcategory.findMany({
      where: { ...langFilter, maincatId: categoryId, status: 1 },
      orderBy: [{ rowOrder: 'asc' }, { id: 'asc' }],
      select: {
        id: true,
        subcategoryName: true,
        slug: true,
        image: true,
        isPremium: true,
        coins: true,
        rowOrder: true,
      },
    }).catch(() =>
      this.prisma.subcategory.findMany({
        where: { ...langFilter, maincatId: categoryId },
        orderBy: [{ rowOrder: 'asc' }, { id: 'asc' }],
        select: {
          id: true,
          subcategoryName: true,
          slug: true,
          image: true,
          isPremium: true,
          coins: true,
          rowOrder: true,
        },
      }),
    );
    await this.redis.set(cacheKey, subcategories, CACHE_TTL);
    return { subcategories, cached: false };
  }

  async invalidateCache(languageId?: number) {
    // Invalidate both the language-scoped and the unfiltered cache keys
    await this.redis.del(`categories:all`);
    if (languageId !== undefined) {
      await this.redis.del(`categories:lang:${languageId}`);
    }
  }
}
