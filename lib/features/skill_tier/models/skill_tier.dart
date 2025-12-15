enum SkillTierType { bronze, silver, gold, platinum }

final class SkillTier {
  const SkillTier({
    required this.type,
    required this.accuracyPercent,
  });

  final SkillTierType type;
  final double accuracyPercent;

  static SkillTierType mapFromAccuracy(double accuracy) {
    if (accuracy >= 85) return SkillTierType.platinum;
    if (accuracy >= 70) return SkillTierType.gold;
    if (accuracy >= 50) return SkillTierType.silver;
    return SkillTierType.bronze;
  }

  static String label(SkillTierType type) {
    switch (type) {
      case SkillTierType.platinum:
        return 'Platinum';
      case SkillTierType.gold:
        return 'Gold';
      case SkillTierType.silver:
        return 'Silver';
      case SkillTierType.bronze:
        return 'Bronze';
    }
  }
}
