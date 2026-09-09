import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/assessment_result_model.dart';
import '../viewmodels/assessment_view_model.dart';

/// Per-domain result card for the assessment completion page.
///
/// Shows domain name, a friendly progress bar, and fraction label.
/// Uses warm, encouraging colors — avoids numeric scores that
/// could feel discouraging for aphasia patients.
class ScoreSummaryCard extends StatelessWidget {
  const ScoreSummaryCard({
    super.key,
    required this.result,
  });

  final AssessmentResultModel result;

  @override
  Widget build(BuildContext context) {
    final domainName = AssessmentViewModel.domainDisplayName(result.domain);
    final fraction = result.skipped ? 0.0 : result.scoreFraction;
    final color = _colorForScore(fraction);

    return Container(
      padding: const EdgeInsets.all(AppDimens.d16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(color: AppColors.hairlineSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    _iconForDomain(result.domain),
                    size: AppDimens.iconMd,
                    color: color,
                  ),
                  const SizedBox(width: AppDimens.d8),
                  Text(
                    domainName,
                    style:
                        AppTextStyles.titleSm.copyWith(color: AppColors.ink),
                  ),
                ],
              ),
              if (result.skipped)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.d8,
                    vertical: AppDimens.d4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.mutedSoft.withValues(alpha: 0.2),
                    borderRadius:
                        BorderRadius.circular(AppDimens.radiusFull),
                  ),
                  child: Text(
                    'Skipped',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.muted),
                  ),
                )
              else
                Text(
                  '${result.correctCount}/${result.totalItems}',
                  style:
                      AppTextStyles.caption.copyWith(color: AppColors.muted),
                ),
            ],
          ),
          const SizedBox(height: AppDimens.d12),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimens.radiusFull),
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: AppDimens.d8,
              backgroundColor: AppColors.hairlineSoft,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  Color _colorForScore(double fraction) {
    if (fraction >= 0.7) return AppColors.success;
    if (fraction >= 0.4) return AppColors.accentAmber;
    return AppColors.warning;
  }

  IconData _iconForDomain(String domain) {
    switch (domain) {
      case 'language':
        return Icons.translate_rounded;
      case 'reading_writing':
        return Icons.auto_stories_rounded;
      case 'memory':
        return Icons.psychology_rounded;
      case 'attention':
        return Icons.center_focus_strong_rounded;
      case 'speech':
        return Icons.mic_rounded;
      case 'math':
        return Icons.calculate_rounded;
      default:
        return Icons.quiz_rounded;
    }
  }
}
