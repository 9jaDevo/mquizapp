import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutterquiz/core/core.dart';

/// Device performance tiers for adaptive rendering
enum DevicePerformanceTier {
  high, // Full glassmorphism with backdrop filters
  mid, // Semi-transparent cards without blur
  low, // Solid cards with elevation
}

/// Glass theme configuration for glassmorphism UI
class GlassThemeConfig {
  /// Device performance detector singleton
  static DevicePerformanceTier? _performanceTier;
  static bool _isPerformanceDetectionComplete = false;

  /// Detect device performance tier
  static Future<DevicePerformanceTier> detectPerformanceTier() async {
    if (_isPerformanceDetectionComplete && _performanceTier != null) {
      return _performanceTier!;
    }

    try {
      final deviceInfo = DeviceInfoPlugin();

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        final sdkInt = androidInfo.version.sdkInt;

        // Android 10+ (API 29+) with reasonable hardware
        if (sdkInt >= 29) {
          _performanceTier = DevicePerformanceTier.high;
        } else if (sdkInt >= 26) {
          // Android 8-9 (API 26-28)
          _performanceTier = DevicePerformanceTier.mid;
        } else {
          // Android 7 and below
          _performanceTier = DevicePerformanceTier.low;
        }
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        final systemVersion = iosInfo.systemVersion;
        final majorVersion = int.tryParse(systemVersion.split('.').first) ?? 0;

        if (majorVersion >= 13) {
          _performanceTier = DevicePerformanceTier.high;
        } else if (majorVersion >= 11) {
          _performanceTier = DevicePerformanceTier.mid;
        } else {
          _performanceTier = DevicePerformanceTier.low;
        }
      } else {
        // Desktop platforms - assume high performance
        _performanceTier = DevicePerformanceTier.high;
      }
    } catch (e) {
      // Fallback to mid-tier if detection fails
      _performanceTier = DevicePerformanceTier.mid;
    }

    _isPerformanceDetectionComplete = true;
    return _performanceTier!;
  }

  /// Get current performance tier (synchronous, must call detectPerformanceTier first)
  static DevicePerformanceTier get performanceTier =>
      _performanceTier ?? DevicePerformanceTier.mid;

  /// Check if glassmorphism effects should be enabled
  static bool get isGlassmorphismEnabled =>
      performanceTier == DevicePerformanceTier.high;

  /// Light theme glass properties
  static GlassProperties lightTheme = const GlassProperties(
    // Medium blur for readability against bright backgrounds
    blurSigma: 15.0,
    // Higher opacity for light theme
    opacity: 0.2,
    // Subtle border
    borderOpacity: 0.15,
    borderWidth: 1.5,
    // Light gradient overlay
    gradientColors: [
      Color(0x1AFFFFFF), // 10% white
      Color(0x0DFFFFFF), // 5% white
    ],
  );

  /// Dark theme glass properties
  static GlassProperties darkTheme = const GlassProperties(
    // Heavier blur for dramatic effect in dark mode
    blurSigma: 22.0,
    // Lower opacity for dark theme
    opacity: 0.12,
    // More visible border in dark mode
    borderOpacity: 0.25,
    borderWidth: 1.5,
    // Dark gradient overlay
    gradientColors: [
      Color(0x1AFFFFFF), // 10% white
      Color(0x0DFFFFFF), // 5% white
    ],
  );

  /// Accent glass (for important cards like achievements, daily challenge)
  static GlassProperties accentLightTheme = const GlassProperties(
    blurSigma: 18.0,
    opacity: 0.25,
    borderOpacity: 0.2,
    borderWidth: 2.0,
    gradientColors: [
      Color(0x26FFFFFF), // 15% white
      Color(0x1AFFFFFF), // 10% white
    ],
  );

  static GlassProperties accentDarkTheme = const GlassProperties(
    blurSigma: 25.0,
    opacity: 0.15,
    borderOpacity: 0.3,
    borderWidth: 2.0,
    gradientColors: [
      Color(0x26FFFFFF), // 15% white
      Color(0x1AFFFFFF), // 10% white
    ],
  );

  /// Light glass (for background cards like quiz zones)
  static GlassProperties lightGlassLightTheme = const GlassProperties(
    blurSigma: 12.0,
    opacity: 0.15,
    borderOpacity: 0.1,
    borderWidth: 1.0,
    gradientColors: [
      Color(0x14FFFFFF), // 8% white
      Color(0x0AFFFFFF), // 4% white
    ],
  );

  static GlassProperties lightGlassDarkTheme = const GlassProperties(
    blurSigma: 18.0,
    opacity: 0.08,
    borderOpacity: 0.2,
    borderWidth: 1.0,
    gradientColors: [
      Color(0x14FFFFFF), // 8% white
      Color(0x0AFFFFFF), // 4% white
    ],
  );

  /// Get glass properties based on theme and intensity
  static GlassProperties getProperties(
    BuildContext context, {
    GlassIntensity intensity = GlassIntensity.medium,
  }) {
    final isDark = context.brightness == Brightness.dark;

    switch (intensity) {
      case GlassIntensity.light:
        return isDark ? lightGlassDarkTheme : lightGlassLightTheme;
      case GlassIntensity.medium:
        return isDark ? darkTheme : lightTheme;
      case GlassIntensity.accent:
        return isDark ? accentDarkTheme : accentLightTheme;
    }
  }

  /// Fallback properties for mid-tier devices (no blur)
  static BoxDecoration getFallbackDecoration(
    BuildContext context, {
    GlassIntensity intensity = GlassIntensity.medium,
  }) {
    final isDark = context.brightness == Brightness.dark;
    final surfaceColor = isDark ? kdBackgroundColor : klBackgroundColor;

    // Base opacity based on intensity
    final opacity = switch (intensity) {
      GlassIntensity.light => 0.5,
      GlassIntensity.medium => 0.7,
      GlassIntensity.accent => 0.85,
    };

    return BoxDecoration(
      color: surfaceColor.withValues(alpha: opacity),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: isDark
            ? Colors.white.withValues(alpha: 0.1)
            : Colors.black.withValues(alpha: 0.05),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: (isDark ? kdPrimaryColor : klPrimaryColor)
              .withValues(alpha: 0.15),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  /// Low-tier fallback (solid cards with elevation)
  static BoxDecoration getLowTierDecoration(
    BuildContext context, {
    GlassIntensity intensity = GlassIntensity.medium,
  }) {
    final isDark = context.brightness == Brightness.dark;
    final surfaceColor = isDark ? kdBackgroundColor : klBackgroundColor;

    final elevation = switch (intensity) {
      GlassIntensity.light => 2.0,
      GlassIntensity.medium => 4.0,
      GlassIntensity.accent => 8.0,
    };

    return BoxDecoration(
      color: surfaceColor,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.1),
          blurRadius: elevation * 2,
          offset: Offset(0, elevation),
        ),
      ],
    );
  }
}

/// Glass intensity levels
enum GlassIntensity {
  light, // Background cards
  medium, // Standard cards
  accent, // Important/highlighted cards
}

/// Glass properties configuration
class GlassProperties {
  final double blurSigma;
  final double opacity;
  final double borderOpacity;
  final double borderWidth;
  final List<Color> gradientColors;

  const GlassProperties({
    required this.blurSigma,
    required this.opacity,
    required this.borderOpacity,
    required this.borderWidth,
    required this.gradientColors,
  });
}

/// Extension for easy access to glass properties
extension GlassThemeExtension on BuildContext {
  /// Get glass properties for current theme
  GlassProperties glassProperties({
    GlassIntensity intensity = GlassIntensity.medium,
  }) {
    return GlassThemeConfig.getProperties(this, intensity: intensity);
  }

  /// Check if device supports glassmorphism
  bool get supportsGlassmorphism => GlassThemeConfig.isGlassmorphismEnabled;

  /// Get appropriate decoration based on device capability
  BoxDecoration glassDecoration({
    GlassIntensity intensity = GlassIntensity.medium,
  }) {
    final tier = GlassThemeConfig.performanceTier;

    return switch (tier) {
      DevicePerformanceTier.high => BoxDecoration(
          // Will be replaced with actual glass widget
          borderRadius: BorderRadius.circular(16),
        ),
      DevicePerformanceTier.mid =>
        GlassThemeConfig.getFallbackDecoration(this, intensity: intensity),
      DevicePerformanceTier.low =>
        GlassThemeConfig.getLowTierDecoration(this, intensity: intensity),
    };
  }
}
