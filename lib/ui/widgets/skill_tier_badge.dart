import 'package:flutter/material.dart';
import 'package:flutterquiz/features/skill_tier/models/skill_tier.dart';
import 'package:flutterquiz/features/skill_tier/skill_tier_service.dart';

class SkillTierBadge extends StatelessWidget {
  const SkillTierBadge({super.key});

  Color _colorFor(SkillTierType type, ThemeData theme) {
    switch (type) {
      case SkillTierType.platinum:
        return theme.colorScheme.primary;
      case SkillTierType.gold:
        return const Color(0xffD4AF37);
      case SkillTierType.silver:
        return const Color(0xffC0C0C0);
      case SkillTierType.bronze:
        return const Color(0xffCD7F32);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SkillTier>(
      future: SkillTierService.computeTier(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }
        final tier = snapshot.data!;
        final color = _colorFor(tier.type, Theme.of(context));
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(.12),
            borderRadius: BorderRadius.circular(9999),
            border: Border.all(color: color.withOpacity(.5)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Text(
                '${SkillTier.label(tier.type)} • ${tier.accuracyPercent.toStringAsFixed(0)}% accuracy',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onTertiary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
