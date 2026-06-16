import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';

/// ParkirGo Material 3 theme — light + dark.
///
/// Design language:
/// - 12px default radius (Material 3 spec range; overridden below).
/// - 8px spacing system (see [AppSpacing]).
/// - Inter body, Space Grotesk headings (loaded via google_fonts).
/// - Brand primary stays "Parkir Blue" in both modes for recognition.
class AppTheme {
  AppTheme._();

  /// Standard border radius used on cards, buttons, text fields, etc.
  static const double defaultRadius = AppRadius.md; // 12

  // ── Light theme ────────────────────────────────────────────────────
  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      error: AppColors.danger,
      surface: AppColors.white,
      onPrimary: AppColors.white,
      onSecondary: AppColors.white,
      onSurface: AppColors.neutral900,
      onError: AppColors.white,
    );

    return _buildTheme(scheme, Brightness.light);
  }

  // ── Dark theme ─────────────────────────────────────────────────────
  static ThemeData get dark {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
      primary: AppColors.primaryLight,
      secondary: AppColors.secondaryLight,
      error: AppColors.dangerLight,
      surface: AppColors.darkSurface,
      onPrimary: AppColors.white,
      onSecondary: AppColors.white,
      onSurface: AppColors.neutral50,
      onError: AppColors.white,
    );

    return _buildTheme(scheme, Brightness.dark);
  }

  // ── Shared theme builder ──────────────────────────────────────────
  static ThemeData _buildTheme(ColorScheme scheme, Brightness brightness) {
    final bool isLight = brightness == Brightness.light;

    final textTheme = TextTheme(
      displayLarge: AppTypography.displayLarge(color: scheme.onSurface),
      displayMedium: AppTypography.displayMedium(color: scheme.onSurface),
      displaySmall: AppTypography.displaySmall(color: scheme.onSurface),
      headlineLarge: AppTypography.headlineLarge(color: scheme.onSurface),
      headlineMedium: AppTypography.headlineMedium(color: scheme.onSurface),
      headlineSmall: AppTypography.headlineSmall(color: scheme.onSurface),
      titleLarge: AppTypography.titleLarge(color: scheme.onSurface),
      titleMedium: AppTypography.titleMedium(color: scheme.onSurface),
      titleSmall: AppTypography.titleSmall(color: scheme.onSurface),
      bodyLarge: AppTypography.bodyLarge(color: scheme.onSurface),
      bodyMedium: AppTypography.bodyMedium(color: scheme.onSurface),
      bodySmall: AppTypography.bodySmall(
        color: isLight ? AppColors.neutral600 : AppColors.neutral400,
      ),
      labelLarge: AppTypography.labelLarge(color: scheme.onSurface),
      labelMedium: AppTypography.labelMedium(color: scheme.onSurface),
      labelSmall: AppTypography.labelSmall(
        color: isLight ? AppColors.neutral600 : AppColors.neutral400,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: isLight
          ? AppColors.backgroundLight
          : AppColors.backgroundDark,
      textTheme: textTheme,
      fontFamily: 'Inter',
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: isLight ? AppColors.white : AppColors.darkSurface,
        foregroundColor: scheme.onSurface,
        systemOverlayStyle: isLight
            ? SystemUiOverlayStyle.dark
            : SystemUiOverlayStyle.light,
        titleTextStyle: AppTypography.titleLarge(color: scheme.onSurface),
        iconTheme: IconThemeData(color: scheme.onSurface),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: isLight ? AppColors.cardLight : AppColors.cardDark,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(defaultRadius),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(defaultRadius),
          ),
          textStyle: AppTypography.labelLarge(),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          foregroundColor: scheme.primary,
          side: BorderSide(color: scheme.primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(defaultRadius),
          ),
          textStyle: AppTypography.labelLarge(),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          textStyle: AppTypography.labelLarge(),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(defaultRadius),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isLight ? AppColors.neutral100 : AppColors.darkSurfaceVariant,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.md,
        ),
        hintStyle: AppTypography.bodyMedium(
          color: isLight ? AppColors.neutral500 : AppColors.neutral400,
        ),
        labelStyle: AppTypography.labelMedium(
          color: isLight ? AppColors.neutral600 : AppColors.neutral400,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(defaultRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(defaultRadius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(defaultRadius),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(defaultRadius),
          borderSide: BorderSide(color: scheme.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(defaultRadius),
          borderSide: BorderSide(color: scheme.error, width: 1.5),
        ),
        errorStyle: AppTypography.bodySmall(color: scheme.error),
      ),
      dividerTheme: DividerThemeData(
        color: isLight ? AppColors.dividerLight : AppColors.dividerDark,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isLight ? AppColors.neutral900 : AppColors.neutral200,
        contentTextStyle: AppTypography.bodyMedium(
          color: isLight ? AppColors.white : AppColors.neutral900,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(defaultRadius),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: isLight
            ? AppColors.neutral200
            : AppColors.neutral800,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: isLight
            ? AppColors.white
            : AppColors.darkSurfaceVariant,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
    );
  }
}
