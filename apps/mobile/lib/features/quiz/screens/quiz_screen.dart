import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mquiz/core/constants/app_constants.dart';
import 'package:mquiz/core/theme/app_colors.dart';
import 'package:mquiz/core/widgets/common_widgets.dart';
import 'package:mquiz/features/quiz/cubit/quiz_cubit.dart';
import 'package:mquiz/features/quiz/models/question_model.dart';

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<QuizCubit, QuizState>(
      listenWhen: (prev, cur) => cur is QuizCompleted || cur is QuizError,
      listener: (context, state) {
        if (state is QuizCompleted) {
          context.pushReplacement('/quiz/result');
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.pageBackground,
          body: SafeArea(
            child: switch (state) {
              QuizIdle() ||
              QuizLoading() =>
                const Center(child: CircularProgressIndicator()),
              QuizSubmitting() => const _SubmittingView(),
              QuizError(message: final msg) => ErrorStateView(
                  message: msg,
                  onRetry: () => context.pop(),
                ),
              QuizInProgress() => _QuizPlayView(state: state),
              QuizCompleted() =>
                const Center(child: CircularProgressIndicator()),
            },
          ),
        );
      },
    );
  }
}

class _SubmittingView extends StatelessWidget {
  const _SubmittingView();
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 18),
          Text('Scoring your answers...'),
        ],
      ),
    );
  }
}

class _QuizPlayView extends StatelessWidget {
  const _QuizPlayView({required this.state});
  final QuizInProgress state;

  @override
  Widget build(BuildContext context) {
    final q = state.current;
    final selected = state.selectedFor(q.id);
    final progress = (state.index + 1) / state.total;
    final timeFraction =
        state.secondsLeft / AppConstants.secondsPerQuestion;
    return Column(
      children: [
        _QuizHeader(
          index: state.index,
          total: state.total,
          progress: progress,
          secondsLeft: state.secondsLeft,
          timeFraction: timeFraction,
          onClose: () async {
            final confirmed = await _confirmQuit(context);
            if (confirmed && context.mounted) {
              context.read<QuizCubit>().reset();
              context.pop();
            }
          },
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Question ${state.index + 1}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
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
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
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
                        context.read<QuizCubit>().selectOption(opt.key),
                  ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: PrimaryButton(
            label: state.isLast ? 'Submit' : 'Next',
            icon: state.isLast ? Icons.check : Icons.arrow_forward_rounded,
            onPressed: selected == null
                ? null
                : () => context.read<QuizCubit>().nextQuestion(),
          ),
        ),
      ],
    );
  }

  Future<bool> _confirmQuit(BuildContext context) async {
    final res = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Quit quiz?'),
        content: const Text('Your progress will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
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

class _QuizHeader extends StatelessWidget {
  const _QuizHeader({
    required this.index,
    required this.total,
    required this.progress,
    required this.secondsLeft,
    required this.timeFraction,
    required this.onClose,
  });

  final int index;
  final int total;
  final double progress;
  final int secondsLeft;
  final double timeFraction;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final timeColor =
        timeFraction < 0.3 ? AppColors.wrong : AppColors.primary;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: onClose,
                icon: const Icon(Icons.close),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    '${index + 1} / $total',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: timeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.timer_outlined, size: 16, color: timeColor),
                    const SizedBox(width: 4),
                    Text(
                      '${secondsLeft}s',
                      style: TextStyle(
                        color: timeColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppColors.divider,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ],
      ),
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
                    color: selected ? AppColors.primary : AppColors.divider,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    optionKey.toUpperCase(),
                    style: TextStyle(
                      color: selected ? Colors.white : AppColors.textPrimary,
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
