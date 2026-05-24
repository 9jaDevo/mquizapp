import {
  BadRequestException,
  ConflictException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { randomBytes } from 'crypto';
import { PrismaService } from '../../prisma/prisma.service';
import { ApplyReferralDto } from './dto/apply-referral.dto';

const SIGNUP_REWARD_REFERRER = 50;
const SIGNUP_REWARD_REFEREE = 25;

@Injectable()
export class ReferralService {
  constructor(private readonly prisma: PrismaService) {}

  async getMyCode(firebaseUid: string) {
    const userId = await this.resolveUserId(firebaseUid);
    let code = await this.prisma.tbl_referral_codes.findUnique({ where: { user_id: userId } });
    if (!code) {
      code = await this.prisma.tbl_referral_codes.create({
        data: {
          user_id: userId,
          uid: userId.toString(),
          referral_code: await this.generateUniqueCode(),
        },
      });
    }
    return {
      code: code.referral_code,
      totalReferrals: code.total_referrals ?? 0,
      successfulReferrals: code.successful_referrals ?? 0,
      totalCoinsEarned: code.total_coins_earned ?? 0,
    };
  }

  async applyCode(firebaseUid: string, dto: ApplyReferralDto) {
    const userId = await this.resolveUserId(firebaseUid);
    const inputCode = dto.code.trim().toUpperCase();

    // Already referred?
    const existing = await this.prisma.tbl_referrals.findUnique({ where: { referee_id: userId } });
    if (existing) {
      throw new ConflictException({
        error: 'REFERRAL_ALREADY_APPLIED',
        message: 'Referral code already applied for this account',
      });
    }

    const referrerCode = await this.prisma.tbl_referral_codes.findUnique({
      where: { referral_code: inputCode },
    });
    if (!referrerCode) {
      throw new NotFoundException({
        error: 'REFERRAL_CODE_NOT_FOUND',
        message: 'Invalid referral code',
      });
    }
    if (referrerCode.user_id === userId) {
      throw new BadRequestException({
        error: 'REFERRAL_SELF',
        message: 'Cannot apply your own referral code',
      });
    }

    return this.prisma.$transaction(async (tx) => {
      await tx.tbl_referrals.create({
        data: {
          referrer_id: referrerCode.user_id,
          referrer_uid: referrerCode.user_id.toString(),
          referee_id: userId,
          referee_uid: userId.toString(),
          referral_code: inputCode,
          signup_ip: dto.signupIp ?? null,
          signup_device_id: dto.deviceId ?? null,
          status: 'pending',
        },
      });
      await tx.tbl_referral_codes.update({
        where: { id: referrerCode.id },
        data: { total_referrals: { increment: 1 } },
      });
      // Reward referee at signup; referrer rewards happen on qualification
      await tx.user.update({ where: { id: userId }, data: { coins: { increment: SIGNUP_REWARD_REFEREE } } });
      await tx.tracker.create({
        data: {
          userId,
          uid: userId.toString(),
          points: SIGNUP_REWARD_REFEREE.toString(),
          type: 'referral_signup',
          status: 0,
          date: new Date(),
        },
      });
      return { applied: true, refereeReward: SIGNUP_REWARD_REFEREE, referrerPendingReward: SIGNUP_REWARD_REFERRER };
    });
  }

  private async generateUniqueCode(): Promise<string> {
    for (let i = 0; i < 5; i++) {
      const code = randomBytes(4).toString('hex').toUpperCase();
      const exists = await this.prisma.tbl_referral_codes.findUnique({ where: { referral_code: code } });
      if (!exists) return code;
    }
    throw new Error('Failed to generate unique referral code');
  }

  private async resolveUserId(firebaseUid: string): Promise<number> {
    const u = await this.prisma.user.findFirst({
      where: { firebaseId: firebaseUid },
      select: { id: true },
    });
    if (!u) throw new NotFoundException({ error: 'USER_NOT_FOUND', message: 'User not found' });
    return u.id;
  }
}
