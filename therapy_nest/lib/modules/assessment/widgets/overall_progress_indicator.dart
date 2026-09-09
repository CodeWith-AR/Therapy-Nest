import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/repositories/assessment_repository.dart';
import '../viewmodels/assessment_view_model.dart';

/// Segmented bar showing completion across all 6 domains.
/// Completed domains are filled, current is partially filled,
/// future domains are empty.
class OverallProgressIndicator extends StatelessWidget {
  const OverallProgressIndicator({
    super.key,
    required this.currentDomainIndex,
    required this.totalDomains,
    required this.currentDomainProgress,
  });

  final int currentDomainIndex;
  final int totalDomains;
  final double currentDomainProgress;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: List.generate(totalDomains, (index) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: index < totalDomains - 1 ? AppDimens.d4 : 0,
                ),
                child: _SegmentBar(
                  progress: index < currentDomainIndex
                      ? 1.0
                      : index == currentDomainIndex
                          ? currentDomainProgress
                          : 0.0,
                  isActive: index == currentDomainIndex,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: AppDimens.d4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(totalDomains, (index) {
            final domain = AssessmentRepository.domainOrder[index];
            final isActive = index == currentDomainIndex;
            final isDone = index < currentDomainIndex;
            return Expanded(
              child: Text(
                AssessmentViewModel.domainDisplayName(domain)
                    .substring(0, 3)
                    .toUpperCase(),
                textAlign: TextAlign.center,
                style: AppTextStyles.caption.copyWith(
                  color: isDone
                      ? AppColors.success
                      : isActive
                          ? AppColors.primary
                          : AppColors.mutedSoft,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _SegmentBar extends StatelessWidget {
  const _SegmentBar({
    required this.progress,
    required this.isActive,
  });

  final double progress;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimens.radiusFull),
      child: SizedBox(
        height: isActive ? 6.0 : 4.0,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.hairlineSoft,
            valueColor: AlwaysStoppedAnimation<Color>(
              progress >= 1.0 ? AppColors.success : AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}
