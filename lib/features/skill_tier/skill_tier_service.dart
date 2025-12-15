import 'dart:convert';

import 'package:flutterquiz/core/constants/hive_constants.dart';
import 'package:flutterquiz/features/statistic/statistic_repository.dart';
import 'package:flutterquiz/features/skill_tier/models/skill_tier.dart';
import 'package:hive_flutter/hive_flutter.dart';

final class SkillTierService {
  SkillTierService._();

  static Future<SkillTier> computeTier() async {
    try {
      final repo = StatisticRepository();
      final stats = await repo.getStatistic(getBattleStatistics: false);

      final answered = double.tryParse(stats.answeredQuestions) ?? 0;
      final correct = double.tryParse(stats.correctAnswers) ?? 0;
      final accuracy = answered == 0 ? 0.0 : (correct / answered) * 100.0;
      final type = SkillTier.mapFromAccuracy(accuracy);

      // cache in settings box for quick access
      final box = Hive.box<dynamic>(settingsBox);
      box.put(
        skillTierKey,
        jsonEncode(<String, dynamic>{
          'type': type.name,
          'accuracy': accuracy,
        }),
      );

      return SkillTier(type: type, accuracyPercent: accuracy);
    } catch (_) {
      // Fallback to cached value if any
      final box = Hive.box<dynamic>(settingsBox);
      final cached = box.get(skillTierKey) as String?;
      if (cached != null) {
        final map = jsonDecode(cached) as Map<String, dynamic>;
        final name = (map['type'] as String?) ?? SkillTierType.bronze.name;
        final type = SkillTierType.values.firstWhere(
          (e) => e.name == name,
          orElse: () => SkillTierType.bronze,
        );
        final acc = (map['accuracy'] as num?)?.toDouble() ?? 0.0;
        return SkillTier(type: type, accuracyPercent: acc);
      }
      return const SkillTier(type: SkillTierType.bronze, accuracyPercent: 0);
    }
  }
}
