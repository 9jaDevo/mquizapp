import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class BoostersService {
  constructor(private readonly prisma: PrismaService) {}

  async listTypes() {
    const types = await this.prisma.boosterType.findMany({
      where: { isActive: true },
      orderBy: { id: 'asc' },
    });
    return { types };
  }

  async myInventory(firebaseUid: string) {
    const userId = await this.resolveUserId(firebaseUid);
    const items = await this.prisma.userBoosterInventory.findMany({
      where: { userId },
      include: { boosterType: true },
    });
    return {
      items: items.map((i) => ({
        boosterTypeId: i.boosterTypeId,
        code: i.boosterType.code,
        name: i.boosterType.name,
        quantity: i.quantity,
        costCoins: i.boosterType.costCoins,
      })),
    };
  }

  async purchase(firebaseUid: string, boosterTypeId: number) {
    const userId = await this.resolveUserId(firebaseUid);
    return this.prisma.$transaction(async (tx) => {
      const type = await tx.boosterType.findUnique({ where: { id: boosterTypeId } });
      if (!type || !type.isActive) {
        throw new NotFoundException({ error: 'BOOSTER_NOT_FOUND', message: 'Booster type not found' });
      }
      const user = await tx.user.findUnique({ where: { id: userId } });
      if (!user) throw new NotFoundException({ error: 'USER_NOT_FOUND', message: 'User not found' });
      if (user.coins < type.costCoins) {
        throw new BadRequestException({
          error: 'INSUFFICIENT_COINS',
          message: `Need ${type.costCoins} coins`,
        });
      }
      await tx.user.update({ where: { id: userId }, data: { coins: { decrement: type.costCoins } } });
      await tx.tracker.create({
        data: {
          userId,
          uid: userId.toString(),
          points: type.costCoins.toString(),
          type: `booster_purchase:${type.code}`,
          status: 1,
          date: new Date(),
        },
      });
      const inv = await tx.userBoosterInventory.upsert({
        where: { userId_boosterTypeId: { userId, boosterTypeId } },
        update: { quantity: { increment: 1 } },
        create: { userId, boosterTypeId, quantity: 1 },
      });
      return {
        boosterTypeId,
        code: type.code,
        quantity: inv.quantity,
        coinsSpent: type.costCoins,
      };
    });
  }

  async consume(firebaseUid: string, boosterTypeId: number) {
    const userId = await this.resolveUserId(firebaseUid);
    return this.prisma.$transaction(async (tx) => {
      const inv = await tx.userBoosterInventory.findUnique({
        where: { userId_boosterTypeId: { userId, boosterTypeId } },
      });
      if (!inv || inv.quantity <= 0) {
        throw new BadRequestException({
          error: 'NO_BOOSTERS',
          message: 'No boosters of this type to consume',
        });
      }
      const updated = await tx.userBoosterInventory.update({
        where: { id: inv.id },
        data: { quantity: { decrement: 1 } },
      });
      return { boosterTypeId, remaining: updated.quantity };
    });
  }

  /**
   * Fifty-fifty booster: consumes 1 booster from inventory and returns
   * 2 wrong option keys for the given question so the client can hide them.
   */
  async fiftyFifty(firebaseUid: string, questionId: number, boosterTypeId: number, source: 'quiz' | 'contest') {
    const userId = await this.resolveUserId(firebaseUid);

    // Validate booster type
    const type = await this.prisma.boosterType.findUnique({ where: { id: boosterTypeId } });
    if (!type || !type.isActive) {
      throw new NotFoundException({ error: 'BOOSTER_NOT_FOUND', message: 'Booster type not found' });
    }
    if (type.code !== '50_50') {
      throw new BadRequestException({ error: 'INVALID_BOOSTER', message: 'Booster is not a 50/50 type' });
    }

    // Fetch question and correct answer
    let correctKey: string | null = null;
    let optionKeys: string[] = ['a', 'b', 'c', 'd'];

    if (source === 'contest') {
      const q = await this.prisma.tbl_contest_question.findUnique({ where: { id: questionId } });
      if (!q) throw new NotFoundException({ error: 'QUESTION_NOT_FOUND', message: 'Question not found' });
      correctKey = q.answer?.trim().toLowerCase() ?? null;
      if (q.optione) optionKeys = ['a', 'b', 'c', 'd', 'e'];
    } else {
      const q = await this.prisma.question.findUnique({ where: { id: questionId } });
      if (!q) throw new NotFoundException({ error: 'QUESTION_NOT_FOUND', message: 'Question not found' });
      correctKey = q.answer?.trim().toLowerCase() ?? null;
      if (q.optione) optionKeys = ['a', 'b', 'c', 'd', 'e'];
    }

    // Consume booster atomically
    await this.prisma.$transaction(async (tx) => {
      const inv = await tx.userBoosterInventory.findUnique({
        where: { userId_boosterTypeId: { userId, boosterTypeId } },
      });
      if (!inv || inv.quantity <= 0) {
        throw new BadRequestException({ error: 'NO_BOOSTERS', message: 'No 50/50 boosters in inventory' });
      }
      await tx.userBoosterInventory.update({
        where: { id: inv.id },
        data: { quantity: { decrement: 1 } },
      });
    });

    // Pick 2 wrong options to remove (shuffle wrong options, take first 2)
    const wrongOptions = optionKeys.filter((k) => k !== correctKey);
    for (let i = wrongOptions.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [wrongOptions[i], wrongOptions[j]] = [wrongOptions[j], wrongOptions[i]];
    }
    const removedOptions = wrongOptions.slice(0, 2);

    return { removedOptions };
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
