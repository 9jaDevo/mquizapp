import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mquiz/core/constants/app_constants.dart';
import 'package:mquiz/core/theme/app_colors.dart';
import 'package:mquiz/core/widgets/common_widgets.dart';
import 'package:mquiz/features/quiz/models/question_model.dart';

/// Carries result data to [SessionResultScreen] via GoRouter extra.
/// Used by both League quiz and Contest quiz result navigation.
class SessionResultExtra {
  const SessionResultExtra({
    required this.result,
    required this.questions,
    required this.title,
    this.subtitle,
  });

  final QuizResult result;
  final List<QuizQuestion> questions;
  final String title;
  final String? subtitle;
}

/// Shared result screen for league quiz and contest quiz completions.
/// Receives data via GoRouter [extra] as [SessionResultExtra].
class SessionResultScreen extends StatelessWidget {
  const SessionResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final extra = GoRouterState.of(context).extra as SessionResultExtra?;
    if (extra == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('No result data found.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go(AppConstants.routeHome),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      );
    }

    final result = extra.result;
    final accuracyPct = result.accuracy.round();

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: SafeArea(
        child: Column(
          children: [
            // ── Result Header ──────────────────────────────────────────────
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(28)),
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              child: Column(
                children: [
                  const Icon(Icons.emoji_events_rounded,
                      color: Colors.white, size: 56),
                  const SizedBox(height: 10),
                  Text(
                    extra.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 22,
                    ),
                  ),
                  if (extra.subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      extra.subtitle!,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _SummaryStat(
                        label: 'Score',
                        value: '${result.score}',
                        icon: Icons.star_rounded,
                      ),
                      _SummaryStat(
                        label: 'Accuracy',
                        value: '$accuracyPct%',
                        icon: Icons.track_changes_rounded,
                      ),
                      _SummaryStat(
                        label: 'Coins',
                        value: '+${result.coinsEarned}',
                        icon: Icons.bolt_rounded,
                        iconColor: AppColors.coin,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // ── Breakdown ──────────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Breakdown',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _MiniStat(
                            label: 'Correct',
                            value: result.correctCount.toString(),
                            color: AppColors.correct,
                          ),
                          const SizedBox(width: 12),
                          _MiniStat(
                            label: 'Wrong',
                            value: result.wrongCount.toString(),
                            color: AppColors.wrong,
                          ),
                          const SizedBox(width: 12),
                          _MiniStat(
                            label: 'Total',
                            value: extra.questions.length.toString(),
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                      if (result.breakdown.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const Divider(),
                        Expanded(
                          child: ListView.builder(
                            itemCount: result.breakdown.length,
                            itemBuilder: (ctx, i) {
                              final bd = result.breakdown[i];
                              return _BreakdownRow(
                                index: i,
                                isCorrect: bd.isCorrect,
                                userAnswer: bd.userAnswer.isEmpty
                                    ? 'Skipped'
                                    : bd.userAnswer.toUpperCase(),
                                correctAnswer:
                                    bd.correctAnswer.toUpperCase(),
                              );
                            },
                          ),
                        ),
                      ] else
                        const Expanded(
                          child: Center(
                            child: Text(
                              'No breakdown available.',
                              style:
                                  TextStyle(color: AppColors.textSecondary),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            // ── Actions ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: PrimaryButton(
                label: 'Back to Home',
                icon: Icons.home_rounded,
                onPressed: () => context.go(AppConstants.routeHome),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({
    required this.label,
    required this.value,
    required this.icon,
    this.iconColor = Colors.white,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
            Text(
              label,
              style: TextStyle(color: color, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow({
    required this.index,
    required this.isCorrect,
    required this.userAnswer,
    required this.correctAnswer,
  });

  final int index;
  final bool isCorrect;
  final String userAnswer;
  final String correctAnswer;

  @override
  Widget build(BuildContext context) {
    final color = isCorrect ? AppColors.correct : AppColors.wrong;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCorrect ? Icons.check : Icons.close,
              color: color,
              size: 16,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Q${index + 1}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          if (!isCorrect) ...[
            Text('Your: $userAnswer',
                style: const TextStyle(
                    color: AppColors.wrong, fontSize: 12)),
            const SizedBox(width: 8),
            Text('✓ $correctAnswer',
                style: const TextStyle(
                    color: AppColors.correct, fontSize: 12)),
          ] else
            Text('$userAnswer ✓',
                style: const TextStyle(
                    color: AppColors.correct,
                    fontWeight: FontWeight.w600,
                    fontSize: 12)),
        ],
      ),
    );
  }
}
