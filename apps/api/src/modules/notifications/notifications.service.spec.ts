import { NotFoundException } from '@nestjs/common';
import { NotificationsService } from './notifications.service';
import { PrismaService } from '../../prisma/prisma.service';
import { RedisService } from '../../redis/redis.service';

describe('NotificationsService', () => {
  let service: NotificationsService;
  let prisma: jest.Mocked<Partial<PrismaService>>;
  let redis: jest.Mocked<Pick<RedisService, 'getClient' | 'set'>>;

  const redisClient = {
    mget: jest.fn(),
  };

  const mockUser = { id: 1 };
  const mockNotifications = [
    { id: 10, title: 'Welcome', message: 'Hello', type: 'general', type_id: 0, image: null, date_sent: new Date(), users: 'all', user_id: '' },
    { id: 11, title: 'Alert', message: 'Check this out', type: 'general', type_id: 0, image: null, date_sent: new Date(), users: 'specific', user_id: '1,2' },
  ];

  beforeEach(() => {
    redis = {
      getClient: jest.fn().mockReturnValue(redisClient),
      set: jest.fn().mockResolvedValue(undefined),
    };

    prisma = {
      user: {
        findFirst: jest.fn().mockResolvedValue(mockUser),
      } as unknown as PrismaService['user'],
      tbl_notifications: {
        findMany: jest.fn().mockResolvedValue(mockNotifications),
        count: jest.fn().mockResolvedValue(2),
        findUnique: jest.fn(),
      } as unknown as PrismaService['tbl_notifications'],
    };

    service = new NotificationsService(
      prisma as unknown as PrismaService,
      redis as unknown as RedisService,
    );
  });

  describe('list', () => {
    it('throws NotFoundException when user not found', async () => {
      (prisma.user as jest.Mocked<PrismaService['user']>).findFirst = jest
        .fn()
        .mockResolvedValueOnce(null);
      await expect(service.list('unknown-uid', { page: 1, limit: 20 })).rejects.toBeInstanceOf(
        NotFoundException,
      );
    });

    it('returns items with isRead=false when not in Redis', async () => {
      redisClient.mget.mockResolvedValueOnce([null, null]); // neither key found
      const result = await service.list('uid-1', { page: 1, limit: 20 });
      expect(result.items).toHaveLength(2);
      expect(result.items[0].isRead).toBe(false);
      expect(result.items[1].isRead).toBe(false);
      expect(result.unreadCount).toBe(2);
    });

    it('returns isRead=true for notifications found in Redis', async () => {
      redisClient.mget.mockResolvedValueOnce(['1', null]); // first notif is read
      const result = await service.list('uid-1', { page: 1, limit: 20 });
      expect(result.items[0].isRead).toBe(true);
      expect(result.items[1].isRead).toBe(false);
      expect(result.unreadCount).toBe(1);
    });

    it('returns pagination metadata', async () => {
      redisClient.mget.mockResolvedValueOnce([null, null]);
      const result = await service.list('uid-1', { page: 1, limit: 20 });
      expect(result).toHaveProperty('pagination');
      expect(result.pagination.total).toBe(2);
    });
  });

  describe('markRead', () => {
    it('throws NotFoundException when user not found', async () => {
      (prisma.user as jest.Mocked<PrismaService['user']>).findFirst = jest
        .fn()
        .mockResolvedValueOnce(null);
      await expect(service.markRead('unknown-uid', 10)).rejects.toBeInstanceOf(NotFoundException);
    });

    it('throws NotFoundException when notification does not exist', async () => {
      (prisma.tbl_notifications as jest.Mocked<PrismaService['tbl_notifications']>).findUnique = jest
        .fn()
        .mockResolvedValueOnce(null);
      await expect(service.markRead('uid-1', 999)).rejects.toBeInstanceOf(NotFoundException);
    });

    it('sets Redis key and returns {id, read:true} for valid notification', async () => {
      (prisma.tbl_notifications as jest.Mocked<PrismaService['tbl_notifications']>).findUnique = jest
        .fn()
        .mockResolvedValueOnce(mockNotifications[0]); // users='all'

      const result = await service.markRead('uid-1', 10);
      expect(result.read).toBe(true);
      expect(result.id).toBe(10);
      expect(redis.set).toHaveBeenCalledWith(
        'notif:read:1:10',
        '1',
        expect.any(Number),
      );
    });

    it('throws NotFoundException when notification does not apply to user', async () => {
      (prisma.tbl_notifications as jest.Mocked<PrismaService['tbl_notifications']>).findUnique = jest
        .fn()
        .mockResolvedValueOnce({
          ...mockNotifications[1],
          users: 'specific',
          user_id: '5,6,7', // user id 1 is NOT in this list
        });
      await expect(service.markRead('uid-1', 11)).rejects.toBeInstanceOf(NotFoundException);
    });
  });
});
