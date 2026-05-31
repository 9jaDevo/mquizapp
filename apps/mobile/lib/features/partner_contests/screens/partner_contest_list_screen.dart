import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mquiz/core/constants/app_constants.dart';
import 'package:mquiz/core/theme/app_colors.dart';
import 'package:mquiz/core/widgets/common_widgets.dart';
import 'package:mquiz/features/partner_contests/cubit/partner_contest_list_cubit.dart';
import 'package:mquiz/features/partner_contests/models/partner_contest.dart';

class PartnerContestListScreen extends StatefulWidget {
  const PartnerContestListScreen({super.key});

  @override
  State<PartnerContestListScreen> createState() => _PartnerContestListScreenState();
}

class _PartnerContestListScreenState extends State<PartnerContestListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PartnerContestListCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        title: const Text('Partner Contests'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner_rounded),
            tooltip: 'Enter invite code',
            onPressed: () => context.push(AppConstants.routePartnerContestJoinCode),
          ),
        ],
      ),
      body: BlocBuilder<PartnerContestListCubit, PartnerContestListState>(
        builder: (context, state) => switch (state) {
          PartnerContestListInitial() ||
          PartnerContestListLoading() =>
            const Center(child: CircularProgressIndicator()),
          PartnerContestListError(message: final m) => ErrorStateView(
              message: m,
              onRetry: () => context.read<PartnerContestListCubit>().load(),
            ),
          PartnerContestListLoaded(contests: final list) => RefreshIndicator(
              onRefresh: () => context.read<PartnerContestListCubit>().load(),
              child: list.isEmpty
                  ? ListView(children: const [
                      SizedBox(height: 80),
                      EmptyStateView(
                        message: 'No partner contests right now.',
                        icon: Icons.business_center_outlined,
                      ),
                    ])
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (ctx, i) => _PartnerContestCard(list[i]),
                    ),
            ),
        },
      ),
    );
  }
}

class _PartnerContestCard extends StatelessWidget {
  const _PartnerContestCard(this.contest);
  final PartnerContest contest;

  String _formatDate(DateTime? d) =>
      d == null ? '—' : DateFormat('MMM d, h:mm a').format(d);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(
        '/partner-contests/${contest.id}',
        extra: contest,
      ),
      child: Container(
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
                _StatusChip(contest.status),
                if (contest.isFull) ...[
                  const SizedBox(width: 8),
                  _StatusChip('FULL', color: AppColors.error),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Text(
              contest.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            if (contest.orgName != null) ...[
              const SizedBox(height: 4),
              Text(
                'by ${contest.orgName}',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
            if (contest.description != null) ...[
              const SizedBox(height: 6),
              Text(
                contest.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                _InfoChip(Icons.quiz_outlined, '${contest.questionCount} Qs'),
                const SizedBox(width: 8),
                _InfoChip(Icons.people_outline, '${contest.participantCount}'),
                if (contest.endDate != null) ...[
                  const SizedBox(width: 8),
                  _InfoChip(Icons.schedule_outlined, _formatDate(contest.endDate)),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip(this.label, {Color? color}) : _color = color;
  final String label;
  final Color? _color;

  @override
  Widget build(BuildContext context) {
    final c = _color ?? AppColors.correct;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(color: c, fontWeight: FontWeight.w800, fontSize: 11)),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip(this.icon, this.label);
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      ],
    );
  }
}
