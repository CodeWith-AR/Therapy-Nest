import 'package:flutter/material.dart';

/// All application colors — the single source of truth.
/// Automatically adapts to High Contrast (WCAG AAA 7:1) and Dark Mode.
class AppColors {
  AppColors._();

  /// Runtime accessibility flags synchronized from AccessibilityViewModel.
  static bool isHighContrast = false;
  static bool isDarkMode = false;

  // ── Brand ──────────────────────────────────────────────────────────
  static Color get primary => isHighContrast
      ? hcPrimary
      : (isDarkMode ? const Color(0xFFE08E74) : const Color(0xFFCC785C));
  static Color get primaryLight => isHighContrast
      ? hcPrimaryLight
      : (isDarkMode ? darkPrimaryLight : const Color(0xFFF9ECE6));
  static Color get primaryDark => isHighContrast
      ? (isDarkMode ? const Color(0xFF99CCFF) : const Color(0xFF002B7A))
      : (isDarkMode ? const Color(0xFFFFBCA7) : const Color(0xFFA9583E));
  static Color get primaryDisabled => isHighContrast
      ? (isDarkMode ? const Color(0xFF555555) : const Color(0xFF666666))
      : (isDarkMode ? const Color(0xFF423B36) : const Color(0xFFE6DFD8));

  // ── Surfaces ───────────────────────────────────────────────────────
  static Color get canvas => isHighContrast
      ? hcBackground
      : (isDarkMode ? darkCanvas : const Color(0xFFFAF9F5));
  static Color get surfaceSoft => isHighContrast
      ? hcBackground
      : (isDarkMode ? darkSurfaceElevated : const Color(0xFFF5F0E8));
  static Color get surfaceCard => isHighContrast
      ? hcSurface
      : (isDarkMode ? darkSurfaceCard : const Color(0xFFEFE9DE));
  static Color get surfaceDark => isHighContrast
      ? const Color(0xFF000000)
      : const Color(0xFF181715);
  static Color get surfaceDarkEl => isHighContrast
      ? const Color(0xFF111111)
      : const Color(0xFF252320);
  static Color get surfaceWhite => isHighContrast
      ? hcSurface
      : (isDarkMode ? darkSurfaceCard : const Color(0xFFFFFFFF));

  // ── Text ───────────────────────────────────────────────────────────
  static Color get ink => isHighContrast
      ? hcText
      : (isDarkMode ? darkInk : const Color(0xFF141413));
  static Color get bodyStrong => isHighContrast
      ? hcText
      : (isDarkMode ? darkInk : const Color(0xFF252523));
  static Color get body => isHighContrast
      ? hcText
      : (isDarkMode ? darkBody : const Color(0xFF3D3D3A));
  static Color get muted => isHighContrast
      ? hcMuted
      : (isDarkMode ? darkMuted : const Color(0xFF6C6A64));
  static Color get mutedSoft => isHighContrast
      ? hcMuted
      : (isDarkMode ? darkMutedSoft : const Color(0xFF8E8B82));
  static const Color onPrimary       = Color(0xFFFFFFFF);
  static const Color onDark          = Color(0xFFFAF9F5);
  static const Color onDarkSoft      = Color(0xFFA09D96);

  // ── Semantic ───────────────────────────────────────────────────────
  static Color get success => isHighContrast
      ? hcSuccess
      : (isDarkMode ? const Color(0xFF68D391) : const Color(0xFF5DB872));
  static Color get warning => isHighContrast
      ? const Color(0xFF8B5E00)
      : (isDarkMode ? const Color(0xFFECC94B) : const Color(0xFFD4A017));
  static Color get error => isHighContrast
      ? hcError
      : (isDarkMode ? const Color(0xFFE57373) : const Color(0xFFC64545));
  static Color get info => isHighContrast
      ? const Color(0xFF004455)
      : (isDarkMode ? const Color(0xFF4FD1C5) : const Color(0xFF5DB8A6));

  // ── Accents ────────────────────────────────────────────────────────
  static Color get accentTeal => isHighContrast
      ? const Color(0xFF004D40)
      : (isDarkMode ? const Color(0xFF4FD1C5) : const Color(0xFF5DB8A6));
  static Color get accentAmber => isHighContrast
      ? const Color(0xFF8B5E00)
      : (isDarkMode ? const Color(0xFFF6AD55) : const Color(0xFFE8A55A));
  static Color get accentGreen => isHighContrast
      ? hcSuccess
      : (isDarkMode ? const Color(0xFF68D391) : const Color(0xFF5DB872));
  static Color get accentPurple => isHighContrast
      ? const Color(0xFF4A148C)
      : (isDarkMode ? const Color(0xFFB794F4) : const Color(0xFF805AD5));

  // ── Borders ────────────────────────────────────────────────────────
  static Color get hairline => isHighContrast
      ? hcBorder
      : (isDarkMode ? darkHairline : const Color(0xFFE6DFD8));
  static Color get hairlineSoft => isHighContrast
      ? hcBorder
      : (isDarkMode ? darkHairlineSoft : const Color(0xFFEBE6DF));

  // ── High Contrast (WCAG AAA — 7:1 ratios) ────────────────────────
  static const Color hcPrimary       = Color(0xFF0040B0);
  static const Color hcPrimaryLight  = Color(0xFFCCDDFF);
  static const Color hcText          = Color(0xFF000000);
  static const Color hcBackground    = Color(0xFFFFFFFF);
  static const Color hcSurface       = Color(0xFFFFFFFF);
  static const Color hcError         = Color(0xFF9B0000);
  static const Color hcSuccess       = Color(0xFF006400);
  static const Color hcBorder        = Color(0xFF000000);
  static const Color hcMuted         = Color(0xFF222222);

  // ── Dark Theme ─────────────────────────────────────────────────────
  static const Color darkCanvas          = Color(0xFF181715);
  static const Color darkSurface         = Color(0xFF1A2744);
  static const Color darkSurfaceCard     = Color(0xFF252320);
  static const Color darkSurfaceElevated = Color(0xFF2A2826);
  static const Color darkInk             = Color(0xFFFAF9F5);
  static const Color darkBody            = Color(0xFFD0CFC8);
  static const Color darkMuted           = Color(0xFFA8A49C);
  static const Color darkMutedSoft       = Color(0xFF8E8B82);
  static const Color darkHairline        = Color(0xFF3D3B37);
  static const Color darkHairlineSoft    = Color(0xFF333130);
  static const Color darkPrimaryLight    = Color(0xFF3D2A1E);
}
