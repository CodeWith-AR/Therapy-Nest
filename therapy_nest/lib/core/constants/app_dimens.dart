/// All application dimensions — spacing, border radii, touch targets, icons.
/// No hardcoded numeric values anywhere else in the codebase.
class AppDimens {
  AppDimens._();

  // ── Spacing ────────────────────────────────────────────────────────
  static const double d4  = 4;
  static const double d8  = 8;
  static const double d12 = 12;
  static const double d16 = 16;
  static const double d20 = 20;
  static const double d24 = 24;
  static const double d32 = 32;
  static const double d40 = 40;
  static const double d48 = 48;
  static const double d64 = 64;
  static const double d96 = 96;

  // ── Border Radius ──────────────────────────────────────────────────
  static const double radiusXs   = 4;
  static const double radiusSm   = 8;
  static const double radiusMd   = 12;
  static const double radiusLg   = 20;
  static const double radiusXl   = 28;
  static const double radiusFull = 999;

  // ── Touch Targets (WCAG / motor-impaired accessibility) ────────────
  static double touchScale = 1.0;
  static const double touchMinBase    = 64;  // primary therapy buttons
  static const double touchNormalBase = 56;  // standard interactive elements
  static const double touchSmallBase  = 48;  // secondary actions

  static double get touchMin    => touchMinBase * touchScale;
  static double get touchNormal => touchNormalBase * touchScale;
  static double get touchSmall  => touchSmallBase * touchScale;

  // ── Icon Sizes ─────────────────────────────────────────────────────
  static const double iconSm = 20;
  static const double iconMd = 24;
  static const double iconLg = 32;
  static const double iconXl = 48;
}
