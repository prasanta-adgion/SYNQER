// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

// class AppColors {
//   // Brand
//   static const Color primary = Color(0xFF301BF3);
//   static const Color secondary = Color(0xFF5E4AE5);

//   // Semantic
//   static const Color green = Color(0xFF27AE60);
//   static const Color error = Colors.redAccent;
//   static const Color info = Color(0xFF413D81);

//   // Text
//   static const Color textPrimary = Color(0xFFEFF3FF);
//   static final Color textSecondary = Colors.white.withOpacity(0.55);
//   static final Color textMuted = Colors.white.withOpacity(0.25);
// }

/// Color tokens for both light and dark themes.
///
/// Never use these directly in widgets — go through `context.colors`
/// so the UI rebuilds correctly when the theme changes.
class AppColors {
  // ─── Brand (shared across both themes) ───────────────────────────────────
  final Color primary;
  final Color secondary;

  // ─── Semantic ────────────────────────────────────────────────────────────
  final Color green;
  final Color error;
  final Color info;

  // ─── Surfaces ────────────────────────────────────────────────────────────
  final Color bg;
  final Color surface;
  final Color surfaceHigh;

  // ─── Borders ─────────────────────────────────────────────────────────────
  final Color border;
  final Color borderStrong;

  // ─── Text ────────────────────────────────────────────────────────────────
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;

  // ─── Misc ────────────────────────────────────────────────────────────────
  /// Used for text/icons placed on top of the brand gradient.
  final Color onBrand;

  const AppColors({
    required this.primary,
    required this.secondary,
    required this.green,
    required this.error,
    required this.info,
    required this.bg,
    required this.surface,
    required this.surfaceHigh,
    required this.border,
    required this.borderStrong,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.onBrand,
  });

  // ─── Dark theme ──────────────────────────────────────────────────────────
  static final AppColors dark = AppColors(
    primary: const Color(0xFF301BF3),
    secondary: const Color(0xFF5E4AE5),
    green: const Color(0xFF27AE60),
    error: Colors.redAccent,
    info: const Color(0xFF413D81),

    bg: const Color(0xFF000000),
    surface: const Color(0xFF0A0A0A),
    surfaceHigh: const Color(0xFF141414),

    border: Colors.white.withOpacity(0.08),
    borderStrong: Colors.white.withOpacity(0.14),

    textPrimary: const Color(0xFFEFF3FF),
    textSecondary: Colors.white.withOpacity(0.55),
    textMuted: Colors.white.withOpacity(0.25),

    onBrand: Colors.white,
  );

  // ─── Light theme ─────────────────────────────────────────────────────────
  static final AppColors light = AppColors(
    primary: const Color(0xFF301BF3),
    secondary: const Color(0xFF5E4AE5),
    green: const Color(0xFF1F8F4D),
    error: const Color(0xFFE53935),
    info: const Color(0xFF413D81),

    bg: const Color(0xFFFAFAFA),
    surface: const Color(0xFFFFFFFF),
    surfaceHigh: const Color(0xFFF2F2F4),

    border: Colors.black.withOpacity(0.08),
    borderStrong: Colors.black.withOpacity(0.16),

    textPrimary: const Color(0xFF0A0A12),
    textSecondary: Colors.black.withOpacity(0.60),
    textMuted: Colors.black.withOpacity(0.30),

    onBrand: Colors.white,
  );
}
