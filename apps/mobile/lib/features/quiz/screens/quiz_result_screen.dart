import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mquiz/core/constants/app_constants.dart';
import 'package:mquiz/core/theme/app_colors.dart';
import 'package:mquiz/core/widgets/common_widgets.dart';
import 'package:mquiz/features/home/cubit/home_cubit.dart';
import 'package:mquiz/features/quiz/cubit/quiz_cubit.dart';

class QuizResultScreen extends StatelessWidget {
  const QuizResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QuizCubit, QuizState>(
      builder: (context, state) {
        if (state is! QuizCompleted) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final result = state.result;
        final accuracyPct = (result.accuracy * 100).clamp(0, 100).round();
        return Scaffold(
          backgroundColor: AppColors.pageBackground,
          body: SafeArea(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius:
                        BorderRadius.vertical(bottom: Radius.circular(28)),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 28),
                  child: Column(
                    children: [
                      const Icon(Icons.emoji_events_rounded,
                          color: Colors.white, size: 56),
                      const SizedBox(height: 12),
                      const Text(
                        'Quiz Complete!',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 22,
                        ),
                      ),
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
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Breakdown',
                            style: const TextStyle(
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
                                value: result.total.toString(),
                                color: AppColors.primary,
                              ),
                            ],
                          ),
                          if (result.fraudReviewed) ...[
                            const SizedBox(height: 14),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.coin.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.info_outline,
                                      color: AppColors.coin, size: 18),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'This attempt is under fraud review. Rewards will be applied after verification.',
                                      style: TextStyle(fontSize: 12.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () => _exit(context),
                          child: const Text('Done'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: PrimaryButton(
                          label: 'Play Again',
                          icon: Icons.replay_rounded,
                          onPressed: () => _exit(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _exit(BuildContext context) {
    context.read<QuizCubit>().reset();
    // refresh home stats (coins/score may have changed)
    context.read<HomeCubit>().refresh();
    context.go(AppConstants.routeHome);
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({
    required this.label,
    required this.value,
    required this.icon,
    this.iconColor,
  });
  final String label;
  final String value;
  final IconData icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: iconColor ?? Colors.white, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.85),
            fontSize: 12,
          ),
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
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
