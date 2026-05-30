import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:mquiz/core/ads/ad_service.dart';
import 'package:mquiz/core/constants/app_constants.dart';
import 'package:mquiz/core/theme/app_colors.dart';
import 'package:mquiz/core/widgets/common_widgets.dart';
import 'package:mquiz/features/home/cubit/home_cubit.dart';
import 'package:mquiz/features/quiz/cubit/quiz_cubit.dart';
import 'package:mquiz/features/quiz/models/question_model.dart';

class QuizResultScreen extends StatefulWidget {
  const QuizResultScreen({super.key});

  @override
  State<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends State<QuizResultScreen> {
  bool _mysteryBoxShown = false;

  @override
  void initState() {
    super.initState();
    // Non-blocking: triggers an interstitial ad every N completions.
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => AdService.instance.recordQuizCompletion());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<QuizCubit, QuizState>(
      listenWhen: (_, cur) =>
          cur is QuizCompleted && cur.triggerMysteryBox && !_mysteryBoxShown,
      listener: (context, state) {
        if (state is QuizCompleted && state.triggerMysteryBox) {
          _mysteryBoxShown = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) _showMysteryBox(context);
          });
        }
      },
      builder: (context, state) {
        if (state is! QuizCompleted) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final result = state.result;
        final accuracyPct = result.accuracy.round();
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
                      const SizedBox(width: 8),
                      // Share result
                      IconButton.filled(
                        onPressed: () => _share(context, state.result,
                              result.accuracy.round()),
                        icon: const Icon(Icons.share_rounded),
                        style: IconButton.styleFrom(
                          backgroundColor:
                              AppColors.primary.withValues(alpha: 0.12),
                          foregroundColor: AppColors.primary,
                        ),
                        tooltip: 'Share result',
                      ),
                      const SizedBox(width: 8),
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
    context.read<HomeCubit>().refresh();
    context.go(AppConstants.routeHome);
  }

  void _share(
      BuildContext context, QuizResult result, int accuracyPct) {
    final text =
        'I just scored ${result.score} points with $accuracyPct% accuracy '
        'on mQuiz and earned ${result.coinsEarned} coins! 🎉\n'
        'Play now: https://mquizapp.com';
    Share.share(text, subject: 'My mQuiz result');
  }

  void _showMysteryBox(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const _MysteryBoxSheet(),
    );
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

// ── Mystery Box Sheet ─────────────────────────────────────────────────────────

class _MysteryBoxSheet extends StatefulWidget {
  const _MysteryBoxSheet();

  @override
  State<_MysteryBoxSheet> createState() => _MysteryBoxSheetState();
}

class _MysteryBoxSheetState extends State<_MysteryBoxSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  bool _opened = false;
  /// Simulated prize — in production this would come from the backend.
  int _prize = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _openBox() {
    setState(() {
      _opened = true;
      // Simple random prize: 5-100 coins
      _prize = 5 + (DateTime.now().millisecondsSinceEpoch % 20) * 5;
    });
    _ctrl.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFD1D5DB),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          ScaleTransition(
            scale: _opened ? _scale : const AlwaysStoppedAnimation(1.0),
            child: Icon(
              _opened ? Icons.card_giftcard_rounded : Icons.all_inbox_rounded,
              size: 72,
              color: _opened ? AppColors.coin : AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _opened ? 'You got $_prize coins! 🎉' : 'Mystery Box!',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _opened
                ? 'Coins added to your balance.'
                : 'Complete 5 quizzes to earn a surprise reward.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: _opened
                ? OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Collect & Close'),
                  )
                : ElevatedButton.icon(
                    onPressed: _openBox,
                    icon: const Icon(Icons.lock_open_rounded),
                    label: const Text('Open Box'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
