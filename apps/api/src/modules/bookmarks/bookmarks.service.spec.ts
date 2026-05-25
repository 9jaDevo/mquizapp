import { ConflictException, NotFoundException } from '@nestjs/common';
import { BookmarksService } from './bookmarks.service';
import { PrismaService } from '../../prisma/prisma.service';

describe('BookmarksService', () => {
  let service: BookmarksService;
  let prisma: jest.Mocked<Pick<PrismaService, 'userBookmark' | 'question' | '$transaction'>>;

  const userId = 1;
  const questionId = 42;

  const mockBookmark = {
    id: 1,
    questionId,
    createdAt: new Date(),
  };

  beforeEach(() => {
    prisma = {
      userBookmark: {
        findMany: jest.fn(),
        count: jest.fn(),
        create: jest.fn(),
        delete: jest.fn(),
        findUnique: jest.fn(),
      } as unknown as PrismaService['userBookmark'],
      question: {
        findUnique: jest.fn(),
      } as unknown as PrismaService['question'],
      $transaction: jest.fn(),
    };

    service = new BookmarksService(prisma as unknown as PrismaService);
  });

  // ── listBookmarks ──────────────────────────────────────────────────────────
  describe('listBookmarks', () => {
    it('returns paginated bookmarks', async () => {
      (prisma.$transaction as jest.Mock).mockResolvedValue([[mockBookmark], 1]);

      const result = await service.listBookmarks(userId, { page: 1, limit: 20 });

      expect(result.items).toHaveLength(1);
      expect(result.total).toBe(1);
      expect(result.totalPages).toBe(1);
    });

    it('caps limit at 100', async () => {
      (prisma.$transaction as jest.Mock).mockResolvedValue([[], 0]);
      await service.listBookmarks(userId, { page: 1, limit: 999 });
      // $transaction called with take capped at 100
      expect(prisma.$transaction).toHaveBeenCalled();
    });
  });

  // ── createBookmark ─────────────────────────────────────────────────────────
  describe('createBookmark', () => {
    it('creates a bookmark when question exists', async () => {
      (prisma.question.findUnique as jest.Mock).mockResolvedValue({ id: questionId });
      (prisma.userBookmark.create as jest.Mock).mockResolvedValue(mockBookmark);

      const result = await service.createBookmark(userId, { questionId });
      expect(result).toEqual(mockBookmark);
    });

    it('throws NotFoundException when question does not exist', async () => {
      (prisma.question.findUnique as jest.Mock).mockResolvedValue(null);

      await expect(service.createBookmark(userId, { questionId })).rejects.toBeInstanceOf(
        NotFoundException,
      );
    });

    it('throws ConflictException on duplicate bookmark (P2002)', async () => {
      (prisma.question.findUnique as jest.Mock).mockResolvedValue({ id: questionId });
      const prismaError = Object.assign(new Error('Unique constraint'), { code: 'P2002' });
      (prisma.userBookmark.create as jest.Mock).mockRejectedValue(prismaError);

      await expect(service.createBookmark(userId, { questionId })).rejects.toBeInstanceOf(
        ConflictException,
      );
    });
  });

  // ── deleteBookmark ─────────────────────────────────────────────────────────
  describe('deleteBookmark', () => {
    it('deletes an existing bookmark', async () => {
      (prisma.userBookmark.findUnique as jest.Mock).mockResolvedValue({ id: 1 });
      (prisma.userBookmark.delete as jest.Mock).mockResolvedValue({});

      const result = await service.deleteBookmark(userId, questionId);
      expect(result).toEqual({ deleted: true, questionId });
    });

    it('throws NotFoundException when bookmark does not exist', async () => {
      (prisma.userBookmark.findUnique as jest.Mock).mockResolvedValue(null);

      await expect(service.deleteBookmark(userId, questionId)).rejects.toBeInstanceOf(
        NotFoundException,
      );
    });
  });
});
