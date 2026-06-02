import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mquiz/core/constants/app_constants.dart';
import 'package:mquiz/core/theme/app_colors.dart';
import 'package:mquiz/core/widgets/common_widgets.dart';
import 'package:mquiz/features/partner_contests/cubit/partner_contest_quiz_cubit.dart';
import 'package:mquiz/features/partner_contests/data/partner_contest_repository.dart';
import 'package:mquiz/features/partner_contests/models/partner_contest.dart';
import 'package:mquiz/features/quiz/screens/session_result_screen.dart';

class PartnerContestQuizScreen extends StatelessWidget {
  const PartnerContestQuizScreen({
    super.key,
    required this.contestId,
    this.contest,
  });

  final int contestId;
  final PartnerContest? contest;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PartnerContestQuizCubit(
        context.read<PartnerContestRepository>(),
        contestId,
        timeLimitSeconds: contest?.timeLimitSeconds,
      )..start(),
      child:
          _PartnerQuizView(contestId: contestId, contestName: contest?.title),
    );
  }
}

class _PartnerQuizView extends StatelessWidget {
  const _PartnerQuizView({required this.contestId, this.contestName});

  final int contestId;
  final String? contestName;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PartnerContestQuizCubit, PartnerContestQuizState>(
      listenWhen: (_, cur) =>
          cur is PartnerContestQuizCompleted || cur is PartnerContestQuizError,
      listener: (ctx, state) {
        if (state is PartnerContestQuizCompleted) {
          ctx.pushReplacement(
            AppConstants.routeSessionResult,
            extra: SessionResultExtra(
              result: state.result,
              questions: state.questions,
              title: 'Partner Contest Complete!',
              subtitle: contestName,
            ),
          );
        }
      },
      builder: (context, state) => Scaffold(
        backgroundColor: AppColors.pageBackground,
        body: SafeArea(
          child: switch (state) {
            PartnerContestQuizIdle() ||
            PartnerContestQuizLoading() =>
              const Center(child: CircularProgressIndicator()),
            PartnerContestQuizSubmitting() => const _SubmittingView(),
            PartnerContestQuizError(message: final msg) => ErrorStateView(
                message: msg,
                onRetry: () => context.pop(),
              ),
            PartnerContestQuizInProgress() =>
              _PartnerQuizPlayView(state: state, cubit: context.read()),
            PartnerContestQuizCompleted() =>
              const Center(child: CircularProgressIndicator()),
          },
        ),
      ),
    );
  }
}

class _SubmittingView extends StatelessWidget {
  const _SubmittingView();
  @override
  Widget build(BuildContext context) => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 18),
            Text('Scoring your answers…'),
          ],
        ),
      );
}

class _PartnerQuizPlayView extends StatelessWidget {
  const _PartnerQuizPlayView({required this.state, required this.cubit});

  final PartnerContestQuizInProgress state;
  final PartnerContestQuizCubit cubit;

  @override
  Widget build(BuildContext context) {
    final q = state.current;
    final selected = state.selectedFor(q.id);
    final progress = (state.index + 1) / state.total;
    final timeFraction = state.secondsLeft / state.timeLimitSeconds;
    final timeColor = timeFraction < 0.3 ? AppColors.wrong : AppColors.primary;

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () async {
                  final quit = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Quit Contest?'),
                      content: const Text('Your progress will not be saved.'),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Stay')),
                        TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Quit')),
                      ],
                    ),
                  );
                  if ((quit ?? false) && context.mounted) {
                    cubit.reset();
                    context.pop();
                  }
                },
              ),
              Expanded(
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: AppColors.border,
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                  minHeight: 8,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: timeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${state.secondsLeft}s',
                  style:
                      TextStyle(color: timeColor, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        Text('${state.index + 1} / ${state.total}',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        const SizedBox(height: 16),
        // Question
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(q.text,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 16),
                ...q.options.entries.map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _OptionTile(
                      label: e.key,
                      text: e.value,
                      selected: selected == e.key,
                      onTap: () => cubit.selectOption(e.key),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Next button
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: cubit.nextQuestion,
              child: Text(state.isLast ? 'Submit' : 'Next'),
            ),
          ),
        ),
      ],
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.label,
    required this.text,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String text;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary
                    : AppColors.border.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
              child: Text(
                label.toUpperCase(),
                style: TextStyle(
                  color: selected ? Colors.white : AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(text, style: const TextStyle(fontSize: 15))),
          ],
        ),
      ),
    );
  }
}
