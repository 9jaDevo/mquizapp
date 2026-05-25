import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mquiz/core/theme/app_colors.dart';
import 'package:mquiz/core/widgets/common_widgets.dart';
import 'package:mquiz/features/leagues/cubit/league_cubit.dart';
import 'package:mquiz/features/leagues/models/league_model.dart';

class LeaguesListScreen extends StatefulWidget {
  const LeaguesListScreen({super.key});

  @override
  State<LeaguesListScreen> createState() => _LeaguesListScreenState();
}

class _LeaguesListScreenState extends State<LeaguesListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<LeaguesListCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        title: const Text('Leagues'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<LeaguesListCubit, LeaguesListState>(
        builder: (context, state) {
          return switch (state) {
            LeaguesListInitial() ||
            LeaguesListLoading() =>
              const Center(child: CircularProgressIndicator()),
            LeaguesListError(message: final m) => ErrorStateView(
                message: m,
                onRetry: () => context.read<LeaguesListCubit>().load(),
              ),
            LeaguesListLoaded() => RefreshIndicator(
                onRefresh: () => context.read<LeaguesListCubit>().load(),
                child: state.leagues.isEmpty
                    ? ListView(
                        children: const [
                          SizedBox(height: 80),
                          EmptyStateView(
                            message: 'No leagues are running right now.',
                            icon: Icons.emoji_events_outlined,
                          ),
                        ],
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.leagues.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 12),
                        itemBuilder: (ctx, i) {
                          final l = state.leagues[i];
                          return _LeagueCard(
                            league: l,
                            isMine: state.membership?.leagueId == l.id,
                          );
                        },
                      ),
              ),
          };
        },
      ),
    );
  }
}

class _LeagueCard extends StatelessWidget {
  const _LeagueCard({required this.league, required this.isMine});
  final League league;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: () => context.push('/leagues/${league.id}'),
      gradient: AppColors.primaryGradient,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.emoji_events, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  league.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
              if (isMine)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Joined',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ),
            ],
          ),
          if ((league.description ?? '').isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              league.description!,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 13,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              if (league.prizePool != null)
                _Pill(
                  icon: Icons.bolt_rounded,
                  label: '${league.prizePool} coin pool',
                ),
              if (league.participantsCount != null) ...[
                const SizedBox(width: 8),
                _Pill(
                  icon: Icons.people_outline,
                  label: '${league.participantsCount} players',
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
