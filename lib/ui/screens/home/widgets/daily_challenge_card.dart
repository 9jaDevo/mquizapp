import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutterquiz/core/constants/hive_constants.dart';
import 'package:flutterquiz/core/routes/routes.dart';
import 'package:flutterquiz/features/quiz/models/quiz_type.dart';
import 'package:flutterquiz/features/quiz/quiz_repository.dart';
import 'package:flutterquiz/features/system_config/cubits/system_config_cubit.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

class DailyChallengeCard extends StatefulWidget {
  const DailyChallengeCard({super.key});

  @override
  State<DailyChallengeCard> createState() => _DailyChallengeCardState();
}

class _DailyChallengeCardState extends State<DailyChallengeCard> {
  Map<String, dynamic>? _challenge;
  bool _loading = true;
  bool _completedToday = false;

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  Future<void> _prepare() async {
    final box = Hive.box<dynamic>(settingsBox);
    final today = DateTime.now();
    final todayKey = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    // completion flag
    final completedOn = box.get(dailyChallengeCompletedOnKey) as String?;
    _completedToday = completedOn == todayKey;

    // try cache
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

    // compute deterministically using available categories
    final repo = QuizRepository();
    final langId = UiUtils.getCurrentQuizLanguageId(context);
    // fallback if context not required, UiUtils static might handle it; if null, let repository default flow.
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

    // pick a simple level (1)
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

    await Navigator.of(context).pushNamed(
      Routes.quiz,
      arguments: {
        'quizType': QuizTypes.quizZone,
        'categoryId': _challenge!['categoryId'] as String,
        'subcategoryId': '',
        'level': '1',
      },
    );

    // Mark completed for today when returning from quiz flow
    final box = Hive.box<dynamic>(settingsBox);
    final today = DateTime.now();
    final todayKey = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    box.put(dailyChallengeCompletedOnKey, todayKey);
    if (mounted) {
      setState(() => _completedToday = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _challenge == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final sysConfig = context.read<SystemConfigCubit>();
    final bonusCoins = sysConfig.rewardAdsCoin;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Today\'s Challenge',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onTertiary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _challenge!['categoryName']?.toString() ?? '',
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.colorScheme.onTertiary.withOpacity(.7),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (_completedToday) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 8,
                        ),
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withOpacity(.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle, size: 14, color: theme.primaryColor),
                            const SizedBox(width: 4),
                            Text(
                              'Completed today',
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.onTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                if (bonusCoins > 0 && !_completedToday) ...[
                  const SizedBox(height: 4),
                  Text(
                    '+$bonusCoins ${context.tr('coinsLbl') ?? 'coins'} bonus',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (!_completedToday)
            TextButton(
              onPressed: _playNow,
              child: const Text('Play Now'),
            ),
        ],
      ),
    );
  }
}
