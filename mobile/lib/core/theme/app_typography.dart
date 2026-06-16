import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography scale for ParkirGo.
///
/// Body text: **Inter** — clean, neutral, designed for screen readability.
/// Display / headings: **Space Grotesk** — geometric, friendly, with a
/// tech feel that matches the parking-domain voice.
///
/// Both fonts are loaded via `google_fonts` and cached at runtime; no
/// font files are bundled in the APK.
class AppTypography {
  AppTypography._();

  // ── Base font getters ──────────────────────────────────────────────
  static TextStyle _bodyBase({
    double size = 14,
    FontWeight weight = FontWeight.w400,
    double height = 1.5,
    Color? color,
    double letterSpacing = 0,
  }) {
    return GoogleFonts.inter(
      fontSize: size,
      fontWeight: weight,
      height: height,
      color: color,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle _displayBase({
    double size = 24,
    FontWeight weight = FontWeight.w600,
    double height = 1.2,
    Color? color,
    double letterSpacing = -0.2,
  }) {
    return GoogleFonts.spaceGrotesk(
      fontSize: size,
      fontWeight: weight,
      height: height,
      color: color,
      letterSpacing: letterSpacing,
    );
  }

  // ── Display (Space Grotesk) ────────────────────────────────────────
  static TextStyle displayLarge({Color? color}) =>
      _displayBase(size: 32, weight: FontWeight.w700, color: color);

  static TextStyle displayMedium({Color? color}) =>
      _displayBase(size: 28, weight: FontWeight.w600, color: color);

  static TextStyle displaySmall({Color? color}) =>
      _displayBase(size: 24, weight: FontWeight.w600, color: color);

  static TextStyle headlineLarge({Color? color}) =>
      _displayBase(size: 22, weight: FontWeight.w600, color: color);

  static TextStyle headlineMedium({Color? color}) =>
      _displayBase(size: 20, weight: FontWeight.w600, color: color);

  static TextStyle headlineSmall({Color? color}) =>
      _displayBase(size: 18, weight: FontWeight.w600, color: color);

  static TextStyle titleLarge({Color? color}) =>
      _displayBase(size: 16, weight: FontWeight.w600, color: color);

  static TextStyle titleMedium({Color? color}) =>
      _displayBase(size: 15, weight: FontWeight.w600, color: color);

  static TextStyle titleSmall({Color? color}) =>
      _displayBase(size: 14, weight: FontWeight.w600, color: color);

  // ── Body (Inter) ───────────────────────────────────────────────────
  static TextStyle bodyLarge({Color? color}) =>
      _bodyBase(size: 16, weight: FontWeight.w400, color: color);

  static TextStyle bodyMedium({Color? color}) =>
      _bodyBase(size: 14, weight: FontWeight.w400, color: color);

  static TextStyle bodySmall({Color? color}) =>
      _bodyBase(size: 12, weight: FontWeight.w400, color: color);

  static TextStyle labelLarge({Color? color}) =>
      _bodyBase(
        size: 14,
        weight: FontWeight.w600,
        letterSpacing: 0.1,
        color: color,
      );

  static TextStyle labelMedium({Color? color}) =>
      _bodyBase(
        size: 12,
        weight: FontWeight.w600,
        letterSpacing: 0.1,
        color: color,
      );

  static TextStyle labelSmall({Color? color}) =>
      _bodyBase(
        size: 11,
        weight: FontWeight.w600,
        letterSpacing: 0.2,
        color: color,
      );

  // ── Number / monetary (tabular figures for prices) ─────────────────
  static TextStyle numberLarge({Color? color}) =>
      _displayBase(
        size: 28,
        weight: FontWeight.w700,
        color: color,
        letterSpacing: -0.5,
      ).copyWith(fontFeatures: const [FontFeature.tabularFigures()]);

  static TextStyle numberMedium({Color? color}) =>
      _displayBase(
        size: 18,
        weight: FontWeight.w700,
        color: color,
      ).copyWith(fontFeatures: const [FontFeature.tabularFigures()]);
}

/// 8px spacing scale — every padding/margin/gap must use one of these.
class AppSpacing {
  AppSpacing._();
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double base = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
}

class AppRadius {
  AppRadius._();
  static const double xs = 6;
  static const double sm = 8;
  static const double md = 12; // default per spec
  static const double lg = 16;
  static const double xl = 20;
  static const double full = 9999;
}
