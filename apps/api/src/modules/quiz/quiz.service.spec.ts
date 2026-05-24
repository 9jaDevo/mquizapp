import { BadRequestException, NotFoundException } from '@nestjs/common';
import { QuizService } from './quiz.service';
import { PrismaService } from '../../prisma/prisma.service';

describe('QuizService', () => {
  let service: QuizService;
  let prisma: jest.Mocked<Partial<PrismaService>>;

  const mockUser = { id: 1 };
  const mockQuestions = [
    { id: 1, answer: 'a', category: 1, subcategory: 1 },
    { id: 2, answer: 'b', category: 1, subcategory: 1 },
    { id: 3, answer: 'c', category: 1, subcategory: 1 },
  ];

  beforeEach(() => {
    const txMock = {
      user: { update: jest.fn().mockResolvedValue({}) },
      tracker: { create: jest.fn().mockResolvedValue({}) },
      leaderboardDaily: { create: jest.fn().mockResolvedValue({}) },
      userProgress: { upsert: jest.fn().mockResolvedValue({}) },
      fraudDetection: { create: jest.fn().mockResolvedValue({}) },
    };

    prisma = {
      user: {
        findFirst: jest.fn().mockResolvedValue(mockUser),
      } as unknown as PrismaService['user'],
      question: {
        findMany: jest.fn().mockResolvedValue(mockQuestions),
      } as unknown as PrismaService['question'],
      $transaction: jest.fn().mockImplementation((fn: (tx: typeof txMock) => unknown) =>
        typeof fn === 'function' ? fn(txMock) : Promise.all(fn),
      ),
      $queryRawUnsafe: jest.fn().mockResolvedValue([{ id: 1 }, { id: 2 }, { id: 3 }]),
    };

    service = new QuizService(prisma as unknown as PrismaService);
  });

  describe('submitAnswers', () => {
    it('throws BadRequestException when answers array is empty', async () => {
      await expect(
        service.submitAnswers('uid-1', { answers: [], durationMs: 5000 }),
      ).rejects.toBeInstanceOf(BadRequestException);
    });

    it('throws BadRequestException when duplicate question IDs are submitted', async () => {
      await expect(
        service.submitAnswers('uid-1', {
          answers: [
            { questionId: 1, answer: 'a' },
            { questionId: 1, answer: 'b' },
          ],
          durationMs: 5000,
        }),
      ).rejects.toBeInstanceOf(BadRequestException);
    });

    it('scores answers server-side: 2 correct out of 3 = score 20, coins 4', async () => {
      const result = await service.submitAnswers('uid-1', {
        answers: [
          { questionId: 1, answer: 'a' }, // correct
          { questionId: 2, answer: 'b' }, // correct
          { questionId: 3, answer: 'a' }, // wrong (correct is 'c')
        ],
        durationMs: 30000,
      });

      expect(result.correctCount).toBe(2);
      expect(result.wrongCount).toBe(1);
      expect(result.score).toBe(20); // 2 * 10
      expect(result.coinsEarned).toBe(4); // 2 * 2
      expect(result.accuracy).toBe(67); // Math.round(2/3*100)
    });

    it('scores all correct answers', async () => {
      const result = await service.submitAnswers('uid-1', {
        answers: [
          { questionId: 1, answer: 'a' },
          { questionId: 2, answer: 'b' },
          { questionId: 3, answer: 'c' },
        ],
        durationMs: 30000,
      });
      expect(result.correctCount).toBe(3);
      expect(result.wrongCount).toBe(0);
      expect(result.accuracy).toBe(100);
    });

    it('flags fraud when submission is faster than 1 second per question', async () => {
      const result = await service.submitAnswers('uid-1', {
        answers: [
          { questionId: 1, answer: 'a' },
          { questionId: 2, answer: 'b' },
          { questionId: 3, answer: 'c' },
        ],
        durationMs: 500, // 500ms for 3 questions = ~167ms each, below 1000ms threshold
      });
      expect(result.fraudReviewed).toBe(true);
    });

    it('does NOT flag fraud for legitimate submission speed', async () => {
      const result = await service.submitAnswers('uid-1', {
        answers: [
          { questionId: 1, answer: 'a' },
          { questionId: 2, answer: 'b' },
          { questionId: 3, answer: 'c' },
        ],
        durationMs: 45000, // 15s per question
      });
      expect(result.fraudReviewed).toBe(false);
    });

    it('answer comparison is case-insensitive', async () => {
      const result = await service.submitAnswers('uid-1', {
        answers: [
          { questionId: 1, answer: 'A' }, // uppercase 'A' should match correct answer 'a'
          { questionId: 2, answer: 'B' }, // uppercase 'B' matches 'b'
          { questionId: 3, answer: 'C' }, // uppercase 'C' matches 'c'
        ],
        durationMs: 5000,
      });
      expect(result.breakdown[0].isCorrect).toBe(true);
      expect(result.correctCount).toBe(3);
    });
  });

  describe('getDailyChallenge', () => {
    it('throws NotFoundException when no daily quiz exists for today', async () => {
      (prisma as jest.Mocked<Record<string, unknown>>).tbl_daily_quiz = {
        findFirst: jest.fn().mockResolvedValue(null),
      };

      await expect(service.getDailyChallenge('uid-1', 1)).rejects.toBeInstanceOf(NotFoundException);
    });

    it('returns alreadyCompleted=false when user has not submitted today', async () => {
      (prisma as jest.Mocked<Record<string, unknown>>).tbl_daily_quiz = {
        findFirst: jest.fn().mockResolvedValue({
          id: 1,
          language_id: 1,
          date_published: new Date(),
          questions_id: '1,2,3',
        }),
      };
      (prisma as jest.Mocked<Record<string, unknown>>).tbl_daily_quiz_user = {
        findFirst: jest.fn().mockResolvedValue(null),
      };

      const result = await service.getDailyChallenge('uid-1', 1);
      expect(result.alreadyCompleted).toBe(false);
    });

    it('returns alreadyCompleted=true when user already submitted today', async () => {
      (prisma as jest.Mocked<Record<string, unknown>>).tbl_daily_quiz = {
        findFirst: jest.fn().mockResolvedValue({
          id: 1,
          language_id: 1,
          date_published: new Date(),
          questions_id: '1,2,3',
        }),
      };
      (prisma as jest.Mocked<Record<string, unknown>>).tbl_daily_quiz_user = {
        findFirst: jest.fn().mockResolvedValue({ id: 5 }),
      };

      const result = await service.getDailyChallenge('uid-1', 1);
      expect(result.alreadyCompleted).toBe(true);
    });
  });
});
