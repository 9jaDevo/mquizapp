import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/core/constants/hive_constants.dart';
import 'package:flutterquiz/core/routes/routes.dart';
import 'package:flutterquiz/features/quiz/models/quiz_type.dart';
import 'package:flutterquiz/features/quiz/quiz_repository.dart';
import 'package:flutterquiz/features/system_config/cubits/system_config_cubit.dart';
import 'package:flutterquiz/ui/widgets/glass_container.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Glassmorphism daily challenge card with modern design
class DailyChallengeGlassCard extends StatefulWidget {
  const DailyChallengeGlassCard({super.key});

  @override
  State<DailyChallengeGlassCard> createState() =>
      _DailyChallengeGlassCardState();
}

class _DailyChallengeGlassCardState extends State<DailyChallengeGlassCard>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? _challenge;
  bool _loading = true;
  bool _completedToday = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _prepare();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _prepare() async {
    final box = Hive.box<dynamic>(settingsBox);
    final today = DateTime.now();
    final todayKey =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    // Completion flag
    final completedOn = box.get(dailyChallengeCompletedOnKey) as String?;
    _completedToday = completedOn == todayKey;

    // Try cache
    final cacheStr = box.get(dailyChallengeCacheKey) as String?;
    if (cacheStr != null) {
      final m = jsonDecode(cacheStr) as Map<String, dynamic>;
      if (m['date'] == todayKey) {
        setState(() {
          _challenge = m;
          _loading = false;
        });
        return;
      }
    }

    // Compute deterministically using available categories
    final repo = QuizRepository();
    final langId = UiUtils.getCurrentQuizLanguageId(context);
    final categories = await repo.getCategoryWithoutUser(
      languageId: langId,
      type: 'main',
    );

    if (categories.isEmpty) {
      setState(() => _loading = false);
      return;
    }

    final idx = today.millisecondsSinceEpoch % categories.length;
    final cat = categories[idx];

    final data = <String, dynamic>{
      'date': todayKey,
      'categoryId': cat.id,
      'categoryName': cat.categoryName,
      'level': '1',
    };

    box.put(dailyChallengeCacheKey, jsonEncode(data));
    setState(() {
      _challenge = data;
      _loading = false;
    });
  }

  Future<void> _playNow() async {
    if (_challenge == null) return;

    HapticFeedback.mediumImpact();

    await Navigator.of(context).pushNamed(
      Routes.quiz,
      arguments: {
        'quizType': QuizTypes.quizZone,
        'categoryId': _challenge!['categoryId'] as String,
        'subcategoryId': '',
        'level': '1',
      },
    );

    // Mark completed for today when returning from quiz
    final box = Hive.box<dynamic>(settingsBox);
    final today = DateTime.now();
    final todayKey =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    box.put(dailyChallengeCompletedOnKey, todayKey);
    if (mounted) {
      setState(() => _completedToday = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _challenge == null) return const SizedBox.shrink();

    final sysConfig = context.read<SystemConfigCubit>();
    final bonusCoins = sysConfig.rewardAdsCoins;

    return RepaintBoundary(
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: context.width * UiUtils.hzMarginPct,
        ),
        child: GlassContainer(
          intensity: GlassIntensity.accent,
          padding: const EdgeInsets.all(20),
          borderRadius: BorderRadius.circular(20),
          child: Row(
            children: [
              // Daily challenge icon with gradient
              _buildChallengeIcon(context),
              const SizedBox(width: 16),

              // Challenge info
              Expanded(
                child: _buildChallengeInfo(context, bonusCoins),
              ),
              const SizedBox(width: 12),

              // Action button
              if (!_completedToday) _buildPlayButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChallengeIcon(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.primaryColor,
            context.primaryColor.withValues(alpha: .7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: context.primaryColor.withValues(alpha: .3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(
        Icons.calendar_today_rounded,
        color: Colors.white,
        size: 28,
      ),
    );
  }

  Widget _buildChallengeInfo(BuildContext context, int bonusCoins) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Title
        Row(
          children: [
            Text(
              context.tr('dailyChallenge') ?? 'Daily Challenge',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: context.primaryTextColor,
                letterSpacing: 0.2,
              ),
            ),
            if (_completedToday) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.check_circle,
                size: 20,
                color: Colors.green,
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),

        // Category name
        Text(
          _challenge!['categoryName']?.toString() ?? '',
          style: TextStyle(
            fontSize: 14,
            color: context.primaryTextColor.withValues(alpha: .7),
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        // Bonus coins
        if (bonusCoins > 0 && !_completedToday) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                Icons.monetization_on,
                size: 16,
                color: context.primaryColor,
              ),
              const SizedBox(width: 4),
              Text(
                '+$bonusCoins ${context.tr('coinsLbl')}',
                style: TextStyle(
                  fontSize: 13,
                  color: context.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],

        // Completed badge
        if (_completedToday) ...[
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 4,
              horizontal: 10,
            ),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: .15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.green.withValues(alpha: .3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 14,
                  color: Colors.green,
                ),
                const SizedBox(width: 4),
                Text(
                  context.tr('completedToday') ?? 'Completed',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPlayButton(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: child,
        );
      },
      child: Semantics(
        button: true,
        label: 'Play daily challenge',
        child: Material(
          color: context.primaryColor,
          borderRadius: BorderRadius.circular(14),
          elevation: 4,
          shadowColor: context.primaryColor.withValues(alpha: .4),
          child: InkWell(
            onTap: _playNow,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 14,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    context.tr('play') ?? 'Play',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
