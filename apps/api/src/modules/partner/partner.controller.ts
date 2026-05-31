import {
  Body,
  Controller,
  Delete,
  Get,
  HttpCode,
  Param,
  ParseIntPipe,
  Post,
  Put,
  Query,
  UseGuards,
} from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { PartnerService } from './partner.service';
import { PartnerAuthGuard } from '../../common/guards/partner-auth.guard';
import { CurrentPartner, PartnerPrincipal } from '../../common/decorators/current-partner.decorator';
import { CreatePartnerContestDto } from './dto/create-partner-contest.dto';
import {
  AddPartnerQuestionDto,
  AddQuestionsFromBankDto,
  ReorderQuestionsDto,
} from './dto/add-partner-question.dto';

@ApiTags('partner')
@ApiBearerAuth('firebase-token')
@UseGuards(PartnerAuthGuard)
@Controller({ path: 'partner', version: '2' })
export class PartnerController {
  constructor(private readonly service: PartnerService) {}

  // ─── Profile ────────────────────────────────────────────────────────────

  @Get('profile')
  @ApiOperation({ summary: 'Get own partner profile + plan usage' })
  getProfile(@CurrentPartner() p: PartnerPrincipal) {
    return this.service.getProfile(p.partnerId);
  }

  @Put('profile')
  @ApiOperation({ summary: 'Update partner profile' })
  updateProfile(@CurrentPartner() p: PartnerPrincipal, @Body() body: Partial<{ orgName: string; phone: string; website: string; description: string; logoUrl: string; country: string }>) {
    return this.service.updateProfile(p.partnerId, body);
  }

  @Get('plan')
  @ApiOperation({ summary: 'Get current plan limits and usage' })
  getPlan(@CurrentPartner() p: PartnerPrincipal) {
    return this.service.getProfile(p.partnerId);
  }

  // ─── Team ───────────────────────────────────────────────────────────────

  @Get('team')
  @ApiOperation({ summary: 'List team members' })
  listTeam(@CurrentPartner() p: PartnerPrincipal) {
    return this.service.listTeam(p.partnerId);
  }

  @Post('team/invite')
  @HttpCode(201)
  @ApiOperation({ summary: 'Invite a team member by email' })
  inviteTeamMember(
    @CurrentPartner() p: PartnerPrincipal,
    @Body() body: { email: string; role: string },
  ) {
    return this.service.inviteTeamMember(p.partnerId, body.email, body.role);
  }

  @Delete('team/:memberId')
  @HttpCode(200)
  @ApiOperation({ summary: 'Remove a team member (owner only)' })
  removeTeamMember(
    @CurrentPartner() p: PartnerPrincipal,
    @Param('memberId', ParseIntPipe) memberId: number,
  ) {
    return this.service.removeTeamMember(p.partnerId, memberId, p.partnerRole);
  }

  // ─── Contests ───────────────────────────────────────────────────────────

  @Get('contests')
  @ApiOperation({ summary: 'List own contests (paginated)' })
  listContests(
    @CurrentPartner() p: PartnerPrincipal,
    @Query('status') status?: string,
    @Query('page') page?: string,
    @Query('limit') limit?: string,
  ) {
    return this.service.listContests(p.partnerId, status, parseInt(page ?? '1'), parseInt(limit ?? '20'));
  }

  @Get('contests/:id')
  @ApiOperation({ summary: 'Get contest detail' })
  getContest(@CurrentPartner() p: PartnerPrincipal, @Param('id', ParseIntPipe) id: number) {
    return this.service.getContest(p.partnerId, id);
  }

  @Post('contests')
  @HttpCode(201)
  @ApiOperation({ summary: 'Create a contest (draft)' })
  createContest(@CurrentPartner() p: PartnerPrincipal, @Body() dto: CreatePartnerContestDto) {
    return this.service.createContest(p.partnerId, dto);
  }

  @Put('contests/:id')
  @ApiOperation({ summary: 'Update a draft contest' })
  updateContest(
    @CurrentPartner() p: PartnerPrincipal,
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: Partial<CreatePartnerContestDto>,
  ) {
    return this.service.updateContest(p.partnerId, id, dto);
  }

  @Post('contests/:id/publish')
  @HttpCode(200)
  @ApiOperation({ summary: 'Publish a draft contest' })
  publishContest(@CurrentPartner() p: PartnerPrincipal, @Param('id', ParseIntPipe) id: number) {
    return this.service.publishContest(p.partnerId, id);
  }

  @Post('contests/:id/end')
  @HttpCode(200)
  @ApiOperation({ summary: 'Manually end a live/published contest' })
  endContest(@CurrentPartner() p: PartnerPrincipal, @Param('id', ParseIntPipe) id: number) {
    return this.service.endContest(p.partnerId, id);
  }

  @Delete('contests/:id')
  @HttpCode(200)
  @ApiOperation({ summary: 'Delete a draft contest' })
  deleteContest(@CurrentPartner() p: PartnerPrincipal, @Param('id', ParseIntPipe) id: number) {
    return this.service.deleteContest(p.partnerId, id);
  }

  @Post('contests/:id/regenerate-code')
  @HttpCode(200)
  @ApiOperation({ summary: 'Regenerate invite code for a private contest' })
  regenerateCode(@CurrentPartner() p: PartnerPrincipal, @Param('id', ParseIntPipe) id: number) {
    return this.service.regenerateInviteCode(p.partnerId, id);
  }

  // ─── Questions ──────────────────────────────────────────────────────────

  @Get('contests/:id/questions')
  @ApiOperation({ summary: 'List questions for a contest' })
  listQuestions(@CurrentPartner() p: PartnerPrincipal, @Param('id', ParseIntPipe) id: number) {
    return this.service.listQuestions(p.partnerId, id);
  }

  @Post('contests/:id/questions')
  @HttpCode(201)
  @ApiOperation({ summary: 'Add a custom question' })
  addQuestion(
    @CurrentPartner() p: PartnerPrincipal,
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: AddPartnerQuestionDto,
  ) {
    return this.service.addQuestion(p.partnerId, id, dto);
  }

  @Put('contests/:id/questions/:qid')
  @ApiOperation({ summary: 'Update a question' })
  updateQuestion(
    @CurrentPartner() p: PartnerPrincipal,
    @Param('id', ParseIntPipe) id: number,
    @Param('qid', ParseIntPipe) qid: number,
    @Body() dto: Partial<AddPartnerQuestionDto>,
  ) {
    return this.service.updateQuestion(p.partnerId, id, qid, dto);
  }

  @Delete('contests/:id/questions/:qid')
  @HttpCode(200)
  @ApiOperation({ summary: 'Delete a question' })
  deleteQuestion(
    @CurrentPartner() p: PartnerPrincipal,
    @Param('id', ParseIntPipe) id: number,
    @Param('qid', ParseIntPipe) qid: number,
  ) {
    return this.service.deleteQuestion(p.partnerId, id, qid);
  }

  @Post('contests/:id/questions/from-bank')
  @HttpCode(201)
  @ApiOperation({ summary: 'Add questions from mQuiz bank (Starter+ only)' })
  addFromBank(
    @CurrentPartner() p: PartnerPrincipal,
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: AddQuestionsFromBankDto,
  ) {
    return this.service.addQuestionsFromBank(p.partnerId, id, dto);
  }

  @Put('contests/:id/questions/reorder')
  @ApiOperation({ summary: 'Reorder questions' })
  reorderQuestions(
    @CurrentPartner() p: PartnerPrincipal,
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: ReorderQuestionsDto,
  ) {
    return this.service.reorderQuestions(p.partnerId, id, dto);
  }

  // ─── Participants & Leaderboard ──────────────────────────────────────────

  @Get('contests/:id/participants')
  @ApiOperation({ summary: 'List participants for a contest' })
  listParticipants(
    @CurrentPartner() p: PartnerPrincipal,
    @Param('id', ParseIntPipe) id: number,
    @Query('submitted') submitted?: string,
    @Query('page') page?: string,
    @Query('limit') limit?: string,
  ) {
    const sub = submitted === 'true' ? true : submitted === 'false' ? false : undefined;
    return this.service.listParticipants(p.partnerId, id, sub, parseInt(page ?? '1'), parseInt(limit ?? '50'));
  }

  @Get('contests/:id/leaderboard')
  @ApiOperation({ summary: 'Live leaderboard for a contest' })
  getLeaderboard(@CurrentPartner() p: PartnerPrincipal, @Param('id', ParseIntPipe) id: number) {
    return this.service.getLeaderboard(p.partnerId, id);
  }

  @Post('contests/:id/prizes/distribute')
  @HttpCode(200)
  @ApiOperation({ summary: 'Mark prizes as distributed for an ended contest' })
  distributePrizes(@CurrentPartner() p: PartnerPrincipal, @Param('id', ParseIntPipe) id: number) {
    return this.service.markPrizesDistributed(p.partnerId, id);
  }

  // ─── Analytics ──────────────────────────────────────────────────────────

  @Get('analytics')
  @ApiOperation({ summary: 'Overview analytics for all own contests' })
  analytics(@CurrentPartner() p: PartnerPrincipal) {
    return this.service.getAnalytics(p.partnerId);
  }

  @Get('analytics/contests/:id')
  @ApiOperation({ summary: 'Per-contest analytics' })
  contestAnalytics(@CurrentPartner() p: PartnerPrincipal, @Param('id', ParseIntPipe) id: number) {
    return this.service.getContestAnalytics(p.partnerId, id);
  }
}
