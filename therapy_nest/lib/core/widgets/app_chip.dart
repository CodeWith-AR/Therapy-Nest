import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimens.dart';
import '../constants/app_text_styles.dart';

/// Tag / status chip widget.
class AppChip extends StatelessWidget {
  const AppChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
    this.icon,
    this.color,
  });

  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final IconData? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final bgColor =
        isSelected ? (color ?? AppColors.primaryLight) : AppColors.surfaceSoft;
    final textColor =
        isSelected ? (color ?? AppColors.primary) : AppColors.body;
    final borderColor = isSelected ? (color ?? AppColors.primary) : Colors.transparent;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.d16,
          vertical: AppDimens.d8,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppDimens.radiusFull),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: AppDimens.iconSm, color: textColor),
              const SizedBox(width: AppDimens.d4),
            ],
            Text(
              label,
              style: AppTextStyles.label.copyWith(color: textColor),
            ),
          ],
        ),
      ),
    );
  }
}
