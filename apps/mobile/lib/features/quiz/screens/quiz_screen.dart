import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mquiz/core/constants/app_constants.dart';
import 'package:mquiz/core/theme/app_colors.dart';
import 'package:mquiz/core/widgets/common_widgets.dart';
import 'package:mquiz/features/bookmarks/cubit/bookmarks_cubit.dart';
import 'package:mquiz/features/lives/cubit/booster_store_cubit.dart';
import 'package:mquiz/features/lives/models/lives_models.dart';
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
          onBookmark: () {
            context.read<BookmarksCubit>().addInQuiz(state.current.id);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Question bookmarked'),
                behavior: SnackBarBehavior.floating,
                duration: Duration(seconds: 2),
              ),
            );
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
                // ── Question type branching ─────────────────────────────────
                if (q.type == 'fun_and_learn')
                  _FunLearnView(
                    question: q,
                    selected: selected,
                    onSelect: (k) =>
                        context.read<QuizCubit>().selectOption(k),
                  )
                else if (q.type == 'guess_the_word')
                  _GuessTheWordView(
                    question: q,
                    selected: selected,
                    onSelect: (k) =>
                        context.read<QuizCubit>().selectOption(k),
                  )
                else
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
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
          child: _BoosterTray(state: state),
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
    required this.onBookmark,
  });

  final int index;
  final int total;
  final double progress;
  final int secondsLeft;
  final double timeFraction;
  final VoidCallback onClose;
  final VoidCallback onBookmark;

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
              IconButton(
                onPressed: onBookmark,
                icon: const Icon(Icons.bookmark_border),
                tooltip: 'Bookmark question',
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

// ── Booster Tray ─────────────────────────────────────────────────────────────

class _BoosterTray extends StatelessWidget {
  const _BoosterTray({required this.state});
  final QuizInProgress state;

  @override
  Widget build(BuildContext context) {
    final boosterState = context.watch<BoosterStoreCubit>().state;
    if (boosterState is! BoosterStoreLoaded) return const SizedBox.shrink();
    final owned = boosterState.owned
        .where((b) => (b.quantity ?? 0) > 0)
        .toList(growable: false);
    if (owned.isEmpty) {
      if (boosterState.catalog.isEmpty) return const SizedBox.shrink();
      return Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          onPressed: () => context.push(AppConstants.routeCoinStore),
          icon: const Icon(Icons.bolt_rounded, size: 16),
          label: const Text('Get Boosters'),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
      );
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final booster in owned)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _BoosterChip(booster: booster, state: state),
            ),
        ],
      ),
    );
  }
}

class _BoosterChip extends StatelessWidget {
  const _BoosterChip({required this.booster, required this.state});
  final Booster booster;
  final QuizInProgress state;

  @override
  Widget build(BuildContext context) {
    final name = booster.name.toLowerCase();
    IconData icon;
    if (name.contains('time') || name.contains('clock')) {
      icon = Icons.timer_rounded;
    } else if (name.contains('skip')) {
      icon = Icons.skip_next_rounded;
    } else if (name.contains('50') || name.contains('half')) {
      icon = Icons.looks_two_rounded;
    } else {
      icon = Icons.bolt_rounded;
    }
    return Tooltip(
      message: booster.name,
      child: Material(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _applyBooster(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: AppColors.primary),
                const SizedBox(width: 4),
                Text(
                  booster.name,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '×${booster.quantity}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _applyBooster(BuildContext context) {
    final cubit = context.read<QuizCubit>();
    final name = booster.name.toLowerCase();
    if (name.contains('time') || name.contains('clock')) {
      cubit.addTime(30);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('+30 seconds added!'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    } else if (name.contains('skip')) {
      cubit.skipQuestion();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${booster.name} activated!'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}

// ── Fun & Learn View ──────────────────────────────────────────────────────────
// Shows a brief explanation card before revealing answer options.

class _FunLearnView extends StatefulWidget {
  const _FunLearnView({
    required this.question,
    required this.selected,
    required this.onSelect,
  });
  final QuizQuestion question;
  final String? selected;
  final ValueChanged<String> onSelect;

  @override
  State<_FunLearnView> createState() => _FunLearnViewState();
}

class _FunLearnViewState extends State<_FunLearnView> {
  bool _showOptions = false;

  @override
  void initState() {
    super.initState();
    // Auto-reveal options after 3 s
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showOptions = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.25)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.lightbulb_outline_rounded,
                  color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.question.text,
                  style: const TextStyle(fontSize: 14, height: 1.45),
                ),
              ),
            ],
          ),
        ),
        if (!_showOptions) ...[
          const SizedBox(height: 20),
          Center(
            child: TextButton.icon(
              onPressed: () => setState(() => _showOptions = true),
              icon: const Icon(Icons.visibility_outlined),
              label: const Text('Show options now'),
            ),
          ),
        ] else ...[
          const SizedBox(height: 16),
          for (final opt in widget.question.orderedOptions)
            _OptionTile(
              optionKey: opt.key,
              label: opt.value,
              selected: widget.selected == opt.key,
              onTap: () => widget.onSelect(opt.key),
            ),
        ],
      ],
    );
  }
}

// ── Guess The Word View ───────────────────────────────────────────────────────

class _GuessTheWordView extends StatelessWidget {
  const _GuessTheWordView({
    required this.question,
    required this.selected,
    required this.onSelect,
  });
  final QuizQuestion question;
  final String? selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    // GTTW uses same MC options but displayed as larger tap tiles
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final opt in question.orderedOptions)
          GestureDetector(
            onTap: () => onSelect(opt.key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: selected == opt.key
                    ? AppColors.primary
                    : AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected == opt.key
                      ? AppColors.primary
                      : AppColors.primary.withValues(alpha: 0.35),
                  width: 2,
                ),
              ),
              child: Text(
                opt.value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: selected == opt.key
                      ? Colors.white
                      : AppColors.textPrimary,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
