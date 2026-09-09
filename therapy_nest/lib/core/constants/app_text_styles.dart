import 'package:flutter/material.dart';

/// All application text styles — the single source of truth.
/// Uses Nunito for display headings (friendly, rounded) and Inter for body/UI.
/// No inline `TextStyle(...)` anywhere else in the codebase.
class AppTextStyles {
  AppTextStyles._();

  // ── Display — Nunito, rounded, friendly, accessible ────────────────
  static const TextStyle displayXl = TextStyle(
    fontFamily: 'Georgia',
    fontFamilyFallback: ['Garamond', 'Times New Roman', 'serif'],
    fontSize: 40,
    fontWeight: FontWeight.w400,
    letterSpacing: -1.2,
  );

  static const TextStyle displayLg = TextStyle(
    fontFamily: 'Georgia',
    fontFamilyFallback: ['Garamond', 'Times New Roman', 'serif'],
    fontSize: 32,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.8,
  );

  static const TextStyle displayMd = TextStyle(
    fontFamily: 'Georgia',
    fontFamilyFallback: ['Garamond', 'Times New Roman', 'serif'],
    fontSize: 26,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.5,
  );

  static const TextStyle displaySm = TextStyle(
    fontFamily: 'Georgia',
    fontFamilyFallback: ['Garamond', 'Times New Roman', 'serif'],
    fontSize: 22,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.3,
  );

  // ── Title — Inter ──────────────────────────────────────────────────
  /// App bar title — prominent, bold, and easily readable for patients.
  static const TextStyle appBarTitle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 21,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
  );

  static const TextStyle titleLg = TextStyle(
    fontFamily: 'Inter',
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle titleMd = TextStyle(
    fontFamily: 'Inter',
    fontSize: 17,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle titleSm = TextStyle(
    fontFamily: 'Inter',
    fontSize: 15,
    fontWeight: FontWeight.w600,
  );

  // ── Body — Inter ───────────────────────────────────────────────────
  static const TextStyle bodyLg = TextStyle(
    fontFamily: 'Inter',
    fontSize: 17,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );

  static const TextStyle bodyMd = TextStyle(
    fontFamily: 'Inter',
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.55,
  );

  static const TextStyle bodySm = TextStyle(
    fontFamily: 'Inter',
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.55,
  );

  // ── UI ─────────────────────────────────────────────────────────────
  static const TextStyle button = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
  );

  static const TextStyle buttonSm = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle label = TextStyle(
    fontFamily: 'Inter',
    fontSize: 13,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle navLink = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );
}
