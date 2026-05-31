import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mquiz/core/constants/app_constants.dart';
import 'package:mquiz/core/theme/app_colors.dart';
import 'package:mquiz/core/widgets/common_widgets.dart';
import 'package:mquiz/features/partner_contests/cubit/partner_contest_list_cubit.dart';
import 'package:mquiz/features/partner_contests/models/partner_contest.dart';

class PartnerContestDetailScreen extends StatefulWidget {
  const PartnerContestDetailScreen({
    super.key,
    required this.contestId,
    this.contest,
  });

  final int contestId;
  final PartnerContest? contest;

  @override
  State<PartnerContestDetailScreen> createState() => _PartnerContestDetailScreenState();
}

class _PartnerContestDetailScreenState extends State<PartnerContestDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PartnerContestDetailCubit>().load(widget.contestId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PartnerContestDetailCubit, PartnerContestDetailState>(
      listener: (ctx, state) {
        if (state is PartnerContestJoined) {
          context.push('/partner-contests/${state.contest.id}/play', extra: state.contest);
        }
        if (state is PartnerContestDetailError) {
          ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (ctx, state) => Scaffold(
        backgroundColor: AppColors.pageBackground,
        appBar: AppBar(
          title: Text(widget.contest?.title ?? 'Contest'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: switch (state) {
          PartnerContestDetailInitial() ||
          PartnerContestDetailLoading() =>
            const Center(child: CircularProgressIndicator()),
          PartnerContestDetailError(message: final m) => ErrorStateView(
              message: m,
              onRetry: () => ctx.read<PartnerContestDetailCubit>().load(widget.contestId),
            ),
          PartnerContestJoined() || PartnerContestDetailLoaded() => () {
              final loaded = state is PartnerContestDetailLoaded ? state : null;
              final contest = loaded?.contest ?? widget.contest;
              if (contest == null) return const SizedBox();
              return _DetailBody(
                contest: contest,
                leaderboard: loaded?.leaderboard ?? [],
              );
            }(),
        },
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.contest, required this.leaderboard});
  final PartnerContest contest;
  final List leaderboard;

  String _format(DateTime? d) =>
      d == null ? '—' : DateFormat('MMM d, yyyy  h:mm a').format(d);

  @override
  Widget build(BuildContext context) {
    final canPlay = contest.isLive && !contest.isFull;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (contest.bannerUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(contest.bannerUrl!, height: 160, width: double.infinity, fit: BoxFit.cover),
            ),
          const SizedBox(height: 16),
          Text(contest.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          if (contest.orgName != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('Hosted by ${contest.orgName}',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            ),
          const SizedBox(height: 16),
          _InfoRow(Icons.quiz_outlined, '${contest.questionCount} questions'),
          _InfoRow(Icons.people_outline, '${contest.participantCount} participants'),
          if (contest.timeLimitSeconds != null)
            _InfoRow(Icons.timer_outlined, '${contest.timeLimitSeconds}s per question'),
          _InfoRow(Icons.calendar_today_outlined, 'Ends: ${_format(contest.endDate)}'),
          if (contest.coinPrizePool != null && contest.coinPrizePool! > 0)
            _InfoRow(Icons.monetization_on_outlined, '${contest.coinPrizePool} coin prize pool'),
          if (contest.description != null) ...[
            const SizedBox(height: 16),
            const Text('About', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 6),
            Text(contest.description!, style: TextStyle(color: AppColors.textSecondary)),
          ],
          if (contest.customJoinMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(contest.customJoinMessage!),
            ),
          ],
          const SizedBox(height: 24),
          if (contest.hasJoined)
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Play Contest'),
                onPressed: () =>
                    context.push('/partner-contests/${contest.id}/play', extra: contest),
              ),
            )
          else if (canPlay)
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(Icons.login_rounded),
                label: const Text('Join & Play'),
                onPressed: () =>
                    context.read<PartnerContestDetailCubit>().join(contest.id),
              ),
            )
          else if (contest.isFull)
            const Center(child: Text('Contest is full.'))
          else
            const Center(child: Text('Contest is not live yet.')),
          const SizedBox(height: 16),
          if (leaderboard.isNotEmpty)
            TextButton.icon(
              icon: const Icon(Icons.leaderboard_rounded),
              label: const Text('View Leaderboard'),
              onPressed: () => context.push('/partner-contests/${contest.id}/leaderboard'),
            ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.icon, this.label);
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
        ],
      ),
    );
  }
}
