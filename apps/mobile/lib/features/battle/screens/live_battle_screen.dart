import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mquiz/core/constants/app_constants.dart';
import 'package:mquiz/core/theme/app_colors.dart';
import 'package:mquiz/core/widgets/common_widgets.dart';
import 'package:mquiz/features/battle/cubit/battle_cubit.dart';

/// Live battle quiz play screen.
/// Displays own progress + opponent's live progress side-by-side.
class LiveBattleScreen extends StatelessWidget {
  const LiveBattleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) {
          final confirmed = await _confirmQuit(context);
          if (confirmed && context.mounted) {
            await context.read<BattleCubit>().cancel();
            if (context.mounted) context.go(AppConstants.routeHome);
          }
        }
      },
      child: BlocConsumer<BattleCubit, BattleState>(
        listenWhen: (_, cur) =>
            cur is BattleCompleted ||
            cur is BattleError ||
            cur is BattleIdle,
        listener: (ctx, state) {
          if (state is BattleCompleted) {
            ctx.pushReplacement(AppConstants.routeBattleResult);
          } else if (state is BattleError) {
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(
                content: Text(state.message),
                behavior: SnackBarBehavior.floating,
                backgroundColor: AppColors.wrong,
              ),
            );
            ctx.go(AppConstants.routeHome);
          } else if (state is BattleIdle) {
            ctx.go(AppConstants.routeHome);
          }
        },
        builder: (context, state) => Scaffold(
          backgroundColor: AppColors.pageBackground,
          body: SafeArea(
            child: switch (state) {
              BattleInProgress() =>
                _BattlePlayView(state: state),
              BattleSubmitting() => const _SubmittingView(),
              _ => const Center(child: CircularProgressIndicator()),
            },
          ),
        ),
      ),
    );
  }

  Future<bool> _confirmQuit(BuildContext context) async {
    final res = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Quit battle?'),
        content: const Text(
            'Quitting now forfeits the battle. Your opponent wins.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Stay'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.wrong),
            child: const Text('Quit'),
          ),
        ],
      ),
    );
    return res ?? false;
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
            Text('Waiting for opponent to finish…'),
          ],
        ),
      );
}

class _BattlePlayView extends StatelessWidget {
  const _BattlePlayView({required this.state});
  final BattleInProgress state;

  @override
  Widget build(BuildContext context) {
    final q = state.current;
    final selected = state.selectedFor(q.id);
    final timeFraction = state.secondsLeft / AppConstants.secondsPerQuestion;

    return Column(
      children: [
        // ── Battle Header ──────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  // Me
                  _PlayerStatus(
                    label: 'You',
                    correct: state.answers.entries
                        .where((e) {
                          final qItem = state.questions.firstWhere(
                              (qq) => qq.id == e.key,
                              orElse: () => state.questions.first);
                          return qItem.correctAnswer != null &&
                              qItem.correctAnswer!.isNotEmpty &&
                              e.value == qItem.correctAnswer;
                        })
                        .length,
                    total: state.answers.length,
                    isMe: true,
                  ),
                  // Timer
                  Expanded(
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.timer_outlined,
                                size: 16,
                                color: timeFraction < 0.3
                                    ? Colors.red.shade200
                                    : Colors.white),
                            const SizedBox(width: 4),
                            Text(
                              '${state.secondsLeft}s',
                              style: TextStyle(
                                color: timeFraction < 0.3
                                    ? Colors.red.shade200
                                    : Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Opponent
                  _PlayerStatus(
                    label: 'Opponent',
                    correct: state.opponentCorrect,
                    total: state.opponentAnswersCount,
                    isMe: false,
                    finished: state.opponentFinished,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Q${state.index + 1} of ${state.total}',
                style: const TextStyle(
                    color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: (state.index + 1) / state.total,
                  minHeight: 5,
                  backgroundColor: Colors.white24,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ],
          ),
        ),
        // ── Question + Options ─────────────────────────────────────────
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  q.text,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
                if (q.image != null && q.image!.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(
                      q.image!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const SizedBox.shrink(),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                for (final opt in q.orderedOptions)
                  _OptionTile(
                    optionKey: opt.key,
                    label: opt.value,
                    selected: selected == opt.key,
                    onTap: () =>
                        context.read<BattleCubit>().selectOption(opt.key),
                  ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: PrimaryButton(
            label: state.isLast ? 'Finish' : 'Next',
            icon: state.isLast
                ? Icons.check
                : Icons.arrow_forward_rounded,
            onPressed:
                selected == null ? null : () => context.read<BattleCubit>().nextQuestion(),
          ),
        ),
      ],
    );
  }
}

class _PlayerStatus extends StatelessWidget {
  const _PlayerStatus({
    required this.label,
    required this.correct,
    required this.total,
    required this.isMe,
    this.finished = false,
  });

  final String label;
  final int correct;
  final int total;
  final bool isMe;
  final bool finished;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontWeight: isMe ? FontWeight.w800 : FontWeight.w500,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$correct correct',
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w700),
        ),
        if (finished)
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Done',
              style: TextStyle(color: Colors.white70, fontSize: 10),
            ),
          ),
      ],
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.optionKey,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String optionKey;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.primary.withValues(alpha: 0.10)
                  : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected ? AppColors.primary : AppColors.border,
                width: selected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  height: 32,
                  width: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primary
                        : AppColors.divider,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    optionKey.toUpperCase(),
                    style: TextStyle(
                      color: selected
                          ? Colors.white
                          : AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(fontSize: 15, height: 1.3),
                  ),
                ),
                if (selected)
                  const Icon(Icons.check_circle,
                      color: AppColors.primary, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
