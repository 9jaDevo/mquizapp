import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mquiz/core/theme/app_colors.dart';
import 'package:mquiz/core/widgets/common_widgets.dart';
import 'package:mquiz/features/partner_contests/cubit/partner_contest_list_cubit.dart';
import 'package:mquiz/features/partner_contests/models/partner_leaderboard.dart';

class PartnerContestLeaderboardScreen extends StatefulWidget {
  const PartnerContestLeaderboardScreen({super.key, required this.contestId});
  final int contestId;

  @override
  State<PartnerContestLeaderboardScreen> createState() =>
      _PartnerContestLeaderboardScreenState();
}

class _PartnerContestLeaderboardScreenState
    extends State<PartnerContestLeaderboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PartnerContestDetailCubit>().load(widget.contestId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        title: const Text('Leaderboard'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<PartnerContestDetailCubit, PartnerContestDetailState>(
        builder: (context, state) => switch (state) {
          PartnerContestDetailLoading() ||
          PartnerContestDetailInitial() =>
            const Center(child: CircularProgressIndicator()),
          PartnerContestDetailError(message: final m) => ErrorStateView(
              message: m,
              onRetry: () =>
                  context.read<PartnerContestDetailCubit>().load(widget.contestId),
            ),
          PartnerContestDetailLoaded(leaderboard: final entries) => () {
              if (entries.isEmpty) {
                return const EmptyStateView(
                  message: 'No results yet.',
                  icon: Icons.leaderboard_outlined,
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: entries.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) => _LeaderboardTile(entries[i]),
              );
            }(),
          _ => const SizedBox.shrink(),
        },
      ),
    );
  }
}

class _LeaderboardTile extends StatelessWidget {
  const _LeaderboardTile(this.entry);
  final PartnerLeaderboardEntry entry;

  @override
  Widget build(BuildContext context) {
    final isTop = entry.rank <= 3;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: entry.isCurrentUser
            ? AppColors.primary.withValues(alpha: 0.08)
            : isTop
                ? AppColors.correct.withValues(alpha: 0.06)
                : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: entry.isCurrentUser
              ? AppColors.primary
              : isTop
                  ? AppColors.correct.withValues(alpha: 0.3)
                  : AppColors.border,
          width: entry.isCurrentUser ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Text(
              entry.rank == 1
                  ? '🥇'
                  : entry.rank == 2
                      ? '🥈'
                      : entry.rank == 3
                          ? '🥉'
                          : '#${entry.rank}',
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 20,
            backgroundImage:
                entry.avatarUrl != null ? NetworkImage(entry.avatarUrl!) : null,
            backgroundColor: AppColors.primary.withValues(alpha: 0.15),
            child: entry.avatarUrl == null
                ? Text(entry.displayName[0].toUpperCase(),
                    style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold))
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.displayName,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                Text(
                  '${entry.correctAnswers} correct · ${entry.formattedTime}',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            '${entry.score.toStringAsFixed(1)}%',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
