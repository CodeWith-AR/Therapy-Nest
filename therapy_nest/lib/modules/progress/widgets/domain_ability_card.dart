import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/domain_ability_model.dart';

/// Horizontal-scrollable domain card showing domain name, icon,
/// and ability bar (θ mapped to 0–100%).
///
/// Tappable — navigates to domain detail.
class DomainAbilityCard extends StatelessWidget {
  const DomainAbilityCard({
    super.key,
    required this.ability,
    this.onTap,
  });

  final DomainAbilityModel ability;
  final VoidCallback? onTap;

  static const _domainIcons = {
    'language': Icons.chat_bubble_rounded,
    'memory': Icons.psychology_rounded,
    'attention': Icons.center_focus_strong_rounded,
    'speech': Icons.record_voice_over_rounded,
    'reading_writing': Icons.menu_book_rounded,
    'math': Icons.calculate_rounded,
  };

  static Color _getDomainColor(String domainCode) {
    switch (domainCode) {
      case 'language':
        return AppColors.primary;
      case 'memory':
        return AppColors.accentPurple;
      case 'attention':
        return AppColors.accentTeal;
      case 'speech':
        return AppColors.accentGreen;
      case 'reading_writing':
        return AppColors.info;
      case 'math':
        return AppColors.warning;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final icon = _domainIcons[ability.domainCode] ?? Icons.extension_rounded;
    final color = _getDomainColor(ability.domainCode);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(AppDimens.d12),
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          border: Border.all(color: AppColors.hairlineSoft),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: AppDimens.d40,
              height: AppDimens.d40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppDimens.radiusSm),
              ),
              child: Icon(icon, size: AppDimens.iconMd, color: color),
            ),
            const SizedBox(height: AppDimens.d8),

            // Label
            Text(
              ability.domainLabel,
              style: AppTextStyles.titleSm.copyWith(color: AppColors.ink),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppDimens.d4),

            // Change text (positive framing)
            Text(
              ability.changeText,
              style: AppTextStyles.caption.copyWith(color: AppColors.body),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppDimens.d8),

            // Ability bar
            ClipRRect(
              borderRadius: BorderRadius.circular(AppDimens.radiusFull),
              child: LinearProgressIndicator(
                value: (ability.abilityPercent / 100).clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: AppColors.surfaceSoft,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            const SizedBox(height: AppDimens.d4),

            // Percentage
            Text(
              '${ability.abilityPercent.toStringAsFixed(0)}%',
              style: AppTextStyles.caption.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
