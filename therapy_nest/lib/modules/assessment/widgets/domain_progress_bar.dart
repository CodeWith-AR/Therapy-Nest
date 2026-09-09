import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';

/// Shows the current domain name and item progress (e.g. "Language 3/10")
/// with an animated progress bar.
class DomainProgressBar extends StatelessWidget {
  const DomainProgressBar({
    super.key,
    required this.domainName,
    required this.currentItem,
    required this.totalItems,
    required this.progress,
  });

  final String domainName;
  final int currentItem;
  final int totalItems;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              domainName,
              style: AppTextStyles.titleSm.copyWith(color: AppColors.primary),
            ),
            Text(
              '$currentItem / $totalItems',
              style: AppTextStyles.caption.copyWith(color: AppColors.muted),
            ),
          ],
        ),
        const SizedBox(height: AppDimens.d8),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppDimens.radiusFull),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            height: AppDimens.d8,
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.hairlineSoft,
              valueColor:
                  AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }
}
