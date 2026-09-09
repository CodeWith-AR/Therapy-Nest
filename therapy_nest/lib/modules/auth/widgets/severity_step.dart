import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../viewmodels/onboarding_view_model.dart';

/// Onboarding Step 2 — Severity self-assessment sliders (1–5 scale).
class SeverityStep extends StatelessWidget {
  const SeverityStep({super.key});

  static const List<_SeverityDomain> _domains = [
    _SeverityDomain('speech', 'Finding words when speaking', Icons.record_voice_over_rounded),
    _SeverityDomain('comprehension', 'Understanding what others say', Icons.hearing_rounded),
    _SeverityDomain('reading', 'Reading and writing', Icons.auto_stories_rounded),
    _SeverityDomain('memory', 'Memory and concentration', Icons.psychology_rounded),
    _SeverityDomain('math', 'Doing math or everyday tasks', Icons.calculate_rounded),
  ];

  static const List<String> _levelLabels = [
    'No difficulty',
    'Mild',
    'Moderate',
    'Significant',
    'Severe',
  ];

  @override
  Widget build(BuildContext context) {
    final severityMap =
        context.select<OnboardingViewModel, Map<String, int>>((vm) => vm.severityMap);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.d24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppDimens.d24),
          Text(
            AppStrings.onboardingSeverityTitle,
            style: AppTextStyles.displaySm.copyWith(color: AppColors.ink),
          ),
          const SizedBox(height: AppDimens.d8),
          Text(
            'Rate each area from 1 (no difficulty) to 5 (severe)',
            style: AppTextStyles.bodyMd.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: AppDimens.d20),
          Expanded(
            child: ListView.separated(
              itemCount: _domains.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppDimens.d16),
              itemBuilder: (context, index) {
                final domain = _domains[index];
                final value = severityMap[domain.id] ?? 3;

                return _SeveritySliderCard(
                  domain: domain,
                  value: value,
                  onChanged: (v) => context
                      .read<OnboardingViewModel>()
                      .setSeverity(domain.id, v),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SeverityDomain {
  final String id;
  final String label;
  final IconData icon;

  const _SeverityDomain(this.id, this.label, this.icon);
}

class _SeveritySliderCard extends StatelessWidget {
  const _SeveritySliderCard({
    required this.domain,
    required this.value,
    required this.onChanged,
  });

  final _SeverityDomain domain;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.d16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(domain.icon, size: AppDimens.iconMd, color: AppColors.primary),
              const SizedBox(width: AppDimens.d12),
              Expanded(
                child: Text(
                  domain.label,
                  style: AppTextStyles.titleSm.copyWith(color: AppColors.ink),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.d12),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.hairline,
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withValues(alpha: 0.15),
              trackHeight: 6,
              thumbShape:
                  const RoundSliderThumbShape(enabledThumbRadius: 10),
            ),
            child: Slider(
              value: value.toDouble(),
              min: 1,
              max: 5,
              divisions: 4,
              onChanged: (v) => onChanged(v.round()),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimens.d8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(5, (i) {
                final isActive = i + 1 == value;
                return Text(
                  '${i + 1}',
                  style: AppTextStyles.caption.copyWith(
                    color: isActive ? AppColors.primary : AppColors.muted,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: AppDimens.d4),
          Center(
            child: Text(
              SeverityStep._levelLabels[value - 1],
              style: AppTextStyles.label.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
