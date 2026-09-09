import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimens.dart';
import '../constants/app_text_styles.dart';

/// Unified button widget with 4 variants: primary, secondary, outlined, text.
/// Minimum height 56dp for motor-impaired accessibility.
enum AppButtonVariant { primary, secondary, outlined, text }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.isEnabled = true,
    this.icon,
    this.width,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final bool isEnabled;
  final IconData? icon;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = (isLoading || !isEnabled) ? null : onPressed;

    Widget child = isLoading
        ? const SizedBox(
            height: AppDimens.iconMd,
            width: AppDimens.iconMd,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.onPrimary),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: AppDimens.iconMd),
                const SizedBox(width: AppDimens.d8),
              ],
              Text(label),
            ],
          );

    final buttonStyle = _buildStyle(context);

    Widget button;
    switch (variant) {
      case AppButtonVariant.primary:
      case AppButtonVariant.secondary:
        button = ElevatedButton(
          onPressed: effectiveOnPressed,
          style: buttonStyle,
          child: child,
        );
      case AppButtonVariant.outlined:
        // For outlined variant, adjust loading indicator color
        if (isLoading) {
          child = SizedBox(
            height: AppDimens.iconMd,
            width: AppDimens.iconMd,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(
                variant == AppButtonVariant.outlined
                    ? AppColors.primary
                    : AppColors.onPrimary,
              ),
            ),
          );
        }
        button = OutlinedButton(
          onPressed: effectiveOnPressed,
          style: buttonStyle,
          child: child,
        );
      case AppButtonVariant.text:
        if (isLoading) {
          child = SizedBox(
            height: AppDimens.iconMd,
            width: AppDimens.iconMd,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          );
        }
        button = TextButton(
          onPressed: effectiveOnPressed,
          style: buttonStyle,
          child: child,
        );
    }

    if (width != null) {
      return SizedBox(width: width, child: button);
    }
    return SizedBox(width: double.infinity, child: button);
  }

  ButtonStyle _buildStyle(BuildContext context) {
    switch (variant) {
      case AppButtonVariant.primary:
        return ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          disabledBackgroundColor: AppColors.primaryDisabled,
          disabledForegroundColor: AppColors.onPrimary.withValues(alpha: 0.7),
          minimumSize: Size(0, AppDimens.touchNormal),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          ),
          textStyle: AppTextStyles.button,
          elevation: 0,
        );
      case AppButtonVariant.secondary:
        return ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryLight,
          foregroundColor: AppColors.primary,
          minimumSize: Size(0, AppDimens.touchNormal),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          ),
          textStyle: AppTextStyles.button,
          elevation: 0,
        );
      case AppButtonVariant.outlined:
        return OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: Size(0, AppDimens.touchNormal),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          ),
          side: BorderSide(color: AppColors.hairline, width: 1.5),
          textStyle: AppTextStyles.button,
        );
      case AppButtonVariant.text:
        return TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: Size(0, AppDimens.touchSmall),
          textStyle: AppTextStyles.buttonSm,
        );
    }
  }
}
