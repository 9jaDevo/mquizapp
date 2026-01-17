import 'package:flutter/material.dart';
import 'package:flutterquiz/core/core.dart';
import 'package:flutterquiz/ui/widgets/glass_container.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';
import 'package:intl/intl.dart';

/// Glassmorphism version of user achievements card
class UserAchievementsGlassCard extends StatelessWidget {
  const UserAchievementsGlassCard({
    super.key,
    this.userRank = '0',
    this.userCoins = '0',
    this.userScore = '0',
  });

  final String userRank;
  final String userCoins;
  final String userScore;

  @override
  Widget build(BuildContext context) {
    final rank = context.tr('rankLbl')!;
    final coins = context.tr('coinsLbl')!;
    final score = context.tr('scoreLbl')!;

    final numberFormat = NumberFormat.decimalPattern();

    final verticalDivider = Container(
      height: 52,
      width: 2,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            context.primaryTextColor.withValues(alpha: 0),
            context.primaryTextColor.withValues(alpha: .15),
            context.primaryTextColor.withValues(alpha: 0),
          ],
        ),
        borderRadius: BorderRadius.circular(2),
      ),
    );

    return RepaintBoundary(
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: context.width * UiUtils.hzMarginPct,
        ),
        // Outer glow effect
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, 8),
              blurRadius: 24,
              spreadRadius: 2,
              color: context.primaryColor.withValues(alpha: .15),
            ),
          ],
          borderRadius: const BorderRadius.all(Radius.circular(20)),
        ),
        child: GlassContainer(
          intensity: GlassIntensity.accent,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: _AchievementGlass(
                  title: rank,
                  value: numberFormat.format(double.parse(userRank)),
                  icon: Icons.emoji_events_rounded,
                ),
              ),
              verticalDivider,
              Expanded(
                child: _AchievementGlass(
                  title: coins,
                  value: numberFormat.format(double.parse(userCoins)),
                  icon: Icons.monetization_on_rounded,
                ),
              ),
              verticalDivider,
              Expanded(
                child: _AchievementGlass(
                  title: score,
                  value: numberFormat.format(double.parse(userScore)),
                  icon: Icons.stars_rounded,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AchievementGlass extends StatelessWidget {
  const _AchievementGlass({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    // Parse the numeric value for animation
    final numericValue = double.tryParse(value.replaceAll(',', '')) ?? 0;
    final numberFormat = NumberFormat.decimalPattern();

    return Semantics(
      label: '$title: $value',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with gradient
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  context.primaryColor.withValues(alpha: .2),
                  context.primaryColor.withValues(alpha: .05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 24,
              color: context.primaryColor,
            ),
          ),
          const SizedBox(height: 8),

          // Title
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeights.medium,
              color: context.primaryTextColor.withValues(alpha: 0.65),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),

          // Animated value
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: numericValue),
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeOutCubic,
            builder: (context, animatedValue, child) {
              return Text(
                numberFormat.format(animatedValue.round()),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeights.bold,
                  height: 1.2,
                  color: context.primaryTextColor,
                  letterSpacing: -0.5,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
