import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimens.dart';
import '../constants/app_text_styles.dart';
import '../../data/models/achievement_definitions.dart';

/// Full-screen celebration overlay shown when an achievement is unlocked.
///
/// Displays:
/// - A confetti/particle animation background (using flutter_animate)
/// - The achievement badge (amber gradient circle with icon)
/// - Achievement name and description
/// - Auto-dismisses after 4 seconds or on tap
///
/// Respects [reduceMotion] — when true, shows a static badge with no
/// particle animation (accessibility compliance).
class CelebrationOverlay extends StatefulWidget {
  const CelebrationOverlay({
    super.key,
    required this.achievement,
    required this.onDismiss,
    this.reduceMotion = false,
  });

  /// The achievement that was just unlocked.
  final AchievementDef achievement;

  /// Called when the overlay is dismissed (tap or auto-timeout).
  final VoidCallback onDismiss;

  /// When true, skip particle animation for vestibular comfort.
  final bool reduceMotion;

  @override
  State<CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<CelebrationOverlay> {
  @override
  void initState() {
    super.initState();
    // Auto-dismiss after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) widget.onDismiss();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onDismiss,
      child: Material(
        color: Colors.black54,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // ── Confetti Particles ──────────────────────────────────
            if (!widget.reduceMotion) _ConfettiLayer(),

            // ── Achievement Badge ──────────────────────────────────
            _AchievementBadge(
              achievement: widget.achievement,
              reduceMotion: widget.reduceMotion,
            ),
          ],
        ),
      ),
    );
  }
}

/// Generates scattered confetti-like particles using flutter_animate.
class _ConfettiLayer extends StatelessWidget {
  final _random = Random();

  _ConfettiLayer();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final particles = List.generate(24, (i) => i);

    return SizedBox.expand(
      child: Stack(
        children: particles.map((i) {
          final left = _random.nextDouble() * size.width;
          final top = _random.nextDouble() * size.height * 0.6;
          final particleSize = _random.nextDouble() * 10 + 6;
          final delay = Duration(milliseconds: _random.nextInt(800));
          final color = _confettiColors[i % _confettiColors.length];
          final isCircle = _random.nextBool();

          return Positioned(
            left: left,
            top: top,
            child: Container(
              width: particleSize,
              height: isCircle ? particleSize : particleSize * 0.4,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(
                  isCircle ? AppDimens.radiusFull : AppDimens.radiusXs,
                ),
              ),
            )
                .animate()
                .fadeIn(duration: 300.ms, delay: delay)
                .scale(
                  begin: const Offset(0, 0),
                  end: const Offset(1, 1),
                  duration: 400.ms,
                  delay: delay,
                  curve: Curves.easeOutBack,
                )
                .then()
                .moveY(
                  begin: 0,
                  end: size.height * 0.6,
                  duration: 2000.ms,
                  curve: Curves.easeIn,
                )
                .rotate(
                  begin: 0,
                  end: _random.nextDouble() * 2 - 1,
                  duration: 2000.ms,
                )
                .fadeOut(
                  duration: 600.ms,
                  delay: 1400.ms,
                ),
          );
        }).toList(),
      ),
    );
  }

  static final List<Color> _confettiColors = [
    AppColors.accentAmber,
    AppColors.accentGreen,
    AppColors.accentTeal,
    AppColors.accentPurple,
    AppColors.primary,
    AppColors.success,
  ];
}

/// The centred badge showing icon, name, and description.
class _AchievementBadge extends StatelessWidget {
  const _AchievementBadge({
    required this.achievement,
    required this.reduceMotion,
  });

  final AchievementDef achievement;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    final badge = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Badge Circle ───────────────────────────────────────────
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.accentAmber,
                Color(0xFFD4880F), // deeper gold
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x40E8A55A),
                blurRadius: 32,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Icon(
            achievement.iconData,
            size: AppDimens.d48,
            color: AppColors.onDark,
          ),
        ),
        const SizedBox(height: AppDimens.d24),

        // ── Title ──────────────────────────────────────────────────
        Text(
          'Achievement Unlocked! 🏆',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.accentAmber,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: AppDimens.d8),

        Text(
          achievement.name,
          style: AppTextStyles.displaySm.copyWith(
            color: AppColors.onDark,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimens.d8),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.d40),
          child: Text(
            achievement.description,
            style: AppTextStyles.bodyMd.copyWith(
              color: AppColors.onDark.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: AppDimens.d24),

        // ── Tap to dismiss ─────────────────────────────────────────
        Text(
          'Tap to continue',
          style: AppTextStyles.bodySm.copyWith(
            color: AppColors.onDark.withValues(alpha: 0.5),
          ),
        ),
      ],
    );

    if (reduceMotion) return badge;

    // With animation: scale in + subtle shimmer
    return badge
        .animate()
        .scale(
          begin: const Offset(0.5, 0.5),
          end: const Offset(1, 1),
          duration: 600.ms,
          curve: Curves.easeOutBack,
        )
        .fadeIn(duration: 400.ms)
        .then(delay: 200.ms)
        .shimmer(
          duration: 1200.ms,
          color: Colors.white.withValues(alpha: 0.15),
        );
  }
}
