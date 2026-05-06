// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class AppColors {
  final Color primary;
  final Color secondary;

  final Color green;
  final Color error;
  final Color info;

  final Color bg;
  final Color surface;
  final Color surfaceHigh;

  final Color border;
  final Color borderStrong;

  // ─── Text
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;

  final Color onBrand;

  // ─── Overlays
  final Color dropdown;
  final Color dropdownDivider;
  final Color bottomSheet;
  final Color bottomSheetHandle;

  // ─── TextField
  final Color inputFill;
  final Color inputText;
  final Color inputHint;
  final Color inputBorder;
  final Color inputBorderFocus;
  final Color inputIcon;
  final Color inputIconFocus;

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
    required this.dropdown,
    required this.dropdownDivider,
    required this.bottomSheet,
    required this.bottomSheetHandle,

    // TextField
    required this.inputFill,
    required this.inputText,
    required this.inputHint,
    required this.inputBorder,
    required this.inputBorderFocus,
    required this.inputIcon,
    required this.inputIconFocus,
  });

  // ─── Dark Theme ─────────────────────────────────────────────
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

    dropdown: const Color(0xFF1C1C1E),
    dropdownDivider: Colors.white.withOpacity(0.07),

    bottomSheet: const Color(0xFF141414),
    bottomSheetHandle: Colors.white.withOpacity(0.18),

    // ─── TextField
    inputFill: const Color(0xFF141414),
    inputText: const Color(0xFFEFF3FF),
    inputHint: Colors.white.withOpacity(0.35),
    inputBorder: Colors.white.withOpacity(0.08),
    inputBorderFocus: const Color(0xFF301BF3),
    inputIcon: Colors.white.withOpacity(0.45),
    inputIconFocus: const Color(0xFF301BF3),
  );

  // ─── Light Theme ────────────────────────────────────────────
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

    dropdown: const Color(0xFFFFFFFF),
    dropdownDivider: Colors.black.withOpacity(0.06),

    bottomSheet: const Color(0xFFFFFFFF),
    bottomSheetHandle: Colors.black.withOpacity(0.14),

    // ─── TextField
    inputFill: const Color(0xFFF7F7F7),
    inputText: const Color(0xFF0A0A12),
    inputHint: Colors.black.withOpacity(0.35),
    inputBorder: Colors.black.withOpacity(0.08),
    inputBorderFocus: const Color(0xFF301BF3),
    inputIcon: Colors.black.withOpacity(0.45),
    inputIconFocus: const Color(0xFF301BF3),
  );
}
