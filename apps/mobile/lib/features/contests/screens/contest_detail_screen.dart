import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mquiz/core/theme/app_colors.dart';
import 'package:mquiz/core/widgets/common_widgets.dart';
import 'package:mquiz/features/auth/cubit/auth_cubit.dart';
import 'package:mquiz/features/contests/cubit/contest_cubit.dart';
import 'package:mquiz/features/contests/models/contest_model.dart';
import 'package:mquiz/features/leaderboard/models/leaderboard_entry_model.dart';

class ContestDetailScreen extends StatefulWidget {
  const ContestDetailScreen({super.key, required this.contest});

  final Contest contest;

  @override
  State<ContestDetailScreen> createState() => _ContestDetailScreenState();
}

class _ContestDetailScreenState extends State<ContestDetailScreen> {
  int? _currentUserId() {
    final s = context.read<AuthCubit>().state;
    if (s is Authenticated) return int.tryParse(s.user.userId);
    return null;
  }

  @override
  void initState() {
    super.initState();
    context.read<ContestDetailCubit>().load(
          widget.contest,
          currentUserId: _currentUserId(),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text(widget.contest.name),
      ),
      body: BlocBuilder<ContestDetailCubit, ContestDetailState>(
        builder: (context, state) => switch (state) {
          ContestDetailInitial() ||
          ContestDetailLoading() =>
            const Center(child: CircularProgressIndicator()),
          ContestDetailError(message: final m) => ErrorStateView(
              message: m,
              onRetry: () => context.read<ContestDetailCubit>().load(
                    widget.contest,
                    currentUserId: _currentUserId(),
                  ),
            ),
          ContestDetailLoaded() => _DetailBody(state: state),
        },
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.state});
  final ContestDetailLoaded state;

  String _formatDate(DateTime? d) =>
      d == null ? '—' : DateFormat('MMM d, yyyy h:mm a').format(d);

  @override
  Widget build(BuildContext context) {
    final contest = state.contest;
    final live = contest.isLive;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ── Banner Card ──────────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: (live ? Colors.greenAccent : Colors.white24)
                          .withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      live ? 'LIVE NOW' : 'UPCOMING',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  if (contest.isParticipated) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'ENTERED',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              Text(
                contest.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if ((contest.description ?? '').isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  contest.description!,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  if (contest.prizePool != null)
                    _StatPill(
                      icon: Icons.workspace_premium,
                      label: '${contest.prizePool} coins prize',
                      iconColor: AppColors.coin,
                    ),
                  if (contest.questionCount != null)
                    _StatPill(
                      icon: Icons.quiz_outlined,
                      label: '${contest.questionCount} questions',
                      iconColor: Colors.white70,
                    ),
                  if (contest.entryCoinCost != null &&
                      contest.entryCoinCost! > 0)
                    _StatPill(
                      icon: Icons.toll_outlined,
                      label: '${contest.entryCoinCost} coin entry',
                      iconColor: AppColors.coin,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.event_outlined,
                      size: 14, color: Colors.white70),
                  const SizedBox(width: 6),
                  Text(
                    '${_formatDate(contest.startDate)} → ${_formatDate(contest.endDate)}',
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // ── Play Button ──────────────────────────────────────────────────────
        if (live)
          PrimaryButton(
            label:
                contest.isParticipated ? 'Play Again' : 'Enter & Play',
            icon: Icons.play_arrow_rounded,
            onPressed: () => context.push(
              '/contests/${contest.id}/play',
              extra: contest,
            ),
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              'Contest has not started yet',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
        const SizedBox(height: 24),
        // ── Leaderboard ──────────────────────────────────────────────────────
        const Text(
          'Leaderboard',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        const SizedBox(height: 8),
        if (state.leaderboard.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: EmptyStateView(
              message: 'No scores yet. Be the first to play!',
              icon: Icons.leaderboard_outlined,
            ),
          )
        else
          ...state.leaderboard.take(20).map(_LeaderboardRow.new),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.icon,
    required this.label,
    required this.iconColor,
  });

  final IconData icon;
  final String label;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: iconColor),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ],
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  const _LeaderboardRow(this.entry);
  final LeaderboardEntry entry;

  @override
  Widget build(BuildContext context) {
    final isTop3 = entry.rank <= 3;
    final rankColor = switch (entry.rank) {
      1 => const Color(0xFFFFD700),
      2 => const Color(0xFFC0C0C0),
      3 => const Color(0xFFCD7F32),
      _ => AppColors.textSecondary,
    };
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: entry.isMe
            ? AppColors.primary.withValues(alpha: 0.08)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: entry.isMe ? AppColors.primary : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '${entry.rank}',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: isTop3 ? rankColor : AppColors.textSecondary,
                fontSize: isTop3 ? 16 : 14,
              ),
            ),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primary.withValues(alpha: 0.12),
            backgroundImage: entry.profileImage != null
                ? NetworkImage(entry.profileImage!)
                : null,
            child: entry.profileImage == null
                ? Text(
                    entry.name.isNotEmpty ? entry.name[0].toUpperCase() : '?',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.primary),
                  )
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              entry.name,
              style: TextStyle(
                fontWeight:
                    entry.isMe ? FontWeight.w700 : FontWeight.normal,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '${entry.score}',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
