import 'package:flutter/material.dart';

/// ParkirGo color palette. Values match `docs/struktur_flutter.md`.
///
/// Each role has a light + dark variant via [ColorScheme] but the brand
/// colors (primary `parkir blue`, secondary `cyan`) stay constant so the
/// app feels the same in both themes.
class AppColors {
  AppColors._();

  // ── Brand ──────────────────────────────────────────────────────────
  /// Primary "Parkir Blue" — used for action buttons, active states.
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryLight = Color(0xFF60A5FA);
  static const Color primaryDark = Color(0xFF1D4ED8);

  /// Secondary "Cyan" — used for highlights, links, info badges.
  static const Color secondary = Color(0xFF0EA5E9);
  static const Color secondaryLight = Color(0xFF38BDF8);
  static const Color secondaryDark = Color(0xFF0284C7);

  // ── Semantic ──────────────────────────────────────────────────────
  static const Color success = Color(0xFF22C55E);
  static const Color successLight = Color(0xFF4ADE80);
  static const Color successDark = Color(0xFF16A34A);

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFBBF24);
  static const Color warningDark = Color(0xFFD97706);

  static const Color danger = Color(0xFFEF4444);
  static const Color dangerLight = Color(0xFFF87171);
  static const Color dangerDark = Color(0xFFDC2626);

  static const Color info = Color(0xFF3B82F6);

  // ── Neutrals (50 → 900) ───────────────────────────────────────────
  static const Color neutral50 = Color(0xFFF8FAFC);
  static const Color neutral100 = Color(0xFFF1F5F9);
  static const Color neutral200 = Color(0xFFE2E8F0);
  static const Color neutral300 = Color(0xFFCBD5E1);
  static const Color neutral400 = Color(0xFF94A3B8);
  static const Color neutral500 = Color(0xFF64748B);
  static const Color neutral600 = Color(0xFF475569);
  static const Color neutral700 = Color(0xFF334155);
  static const Color neutral800 = Color(0xFF1E293B);
  static const Color neutral900 = Color(0xFF0F172A);

  // ── Surfaces ──────────────────────────────────────────────────────
  /// Dark surface used for elevated dark cards / scaffold bg.
  static const Color darkSurface = Color(0xFF0F172A);
  static const Color darkSurfaceVariant = Color(0xFF1E293B);

  /// Pure white / black helpers (avoid `Colors.white` in widgets).
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  /// Transparent — for borders / overlays.
  static const Color transparent = Color(0x00000000);

  // ── Helper getters used by components ─────────────────────────────
  static Color get textPrimaryLight => neutral900;
  static Color get textSecondaryLight => neutral600;
  static Color get textPrimaryDark => neutral50;
  static Color get textSecondaryDark => neutral400;

  static Color get dividerLight => neutral200;
  static Color get dividerDark => neutral800;

  static Color get backgroundLight => neutral50;
  static Color get backgroundDark => darkSurface;

  static Color get cardLight => white;
  static Color get cardDark => darkSurfaceVariant;
}
