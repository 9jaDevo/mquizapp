import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mquiz/core/constants/app_constants.dart';
import 'package:mquiz/core/theme/app_colors.dart';
import 'package:mquiz/core/widgets/common_widgets.dart';
import 'package:mquiz/features/battle/cubit/battle_cubit.dart';
import 'package:mquiz/features/battle/models/battle_model.dart';

/// Shows battle result with win/lose/draw outcome, score comparison,
/// and per-player stats.
class BattleResultScreen extends StatelessWidget {
  const BattleResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<BattleCubit>().state;
    if (state is! BattleCompleted) {
      // Fallback: user arrived here without result state
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('No battle result found.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  context.read<BattleCubit>().reset();
                  context.go(AppConstants.routeHome);
                },
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      );
    }

    final result = state.result;

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: SafeArea(
        child: Column(
          children: [
            // ── Result Banner ──────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 28),
              decoration: BoxDecoration(
                gradient: result.isDraw
                    ? const LinearGradient(
                        colors: [Color(0xFF607D8B), Color(0xFF455A64)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : result.didWin
                        ? const LinearGradient(
                            colors: [
                              Color(0xFF7C3AED),
                              Color(0xFF4F46E5)
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : const LinearGradient(
                            colors: [
                              Color(0xFFE53E3E),
                              Color(0xFFC53030)
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  Icon(
                    result.isDraw
                        ? Icons.handshake_rounded
                        : result.didWin
                            ? Icons.emoji_events_rounded
                            : Icons.sentiment_dissatisfied_rounded,
                    color: Colors.white,
                    size: 60,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    result.isDraw
                        ? "It's a Draw!"
                        : result.didWin
                            ? 'You Won! 🎉'
                            : 'You Lost',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 26,
                    ),
                  ),
                ],
              ),
            ),
            // ── Score Comparison ───────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    GlassCard(
                      child: Row(
                        children: [
                          Expanded(
                            child: _PlayerScoreCard(
                              player: result.myPlayer,
                              label: 'You',
                              isMe: true,
                              didWin: result.myPlayer.correctAnswers >
                                  result.opponent.correctAnswers,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 80,
                            color: AppColors.divider,
                          ),
                          Expanded(
                            child: _PlayerScoreCard(
                              player: result.opponent,
                              label: result.opponent.displayName,
                              isMe: false,
                              didWin: result.opponent.correctAnswers >
                                  result.myPlayer.correctAnswers,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Stats row
                    Row(
                      children: [
                        _StatPill(
                          label: 'Questions',
                          value: '${result.questions.length}',
                          icon: Icons.quiz_outlined,
                        ),
                        const SizedBox(width: 12),
                        _StatPill(
                          label: 'Your Correct',
                          value: '${result.myPlayer.correctAnswers}',
                          icon: Icons.check_circle_outline,
                          color: AppColors.correct,
                        ),
                        const SizedBox(width: 12),
                        _StatPill(
                          label: 'Opp. Correct',
                          value: '${result.opponent.correctAnswers}',
                          icon: Icons.person_outline,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
            // ── Actions ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Column(
                children: [
                  PrimaryButton(
                    label: 'Play Again',
                    icon: Icons.replay_rounded,
                    onPressed: () {
                      context.read<BattleCubit>().reset();
                      context.go(AppConstants.routeBattle);
                    },
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      context.read<BattleCubit>().reset();
                      context.go(AppConstants.routeHome);
                    },
                    icon: const Icon(Icons.home_rounded),
                    label: const Text('Back to Home'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayerScoreCard extends StatelessWidget {
  const _PlayerScoreCard({
    required this.player,
    required this.label,
    required this.isMe,
    required this.didWin,
  });

  final BattlePlayer player;
  final String label;
  final bool isMe;
  final bool didWin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                backgroundImage: player.photoUrl != null
                    ? NetworkImage(player.photoUrl!)
                    : null,
                child: player.photoUrl == null
                    ? Text(
                        player.displayName.isNotEmpty
                            ? player.displayName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary),
                      )
                    : null,
              ),
              if (didWin)
                const Icon(Icons.emoji_events_rounded,
                    color: Color(0xFFFFD700), size: 20),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontWeight: isMe ? FontWeight.w800 : FontWeight.w500,
              fontSize: 13,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            '${player.correctAnswers} correct',
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.label,
    required this.value,
    required this.icon,
    this.color = AppColors.primary,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                  fontWeight: FontWeight.w800, fontSize: 16, color: color),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 10, color: color),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
