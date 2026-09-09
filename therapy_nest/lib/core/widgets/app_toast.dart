import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimens.dart';
import '../constants/app_text_styles.dart';

/// In-app snackbar / toast notification helper.
class AppToast {
  AppToast._();

  static void show(
    BuildContext context, {
    required String message,
    AppToastType type = AppToastType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final color = switch (type) {
      AppToastType.success => AppColors.success,
      AppToastType.error   => AppColors.error,
      AppToastType.warning => AppColors.warning,
      AppToastType.info    => AppColors.info,
    };

    final icon = switch (type) {
      AppToastType.success => Icons.check_circle_rounded,
      AppToastType.error   => Icons.error_rounded,
      AppToastType.warning => Icons.warning_rounded,
      AppToastType.info    => Icons.info_rounded,
    };

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icon, color: AppColors.onPrimary, size: AppDimens.iconMd),
              const SizedBox(width: AppDimens.d12),
              Expanded(
                child: Text(
                  message,
                  style:
                      AppTextStyles.bodyMd.copyWith(color: AppColors.onPrimary),
                ),
              ),
            ],
          ),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          ),
          margin: const EdgeInsets.all(AppDimens.d16),
          duration: duration,
        ),
      );
  }

  /// Convenience methods.
  static void success(BuildContext context, String message) =>
      show(context, message: message, type: AppToastType.success);

  static void error(BuildContext context, String message) =>
      show(context, message: message, type: AppToastType.error);

  static void warning(BuildContext context, String message) =>
      show(context, message: message, type: AppToastType.warning);

  static void info(BuildContext context, String message) =>
      show(context, message: message, type: AppToastType.info);
}

enum AppToastType { success, error, warning, info }
