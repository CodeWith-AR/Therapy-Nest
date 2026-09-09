import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';

/// Full-width, 64dp tall option button with correct/incorrect feedback.
///
/// When [feedbackState] is set, the button shows a green (correct)
/// or red (incorrect) flash animation before resetting.
class OptionButton extends StatelessWidget {
  const OptionButton({
    super.key,
    required this.label,
    required this.onTap,
    this.feedbackState,
    this.isDisabled = false,
  });

  final String label;
  final VoidCallback onTap;

  /// null = no feedback, true = correct, false = incorrect.
  final bool? feedbackState;

  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color borderColor;
    Color textColor;
    IconData? trailingIcon;

    if (feedbackState == true) {
      backgroundColor = AppColors.success.withValues(alpha: 0.12);
      borderColor = AppColors.success;
      textColor = AppColors.success;
      trailingIcon = Icons.check_circle_rounded;
    } else if (feedbackState == false) {
      backgroundColor = AppColors.error.withValues(alpha: 0.08);
      borderColor = AppColors.error.withValues(alpha: 0.4);
      textColor = AppColors.error;
      trailingIcon = Icons.cancel_rounded;
    } else {
      backgroundColor = AppColors.surfaceWhite;
      borderColor = AppColors.hairline;
      textColor = AppColors.ink;
      trailingIcon = null;
    }

    Widget button = Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(AppDimens.radiusMd),
      child: InkWell(
        onTap: isDisabled ? null : onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(minHeight: AppDimens.touchMin),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.d20,
            vertical: AppDimens.d16,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.button.copyWith(color: textColor),
                ),
              ),
              if (trailingIcon != null)
                Icon(trailingIcon, color: textColor, size: AppDimens.iconMd),
            ],
          ),
        ),
      ),
    );

    // Animate feedback state
    if (feedbackState != null) {
      button = button
          .animate()
          .scale(
            begin: const Offset(1.0, 1.0),
            end: const Offset(1.02, 1.02),
            duration: 150.ms,
          )
          .then()
          .scale(
            begin: const Offset(1.02, 1.02),
            end: const Offset(1.0, 1.0),
            duration: 150.ms,
          );
    }

    return button;
  }
}
