import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../viewmodels/onboarding_view_model.dart';

/// Onboarding Step 3 — Goals selection (multi-select tap cards).
class GoalsStep extends StatelessWidget {
  const GoalsStep({super.key});

  static const List<_GoalOption> _options = [
    _GoalOption('speaking', 'Speaking more clearly', Icons.record_voice_over_rounded),
    _GoalOption('understanding', 'Understanding conversations', Icons.hearing_rounded),
    _GoalOption('reading', 'Reading and writing', Icons.auto_stories_rounded),
    _GoalOption('memory', 'Memory and focus', Icons.psychology_rounded),
    _GoalOption('math', 'Everyday math (money, time)', Icons.calculate_rounded),
    _GoalOption('problem_solving', 'Problem solving', Icons.lightbulb_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OnboardingViewModel>();
    final selectedGoals = vm.goals;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.d24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppDimens.d24),
          Text(
            AppStrings.onboardingGoalsTitle,
            style: AppTextStyles.displaySm.copyWith(color: AppColors.ink),
          ),
          const SizedBox(height: AppDimens.d8),
          Text(
            'Select all that apply',
            style: AppTextStyles.bodyMd.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: AppDimens.d24),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: AppDimens.d12,
                mainAxisSpacing: AppDimens.d12,
                childAspectRatio: 0.92,
              ),
              itemCount: _options.length,
              itemBuilder: (context, index) {
                final option = _options[index];
                final isSelected = selectedGoals.contains(option.id);

                return _GoalCard(
                  option: option,
                  isSelected: isSelected,
                  onTap: () => context
                      .read<OnboardingViewModel>()
                      .toggleGoal(option.id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalOption {
  final String id;
  final String label;
  final IconData icon;

  const _GoalOption(this.id, this.label, this.icon);
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  final _GoalOption option;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.hairlineSoft,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.d12,
                  vertical: AppDimens.d8,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : AppColors.surfaceWhite,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        option.icon,
                        color: isSelected ? AppColors.primary : AppColors.muted,
                        size: AppDimens.iconMd,
                      ),
                    ),
                    const SizedBox(height: AppDimens.d8),
                    Text(
                      option.label,
                      style: AppTextStyles.label.copyWith(
                        color: isSelected ? AppColors.primary : AppColors.ink,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        fontSize: 12.5,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            if (isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
