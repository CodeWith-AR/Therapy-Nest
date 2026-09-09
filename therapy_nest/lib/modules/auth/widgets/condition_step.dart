import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../viewmodels/onboarding_view_model.dart';

/// Onboarding Step 1 — Condition selection (multi-select cards).
class ConditionStep extends StatelessWidget {
  const ConditionStep({super.key});

  static const List<_ConditionOption> _options = [
    _ConditionOption('stroke', 'Stroke Survivor', Icons.favorite_rounded),
    _ConditionOption('aphasia', 'Aphasia', Icons.chat_bubble_rounded),
    _ConditionOption('tbi', 'Traumatic Brain Injury (TBI)', Icons.psychology_rounded),
    _ConditionOption('dementia', 'Dementia / Memory Concerns', Icons.memory_rounded),
    _ConditionOption('parkinsons', 'Parkinson\'s Disease', Icons.accessibility_new_rounded),
    _ConditionOption('other', 'Other / Prefer Not to Say', Icons.more_horiz_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OnboardingViewModel>();
    final selectedConditions = vm.conditions;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.d24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppDimens.d24),
          Text(
            AppStrings.onboardingConditionTitle,
            style: AppTextStyles.displaySm.copyWith(color: AppColors.ink),
          ),
          const SizedBox(height: AppDimens.d8),
          Text(
            'Select all that apply',
            style: AppTextStyles.bodyMd.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: AppDimens.d24),
          Expanded(
            child: ListView.separated(
              itemCount: _options.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppDimens.d12),
              itemBuilder: (context, index) {
                final option = _options[index];
                final isSelected =
                    selectedConditions.contains(option.id);

                return _ConditionCard(
                  option: option,
                  isSelected: isSelected,
                  onTap: () => context
                      .read<OnboardingViewModel>()
                      .toggleCondition(option.id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ConditionOption {
  final String id;
  final String label;
  final IconData icon;

  const _ConditionOption(this.id, this.label, this.icon);
}

class _ConditionCard extends StatelessWidget {
  const _ConditionCard({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  final _ConditionOption option;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(AppDimens.d16),
        constraints: BoxConstraints(minHeight: AppDimens.touchMin),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.hairlineSoft,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: AppDimens.d48,
              height: AppDimens.d48,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : AppColors.surfaceWhite,
                borderRadius: BorderRadius.circular(AppDimens.radiusMd),
              ),
              child: Icon(
                option.icon,
                color: isSelected ? AppColors.primary : AppColors.muted,
                size: AppDimens.iconLg,
              ),
            ),
            const SizedBox(width: AppDimens.d16),
            Expanded(
              child: Text(
                option.label,
                style: AppTextStyles.titleSm.copyWith(
                  color: isSelected ? AppColors.primary : AppColors.ink,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: AppColors.primary,
                size: AppDimens.iconMd,
              ),
          ],
        ),
      ),
    );
  }
}
