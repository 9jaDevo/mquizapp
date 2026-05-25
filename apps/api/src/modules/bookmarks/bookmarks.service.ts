import { ConflictException, Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { CreateBookmarkDto, BookmarkQueryDto } from './dto/bookmark.dto';

@Injectable()
export class BookmarksService {
  constructor(private readonly prisma: PrismaService) {}

  async listBookmarks(userId: number, q: BookmarkQueryDto) {
    const take = Math.min(q.limit ?? 20, 100);
    const skip = ((q.page ?? 1) - 1) * take;

    const [items, total] = await this.prisma.$transaction([
      this.prisma.userBookmark.findMany({
        where: { userId },
        orderBy: { createdAt: 'desc' },
        skip,
        take,
        select: {
          id: true,
          questionId: true,
          createdAt: true,
        },
      }),
      this.prisma.userBookmark.count({ where: { userId } }),
    ]);

    return {
      items,
      total,
      page: q.page ?? 1,
      limit: take,
      totalPages: Math.max(1, Math.ceil(total / take)),
    };
  }

  async createBookmark(userId: number, dto: CreateBookmarkDto) {
    // Verify the question exists before bookmarking
    const question = await this.prisma.question.findUnique({
      where: { id: dto.questionId },
      select: { id: true },
    });
    if (!question) {
      throw new NotFoundException('Question not found');
    }

    try {
      const bookmark = await this.prisma.userBookmark.create({
        data: { userId, questionId: dto.questionId },
        select: { id: true, questionId: true, createdAt: true },
      });
      return bookmark;
    } catch (e: unknown) {
      // Unique constraint violation — already bookmarked
      if (
        e instanceof Error &&
        'code' in e &&
        (e as { code: string }).code === 'P2002'
      ) {
        throw new ConflictException('Question is already bookmarked');
      }
      throw e;
    }
  }

  async deleteBookmark(userId: number, questionId: number) {
    const existing = await this.prisma.userBookmark.findUnique({
      where: { uq_user_question: { userId, questionId } },
    });
    if (!existing) {
      throw new NotFoundException('Bookmark not found');
    }
    await this.prisma.userBookmark.delete({
      where: { uq_user_question: { userId, questionId } },
    });
    return { deleted: true, questionId };
  }
}
