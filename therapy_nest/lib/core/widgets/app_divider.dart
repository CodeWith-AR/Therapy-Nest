import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimens.dart';
import '../constants/app_text_styles.dart';

/// Styled divider with optional centered label.
class AppDivider extends StatelessWidget {
  const AppDivider({super.key, this.label, this.padding});

  final String? label;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    if (label == null) {
      return Padding(
        padding: padding ?? EdgeInsets.zero,
        child: Divider(color: AppColors.hairlineSoft, thickness: 1),
      );
    }

    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(vertical: AppDimens.d16),
      child: Row(
        children: [
          Expanded(
            child: Divider(color: AppColors.hairlineSoft, thickness: 1),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimens.d16),
            child: Text(
              label!,
              style: AppTextStyles.caption.copyWith(color: AppColors.muted),
            ),
          ),
          Expanded(
            child: Divider(color: AppColors.hairlineSoft, thickness: 1),
          ),
        ],
      ),
    );
  }
}
