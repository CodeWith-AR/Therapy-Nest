import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';

/// Animated feedback overlay for correct/incorrect answers.
///
/// Displays a centered icon + text with animation:
/// - Correct: green checkmark with scale-in
/// - Incorrect: red X with gentle shake
/// - Streak: confetti effect at milestones
class FeedbackOverlay extends StatelessWidget {
  const FeedbackOverlay({
    super.key,
    required this.isCorrect,
    this.isStreakMilestone = false,
    this.streakCount = 0,
  });

  /// Whether the answer was correct.
  final bool isCorrect;

  /// Whether a streak milestone was hit (5, 10, ...).
  final bool isStreakMilestone;

  /// Current streak count.
  final int streakCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.3),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Icon ──────────────────────────────────────────────
            _buildIcon(),
            const SizedBox(height: AppDimens.d16),

            // ── Text ──────────────────────────────────────────────
            Text(
              isCorrect ? 'Great job!' : 'Let\'s try again',
              style: AppTextStyles.displaySm.copyWith(
                color: AppColors.onPrimary,
                fontWeight: FontWeight.w700,
              ),
            ).animate().fadeIn(duration: 200.ms),

            // ── Streak Badge ──────────────────────────────────────
            if (isStreakMilestone && streakCount > 0) ...[
              const SizedBox(height: AppDimens.d12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.d16,
                  vertical: AppDimens.d8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accentAmber,
                  borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.local_fire_department_rounded,
                      color: Colors.white,
                      size: AppDimens.iconSm,
                    ),
                    const SizedBox(width: AppDimens.d4),
                    Text(
                      '$streakCount in a row!',
                      style: AppTextStyles.buttonSm.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              )
                  .animate()
                  .scale(
                    duration: 400.ms,
                    curve: Curves.easeOutBack,
                  )
                  .then()
                  .shimmer(
                    duration: 800.ms,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    if (isCorrect) {
      return Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: AppColors.success,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.check_rounded,
          color: Colors.white,
          size: AppDimens.iconXl,
        ),
      )
          .animate()
          .scale(
            duration: 400.ms,
            curve: Curves.easeOutBack,
          )
          .then()
          .shimmer(
            duration: 600.ms,
            color: Colors.white.withValues(alpha: 0.3),
          );
    }

    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.error,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.close_rounded,
        color: Colors.white,
        size: AppDimens.iconXl,
      ),
    )
        .animate()
        .scale(duration: 300.ms, curve: Curves.easeOut)
        .then()
        .shake(hz: 4, duration: 400.ms);
  }
}
