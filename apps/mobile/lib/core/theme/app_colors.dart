import 'package:flutter/material.dart';

/// mQuiz color palette.
/// Mirrors the design tokens established in the existing app but uses
/// static const class approach for easy access: AppColors.primary, etc.
abstract final class AppColors {
  AppColors._();

  // ── Brand ──────────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF1F4ED8);
  static const Color primaryDark = Color(0xFF3B82F6);

  static const Color secondary = Color(0xFF7C3AED);
  static const Color secondaryDark = Color(0xFF8B5CF6);

  // ── Background ─────────────────────────────────────────────────────────────
  static const Color background = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFF151922);

  static const Color pageBackground = Color(0xFFF4F7FD);
  static const Color pageBackgroundDark = Color(0xFF0F1115);

  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E2532);

  static const Color cardBackground = Color(0xFFF8FAFC);
  static const Color cardBackgroundDark = Color(0xFF1E2532);

  // ── Text ───────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);

  static const Color textSecondary = Color(0xFF64748B);
  static const Color textSecondaryDark = Color(0xFF94A3B8);

  static const Color textHint = Color(0xFF94A3B8);
  static const Color textHintDark = Color(0xFF475569);

  // ── Border & Divider ───────────────────────────────────────────────────────
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderDark = Color(0xFF2D3748);

  static const Color divider = Color(0xFFF1F5F9);
  static const Color dividerDark = Color(0xFF1A202C);

  // ── Semantic ───────────────────────────────────────────────────────────────
  static const Color correct = Color(0xFF22C55E);
  static const Color wrong = Color(0xFFEF4444);
  static const Color pending = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // ── Gamification ──────────────────────────────────────────────────────────
  static const Color coin = Color(0xFFF59E0B);
  static const Color coinAdd = Color(0xFF22C55E);
  static const Color coinDeduct = Color(0xFFEF4444);
  static const Color streak = Color(0xFFFF6B35);
  static const Color live = Color(0xFFEF4444);
  static const Color xp = Color(0xFF8B5CF6);

  // ── League tiers ──────────────────────────────────────────────────────────
  static const Color bronze = Color(0xFFCD7F32);
  static const Color silver = Color(0xFFC0C0C0);
  static const Color gold = Color(0xFFFFD700);
  static const Color platinum = Color(0xFF00CFCF);
  static const Color diamond = Color(0xFF66B2FF);

  // ── Gradient helpers ──────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1F4ED8), Color(0xFF7C3AED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient streakGradient = LinearGradient(
    colors: [Color(0xFFFF6B35), Color(0xFFFFD700)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
