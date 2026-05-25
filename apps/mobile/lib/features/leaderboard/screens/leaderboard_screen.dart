import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mquiz/core/theme/app_colors.dart';
import 'package:mquiz/core/widgets/common_widgets.dart';
import 'package:mquiz/features/auth/cubit/auth_cubit.dart';
import 'package:mquiz/features/leaderboard/cubit/leaderboard_cubit.dart';
import 'package:mquiz/features/leaderboard/data/leaderboard_repository.dart';
import 'package:mquiz/features/leaderboard/models/leaderboard_entry_model.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  static const _periods = LeaderboardPeriod.values;

  int? _currentUserId() {
    final s = context.read<AuthCubit>().state;
    if (s is Authenticated) return int.tryParse(s.user.userId);
    return null;
  }

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: _periods.length, vsync: this, initialIndex: 1);
    _tabs.addListener(_onTabChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<LeaderboardCubit>()
          .load(_periods[_tabs.index], currentUserId: _currentUserId());
    });
  }

  void _onTabChanged() {
    if (!_tabs.indexIsChanging) return;
    context
        .read<LeaderboardCubit>()
        .load(_periods[_tabs.index], currentUserId: _currentUserId());
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        title: const Text('Leaderboard'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700),
          tabs: [for (final p in _periods) Tab(text: p.label)],
        ),
      ),
      body: BlocBuilder<LeaderboardCubit, LeaderboardState>(
        builder: (context, state) {
          return switch (state) {
            LeaderboardInitial() ||
            LeaderboardLoading() =>
              const Center(child: CircularProgressIndicator()),
            LeaderboardError(message: final msg) => ErrorStateView(
                message: msg,
                onRetry: () => context.read<LeaderboardCubit>().load(
                      _periods[_tabs.index],
                      currentUserId: _currentUserId(),
                    ),
              ),
            LeaderboardLoaded(:final entries) => entries.isEmpty
                ? const EmptyStateView(
                    message: 'No rankings yet — play a quiz to get on the board!',
                    icon: Icons.leaderboard_outlined,
                  )
                : _RankList(entries: entries),
          };
        },
      ),
    );
  }
}

class _RankList extends StatelessWidget {
  const _RankList({required this.entries});
  final List<LeaderboardEntry> entries;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: entries.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (ctx, i) => _RankRow(entry: entries[i]),
    );
  }
}

class _RankRow extends StatelessWidget {
  const _RankRow({required this.entry});
  final LeaderboardEntry entry;

  @override
  Widget build(BuildContext context) {
    Color rankColor() {
      if (entry.rank == 1) return AppColors.coin;
      if (entry.rank == 2) return Colors.grey.shade500;
      if (entry.rank == 3) return const Color(0xFFCD7F32);
      return AppColors.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: entry.isMe
            ? AppColors.primary.withValues(alpha: 0.08)
            : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: entry.isMe ? AppColors.primary : AppColors.border,
          width: entry.isMe ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(
              '#${entry.rank}',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: rankColor(),
              ),
            ),
          ),
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.divider,
            backgroundImage: entry.profileImage != null
                ? NetworkImage(entry.profileImage!)
                : null,
            child: entry.profileImage == null
                ? Text(
                    entry.name.isNotEmpty
                        ? entry.name[0].toUpperCase()
                        : '?',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              entry.name + (entry.isMe ? ' (You)' : ''),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Row(
            children: [
              const Icon(Icons.star_rounded,
                  color: AppColors.coin, size: 18),
              const SizedBox(width: 4),
              Text(
                '${entry.score}',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
