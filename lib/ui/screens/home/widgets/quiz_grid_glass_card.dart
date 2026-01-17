import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterquiz/commons/commons.dart';
import 'package:flutterquiz/core/core.dart';
import 'package:flutterquiz/ui/widgets/glass_container.dart';

/// Glassmorphism quiz grid card with modern design
class QuizGridGlassCard extends StatelessWidget {
  const QuizGridGlassCard({
    required this.title,
    required this.desc,
    required this.img,
    super.key,
    this.onTap,
    this.iconOnRight = true,
  });

  final String title;
  final String desc;
  final String img;
  final bool iconOnRight;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$title. $desc',
      child: LayoutBuilder(
        builder: (_, constraints) {
          final cSize = constraints.maxWidth;
          final iconSize = cSize * .32;
          final iconColor = context.primaryColor;

          return GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              onTap?.call();
            },
            child: RepaintBoundary(
              child: Stack(
                children: [
                  // Glass shadow effect
                  Positioned(
                    top: 0,
                    left: cSize * 0.2,
                    right: cSize * 0.2,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        boxShadow: [
                          BoxShadow(
                            offset: const Offset(0, 40),
                            blurRadius: 30,
                            spreadRadius: 2,
                            color: context.primaryColor.withValues(alpha: .08),
                          ),
                        ],
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(cSize * .525),
                        ),
                      ),
                      width: cSize,
                      height: cSize * .6,
                    ),
                  ),

                  // Glass card
                  GlassContainer(
                    intensity: GlassIntensity.light,
                    width: cSize,
                    height: cSize,
                    padding: const EdgeInsets.all(16),
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Title
                            Text(
                              title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: context.primaryTextColor,
                                letterSpacing: 0.2,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Description
                            Expanded(
                              child: Text(
                                desc,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: context.primaryTextColor
                                      .withValues(alpha: .65),
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Icon with glass effect
                        Align(
                          alignment:
                              iconOnRight ? Alignment.bottomRight : Alignment.bottomLeft,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  iconColor.withValues(alpha: .15),
                                  iconColor.withValues(alpha: .05),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: iconColor.withValues(alpha: .2),
                                width: 1.5,
                              ),
                            ),
                            padding: const EdgeInsets.all(10),
                            width: iconSize,
                            height: iconSize,
                            child: QImage(
                              imageUrl: img,
                              color: iconColor,
                              fit: BoxFit.contain,
                            ),
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
      ),
    );
  }
}
