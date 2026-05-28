import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class ProgressService {
  constructor(private readonly prisma: PrismaService) {}

  async listStages() {
    const stages = await this.prisma.progressStage.findMany({
      where: { isActive: true },
      orderBy: { stageNumber: 'asc' },
    }).catch(() => [] as Awaited<ReturnType<typeof this.prisma.progressStage.findMany>>);
    return { stages };
  }

  async myProgress(firebaseUid: string) {
    const userId = await this.resolveUserId(firebaseUid);
    const [progress, stages] = await Promise.all([
      this.prisma.userProgress.findUnique({ where: { userId } }).catch(() => null),
      this.prisma.progressStage.findMany({
        where: { isActive: true },
        orderBy: { stageNumber: 'asc' },
      }).catch(() => [] as Awaited<ReturnType<typeof this.prisma.progressStage.findMany>>),
    ]);
    const currentScore = progress?.totalScore ?? 0;
    // Calculate current stage from totalScore
    const reachedStage = [...stages].reverse().find((s) => currentScore >= s.minScore) ?? stages[0];
    const nextStage = stages.find((s) => s.stageNumber === (reachedStage?.stageNumber ?? 0) + 1);

    // Persist the calculated stage if it advanced
    if (progress && reachedStage && progress.stageNumber !== reachedStage.stageNumber) {
      await this.prisma.userProgress.update({
        where: { userId },
        data: { stageNumber: reachedStage.stageNumber },
      });
    }

    return {
      totalScore: currentScore,
      currentStage: reachedStage
        ? {
            stageNumber: reachedStage.stageNumber,
            name: reachedStage.name,
            iconUrl: reachedStage.iconUrl,
            minScore: reachedStage.minScore,
          }
        : null,
      nextStage: nextStage
        ? {
            stageNumber: nextStage.stageNumber,
            name: nextStage.name,
            minScore: nextStage.minScore,
            pointsToGo: Math.max(0, nextStage.minScore - currentScore),
          }
        : null,
    };
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
