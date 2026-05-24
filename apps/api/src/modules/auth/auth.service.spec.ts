import { NotFoundException, UnauthorizedException } from '@nestjs/common';
import { AuthService } from './auth.service';
import { PrismaService } from '../../prisma/prisma.service';
import { FirebaseService } from '../../firebase/firebase.service';

describe('AuthService', () => {
  let service: AuthService;
  let prisma: jest.Mocked<Partial<PrismaService>>;
  let firebase: jest.Mocked<Pick<FirebaseService, 'verifyIdToken'>>;

  const fakeUser = {
    id: 1,
    firebaseId: 'uid-1',
    name: 'Test User',
    email: 'test@example.com',
    mobile: '',
    type: 'user',
    profile: '',
    coins: 0,
    referCode: null,
    appLanguage: null,
    countryCode: null,
    dateRegistered: new Date(),
    status: 0,
    country: null,
    gender: null,
    ageGroup: null,
    fcmToken: null,
    allTimeScore: 0,
  };

  beforeEach(() => {
    firebase = { verifyIdToken: jest.fn() };

    const txMock = {
      user: {
        create: jest.fn().mockResolvedValue(fakeUser),
        findFirst: jest.fn().mockResolvedValue(null),
      },
      userLives: { create: jest.fn().mockResolvedValue({}) },
      userProgress: { create: jest.fn().mockResolvedValue({}) },
      dailyStreak: { create: jest.fn().mockResolvedValue({}) },
    };

    prisma = {
      user: {
        findFirst: jest.fn(),
        upsert: jest.fn(),
        create: jest.fn(),
      } as unknown as PrismaService['user'],
      userLives: {
        upsert: jest.fn(),
      } as unknown as PrismaService['userLives'],
      userProgress: {
        upsert: jest.fn(),
      } as unknown as PrismaService['userProgress'],
      dailyStreak: {
        upsert: jest.fn(),
      } as unknown as PrismaService['dailyStreak'],
      $transaction: jest.fn().mockImplementation((fn: unknown) =>
        typeof fn === 'function' ? fn(txMock) : Promise.resolve([]),
      ),
    };

    service = new AuthService(
      prisma as unknown as PrismaService,
      firebase as unknown as FirebaseService,
    );
  });

  describe('loginWithFirebaseToken', () => {
    it('throws UnauthorizedException when Firebase rejects the token', async () => {
      firebase.verifyIdToken.mockRejectedValueOnce(new Error('Token expired'));
      await expect(
        service.loginWithFirebaseToken('bad.token', { email: '', name: '', profile: '' }),
      ).rejects.toBeInstanceOf(UnauthorizedException);
    });

    it('throws UnauthorizedException for forged/invalid tokens', async () => {
      firebase.verifyIdToken.mockRejectedValueOnce(new Error('Decoding Firebase ID token failed'));
      await expect(
        service.loginWithFirebaseToken('forged.token.123', { email: '', name: '', profile: '' }),
      ).rejects.toBeInstanceOf(UnauthorizedException);
    });

    it('upserts user record and returns profile on valid token', async () => {
      firebase.verifyIdToken.mockResolvedValueOnce({
        uid: 'uid-1',
        email: 'test@example.com',
        name: 'Test User',
        picture: '',
      } as never);

      (prisma.user as jest.Mocked<PrismaService['user']>).upsert = jest
        .fn()
        .mockResolvedValueOnce(fakeUser);
      (prisma.userLives as jest.Mocked<PrismaService['userLives']>).upsert = jest
        .fn()
        .mockResolvedValueOnce({});
      (prisma.userProgress as jest.Mocked<PrismaService['userProgress']>).upsert = jest
        .fn()
        .mockResolvedValueOnce({});
      (prisma.dailyStreak as jest.Mocked<PrismaService['dailyStreak']>).upsert = jest
        .fn()
        .mockResolvedValueOnce({});

      const result = await service.loginWithFirebaseToken('valid.token', {
        email: 'test@example.com',
        name: '',
        profile: '',
      });

      expect(result.user.firebaseId).toBe('uid-1');
      expect(result.user.email).toBe('test@example.com');
      expect(result).toHaveProperty('onboardingComplete');
      expect(result).toHaveProperty('isNewUser');
    });
  });

  describe('createGuest', () => {
    it('creates a guest user with type="guest" and isGuest=true', async () => {
      const guestUser = { ...fakeUser, id: 99, type: 'guest', name: 'Guest' };
      const txMock = {
        user: { create: jest.fn().mockResolvedValueOnce(guestUser) },
        userLives: { create: jest.fn().mockResolvedValueOnce({}) },
        userProgress: { create: jest.fn().mockResolvedValueOnce({}) },
      };
      (prisma as jest.Mocked<Partial<PrismaService>>).$transaction = jest
        .fn()
        .mockImplementationOnce((fn: unknown) =>
          typeof fn === 'function' ? fn(txMock) : Promise.resolve([]),
        );
      // generateUniqueReferCode calls prisma.user.findFirst → return null (no collision)
      (prisma.user as jest.Mocked<PrismaService['user']>).findFirst = jest
        .fn()
        .mockResolvedValueOnce(null);

      const result = await service.createGuest({});
      expect(result.user.type).toBe('guest');
      expect(result.isGuest).toBe(true);
    });

    it('creates guest with custom name when name is provided', async () => {
      const guestUser = { ...fakeUser, id: 99, type: 'guest', name: 'My Name' };
      const txMock = {
        user: { create: jest.fn().mockResolvedValueOnce(guestUser) },
        userLives: { create: jest.fn().mockResolvedValueOnce({}) },
        userProgress: { create: jest.fn().mockResolvedValueOnce({}) },
      };
      (prisma as jest.Mocked<Partial<PrismaService>>).$transaction = jest
        .fn()
        .mockImplementationOnce((fn: unknown) =>
          typeof fn === 'function' ? fn(txMock) : Promise.resolve([]),
        );
      (prisma.user as jest.Mocked<PrismaService['user']>).findFirst = jest
        .fn()
        .mockResolvedValueOnce(null);

      const result = await service.createGuest({ name: 'My Name' });
      expect(result.user.name).toBe('My Name');
    });
  });
});
