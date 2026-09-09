import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';

/// Rotated clinical tip card with lightbulb icon.
///
/// 10+ hardcoded tips, rotated daily based on `DateTime.now().day % tipCount`.
class TipOfDayCard extends StatelessWidget {
  const TipOfDayCard({super.key});

  static const _tips = [
    'Take breaks between exercises — your brain consolidates learning during rest.',
    'Practice at the same time each day to build a lasting habit.',
    'Even 5 minutes of practice makes a difference — consistency matters more than duration.',
    'Try speaking your answers aloud — engaging multiple senses strengthens neural pathways.',
    'Celebrate small wins! Each correct answer is a step forward.',
    'If an exercise feels challenging, that means your brain is working hard and growing.',
    'Hydrate before practice — your brain works better when well-hydrated.',
    'Review your progress weekly to see how far you\'ve come.',
    'Practice with a partner or caregiver for extra motivation and support.',
    'Getting enough sleep helps your brain consolidate what you\'ve practiced.',
    'Reduce distractions during practice for better focus and results.',
    'Mix up the domains you practice to keep your brain engaged and flexible.',
  ];

  @override
  Widget build(BuildContext context) {
    final tipIndex = DateTime.now().day % _tips.length;
    final tip = _tips[tipIndex];

    return Container(
      padding: const EdgeInsets.all(AppDimens.d16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryLight,
            AppColors.primaryLight.withValues(alpha: 0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Lightbulb icon
          Container(
            width: AppDimens.d40,
            height: AppDimens.d40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lightbulb_rounded,
              size: AppDimens.iconMd,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: AppDimens.d12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.homeTipOfDay,
                  style: AppTextStyles.titleSm.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppDimens.d4),
                Text(
                  tip,
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.bodyStrong,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
