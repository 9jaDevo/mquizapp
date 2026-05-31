import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  Injectable,
  Logger,
  NotFoundException,
} from '@nestjs/common';
import * as crypto from 'crypto';
import { PrismaService } from '../../prisma/prisma.service';
import { FirebaseService } from '../../firebase/firebase.service';
import { RegisterPartnerDto } from './dto/register-partner.dto';
import { CreatePartnerContestDto } from './dto/create-partner-contest.dto';
import {
  AddPartnerQuestionDto,
  AddQuestionsFromBankDto,
  ReorderQuestionsDto,
} from './dto/add-partner-question.dto';
import { SubmitPartnerContestDto } from './dto/submit-partner-contest.dto';

// Plan limits: [maxActiveContests, maxParticipants, maxQuestionsPerContest, bankAccess]
const PLAN_LIMITS: Record<string, { contests: number; participants: number; questions: number; bank: boolean }> = {
  free:       { contests: 1,         participants: 50,        questions: 30,        bank: false },
  starter:    { contests: 3,         participants: 500,       questions: 200,       bank: true  },
  pro:        { contests: 10,        participants: 5_000,     questions: 99_999,    bank: true  },
  enterprise: { contests: 99_999,    participants: 99_999,    questions: 99_999,    bank: true  },
};

@Injectable()
export class PartnerService {
  private readonly logger = new Logger(PartnerService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly firebase: FirebaseService,
  ) {}

  // ─── Auth ────────────────────────────────────────────────────────────────

  async register(dto: RegisterPartnerDto) {
    const existing = await this.prisma.partner.findUnique({ where: { email: dto.email } });
    if (existing) {
      throw new ConflictException({ error: 'EMAIL_TAKEN', message: 'A partner account already exists with this email' });
    }

    // Create Firebase user
    let firebaseUser: { uid: string };
    try {
      firebaseUser = await this.firebase.auth().createUser({
        email: dto.email,
        password: dto.password,
        displayName: dto.orgName,
      });
    } catch (err: unknown) {
      const msg = (err as { code?: string }).code === 'auth/email-already-exists'
        ? 'A Firebase account already exists with this email'
        : 'Failed to create partner account';
      throw new ConflictException({ error: 'FIREBASE_CREATE_FAILED', message: msg });
    }

    // Auto-approve Free plan; paid plans start pending
    const autoApprove = true; // Free plan is always auto-approved
    const status = autoApprove ? 'active' : 'pending';
    const approvedAt = autoApprove ? new Date() : null;

    const partner = await this.prisma.partner.create({
      data: {
        firebaseUid: firebaseUser.uid,
        orgName: dto.orgName,
        orgType: dto.orgType,
        email: dto.email,
        phone: dto.phone ?? null,
        country: dto.country ?? null,
        plan: 'free',
        status,
        approvedAt,
        users: {
          create: {
            firebaseUid: firebaseUser.uid,
            email: dto.email,
            displayName: dto.orgName,
            role: 'owner',
            status: 'active',
          },
        },
      },
    });

    if (autoApprove) {
      await this._issuePartnerClaims(firebaseUser.uid, partner.id, 'owner', status);
    }

    return {
      partner: this._safePartner(partner),
      status: autoApprove ? 'active' : 'pending_approval',
      message: autoApprove
        ? 'Registration successful. You can now log in.'
        : 'Registration submitted. Await admin approval before logging in.',
    };
  }

  async login(firebaseUid: string) {
    const partnerUser = await this.prisma.partnerUser.findUnique({
      where: { firebaseUid },
      include: { partner: true },
    });
    if (!partnerUser) {
      throw new NotFoundException({ error: 'PARTNER_NOT_FOUND', message: 'No partner account found for this user' });
    }
    if (partnerUser.partner.status === 'suspended') {
      throw new ForbiddenException({ error: 'PARTNER_SUSPENDED', message: 'This partner account has been suspended' });
    }
    if (partnerUser.partner.status === 'pending') {
      throw new ForbiddenException({ error: 'PARTNER_PENDING', message: 'Partner account awaiting admin approval' });
    }

    // Update last login
    await this.prisma.partnerUser.update({
      where: { id: partnerUser.id },
      data: { lastLoginAt: new Date() },
    });

    const customToken = await this.firebase.auth().createCustomToken(firebaseUid, {
      partnerId: partnerUser.partner.id,
      partnerRole: partnerUser.role,
      partnerStatus: partnerUser.partner.status,
    });

    return {
      customToken,
      partner: this._safePartner(partnerUser.partner),
      role: partnerUser.role,
    };
  }

  // ─── Profile ────────────────────────────────────────────────────────────

  async getProfile(partnerId: number) {
    const partner = await this._requirePartner(partnerId);
    const [contestCount, activeContests] = await Promise.all([
      this.prisma.partnerContest.count({ where: { partnerId } }),
      this.prisma.partnerContest.count({ where: { partnerId, status: { in: ['published', 'live'] } } }),
    ]);
    const limits = PLAN_LIMITS[partner.plan] ?? PLAN_LIMITS.free;
    return {
      ...this._safePartner(partner),
      usage: {
        activeContests,
        totalContests: contestCount,
        limits: { contests: limits.contests, participants: limits.participants, questions: limits.questions },
      },
    };
  }

  async updateProfile(partnerId: number, data: Partial<{ orgName: string; phone: string; website: string; description: string; logoUrl: string; country: string }>) {
    await this._requirePartner(partnerId);
    const updated = await this.prisma.partner.update({
      where: { id: partnerId },
      data: {
        ...(data.orgName && { orgName: data.orgName }),
        ...(data.phone !== undefined && { phone: data.phone }),
        ...(data.website !== undefined && { website: data.website }),
        ...(data.description !== undefined && { description: data.description }),
        ...(data.logoUrl !== undefined && { logoUrl: data.logoUrl }),
        ...(data.country !== undefined && { country: data.country }),
      },
    });
    return this._safePartner(updated);
  }

  // ─── Team ───────────────────────────────────────────────────────────────

  async listTeam(partnerId: number) {
    return this.prisma.partnerUser.findMany({
      where: { partnerId },
      select: { id: true, email: true, displayName: true, role: true, status: true, createdAt: true, lastLoginAt: true },
      orderBy: { createdAt: 'asc' },
    });
  }

  async inviteTeamMember(partnerId: number, email: string, role: string) {
    const existing = await this.prisma.partnerUser.findFirst({ where: { email, partnerId } });
    if (existing) throw new ConflictException({ error: 'MEMBER_EXISTS', message: 'This email is already a team member' });

    // Create Firebase user with temporary password (they'll reset it)
    const tempPassword = crypto.randomBytes(16).toString('hex');
    let firebaseUser: { uid: string };
    try {
      firebaseUser = await this.firebase.auth().createUser({ email, password: tempPassword, displayName: email });
    } catch (err: unknown) {
      const code = (err as { code?: string }).code;
      if (code === 'auth/email-already-exists') {
        const existing = await this.firebase.auth().getUserByEmail(email);
        firebaseUser = { uid: existing.uid };
      } else {
        throw new BadRequestException({ error: 'INVITE_FAILED', message: 'Failed to create team member account' });
      }
    }

    await this.firebase.auth().generatePasswordResetLink(email).catch(() => { /* non-blocking */ });

    const member = await this.prisma.partnerUser.create({
      data: { partnerId, firebaseUid: firebaseUser.uid, email, role, status: 'active' },
    });
    return { id: member.id, email: member.email, role: member.role, status: member.status };
  }

  async removeTeamMember(partnerId: number, memberId: number, requestingRole: string) {
    if (requestingRole !== 'owner') {
      throw new ForbiddenException({ error: 'OWNER_ONLY', message: 'Only the owner can remove team members' });
    }
    const member = await this.prisma.partnerUser.findFirst({ where: { id: memberId, partnerId } });
    if (!member) throw new NotFoundException({ error: 'MEMBER_NOT_FOUND', message: 'Team member not found' });
    if (member.role === 'owner') {
      throw new BadRequestException({ error: 'CANNOT_REMOVE_OWNER', message: 'Cannot remove the owner account' });
    }
    await this.prisma.partnerUser.delete({ where: { id: memberId } });
    return { message: 'Team member removed' };
  }

  // ─── Contests ───────────────────────────────────────────────────────────

  async listContests(partnerId: number, status?: string, page = 1, limit = 20) {
    const take = Math.min(limit, 100);
    const skip = (page - 1) * take;
    const where = { partnerId, ...(status ? { status } : {}) };
    const [items, total] = await Promise.all([
      this.prisma.partnerContest.findMany({
        where,
        orderBy: { createdAt: 'desc' },
        skip,
        take,
        include: { _count: { select: { participants: true } } },
      }),
      this.prisma.partnerContest.count({ where }),
    ]);
    return { items, pagination: { page, limit: take, total, pages: Math.ceil(total / take) } };
  }

  async getContest(partnerId: number, contestId: number) {
    const contest = await this.prisma.partnerContest.findFirst({
      where: { id: contestId, partnerId },
      include: { _count: { select: { participants: true, questions: true } } },
    });
    if (!contest) throw new NotFoundException({ error: 'CONTEST_NOT_FOUND', message: 'Contest not found' });
    return contest;
  }

  async createContest(partnerId: number, dto: CreatePartnerContestDto) {
    const partner = await this._requirePartner(partnerId);
    await this._enforceContestLimit(partnerId, partner.plan);

    const inviteCode = dto.visibility === 'private' ? await this._generateInviteCode() : null;

    return this.prisma.partnerContest.create({
      data: {
        partnerId,
        title: dto.title,
        description: dto.description ?? null,
        bannerUrl: dto.bannerUrl ?? null,
        startDate: dto.startDate ? new Date(dto.startDate) : null,
        endDate: dto.endDate ? new Date(dto.endDate) : null,
        visibility: dto.visibility,
        inviteCode,
        maxParticipants: dto.maxParticipants ?? 50,
        timeLimitSeconds: dto.timeLimitSeconds ?? 20,
        prizeDescription: dto.prizeDescription ?? null,
        coinPrizePool: dto.coinPrizePool ?? 0,
        allowRetakes: dto.allowRetakes ?? false,
        customJoinMessage: dto.customJoinMessage ?? null,
        customCompleteMessage: dto.customCompleteMessage ?? null,
      },
    });
  }

  async updateContest(partnerId: number, contestId: number, dto: Partial<CreatePartnerContestDto>) {
    const contest = await this.getContest(partnerId, contestId);
    if (contest.status !== 'draft') {
      throw new BadRequestException({ error: 'CONTEST_NOT_DRAFT', message: 'Only draft contests can be edited' });
    }
    return this.prisma.partnerContest.update({
      where: { id: contestId },
      data: {
        ...(dto.title && { title: dto.title }),
        ...(dto.description !== undefined && { description: dto.description }),
        ...(dto.bannerUrl !== undefined && { bannerUrl: dto.bannerUrl }),
        ...(dto.startDate && { startDate: new Date(dto.startDate) }),
        ...(dto.endDate && { endDate: new Date(dto.endDate) }),
        ...(dto.visibility && { visibility: dto.visibility }),
        ...(dto.maxParticipants !== undefined && { maxParticipants: dto.maxParticipants }),
        ...(dto.timeLimitSeconds !== undefined && { timeLimitSeconds: dto.timeLimitSeconds }),
        ...(dto.prizeDescription !== undefined && { prizeDescription: dto.prizeDescription }),
        ...(dto.coinPrizePool !== undefined && { coinPrizePool: dto.coinPrizePool }),
        ...(dto.allowRetakes !== undefined && { allowRetakes: dto.allowRetakes }),
        ...(dto.customJoinMessage !== undefined && { customJoinMessage: dto.customJoinMessage }),
        ...(dto.customCompleteMessage !== undefined && { customCompleteMessage: dto.customCompleteMessage }),
      },
    });
  }

  async publishContest(partnerId: number, contestId: number) {
    const contest = await this.getContest(partnerId, contestId);
    if (contest.status !== 'draft') {
      throw new BadRequestException({ error: 'CONTEST_NOT_DRAFT', message: 'Only draft contests can be published' });
    }
    const qCount = await this.prisma.partnerContestQuestion.count({ where: { contestId } });
    if (qCount === 0) {
      throw new BadRequestException({ error: 'NO_QUESTIONS', message: 'Add at least one question before publishing' });
    }
    return this.prisma.partnerContest.update({
      where: { id: contestId },
      data: { status: 'published', questionCount: qCount },
    });
  }

  async endContest(partnerId: number, contestId: number) {
    await this.getContest(partnerId, contestId);
    return this.prisma.partnerContest.update({
      where: { id: contestId },
      data: { status: 'ended' },
    });
  }

  async deleteContest(partnerId: number, contestId: number) {
    const contest = await this.getContest(partnerId, contestId);
    if (contest.status !== 'draft') {
      throw new BadRequestException({ error: 'CONTEST_NOT_DRAFT', message: 'Only draft contests can be deleted' });
    }
    await this.prisma.partnerContest.delete({ where: { id: contestId } });
    return { message: 'Contest deleted' };
  }

  async regenerateInviteCode(partnerId: number, contestId: number) {
    const contest = await this.getContest(partnerId, contestId);
    if (contest.visibility !== 'private') {
      throw new BadRequestException({ error: 'NOT_PRIVATE', message: 'Only private contests have invite codes' });
    }
    const inviteCode = await this._generateInviteCode();
    return this.prisma.partnerContest.update({ where: { id: contestId }, data: { inviteCode } });
  }

  // ─── Questions ──────────────────────────────────────────────────────────

  async listQuestions(partnerId: number, contestId: number) {
    await this.getContest(partnerId, contestId);
    return this.prisma.partnerContestQuestion.findMany({
      where: { contestId },
      orderBy: { questionOrder: 'asc' },
    });
  }

  async addQuestion(partnerId: number, contestId: number, dto: AddPartnerQuestionDto) {
    const partner = await this._requirePartner(partnerId);
    await this.getContest(partnerId, contestId);
    await this._enforceQuestionLimit(contestId, partner.plan);

    const maxOrder = await this.prisma.partnerContestQuestion.aggregate({
      where: { contestId },
      _max: { questionOrder: true },
    });
    const nextOrder = (maxOrder._max.questionOrder ?? 0) + 1;

    return this.prisma.partnerContestQuestion.create({
      data: {
        contestId,
        questionOrder: nextOrder,
        questionText: dto.questionText,
        imageUrl: dto.imageUrl ?? null,
        optionA: dto.optionA,
        optionB: dto.optionB,
        optionC: dto.optionC,
        optionD: dto.optionD,
        optionE: dto.optionE ?? null,
        answer: dto.answer,
        explanation: dto.explanation ?? null,
        source: 'custom',
      },
    });
  }

  async updateQuestion(partnerId: number, contestId: number, questionId: number, dto: Partial<AddPartnerQuestionDto>) {
    await this.getContest(partnerId, contestId);
    const q = await this.prisma.partnerContestQuestion.findFirst({ where: { id: questionId, contestId } });
    if (!q) throw new NotFoundException({ error: 'QUESTION_NOT_FOUND', message: 'Question not found' });
    return this.prisma.partnerContestQuestion.update({
      where: { id: questionId },
      data: {
        ...(dto.questionText && { questionText: dto.questionText }),
        ...(dto.imageUrl !== undefined && { imageUrl: dto.imageUrl }),
        ...(dto.optionA && { optionA: dto.optionA }),
        ...(dto.optionB && { optionB: dto.optionB }),
        ...(dto.optionC && { optionC: dto.optionC }),
        ...(dto.optionD && { optionD: dto.optionD }),
        ...(dto.optionE !== undefined && { optionE: dto.optionE }),
        ...(dto.answer && { answer: dto.answer }),
        ...(dto.explanation !== undefined && { explanation: dto.explanation }),
      },
    });
  }

  async deleteQuestion(partnerId: number, contestId: number, questionId: number) {
    await this.getContest(partnerId, contestId);
    const q = await this.prisma.partnerContestQuestion.findFirst({ where: { id: questionId, contestId } });
    if (!q) throw new NotFoundException({ error: 'QUESTION_NOT_FOUND', message: 'Question not found' });
    await this.prisma.partnerContestQuestion.delete({ where: { id: questionId } });
    return { message: 'Question deleted' };
  }

  async addQuestionsFromBank(partnerId: number, contestId: number, dto: AddQuestionsFromBankDto) {
    const partner = await this._requirePartner(partnerId);
    const limits = PLAN_LIMITS[partner.plan] ?? PLAN_LIMITS.free;
    if (!limits.bank) {
      throw new ForbiddenException({ error: 'PLAN_BANK_ACCESS', message: 'Upgrade to Starter or higher to use the question bank' });
    }
    await this.getContest(partnerId, contestId);
    await this._enforceQuestionLimit(contestId, partner.plan);

    const bankQuestions = await this.prisma.question.findMany({
      where: { id: { in: dto.questionIds } },
      select: { id: true, question: true, optiona: true, optionb: true, optionc: true, optiond: true, answer: true },
    });

    const maxOrder = await this.prisma.partnerContestQuestion.aggregate({
      where: { contestId },
      _max: { questionOrder: true },
    });
    let nextOrder = (maxOrder._max.questionOrder ?? 0) + 1;

    const toCreate = bankQuestions.map((bq) => ({
      contestId,
      questionOrder: nextOrder++,
      questionText: bq.question,
      optionA: bq.optiona,
      optionB: bq.optionb,
      optionC: bq.optionc,
      optionD: bq.optiond,
      optionE: null as string | null,
      answer: bq.answer,
      source: 'bank',
      bankQuestionId: bq.id,
    }));

    await this.prisma.partnerContestQuestion.createMany({ data: toCreate });
    return { added: toCreate.length };
  }

  async reorderQuestions(partnerId: number, contestId: number, dto: ReorderQuestionsDto) {
    await this.getContest(partnerId, contestId);
    await this.prisma.$transaction(
      dto.orderedIds.map((id, index) =>
        this.prisma.partnerContestQuestion.updateMany({
          where: { id, contestId },
          data: { questionOrder: index + 1 },
        }),
      ),
    );
    return { message: 'Questions reordered' };
  }

  // ─── Participants ────────────────────────────────────────────────────────

  async listParticipants(partnerId: number, contestId: number, submitted?: boolean, page = 1, limit = 50) {
    await this.getContest(partnerId, contestId);
    const take = Math.min(limit, 200);
    const skip = (page - 1) * take;
    const where = {
      contestId,
      ...(submitted !== undefined ? { hasSubmitted: submitted } : {}),
    };
    const [items, total] = await Promise.all([
      this.prisma.partnerContestParticipant.findMany({
        where,
        orderBy: [{ score: 'desc' }, { timeTakenMs: 'asc' }],
        skip,
        take,
        include: {
          contest: {
            select: {
              partner: { select: { id: true } },
            },
          },
        },
      }),
      this.prisma.partnerContestParticipant.count({ where }),
    ]);
    return {
      items: items.map((p) => ({
        id: p.id,
        userId: p.userId,
        joinedAt: p.joinedAt,
        hasSubmitted: p.hasSubmitted,
        submittedAt: p.submittedAt,
        score: p.score,
        correctCount: p.correctCount,
        timeTakenMs: p.timeTakenMs,
        rank: p.rank,
      })),
      pagination: { page, limit: take, total, pages: Math.ceil(total / take) },
    };
  }

  async getLeaderboard(partnerId: number, contestId: number) {
    await this.getContest(partnerId, contestId);
    const entries = await this.prisma.partnerContestLeaderboard.findMany({
      where: { contestId },
      orderBy: [{ score: 'desc' }, { timeTakenMs: 'asc' }],
      take: 100,
    });
    const total = await this.prisma.partnerContestParticipant.count({ where: { contestId } });
    return { entries, totalParticipants: total };
  }

  async markPrizesDistributed(partnerId: number, contestId: number) {
    const contest = await this.getContest(partnerId, contestId);
    if (contest.status !== 'ended') {
      throw new BadRequestException({ error: 'CONTEST_NOT_ENDED', message: 'Contest must be ended before distributing prizes' });
    }
    return this.prisma.partnerContest.update({
      where: { id: contestId },
      data: { prizeDistributed: true },
    });
  }

  // ─── Analytics ───────────────────────────────────────────────────────────

  async getAnalytics(partnerId: number) {
    const [totalContests, activeContests, totalParticipants] = await Promise.all([
      this.prisma.partnerContest.count({ where: { partnerId } }),
      this.prisma.partnerContest.count({ where: { partnerId, status: { in: ['published', 'live'] } } }),
      this.prisma.partnerContestParticipant.count({
        where: { contest: { partnerId } },
      }),
    ]);
    return { totalContests, activeContests, totalParticipants };
  }

  async getContestAnalytics(partnerId: number, contestId: number) {
    await this.getContest(partnerId, contestId);
    const [participantCount, submittedCount, aggScore] = await Promise.all([
      this.prisma.partnerContestParticipant.count({ where: { contestId } }),
      this.prisma.partnerContestParticipant.count({ where: { contestId, hasSubmitted: true } }),
      this.prisma.partnerContestParticipant.aggregate({
        where: { contestId, hasSubmitted: true },
        _avg: { score: true, timeTakenMs: true },
      }),
    ]);
    return {
      participantCount,
      submittedCount,
      completionRate: participantCount > 0 ? Math.round((submittedCount / participantCount) * 100) : 0,
      avgScore: aggScore._avg.score ?? 0,
      avgTimeTakenMs: aggScore._avg.timeTakenMs ?? 0,
    };
  }

  // ─── Public mobile endpoints ─────────────────────────────────────────────

  async listPublicContests(search?: string, status?: string, page = 1, limit = 20) {
    const take = Math.min(limit, 50);
    const skip = (page - 1) * take;
    const statusFilter = status ? [status] : ['published', 'live'];
    const where: Record<string, unknown> = {
      visibility: 'public',
      status: { in: statusFilter },
    };
    if (search) {
      where.title = { contains: search };
    }
    const [items, total] = await Promise.all([
      this.prisma.partnerContest.findMany({
        where,
        orderBy: [{ status: 'asc' }, { createdAt: 'desc' }],
        skip,
        take,
        include: {
          partner: { select: { id: true, orgName: true, logoUrl: true } },
          _count: { select: { participants: true } },
        },
      }),
      this.prisma.partnerContest.count({ where }),
    ]);
    return {
      items: items.map((c) => ({
        ...this._safeContest(c),
        partnerName: c.partner.orgName,
        partnerLogoUrl: c.partner.logoUrl,
        participantCount: c._count.participants,
      })),
      pagination: { page, limit: take, total, pages: Math.ceil(total / take) },
    };
  }

  async getPublicContest(contestId: number, userId?: number) {
    const contest = await this.prisma.partnerContest.findFirst({
      where: { id: contestId, status: { notIn: ['draft', 'archived'] } },
      include: {
        partner: { select: { id: true, orgName: true, logoUrl: true, description: true } },
        _count: { select: { participants: true } },
      },
    });
    if (!contest) throw new NotFoundException({ error: 'CONTEST_NOT_FOUND', message: 'Contest not found' });

    let isParticipated = false;
    if (userId) {
      const p = await this.prisma.partnerContestParticipant.findUnique({
        where: { contestId_userId: { contestId, userId } },
      });
      isParticipated = !!p;
    }

    return {
      ...this._safeContest(contest),
      partnerName: contest.partner.orgName,
      partnerLogoUrl: contest.partner.logoUrl,
      partnerDescription: contest.partner.description,
      participantCount: contest._count.participants,
      isParticipated,
    };
  }

  async lookupByCode(code: string) {
    const contest = await this.prisma.partnerContest.findFirst({
      where: { inviteCode: code.toUpperCase(), status: { notIn: ['draft', 'archived', 'ended'] } },
      include: { partner: { select: { id: true, orgName: true, logoUrl: true } } },
    });
    if (!contest) {
      throw new NotFoundException({ error: 'INVALID_CODE', message: 'No active contest found with this invite code' });
    }
    return {
      ...this._safeContest(contest),
      partnerName: contest.partner.orgName,
      partnerLogoUrl: contest.partner.logoUrl,
    };
  }

  async joinContest(contestId: number, userId: number) {
    const contest = await this.prisma.partnerContest.findFirst({
      where: { id: contestId, status: { in: ['published', 'live'] } },
    });
    if (!contest) throw new NotFoundException({ error: 'CONTEST_NOT_FOUND', message: 'Contest not found or not open' });

    if (contest.endDate && contest.endDate < new Date()) {
      throw new BadRequestException({ error: 'CONTEST_ENDED', message: 'This contest has ended' });
    }

    const existing = await this.prisma.partnerContestParticipant.findUnique({
      where: { contestId_userId: { contestId, userId } },
    });
    if (existing) {
      if (existing.hasSubmitted && !contest.allowRetakes) {
        throw new ConflictException({ error: 'ALREADY_SUBMITTED', message: 'You have already completed this contest' });
      }
      return { message: 'Already joined', participant: existing };
    }

    const participantCount = await this.prisma.partnerContestParticipant.count({ where: { contestId } });
    if (participantCount >= contest.maxParticipants) {
      throw new BadRequestException({ error: 'CONTEST_FULL', message: 'This contest has reached its participant limit' });
    }

    const participant = await this.prisma.partnerContestParticipant.create({
      data: { contestId, userId },
    });
    return { message: 'Joined successfully', participant };
  }

  async getQuestionsForUser(contestId: number, userId: number) {
    const participant = await this.prisma.partnerContestParticipant.findUnique({
      where: { contestId_userId: { contestId, userId } },
    });
    if (!participant) {
      throw new ForbiddenException({ error: 'NOT_JOINED', message: 'You must join this contest first' });
    }
    if (participant.hasSubmitted) {
      throw new BadRequestException({ error: 'ALREADY_SUBMITTED', message: 'You have already submitted answers' });
    }
    const contest = await this.prisma.partnerContest.findUnique({ where: { id: contestId } });
    if (!contest) throw new NotFoundException({ error: 'CONTEST_NOT_FOUND', message: 'Contest not found' });

    const questions = await this.prisma.partnerContestQuestion.findMany({
      where: { contestId },
      orderBy: { questionOrder: 'asc' },
      select: {
        id: true,
        questionOrder: true,
        questionText: true,
        imageUrl: true,
        optionA: true,
        optionB: true,
        optionC: true,
        optionD: true,
        optionE: true,
        questionType: true,
        // answer is intentionally excluded
      },
    });
    return { questions, timeLimitSeconds: contest.timeLimitSeconds };
  }

  async submitContest(contestId: number, userId: number, dto: SubmitPartnerContestDto) {
    const participant = await this.prisma.partnerContestParticipant.findUnique({
      where: { contestId_userId: { contestId, userId } },
    });
    if (!participant) throw new ForbiddenException({ error: 'NOT_JOINED', message: 'You must join this contest first' });
    if (participant.hasSubmitted) {
      throw new BadRequestException({ error: 'ALREADY_SUBMITTED', message: 'You have already submitted answers' });
    }

    const questions = await this.prisma.partnerContestQuestion.findMany({
      where: { contestId },
      orderBy: { questionOrder: 'asc' },
    });

    let correctCount = 0;
    for (const q of questions) {
      const submitted = dto.answers.find((a) => a.questionId === q.id);
      if (submitted && submitted.answer.toLowerCase() === q.answer.toLowerCase()) {
        correctCount++;
      }
    }

    const totalQuestions = questions.length;
    const score = totalQuestions > 0 ? (correctCount / totalQuestions) * 100 : 0;
    const timeTakenMs = Math.max(0, Math.min(dto.durationMs, totalQuestions * 60_000));

    // Fetch user display name
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: { name: true, profile: true },
    });
    const displayName = user?.name ?? 'Player';
    const avatarUrl = user?.profile ?? null;

    await this.prisma.$transaction(async (tx) => {
      await tx.partnerContestParticipant.update({
        where: { contestId_userId: { contestId, userId } },
        data: {
          hasSubmitted: true,
          submittedAt: new Date(),
          score,
          correctCount,
          timeTakenMs,
        },
      });

      await tx.partnerContestLeaderboard.upsert({
        where: { contestId_userId: { contestId, userId } },
        create: { contestId, userId, displayName, avatarUrl, score, correctAnswers: correctCount, timeTakenMs },
        update: { displayName, avatarUrl, score, correctAnswers: correctCount, timeTakenMs },
      });
    });

    // Recompute ranks
    await this._recomputeRanks(contestId);

    const updated = await this.prisma.partnerContestLeaderboard.findUnique({
      where: { contestId_userId: { contestId, userId } },
    });
    const total = await this.prisma.partnerContestLeaderboard.count({ where: { contestId } });

    return {
      score,
      correct: correctCount,
      total: totalQuestions,
      rank: updated?.rank ?? 0,
      totalParticipants: total,
    };
  }

  async getPublicLeaderboard(contestId: number) {
    const contest = await this.prisma.partnerContest.findUnique({
      where: { id: contestId },
      select: { id: true, title: true, status: true, endDate: true },
    });
    if (!contest) throw new NotFoundException({ error: 'CONTEST_NOT_FOUND', message: 'Contest not found' });

    const entries = await this.prisma.partnerContestLeaderboard.findMany({
      where: { contestId },
      orderBy: [{ score: 'desc' }, { timeTakenMs: 'asc' }],
      take: 100,
    });
    const total = await this.prisma.partnerContestParticipant.count({ where: { contestId } });
    return { entries, totalParticipants: total, contestStatus: contest.status };
  }

  // ─── Firebase-UID wrappers (used by public controller) ──────────────────

  private async _resolveUserId(firebaseUid: string): Promise<number> {
    const user = await this.prisma.user.findFirst({
      where: { firebaseId: firebaseUid },
      select: { id: true },
    });
    if (!user) throw new NotFoundException({ error: 'USER_NOT_FOUND', message: 'User account not found' });
    return user.id;
  }

  async getPublicContestByFirebaseUid(contestId: number, firebaseUid: string) {
    const userId = await this._resolveUserId(firebaseUid);
    return this.getPublicContest(contestId, userId);
  }

  async joinContestByFirebaseUid(contestId: number, firebaseUid: string) {
    const userId = await this._resolveUserId(firebaseUid);
    return this.joinContest(contestId, userId);
  }

  async getQuestionsForFirebaseUid(contestId: number, firebaseUid: string) {
    const userId = await this._resolveUserId(firebaseUid);
    return this.getQuestionsForUser(contestId, userId);
  }

  async submitContestByFirebaseUid(contestId: number, firebaseUid: string, dto: SubmitPartnerContestDto) {
    const userId = await this._resolveUserId(firebaseUid);
    return this.submitContest(contestId, userId, dto);
  }

  // ─── Admin oversight ─────────────────────────────────────────────────────

  async adminListPartners(status?: string, plan?: string, page = 1, limit = 50) {
    const take = Math.min(limit, 200);
    const skip = (page - 1) * take;
    const where = {
      ...(status ? { status } : {}),
      ...(plan ? { plan } : {}),
    };
    const [items, total] = await Promise.all([
      this.prisma.partner.findMany({
        where,
        orderBy: { createdAt: 'desc' },
        skip,
        take,
        include: { _count: { select: { contests: true, users: true } } },
      }),
      this.prisma.partner.count({ where }),
    ]);
    return {
      items: items.map((p) => ({ ...this._safePartner(p), contestCount: p._count.contests, teamSize: p._count.users })),
      pagination: { page, limit: take, total, pages: Math.ceil(total / take) },
    };
  }

  async adminGetPartner(partnerId: number) {
    const partner = await this.prisma.partner.findUnique({
      where: { id: partnerId },
      include: {
        users: { select: { id: true, email: true, displayName: true, role: true, status: true, createdAt: true } },
        contests: { select: { id: true, title: true, status: true, createdAt: true, _count: { select: { participants: true } } }, orderBy: { createdAt: 'desc' }, take: 10 },
      },
    });
    if (!partner) throw new NotFoundException({ error: 'PARTNER_NOT_FOUND', message: 'Partner not found' });
    return partner;
  }

  async adminApprovePartner(partnerId: number) {
    const partner = await this._requirePartner(partnerId);
    if (partner.status !== 'pending') {
      throw new BadRequestException({ error: 'NOT_PENDING', message: 'Partner is not in pending state' });
    }
    const updated = await this.prisma.partner.update({
      where: { id: partnerId },
      data: { status: 'active', approvedAt: new Date() },
    });

    // Issue custom token claims to the owner
    const owner = await this.prisma.partnerUser.findFirst({ where: { partnerId, role: 'owner' } });
    if (owner) {
      await this._issuePartnerClaims(owner.firebaseUid, partnerId, 'owner', 'active');
    }
    return this._safePartner(updated);
  }

  async adminSuspendPartner(partnerId: number) {
    const partner = await this._requirePartner(partnerId);
    const updated = await this.prisma.partner.update({
      where: { id: partnerId },
      data: { status: 'suspended' },
    });

    // Revoke all partner user tokens
    const users = await this.prisma.partnerUser.findMany({ where: { partnerId } });
    await Promise.all(users.map((u) => this.firebase.auth().revokeRefreshTokens(u.firebaseUid).catch(() => {})));
    return this._safePartner(updated);
  }

  async adminOverridePlan(partnerId: number, plan: string, expiresAt?: string) {
    await this._requirePartner(partnerId);
    const updated = await this.prisma.partner.update({
      where: { id: partnerId },
      data: {
        plan,
        planExpiresAt: expiresAt ? new Date(expiresAt) : null,
      },
    });
    return this._safePartner(updated);
  }

  async adminGetPartnerContests(partnerId: number, page = 1, limit = 20) {
    await this._requirePartner(partnerId);
    const take = Math.min(limit, 100);
    const skip = (page - 1) * take;
    const [items, total] = await Promise.all([
      this.prisma.partnerContest.findMany({
        where: { partnerId },
        orderBy: { createdAt: 'desc' },
        skip,
        take,
        include: { _count: { select: { participants: true, questions: true } } },
      }),
      this.prisma.partnerContest.count({ where: { partnerId } }),
    ]);
    return { items, pagination: { page, limit: take, total, pages: Math.ceil(total / take) } };
  }

  // ─── Private helpers ─────────────────────────────────────────────────────

  private async _requirePartner(partnerId: number) {
    const partner = await this.prisma.partner.findUnique({ where: { id: partnerId } });
    if (!partner) throw new NotFoundException({ error: 'PARTNER_NOT_FOUND', message: 'Partner not found' });
    return partner;
  }

  private async _enforceContestLimit(partnerId: number, plan: string) {
    const limits = PLAN_LIMITS[plan] ?? PLAN_LIMITS.free;
    const activeCount = await this.prisma.partnerContest.count({
      where: { partnerId, status: { in: ['draft', 'published', 'live'] } },
    });
    if (activeCount >= limits.contests) {
      throw new ForbiddenException({
        error: 'PLAN_LIMIT_EXCEEDED',
        message: `Your ${plan} plan allows a maximum of ${limits.contests} active contest(s). Upgrade to create more.`,
      });
    }
  }

  private async _enforceQuestionLimit(contestId: number, plan: string) {
    const limits = PLAN_LIMITS[plan] ?? PLAN_LIMITS.free;
    const current = await this.prisma.partnerContestQuestion.count({ where: { contestId } });
    if (current >= limits.questions) {
      throw new ForbiddenException({
        error: 'QUESTION_LIMIT_EXCEEDED',
        message: `Your plan allows a maximum of ${limits.questions} question(s) per contest. Upgrade for more.`,
      });
    }
  }

  private async _generateInviteCode(): Promise<string> {
    for (let i = 0; i < 10; i++) {
      const code = crypto.randomBytes(4).toString('hex').toUpperCase();
      const existing = await this.prisma.partnerContest.findFirst({ where: { inviteCode: code } });
      if (!existing) return code;
    }
    throw new Error('Failed to generate unique invite code');
  }

  private async _recomputeRanks(contestId: number) {
    const entries = await this.prisma.partnerContestLeaderboard.findMany({
      where: { contestId },
      orderBy: [{ score: 'desc' }, { timeTakenMs: 'asc' }],
    });
    await this.prisma.$transaction(
      entries.map((e, i) =>
        this.prisma.partnerContestLeaderboard.update({
          where: { id: e.id },
          data: { rank: i + 1 },
        }),
      ),
    );
  }

  private async _issuePartnerClaims(firebaseUid: string, partnerId: number, role: string, status: string) {
    try {
      await this.firebase.auth().setCustomUserClaims(firebaseUid, { partnerId, partnerRole: role, partnerStatus: status });
    } catch (err) {
      this.logger.warn(`Failed to set partner claims for ${firebaseUid}: ${(err as Error).message}`);
    }
  }

  private _safePartner(p: Record<string, unknown>) {
    // eslint-disable-next-line @typescript-eslint/no-unused-vars
    const { approvedByAdminId, ...rest } = p as { approvedByAdminId: unknown; [k: string]: unknown };
    return rest;
  }

  private _safeContest(c: Record<string, unknown>) {
    // Never return inviteCode to public mobile endpoints
    const { inviteCode, ...rest } = c as { inviteCode: unknown; [k: string]: unknown };
    void inviteCode;
    return rest;
  }
}
