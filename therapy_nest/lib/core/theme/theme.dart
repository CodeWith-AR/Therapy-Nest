import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimens.dart';
import '../constants/app_text_styles.dart';
import 'typography.dart';

/// Builds the single [ThemeData] consumed by [MaterialApp].
/// All global styles for buttons, inputs, app bars, etc. are defined here.
///
/// When [highContrast] is true, swaps to the WCAG AAA high-contrast palette
/// (7:1 minimum contrast ratios) for improved readability.
///
/// When [touchTargetScale] is provided, scales the minimum tap target sizing
/// of all interactive buttons and icons.
ThemeData buildAppTheme({
  bool highContrast = false,
  bool isDark = false,
  double touchTargetScale = 1.0,
}) {
  if (isDark) {
    return _buildDarkTheme(
      highContrast: highContrast,
      touchTargetScale: touchTargetScale,
    );
  }
  return _buildLightTheme(
    highContrast: highContrast,
    touchTargetScale: touchTargetScale,
  );
}

// ── Light Theme ──────────────────────────────────────────────────────
ThemeData _buildLightTheme({
  bool highContrast = false,
  double touchTargetScale = 1.0,
}) {
  final textTheme = buildTextTheme(highContrast: highContrast, isDark: false);

  // Resolve colours based on contrast mode (explicitly light)
  final primary = highContrast ? AppColors.hcPrimary : const Color(0xFFCC785C);
  final primaryLight =
      highContrast ? AppColors.hcPrimaryLight : const Color(0xFFF7EBE6);
  const onPrimary = AppColors.onPrimary;
  final surface = highContrast ? AppColors.hcSurface : const Color(0xFFFFFFFF);
  final ink = highContrast ? AppColors.hcText : const Color(0xFF141413);
  final muted = highContrast ? AppColors.hcMuted : const Color(0xFF828179);
  final mutedSoft = highContrast ? AppColors.hcMuted : const Color(0xFFB4B2A9);
  final canvas = highContrast ? AppColors.hcBackground : const Color(0xFFFAF9F5);
  final error = highContrast ? AppColors.hcError : const Color(0xFFD9534F);
  final hairline = highContrast ? AppColors.hcBorder : const Color(0xFFE6E4DD);
  final hairlineSoft =
      highContrast ? AppColors.hcBorder : const Color(0xFFF0EFEB);
  final surfaceSoft =
      highContrast ? AppColors.hcBackground : const Color(0xFFF0EFEB);
  final primaryDisabled =
      highContrast ? AppColors.hcPrimary : const Color(0xFFE6DFD8);
  final buttonHeight = (AppDimens.touchNormal * touchTargetScale).clamp(40.0, 80.0);

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: canvas,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      onPrimary: onPrimary,
      surface: surface,
      onSurface: ink,
      onSurfaceVariant: muted,
      error: error,
    ),
    textTheme: textTheme,
    fontFamily: 'Inter',

    // ── AppBar ─────────────────────────────────────────────────────
    appBarTheme: AppBarTheme(
      backgroundColor: surface,
      foregroundColor: ink,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      centerTitle: true,
      titleTextStyle: AppTextStyles.appBarTitle.copyWith(color: ink),
      iconTheme: IconThemeData(
        color: ink,
        size: AppDimens.iconMd,
      ),
    ),

    // ── Elevated Button ────────────────────────────────────────────
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: onPrimary,
        disabledBackgroundColor: primaryDisabled,
        disabledForegroundColor: onPrimary.withValues(alpha: 0.7),
        minimumSize: Size(0, buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          side: highContrast ? BorderSide(color: hairline, width: 2.0) : BorderSide.none,
        ),
        textStyle: AppTextStyles.button,
        elevation: 0,
      ),
    ),

    // ── Outlined Button ────────────────────────────────────────────
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primary,
        minimumSize: Size(0, buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        ),
        side: BorderSide(color: hairline, width: highContrast ? 2.5 : 1.5),
        textStyle: AppTextStyles.button,
      ),
    ),

    // ── Icon Button ────────────────────────────────────────────────
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        minimumSize: Size(AppDimens.touchNormal * touchTargetScale, AppDimens.touchNormal * touchTargetScale),
      ),
    ),

    // ── Text Button ────────────────────────────────────────────────
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primary,
        minimumSize: Size(48 * touchTargetScale, buttonHeight * 0.85),
        textStyle: AppTextStyles.buttonSm,
      ),
    ),

    // ── Input Decoration ───────────────────────────────────────────
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppDimens.d16,
        vertical: AppDimens.d16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        borderSide: BorderSide(color: hairline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        borderSide: BorderSide(color: hairline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        borderSide: BorderSide(color: primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        borderSide: BorderSide(color: error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        borderSide: BorderSide(color: error, width: 2),
      ),
      labelStyle: AppTextStyles.label.copyWith(color: muted),
      hintStyle: AppTextStyles.bodyMd.copyWith(color: mutedSoft),
      errorStyle: AppTextStyles.caption.copyWith(color: error),
    ),

    // ── Card ───────────────────────────────────────────────────────
    cardTheme: CardThemeData(
      color: surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        side: BorderSide(color: hairlineSoft),
      ),
    ),

    // ── Divider ────────────────────────────────────────────────────
    dividerTheme: DividerThemeData(
      color: hairlineSoft,
      thickness: 1,
      space: 0,
    ),

    // ── Bottom Sheet ───────────────────────────────────────────────
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimens.radiusXl),
        ),
      ),
    ),

    // ── Chip ───────────────────────────────────────────────────────
    chipTheme: ChipThemeData(
      backgroundColor: surfaceSoft,
      selectedColor: primaryLight,
      labelStyle: AppTextStyles.label,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusFull),
      ),
      side: BorderSide.none,
    ),

    // ── Dialog & Menus ─────────────────────────────────────────────
    dialogTheme: DialogThemeData(
      backgroundColor: surface,
      titleTextStyle: AppTextStyles.titleLg.copyWith(color: ink),
      contentTextStyle: AppTextStyles.bodyMd.copyWith(color: ink),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: surface,
      textStyle: AppTextStyles.bodyMd.copyWith(color: ink),
    ),
    listTileTheme: ListTileThemeData(
      textColor: ink,
      iconColor: muted,
    ),
  );
}

// ── Dark Theme ───────────────────────────────────────────────────────
ThemeData _buildDarkTheme({
  bool highContrast = false,
  double touchTargetScale = 1.0,
}) {
  final textTheme = buildTextTheme(highContrast: highContrast, isDark: true);

  final primary = highContrast ? const Color(0xFF66B2FF) : const Color(0xFFE08E74);
  const onPrimary = AppColors.onPrimary;
  final surface = highContrast ? Colors.black : AppColors.darkSurfaceCard;
  final ink = highContrast ? Colors.white : AppColors.darkInk;
  final muted = highContrast ? const Color(0xFFCCCCCC) : AppColors.darkMuted;
  final mutedSoft = highContrast ? const Color(0xFFAAAAAA) : AppColors.darkMutedSoft;
  final canvas = highContrast ? Colors.black : AppColors.darkCanvas;
  final error = highContrast ? AppColors.hcError : const Color(0xFFE57373);
  final hairline = highContrast ? Colors.white : AppColors.darkHairline;
  final hairlineSoft = highContrast ? Colors.white70 : AppColors.darkHairlineSoft;
  final surfaceSoft = highContrast ? const Color(0xFF1A1A1A) : AppColors.darkSurfaceElevated;
  final primaryLight = highContrast ? const Color(0xFF003366) : AppColors.darkPrimaryLight;
  final primaryDisabled = highContrast ? const Color(0xFF444444) : const Color(0xFF423B36);
  final buttonHeight = (AppDimens.touchNormal * touchTargetScale).clamp(40.0, 80.0);

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: canvas,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.dark,
      primary: primary,
      onPrimary: onPrimary,
      surface: surface,
      onSurface: ink,
      onSurfaceVariant: muted,
      error: error,
    ),
    textTheme: textTheme,
    fontFamily: 'Inter',

    appBarTheme: AppBarTheme(
      backgroundColor: canvas,
      foregroundColor: ink,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      centerTitle: true,
      titleTextStyle: AppTextStyles.appBarTitle.copyWith(color: ink),
      iconTheme: IconThemeData(
        color: ink,
        size: AppDimens.iconMd,
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: onPrimary,
        disabledBackgroundColor: primaryDisabled,
        disabledForegroundColor: onPrimary.withValues(alpha: 0.5),
        minimumSize: Size(0, buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          side: highContrast ? BorderSide(color: hairline, width: 2.0) : BorderSide.none,
        ),
        textStyle: AppTextStyles.button,
        elevation: 0,
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primary,
        minimumSize: Size(0, buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        ),
        side: BorderSide(color: hairline, width: highContrast ? 2.5 : 1.5),
        textStyle: AppTextStyles.button,
      ),
    ),

    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        minimumSize: Size(AppDimens.touchNormal * touchTargetScale, AppDimens.touchNormal * touchTargetScale),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primary,
        textStyle: AppTextStyles.buttonSm,
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppDimens.d16,
        vertical: AppDimens.d16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        borderSide: BorderSide(color: hairline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        borderSide: BorderSide(color: hairline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        borderSide: BorderSide(color: primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        borderSide: BorderSide(color: error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        borderSide: BorderSide(color: error, width: 2),
      ),
      labelStyle: AppTextStyles.label.copyWith(color: muted),
      hintStyle: AppTextStyles.bodyMd.copyWith(color: mutedSoft),
      errorStyle: AppTextStyles.caption.copyWith(color: error),
    ),

    cardTheme: CardThemeData(
      color: surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        side: BorderSide(color: hairlineSoft),
      ),
    ),

    dividerTheme: DividerThemeData(
      color: hairlineSoft,
      thickness: 1,
      space: 0,
    ),

    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimens.radiusXl),
        ),
      ),
    ),

    chipTheme: ChipThemeData(
      backgroundColor: surfaceSoft,
      selectedColor: primaryLight,
      labelStyle: AppTextStyles.label,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusFull),
      ),
      side: BorderSide.none,
    ),

    // ── Dialog & Menus ─────────────────────────────────────────────
    dialogTheme: DialogThemeData(
      backgroundColor: surface,
      titleTextStyle: AppTextStyles.titleLg.copyWith(color: ink),
      contentTextStyle: AppTextStyles.bodyMd.copyWith(color: ink),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: surface,
      textStyle: AppTextStyles.bodyMd.copyWith(color: ink),
    ),
    listTileTheme: ListTileThemeData(
      textColor: ink,
      iconColor: muted,
    ),
  );
}
