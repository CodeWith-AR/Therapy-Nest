import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';

/// Compact card showing 🔥 flame icon + streak count in Nunito bold.
///
/// Uses [AppColors.accentAmber] for the flame. Shows motivational text
/// based on streak length.
class StreakCard extends StatelessWidget {
  const StreakCard({
    super.key,
    required this.currentStreak,
  });

  final int currentStreak;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.d16,
        vertical: AppDimens.d12,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.accentAmber.withValues(alpha: 0.15),
            AppColors.accentAmber.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(
          color: AppColors.accentAmber.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          // Flame icon
          Container(
            width: AppDimens.d48,
            height: AppDimens.d48,
            decoration: BoxDecoration(
              color: AppColors.accentAmber.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                AppStrings.homeStreakPrefix,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: AppDimens.d12),

          // Streak text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$currentStreak${AppStrings.homeStreakSuffix}',
                  style: AppTextStyles.displaySm.copyWith(
                    color: AppColors.ink,
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppDimens.d4),
                Text(
                  _motivationalText,
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.body,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String get _motivationalText {
    if (currentStreak >= 100) return 'Incredible dedication!';
    if (currentStreak >= 30) return 'A whole month — amazing!';
    if (currentStreak >= 7) return 'A full week of practice!';
    if (currentStreak >= 3) return 'Building momentum!';
    if (currentStreak >= 1) return 'Keep it going!';
    return AppStrings.encourageEverySession;
  }
}
