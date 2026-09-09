import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../viewmodels/onboarding_view_model.dart';

/// Onboarding Step 4 — Practice schedule (frequency + duration).
class ScheduleStep extends StatelessWidget {
  const ScheduleStep({super.key});

  static const List<_ScheduleOption> _frequencyOptions = [
    _ScheduleOption(7, 'Every day', Icons.calendar_today_rounded),
    _ScheduleOption(5, '5 days a week', Icons.date_range_rounded),
    _ScheduleOption(3, '3 days a week', Icons.event_rounded),
    _ScheduleOption(0, 'Whenever I can', Icons.schedule_rounded),
  ];

  static const List<_ScheduleOption> _durationOptions = [
    _ScheduleOption(10, '10 minutes', Icons.timer_rounded),
    _ScheduleOption(20, '20 minutes', Icons.timer_rounded),
    _ScheduleOption(30, '30 minutes', Icons.timer_rounded),
    _ScheduleOption(0, 'Flexible', Icons.all_inclusive_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final sessionsPerWeek = context.select<OnboardingViewModel, int>(
        (vm) => vm.sessionsPerWeek);
    final minutesPerSession = context.select<OnboardingViewModel, int>(
        (vm) => vm.minutesPerSession);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.d24,
        vertical: AppDimens.d8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppDimens.d16),
          Text(
            AppStrings.onboardingScheduleTitle,
            style: AppTextStyles.displaySm.copyWith(color: AppColors.ink),
          ),
          const SizedBox(height: AppDimens.d24),

          // ── Frequency ──────────────────────────────────────────
          Text(
            'How often would you like to practice?',
            style: AppTextStyles.titleSm.copyWith(color: AppColors.bodyStrong),
          ),
          const SizedBox(height: AppDimens.d12),
          ..._frequencyOptions.map((option) => Padding(
                padding: const EdgeInsets.only(bottom: AppDimens.d8),
                child: _OptionTile(
                  option: option,
                  isSelected: sessionsPerWeek == option.value,
                  onTap: () => context
                      .read<OnboardingViewModel>()
                      .setSchedule(sessionsPerWeek: option.value),
                ),
              )),

          const SizedBox(height: AppDimens.d20),

          // ── Duration ───────────────────────────────────────────
          Text(
            'How long per session?',
            style: AppTextStyles.titleSm.copyWith(color: AppColors.bodyStrong),
          ),
          const SizedBox(height: AppDimens.d12),
          ..._durationOptions.map((option) => Padding(
                padding: const EdgeInsets.only(bottom: AppDimens.d8),
                child: _OptionTile(
                  option: option,
                  isSelected: minutesPerSession == option.value,
                  onTap: () => context
                      .read<OnboardingViewModel>()
                      .setSchedule(minutesPerSession: option.value),
                ),
              )),
          const SizedBox(height: AppDimens.d16),
        ],
      ),
    );
  }
}

class _ScheduleOption {
  final int value;
  final String label;
  final IconData icon;

  const _ScheduleOption(this.value, this.label, this.icon);
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  final _ScheduleOption option;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.d16,
          vertical: AppDimens.d12,
        ),
        constraints: BoxConstraints(minHeight: AppDimens.touchSmall),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.hairlineSoft,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              option.icon,
              size: AppDimens.iconMd,
              color: isSelected ? AppColors.primary : AppColors.muted,
            ),
            const SizedBox(width: AppDimens.d12),
            Expanded(
              child: Text(
                option.label,
                style: AppTextStyles.bodyMd.copyWith(
                  color: isSelected ? AppColors.primary : AppColors.ink,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w400,
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
