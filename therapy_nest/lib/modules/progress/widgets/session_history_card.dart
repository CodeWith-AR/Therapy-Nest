import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/repositories/progress_repository.dart';

/// Compact card for a past session: date, domain chips, accuracy %, duration.
///
/// Uses positive framing only — shows correct count, never wrong count.
class SessionHistoryCard extends StatelessWidget {
  const SessionHistoryCard({
    super.key,
    required this.session,
  });

  final SessionHistoryModel session;

  static const _domainLabels = {
    'language': 'Language',
    'memory': 'Memory',
    'attention': 'Attention',
    'speech': 'Speech',
    'reading_writing': 'R&W',
    'math': 'Math',
  };

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('MMM d, yyyy').format(session.date);
    final timeStr = DateFormat('h:mm a').format(session.date);

    return Container(
      padding: const EdgeInsets.all(AppDimens.d12),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(color: AppColors.hairlineSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dateStr,
                style: AppTextStyles.titleSm.copyWith(color: AppColors.ink),
              ),
              Text(
                timeStr,
                style: AppTextStyles.caption.copyWith(color: AppColors.muted),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.d8),

          // Domain chips
          Wrap(
            spacing: AppDimens.d4,
            runSpacing: AppDimens.d4,
            children: session.domains.map((d) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.d8,
                  vertical: AppDimens.d4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                ),
                child: Text(
                  _domainLabels[d] ?? d,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppDimens.d8),

          // Stats row
          Row(
            children: [
              // Accuracy pill (e.g. 85%)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.d8,
                  vertical: AppDimens.d4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accentGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                  border: Border.all(
                    color: AppColors.accentGreen.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      size: 14,
                      color: AppColors.accentGreen,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${session.accuracy.toStringAsFixed(0)}%',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.accentGreen,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimens.d12),

              // Duration
              Icon(Icons.schedule_rounded,
                  size: AppDimens.iconSm, color: AppColors.muted),
              const SizedBox(width: AppDimens.d4),
              Text(
                session.formattedDuration,
                style: AppTextStyles.bodySm.copyWith(color: AppColors.body),
              ),
              const Spacer(),

              // Positive result
              Flexible(
                child: Text(
                  session.positiveResultText,
                  style: AppTextStyles.caption.copyWith(color: AppColors.body),
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
