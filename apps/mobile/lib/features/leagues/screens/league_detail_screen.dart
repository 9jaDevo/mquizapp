import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mquiz/core/constants/app_constants.dart';
import 'package:mquiz/core/theme/app_colors.dart';
import 'package:mquiz/core/widgets/common_widgets.dart';
import 'package:mquiz/features/auth/cubit/auth_cubit.dart';
import 'package:mquiz/features/leaderboard/models/leaderboard_entry_model.dart';
import 'package:mquiz/features/leagues/cubit/league_cubit.dart';
import 'package:mquiz/features/leagues/models/league_model.dart';

class LeagueDetailScreen extends StatefulWidget {
  const LeagueDetailScreen({super.key, required this.leagueId});
  final int leagueId;

  @override
  State<LeagueDetailScreen> createState() => _LeagueDetailScreenState();
}

class _LeagueDetailScreenState extends State<LeagueDetailScreen> {
  int? _currentUserId() {
    final s = context.read<AuthCubit>().state;
    if (s is Authenticated) return int.tryParse(s.user.userId);
    return null;
  }

  @override
  void initState() {
    super.initState();
    context
        .read<LeagueDetailCubit>()
        .load(widget.leagueId, currentUserId: _currentUserId());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('League'),
      ),
      body: BlocBuilder<LeagueDetailCubit, LeagueDetailState>(
        builder: (context, state) {
          return switch (state) {
            LeagueDetailInitial() ||
            LeagueDetailLoading() =>
              const Center(child: CircularProgressIndicator()),
            LeagueDetailError(message: final m) => ErrorStateView(
                message: m,
                onRetry: () => context.read<LeagueDetailCubit>().load(
                      widget.leagueId,
                      currentUserId: _currentUserId(),
                    ),
              ),
            LeagueDetailLoaded() => _DetailBody(state: state),
          };
        },
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.state});
  final LeagueDetailLoaded state;

  @override
  Widget build(BuildContext context) {
    final league = state.league;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _HeaderCard(league: league),
        const SizedBox(height: 16),
        if (!league.isJoined)
          PrimaryButton(
            label: league.entryCoinCost != null && league.entryCoinCost! > 0
                ? 'Join for ${league.entryCoinCost} coins'
                : 'Join League',
            icon: Icons.emoji_events_outlined,
            loading: state.joining,
            onPressed: state.joining
                ? null
                : () async {
                    final ok =
                        await context.read<LeagueDetailCubit>().join();
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          ok ? 'Joined!' : 'Could not join right now.',
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
          )
        else
          OutlinedButton.icon(
            onPressed: () => context.push(
              AppConstants.routeLeagueQuiz.replaceFirst(
                  ':leagueId', '${league.id}'),
              extra: league.name,
            ),
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text("Play today's questions"),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
          ),
        const SizedBox(height: 20),
        const Text(
          'Top players',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        const SizedBox(height: 8),
        if (state.entries.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: EmptyStateView(
              message: 'No scores yet. Be the first to play!',
              icon: Icons.leaderboard_outlined,
            ),
          )
        else
          ...state.entries.take(20).map(_LeagueRow.new),
      ],
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.league});
  final League league;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            league.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          if ((league.description ?? '').isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              league.description!,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 13.5,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (league.prizePool != null)
                _Stat(
                  icon: Icons.workspace_premium,
                  label: 'Prize pool',
                  value: '${league.prizePool}',
                ),
              if (league.participantsCount != null)
                _Stat(
                  icon: Icons.people_outline,
                  label: 'Players',
                  value: '${league.participantsCount}',
                ),
              if (league.questionsPerDay != null)
                _Stat(
                  icon: Icons.quiz_outlined,
                  label: 'Daily',
                  value: '${league.questionsPerDay} qs',
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            '$value $label',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _LeagueRow extends StatelessWidget {
  const _LeagueRow(this.entry);
  final LeaderboardEntry entry;

  @override
  Widget build(BuildContext context) {
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
          width: entry.isMe ? 1.4 : 1,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '#${entry.rank}',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          Expanded(
            child: Text(
              entry.name + (entry.isMe ? ' (You)' : ''),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            '${entry.score}',
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: AppColors.coin,
            ),
          ),
        ],
      ),
    );
  }
}
