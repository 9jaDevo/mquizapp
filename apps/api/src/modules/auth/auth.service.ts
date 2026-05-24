import { Injectable, Logger, UnauthorizedException } from '@nestjs/common';
import { randomBytes } from 'crypto';
import { PrismaService } from '../../prisma/prisma.service';
import { FirebaseService } from '../../firebase/firebase.service';
import { LoginDto } from './dto/login.dto';
import { GuestDto } from './dto/guest.dto';

export interface AuthProfile {
  id: number;
  firebaseId: string;
  name: string;
  email: string;
  mobile: string;
  type: string;
  profile: string;
  coins: number;
  referCode: string | null;
  appLanguage: string | null;
  countryCode: string | null;
  dateRegistered: Date;
}

@Injectable()
export class AuthService {
  private readonly logger = new Logger(AuthService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly firebase: FirebaseService,
  ) {}

  async loginWithFirebaseToken(
    token: string,
    body: LoginDto,
  ): Promise<{ user: AuthProfile; onboardingComplete: boolean; isNewUser: boolean }> {
    let decoded;
    try {
      decoded = await this.firebase.verifyIdToken(token);
    } catch (err) {
      this.logger.debug(`login verify failed: ${(err as Error).message}`);
      throw new UnauthorizedException({
        error: 'AUTH_INVALID_TOKEN',
        message: 'Invalid or expired Firebase token',
      });
    }

    const firebaseId = decoded.uid;
    const email = (decoded.email ?? body.email ?? '').toLowerCase().slice(0, 128);
    const name = (decoded.name ?? body.name ?? '').slice(0, 128);
    const profile = (decoded.picture ?? body.profile ?? '').slice(0, 128);
    const mobile = (decoded.phone_number ?? body.mobile ?? '').slice(0, 32);

    // Look up existing user by firebaseId (LongText, can't unique-index full column)
    const existing = await this.prisma.user.findFirst({
      where: { firebaseId },
      select: { id: true, name: true, profile: true, referCode: true },
    });

    let user;
    let isNewUser = false;

    if (existing) {
      // Update lightweight fields only — never coins, status, api_token
      user = await this.prisma.user.update({
        where: { id: existing.id },
        data: {
          email: email || undefined,
          name: existing.name || name,
          profile: existing.profile || profile,
          mobile: mobile || undefined,
          appLanguage: body.appLanguage ?? undefined,
          countryCode: body.countryCode ?? undefined,
          countryName: body.countryName ?? undefined,
        },
      });
    } else {
      isNewUser = true;
      const referCode = await this.generateUniqueReferCode();
      user = await this.prisma.$transaction(async (tx) => {
        const created = await tx.user.create({
          data: {
            firebaseId,
            email,
            name,
            profile,
            mobile,
            type: body.type ?? 'firebase',
            coins: 0,
            referCode,
            friendsCode: body.friendsCode ?? null,
            appLanguage: body.appLanguage ?? null,
            countryCode: body.countryCode ?? null,
            countryName: body.countryName ?? null,
            dateRegistered: new Date(),
            apiToken: randomBytes(32).toString('hex'),
          },
        });
        await tx.userLives.create({ data: { userId: created.id, current: 5, max: 5 } });
        await tx.userProgress.create({ data: { userId: created.id, stageNumber: 1, totalScore: 0 } });
        await tx.dailyStreak.create({
          data: {
            userId: created.id,
            uid: created.id.toString(),
            streakCount: 0,
            maxStreak: 0,
            coinEarnedToday: 0,
          },
        });
        return created;
      });
    }

    return {
      user: this.toProfile(user),
      onboardingComplete: Boolean(user.name && user.countryCode),
      isNewUser,
    };
  }

  async createGuest(body: GuestDto): Promise<{ user: AuthProfile; isGuest: true }> {
    const guestUid = `guest_${randomBytes(12).toString('hex')}`;
    const referCode = await this.generateUniqueReferCode();
    const user = await this.prisma.$transaction(async (tx) => {
      const created = await tx.user.create({
        data: {
          firebaseId: guestUid,
          email: `${guestUid}@guest.mquiz.local`,
          name: body.name?.slice(0, 128) ?? 'Guest',
          profile: '',
          mobile: '',
          type: 'guest',
          coins: 0,
          referCode,
          dateRegistered: new Date(),
          apiToken: randomBytes(32).toString('hex'),
          appLanguage: body.appLanguage ?? null,
          countryCode: body.countryCode ?? null,
        },
      });
      await tx.userLives.create({ data: { userId: created.id, current: 5, max: 5 } });
      await tx.userProgress.create({ data: { userId: created.id } });
      return created;
    });

    return { user: this.toProfile(user), isGuest: true };
  }

  async refresh(token: string): Promise<{ valid: true; uid: string; expiresAt: number }> {
    try {
      const decoded = await this.firebase.verifyIdToken(token);
      return { valid: true, uid: decoded.uid, expiresAt: decoded.exp };
    } catch {
      throw new UnauthorizedException({
        error: 'AUTH_INVALID_TOKEN',
        message: 'Token is expired or revoked',
      });
    }
  }

  private async generateUniqueReferCode(): Promise<string> {
    for (let attempt = 0; attempt < 5; attempt++) {
      const code = randomBytes(4).toString('hex').toUpperCase(); // 8 chars
      const exists = await this.prisma.user.findFirst({
        where: { referCode: code },
        select: { id: true },
      });
      if (!exists) return code;
    }
    // Fall back to a longer code on collision streak
    return randomBytes(6).toString('hex').toUpperCase();
  }

  private toProfile(u: {
    id: number;
    firebaseId: string;
    name: string;
    email: string;
    mobile: string;
    type: string;
    profile: string;
    coins: number;
    referCode: string | null;
    appLanguage: string | null;
    countryCode: string | null;
    dateRegistered: Date;
  }): AuthProfile {
    return {
      id: u.id,
      firebaseId: u.firebaseId,
      name: u.name,
      email: u.email,
      mobile: u.mobile,
      type: u.type,
      profile: u.profile,
      coins: u.coins,
      referCode: u.referCode,
      appLanguage: u.appLanguage,
      countryCode: u.countryCode,
      dateRegistered: u.dateRegistered,
    };
  }
}
