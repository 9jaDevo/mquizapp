import { BadRequestException, NotFoundException } from '@nestjs/common';
import { AdminService } from './admin.service';
import { PrismaService } from '../../prisma/prisma.service';
import { FirebaseService } from '../../firebase/firebase.service';
import { RedisService } from '../../redis/redis.service';
import { SuspendAction } from './dto/suspend-user.dto';

describe('AdminService', () => {
  let service: AdminService;
  let prisma: jest.Mocked<Partial<PrismaService>>;
  let firebase: jest.Mocked<Pick<FirebaseService, 'verifyIdToken'>>;
  let redis: { getClient: jest.Mock };

  const mockAdmin = { id: 99, customClaims: { admin: true } };
  const fakeUser = {
    id: 5,
    name: 'Test User',
    coins: 100,
    status: 0,
    email: 'user@test.com',
    type: 'user',
  };

  beforeEach(() => {
    firebase = { verifyIdToken: jest.fn() };
    redis = { getClient: jest.fn().mockReturnValue({ keys: jest.fn().mockResolvedValue([]) }) };

    prisma = {
      user: {
        findFirst: jest.fn(),
        findUnique: jest.fn(),
        update: jest.fn(),
      } as unknown as PrismaService['user'],
      tracker: {
        create: jest.fn().mockResolvedValue({}),
      } as unknown as PrismaService['tracker'],
      question: {
        findUnique: jest.fn(),
        create: jest.fn(),
        update: jest.fn(),
        delete: jest.fn(),
        createMany: jest.fn(),
        findMany: jest.fn(),
        count: jest.fn(),
      } as unknown as PrismaService['question'],
      aiQuestion: {
        findUnique: jest.fn(),
        update: jest.fn(),
      } as unknown as PrismaService['aiQuestion'],
      $transaction: jest.fn().mockImplementation((fn: unknown) =>
        typeof fn === 'function' ? fn(prisma) : Promise.resolve([]),
      ),
    };

    service = new AdminService(
      prisma as unknown as PrismaService,
      firebase as unknown as FirebaseService,
      redis as unknown as RedisService,
      {} as unknown as import('../partner/partner.service').PartnerService,
    );
  });

  describe('suspendUser', () => {
    it('throws NotFoundException when user not found', async () => {
      (prisma.user as jest.Mocked<PrismaService['user']>).findUnique = jest
        .fn()
        .mockResolvedValueOnce(null);
      await expect(
        service.suspendUser(999, { action: SuspendAction.SUSPEND }),
      ).rejects.toBeInstanceOf(NotFoundException);
    });

    it('sets status=1 to suspend a user', async () => {
      (prisma.user as jest.Mocked<PrismaService['user']>).findUnique = jest
        .fn()
        .mockResolvedValueOnce(fakeUser);
      const updateMock = jest.fn().mockResolvedValueOnce({ ...fakeUser, status: 1 });
      (prisma.user as jest.Mocked<PrismaService['user']>).update = updateMock;

      const result = await service.suspendUser(5, { action: SuspendAction.SUSPEND, reason: 'Spam' });
      expect(updateMock).toHaveBeenCalledWith(
        expect.objectContaining({ data: expect.objectContaining({ status: 1 }) }),
      );
      expect(result.status).toBe(1);
    });

    it('sets status=0 to unsuspend a user', async () => {
      (prisma.user as jest.Mocked<PrismaService['user']>).findUnique = jest
        .fn()
        .mockResolvedValueOnce({ ...fakeUser, status: 1 });
      const updateMock = jest.fn().mockResolvedValueOnce({ ...fakeUser, status: 0 });
      (prisma.user as jest.Mocked<PrismaService['user']>).update = updateMock;

      const result = await service.suspendUser(5, { action: SuspendAction.UNSUSPEND });
      expect(updateMock).toHaveBeenCalledWith(
        expect.objectContaining({ data: expect.objectContaining({ status: 0 }) }),
      );
      expect(result.status).toBe(0);
    });
  });

  describe('adjustUserCoins', () => {
    it('throws NotFoundException when user not found', async () => {
      (prisma.user as jest.Mocked<PrismaService['user']>).findUnique = jest
        .fn()
        .mockResolvedValueOnce(null);
      await expect(
        service.adjustUserCoins(999, { amount: 50, reason: 'Test' }),
      ).rejects.toBeInstanceOf(NotFoundException);
    });

    it('throws BadRequestException when deduction would make coins negative', async () => {
      (prisma.user as jest.Mocked<PrismaService['user']>).findUnique = jest
        .fn()
        .mockResolvedValueOnce({ ...fakeUser, coins: 10 });
      await expect(
        service.adjustUserCoins(5, { amount: -50, reason: 'Test' }), // -50 would make 10-50=-40
      ).rejects.toBeInstanceOf(BadRequestException);
    });

    it('allows positive coin adjustment', async () => {
      (prisma.user as jest.Mocked<PrismaService['user']>).findUnique = jest
        .fn()
        .mockResolvedValueOnce(fakeUser);
      const updateMock = jest.fn().mockResolvedValueOnce({ ...fakeUser, coins: 150 });
      (prisma.user as jest.Mocked<PrismaService['user']>).update = updateMock;

      const result = await service.adjustUserCoins(5, { amount: 50, reason: 'Compensation' });
      expect(result.coinsAfter).toBe(150);
    });
  });

  describe('deleteQuestion', () => {
    it('throws NotFoundException when question not found', async () => {
      (prisma.question as jest.Mocked<PrismaService['question']>).findUnique = jest
        .fn()
        .mockResolvedValueOnce(null);
      await expect(service.deleteQuestion(9999)).rejects.toBeInstanceOf(NotFoundException);
    });

    it('deletes and returns { deleted: true, id }', async () => {
      (prisma.question as jest.Mocked<PrismaService['question']>).findUnique = jest
        .fn()
        .mockResolvedValueOnce({ id: 42 });
      (prisma.question as jest.Mocked<PrismaService['question']>).delete = jest
        .fn()
        .mockResolvedValueOnce({ id: 42 });

      const result = await service.deleteQuestion(42);
      expect(result.deleted).toBe(true);
      expect(result.id).toBe(42);
    });
  });

  describe('rejectAiQuestion', () => {
    it('throws NotFoundException when AI question not found', async () => {
      (prisma.aiQuestion as jest.Mocked<PrismaService['aiQuestion']>).findUnique = jest
        .fn()
        .mockResolvedValueOnce(null);
      await expect(
        service.rejectAiQuestion(1, { reason: 'Inaccurate' }),
      ).rejects.toBeInstanceOf(NotFoundException);
    });

    it('throws BadRequestException when AI question is already reviewed (status !== 0)', async () => {
      (prisma.aiQuestion as jest.Mocked<PrismaService['aiQuestion']>).findUnique = jest
        .fn()
        .mockResolvedValueOnce({ id: BigInt(1), status: 2 }); // already rejected
      await expect(
        service.rejectAiQuestion(1, { reason: 'Test' }),
      ).rejects.toBeInstanceOf(BadRequestException);
    });

    it('sets status=2 and records reason on rejection', async () => {
      (prisma.aiQuestion as jest.Mocked<PrismaService['aiQuestion']>).findUnique = jest
        .fn()
        .mockResolvedValueOnce({ id: BigInt(1), status: 0 });
      const updateMock = jest.fn().mockResolvedValueOnce({ id: BigInt(1), status: 2, note: 'Inaccurate' });
      (prisma.aiQuestion as jest.Mocked<PrismaService['aiQuestion']>).update = updateMock;

      const result = await service.rejectAiQuestion(1, { reason: 'Inaccurate' });
      expect(result.rejected).toBe(true);
    });
  });

  describe('generateQuestions', () => {
    it('throws BadRequestException when OPENAI_API_KEY is not set', async () => {
      const saved = process.env.OPENAI_API_KEY;
      delete process.env.OPENAI_API_KEY;
      await expect(
        service.generateQuestions({ topic: 'Science', count: 3, difficultyLevel: 'easy', categoryId: 1 }),
      ).rejects.toBeInstanceOf(BadRequestException);
      if (saved !== undefined) process.env.OPENAI_API_KEY = saved;
    });
  });

  describe('approveAiQuestion', () => {
    const fakeAi = {
      id: BigInt(1),
      status: 0,
      options: '{"a":"opt1","b":"opt2","c":"opt3","d":"opt4"}',
      category: 1,
      subcategory: 0,
      languageId: 0,
      question: 'Test question',
      questionType: 0,
      level: 1,
      note: null,
      correctAnswer: 'a',
    };

    it('throws NotFoundException when AI question not found', async () => {
      (prisma.aiQuestion as jest.Mocked<PrismaService['aiQuestion']>).findUnique = jest
        .fn()
        .mockResolvedValueOnce(null);
      await expect(service.approveAiQuestion(999)).rejects.toBeInstanceOf(NotFoundException);
    });

    it('throws BadRequestException when AI question already reviewed', async () => {
      (prisma.aiQuestion as jest.Mocked<PrismaService['aiQuestion']>).findUnique = jest
        .fn()
        .mockResolvedValueOnce({ ...fakeAi, status: 1 });
      await expect(service.approveAiQuestion(1)).rejects.toBeInstanceOf(BadRequestException);
    });

    it('creates question and marks AI question status=1', async () => {
      (prisma.aiQuestion as jest.Mocked<PrismaService['aiQuestion']>).findUnique = jest
        .fn()
        .mockResolvedValueOnce(fakeAi);
      (prisma.question as jest.Mocked<PrismaService['question']>).create = jest
        .fn()
        .mockResolvedValueOnce({ id: 100 });
      (prisma.aiQuestion as jest.Mocked<PrismaService['aiQuestion']>).update = jest
        .fn()
        .mockResolvedValueOnce({ ...fakeAi, status: 1 });

      const result = await service.approveAiQuestion(1);
      expect(result.approved).toBe(true);
      expect(result.questionId).toBe(100);
    });
  });

  describe('approveAiQuestionBatch', () => {
    const fakeAi = {
      id: BigInt(2),
      status: 0,
      options: '{"a":"A","b":"B","c":"C","d":"D"}',
      category: 1,
      subcategory: 0,
      languageId: 0,
      question: 'Batch Q',
      questionType: 0,
      level: 2,
      note: null,
      correctAnswer: 'b',
    };

    it('returns summary with per-item approved/failed counts', async () => {
      (prisma.aiQuestion as jest.Mocked<PrismaService['aiQuestion']>).findUnique = jest
        .fn()
        .mockResolvedValueOnce(null)      // id=99 → not found → fail
        .mockResolvedValueOnce(fakeAi);   // id=2 → success
      (prisma.question as jest.Mocked<PrismaService['question']>).create = jest
        .fn()
        .mockResolvedValueOnce({ id: 200 });
      (prisma.aiQuestion as jest.Mocked<PrismaService['aiQuestion']>).update = jest
        .fn()
        .mockResolvedValueOnce({ ...fakeAi, status: 1 });

      const result = await service.approveAiQuestionBatch([99, 2]);
      expect(result.total).toBe(2);
      expect(result.approved).toBe(1);
      expect(result.failed).toBe(1);
    });

    it('returns all approved when all ids are valid', async () => {
      (prisma.aiQuestion as jest.Mocked<PrismaService['aiQuestion']>).findUnique = jest
        .fn()
        .mockResolvedValueOnce(fakeAi)
        .mockResolvedValueOnce({ ...fakeAi, id: BigInt(3) });
      (prisma.question as jest.Mocked<PrismaService['question']>).create = jest
        .fn()
        .mockResolvedValueOnce({ id: 201 })
        .mockResolvedValueOnce({ id: 202 });
      (prisma.aiQuestion as jest.Mocked<PrismaService['aiQuestion']>).update = jest
        .fn()
        .mockResolvedValue({ ...fakeAi, status: 1 });

      const result = await service.approveAiQuestionBatch([2, 3]);
      expect(result.total).toBe(2);
      expect(result.approved).toBe(2);
      expect(result.failed).toBe(0);
    });
  });

  describe('updateQuestion', () => {
    it('throws NotFoundException when question not found', async () => {
      (prisma.question as jest.Mocked<PrismaService['question']>).findUnique = jest
        .fn()
        .mockResolvedValueOnce(null);
      await expect(
        service.updateQuestion(9999, { question: 'New text' }),
      ).rejects.toBeInstanceOf(NotFoundException);
    });

    it('updates and returns the changed question', async () => {
      const existing = { id: 42, question: 'Old text', level: 1 };
      (prisma.question as jest.Mocked<PrismaService['question']>).findUnique = jest
        .fn()
        .mockResolvedValueOnce(existing);
      (prisma.question as jest.Mocked<PrismaService['question']>).update = jest
        .fn()
        .mockResolvedValueOnce({ ...existing, question: 'New text' });

      const result = await service.updateQuestion(42, { question: 'New text' });
      expect((result as { question: string }).question).toBe('New text');
    });
  });

  describe('createQuestion', () => {
    it('creates and returns the new question', async () => {
      const dto = {
        category: 1,
        subcategory: 0,
        question: 'What is 2+2?',
        questionType: 0,
        optiona: '3',
        optionb: '4',
        optionc: '5',
        optiond: '6',
        answer: 'b',
        level: 1,
      };
      const created = { id: 77, ...dto, languageId: 0, image: '', note: '' };
      (prisma.question as jest.Mocked<PrismaService['question']>).create = jest
        .fn()
        .mockResolvedValueOnce(created);

      const result = await service.createQuestion(dto);
      expect((result as { id: number }).id).toBe(77);
      expect((result as { question: string }).question).toBe('What is 2+2?');
    });
  });
});
