import 'package:flutter/material.dart';

/// All motion tokens — the single source of truth for animation durations,
/// curves, and transition constants.
///
/// **Rule**: No raw `Duration(...)` or `Curves.*` anywhere else in the codebase.
/// Always reference [AppMotion] constants.
class AppMotion {
  AppMotion._();

  // ── Durations ──────────────────────────────────────────────────────
  /// Ultra-fast micro-feedback (icon bounce, tap highlight).
  static const Duration dFast = Duration(milliseconds: 120);

  /// Standard widget transitions (fade, scale, slide).
  static const Duration dMedium = Duration(milliseconds: 250);

  /// Page-level transitions and overlays.
  static const Duration dSlow = Duration(milliseconds: 400);

  /// Heavy overlay / bottom-sheet entrance.
  static const Duration dSheet = Duration(milliseconds: 350);

  /// Nav icon bounce animation.
  static const Duration navBounce = Duration(milliseconds: 200);

  /// Feedback delay after answering (assessment items).
  static const Duration feedbackDelay = Duration(milliseconds: 800);

  // ── Curves ─────────────────────────────────────────────────────────
  /// Default ease for most enter transitions.
  static const Curve easeDefault = Curves.easeOutCubic;

  /// Bouncy curve for nav icons and playful interactions.
  static const Curve bounceCurve = Curves.easeOutBack;

  /// Smooth decelerate for slide-in transitions.
  static const Curve decelerate = Curves.decelerate;

  /// Standard ease-in-out for symmetric transitions.
  static const Curve easeInOut = Curves.easeInOut;

  /// Exit curve — elements leaving the screen.
  static const Curve easeIn = Curves.easeIn;

  // ── Page Transition ────────────────────────────────────────────────
  /// Duration used for page-level route transitions.
  static const Duration pageTransition = Duration(milliseconds: 300);

  /// Fade transition duration for route changes.
  static const Duration fadeTransition = Duration(milliseconds: 250);

  // ── Shared Axis ────────────────────────────────────────────────────
  /// Duration for SharedAxisTransition between nav branches.
  static const Duration sharedAxis = Duration(milliseconds: 300);
}
