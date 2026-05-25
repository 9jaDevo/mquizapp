import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mquiz/core/theme/app_colors.dart';
import 'package:mquiz/core/theme/app_text_styles.dart';

abstract final class AppTheme {
  AppTheme._();

  static ThemeData light() => _buildTheme(isDark: false);
  static ThemeData dark() => _buildTheme(isDark: true);

  static ThemeData _buildTheme({required bool isDark}) {
    final seedColor =
        isDark ? AppColors.primaryDark : AppColors.primary;
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: isDark ? Brightness.dark : Brightness.light,
      primary: isDark ? AppColors.primaryDark : AppColors.primary,
      secondary: isDark ? AppColors.secondaryDark : AppColors.secondary,
      surface: isDark ? AppColors.surfaceDark : AppColors.surface,
      onSurface: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor:
          isDark ? AppColors.pageBackgroundDark : AppColors.pageBackground,
      textTheme: AppTextStyles.textTheme(isDark),

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor:
            isDark ? AppColors.backgroundDark : AppColors.background,
        foregroundColor:
            isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
        ),
      ),

      // Card
      cardTheme: CardThemeData(
        color: isDark ? AppColors.cardBackgroundDark : AppColors.cardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.border,
            width: 1,
          ),
        ),
        margin: EdgeInsets.zero,
      ),

      // ElevatedButton
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? AppColors.primaryDark : AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // OutlinedButton
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor:
              isDark ? AppColors.primaryDark : AppColors.primary,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          side: BorderSide(
            color: isDark ? AppColors.primaryDark : AppColors.primary,
            width: 1.5,
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // TextButton
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor:
              isDark ? AppColors.primaryDark : AppColors.primary,
        ),
      ),

      // InputDecoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.surfaceDark : AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? AppColors.primaryDark : AppColors.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.wrong),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor:
            isDark ? AppColors.surfaceDark : AppColors.surface,
      ),

      // BottomNavigationBar
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor:
            isDark ? AppColors.backgroundDark : AppColors.background,
        selectedItemColor:
            isDark ? AppColors.primaryDark : AppColors.primary,
        unselectedItemColor:
            isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // TabBar
      tabBarTheme: TabBarThemeData(
        labelColor: isDark ? AppColors.primaryDark : AppColors.primary,
        unselectedLabelColor:
            isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
        indicator: BoxDecoration(
          color: isDark
              ? AppColors.primaryDark.withValues(alpha: 0.15)
              : AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(25),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: isDark ? AppColors.dividerDark : AppColors.divider,
        thickness: 1,
        space: 1,
      ),

      // SnackBar
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
