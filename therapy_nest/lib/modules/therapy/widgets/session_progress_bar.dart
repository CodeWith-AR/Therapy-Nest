import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';

/// Session progress indicator showing current item / total
/// with a domain label and animated progress bar.
class SessionProgressBar extends StatelessWidget {
  const SessionProgressBar({
    super.key,
    required this.currentIndex,
    required this.totalItems,
    required this.domainLabel,
    this.isLargePrint = false,
    this.onFontToggle,
  });

  /// Zero-based index of the current item.
  final int currentIndex;

  /// Total number of items in the session.
  final int totalItems;

  /// Display label for the current domain.
  final String domainLabel;

  /// Whether large-print mode is currently active.
  final bool isLargePrint;

  /// Callback to toggle large-print mode. If null, the Aa button is hidden.
  final VoidCallback? onFontToggle;

  @override
  Widget build(BuildContext context) {
    final displayIndex = currentIndex + 1;
    final progress = totalItems > 0 ? displayIndex / totalItems : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.d20,
        vertical: AppDimens.d12,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        border: Border(
          bottom: BorderSide(color: AppColors.hairlineSoft, width: 1),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Top Row: domain + counter ──────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Domain pill
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.d12,
                    vertical: AppDimens.d4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius:
                        BorderRadius.circular(AppDimens.radiusFull),
                  ),
                  child: Text(
                    domainLabel,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                // Item counter + optional Aa toggle
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (onFontToggle != null)
                      IconButton(
                        onPressed: onFontToggle,
                        icon: Icon(
                          Icons.text_fields_rounded,
                          size: AppDimens.iconSm,
                          color: isLargePrint
                              ? AppColors.primary
                              : AppColors.muted,
                        ),
                        tooltip: 'Toggle large print',
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: AppDimens.d32,
                          minHeight: AppDimens.d32,
                        ),
                      ),
                    Text(
                      '$displayIndex / $totalItems',
                      style: AppTextStyles.titleSm.copyWith(
                        color: AppColors.body,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppDimens.d8),

            // ── Progress Bar ──────────────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(AppDimens.radiusFull),
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: progress),
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return LinearProgressIndicator(
                    value: value,
                    minHeight: 6,
                    backgroundColor: AppColors.hairlineSoft,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
