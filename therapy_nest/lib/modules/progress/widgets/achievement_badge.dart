import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/achievement_model.dart';

/// Grid-displayed achievement card.
///
/// Shows icon, name, description. Locked state (greyed out) vs.
/// unlocked ([AppColors.accentAmber] badge background with glow animation).
class AchievementBadge extends StatelessWidget {
  const AchievementBadge({
    super.key,
    required this.achievement,
  });

  final AchievementModel achievement;

  @override
  Widget build(BuildContext context) {
    final isUnlocked = achievement.isUnlocked;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: isUnlocked
            ? AppColors.accentAmber.withValues(alpha: 0.12)
            : AppColors.surfaceCard.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(
          color: isUnlocked
              ? AppColors.accentAmber.withValues(alpha: 0.4)
              : AppColors.hairlineSoft,
          width: 1.5,
        ),
        boxShadow: isUnlocked
            ? [
                BoxShadow(
                  color: AppColors.accentAmber.withValues(alpha: 0.15),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      padding: const EdgeInsets.all(AppDimens.d12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with glow for unlocked
          Container(
            width: AppDimens.d48,
            height: AppDimens.d48,
            decoration: BoxDecoration(
              color: isUnlocked
                  ? AppColors.accentAmber.withValues(alpha: 0.2)
                  : AppColors.surfaceSoft,
              shape: BoxShape.circle,
            ),
            child: Icon(
              achievement.iconData,
              size: AppDimens.iconLg,
              color: isUnlocked ? AppColors.accentAmber : AppColors.mutedSoft,
            ),
          ),
          const SizedBox(height: AppDimens.d8),

          // Name
          Text(
            achievement.name,
            style: AppTextStyles.titleSm.copyWith(
              color: isUnlocked ? AppColors.ink : AppColors.muted,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppDimens.d4),

          // Description
          Text(
            isUnlocked
                ? achievement.description
                : AppStrings.achievementsLocked,
            style: AppTextStyles.caption.copyWith(
              color: isUnlocked ? AppColors.body : AppColors.mutedSoft,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          // Unlocked badge
          if (isUnlocked) ...[
            const SizedBox(height: AppDimens.d4),
            Text(
              AppStrings.achievementsUnlocked,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.accentAmber,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
