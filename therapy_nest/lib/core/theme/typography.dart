import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

/// Maps [AppTextStyles] design tokens into Flutter's [TextTheme].
TextTheme buildTextTheme({
  bool highContrast = false,
  bool isDark = false,
}) {
  final bodyColor = highContrast
      ? (isDark ? Colors.white : AppColors.hcText)
      : (isDark ? AppColors.darkBody : const Color(0xFF3D3D3A));
  final displayColor = highContrast
      ? (isDark ? Colors.white : AppColors.hcText)
      : (isDark ? AppColors.darkInk : const Color(0xFF141413));

  return const TextTheme(
    // Display
    displayLarge:  AppTextStyles.displayXl,
    displayMedium: AppTextStyles.displayLg,
    displaySmall:  AppTextStyles.displayMd,

    // Headline
    headlineLarge:  AppTextStyles.displaySm,
    headlineMedium: AppTextStyles.titleLg,
    headlineSmall:  AppTextStyles.titleMd,

    // Title
    titleLarge:  AppTextStyles.titleLg,
    titleMedium: AppTextStyles.titleMd,
    titleSmall:  AppTextStyles.titleSm,

    // Body
    bodyLarge:  AppTextStyles.bodyLg,
    bodyMedium: AppTextStyles.bodyMd,
    bodySmall:  AppTextStyles.bodySm,

    // Label
    labelLarge:  AppTextStyles.button,
    labelMedium: AppTextStyles.label,
    labelSmall:  AppTextStyles.caption,
  ).apply(
    bodyColor: bodyColor,
    displayColor: displayColor,
  );
}

