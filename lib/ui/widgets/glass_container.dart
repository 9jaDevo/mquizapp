import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutterquiz/core/core.dart';
import 'package:flutterquiz/ui/styles/glass_theme.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';

/// Reusable glass container widget with adaptive rendering
class GlassContainer extends StatelessWidget {
  final Widget child;
  final GlassIntensity intensity;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;

  const GlassContainer({
    required this.child,
    super.key,
    this.intensity = GlassIntensity.medium,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.borderRadius,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tier = GlassThemeConfig.performanceTier;
    final glassProps = context.glassProperties(intensity: intensity);
    final radius = borderRadius ?? BorderRadius.circular(16);

    Widget content = child;

    // Wrap in GestureDetector if onTap provided
    if (onTap != null) {
      content = InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: content,
      );
    }

    // High-tier: Full glassmorphism
    if (tier == DevicePerformanceTier.high) {
      return Container(
        width: width,
        height: height,
        margin: margin,
        child: GlassContainer.UI(
          blur: glassProps.blurSigma,
          opacity: glassProps.opacity,
          border: glassProps.borderWidth,
          borderOpacity: glassProps.borderOpacity,
          borderRadius: radius,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: glassProps.gradientColors,
          ),
          child: Padding(
            padding: padding ?? EdgeInsets.zero,
            child: content,
          ),
        ),
      );
    }

    // Mid-tier: Semi-transparent without blur
    if (tier == DevicePerformanceTier.mid) {
      final isDark = context.brightness == Brightness.dark;
      final surfaceColor = isDark ? kdBackgroundColor : klBackgroundColor;

      final opacity = switch (intensity) {
        GlassIntensity.light => 0.5,
        GlassIntensity.medium => 0.7,
        GlassIntensity.accent => 0.85,
      };

      return Container(
        width: width,
        height: height,
        margin: margin,
        padding: padding,
        decoration: BoxDecoration(
          color: surfaceColor.withValues(alpha: opacity),
          borderRadius: radius,
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.05),
            width: glassProps.borderWidth,
          ),
          boxShadow: [
            BoxShadow(
              color: (isDark ? kdPrimaryColor : klPrimaryColor)
                  .withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: content,
      );
    }

    // Low-tier: Solid cards with elevation
    final isDark = context.brightness == Brightness.dark;
    final surfaceColor = isDark ? kdBackgroundColor : klBackgroundColor;

    final elevation = switch (intensity) {
      GlassIntensity.light => 2.0,
      GlassIntensity.medium => 4.0,
      GlassIntensity.accent => 8.0,
    };

    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.1),
            blurRadius: elevation * 2,
            offset: Offset(0, elevation),
          ),
        ],
      ),
      child: content,
    );
  }
}

/// Extension to add glass container to any widget
extension GlassContainerExtension on Widget {
  Widget glassContainer({
    GlassIntensity intensity = GlassIntensity.medium,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double? width,
    double? height,
    BorderRadius? borderRadius,
    VoidCallback? onTap,
  }) {
    return GlassContainer(
      intensity: intensity,
      padding: padding,
      margin: margin,
      width: width,
      height: height,
      borderRadius: borderRadius,
      onTap: onTap,
      child: this,
    );
  }
}
