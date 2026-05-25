import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mquiz/core/theme/app_colors.dart';
import 'package:mquiz/core/widgets/common_widgets.dart';
import 'package:mquiz/features/contests/cubit/contest_cubit.dart';
import 'package:mquiz/features/contests/models/contest_model.dart';

class ContestsListScreen extends StatefulWidget {
  const ContestsListScreen({super.key});

  @override
  State<ContestsListScreen> createState() => _ContestsListScreenState();
}

class _ContestsListScreenState extends State<ContestsListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ContestsListCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        title: const Text('Contests'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<ContestsListCubit, ContestsListState>(
        builder: (context, state) => switch (state) {
          ContestsListInitial() ||
          ContestsListLoading() =>
            const Center(child: CircularProgressIndicator()),
          ContestsListError(message: final m) => ErrorStateView(
              message: m,
              onRetry: () => context.read<ContestsListCubit>().load(),
            ),
          ContestsListLoaded(contests: final list) => RefreshIndicator(
              onRefresh: () => context.read<ContestsListCubit>().load(),
              child: list.isEmpty
                  ? ListView(children: const [
                      SizedBox(height: 80),
                      EmptyStateView(
                        message: 'No live contests right now.',
                        icon: Icons.flag_outlined,
                      ),
                    ])
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: list.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 12),
                      itemBuilder: (ctx, i) => _ContestCard(list[i]),
                    ),
            ),
        },
      ),
    );
  }
}

class _ContestCard extends StatelessWidget {
  const _ContestCard(this.contest);
  final Contest contest;

  String _formatDate(DateTime? d) =>
      d == null ? '—' : DateFormat('MMM d, h:mm a').format(d);

  @override
  Widget build(BuildContext context) {
    final live = contest.isLive;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
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
                  color: (live ? AppColors.correct : AppColors.textSecondary)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  live ? 'LIVE' : 'UPCOMING',
                  style: TextStyle(
                    color: live ? AppColors.correct : AppColors.textSecondary,
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Spacer(),
              if (contest.prizePool != null)
                Row(
                  children: [
                    const Icon(Icons.workspace_premium,
                        color: AppColors.coin, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${contest.prizePool}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.coin,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            contest.name,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          if ((contest.description ?? '').isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              contest.description!,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.event,
                  size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                '${_formatDate(contest.startDate)} → ${_formatDate(contest.endDate)}',
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: live
                  ? () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Contest play screen launches in next pass.'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  : null,
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(contest.isParticipated ? 'Resume' : 'Play'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size.fromHeight(44),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
