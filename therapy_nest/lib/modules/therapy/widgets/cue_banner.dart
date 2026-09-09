import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';

/// Animated hint/cue banner that slides in from the top.
///
/// Shows the current cue text with an icon indicating the cue type
/// (semantic, phonemic, visual, or full model).
class CueBanner extends StatelessWidget {
  const CueBanner({
    super.key,
    required this.cueText,
    required this.cueLevel,
    this.cueType,
  });

  /// The cue text to display.
  final String cueText;

  /// The current cue level (1–4).
  final int cueLevel;

  /// The cue type (semantic, phonemic, visual, model).
  final String? cueType;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: AppDimens.d16),
      padding: const EdgeInsets.all(AppDimens.d16),
      decoration: BoxDecoration(
        color: _bannerColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        boxShadow: [
          BoxShadow(
            color: _bannerColor.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // ── Cue Icon ────────────────────────────────────────────
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppDimens.radiusSm),
            ),
            child: Icon(
              _cueIcon,
              size: AppDimens.iconSm,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: AppDimens.d12),

          // ── Cue Text ────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _cueLabel,
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: AppDimens.d4),
                Text(
                  cueText,
                  style: AppTextStyles.bodyMd.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // ── Level Badge ─────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.d8,
              vertical: AppDimens.d4,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppDimens.radiusFull),
            ),
            child: Text(
              '$cueLevel/4',
              style: AppTextStyles.caption.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .slideY(
          begin: -1,
          end: 0,
          duration: 400.ms,
          curve: Curves.easeOutCubic,
        )
        .fadeIn(duration: 300.ms);
  }

  /// Banner background color based on cue level.
  Color get _bannerColor {
    switch (cueLevel) {
      case 1:
        return AppColors.info;
      case 2:
        return AppColors.accentTeal;
      case 3:
        return AppColors.warning;
      case 4:
        return AppColors.accentPurple;
      default:
        return AppColors.info;
    }
  }

  /// Icon for the cue type.
  IconData get _cueIcon {
    switch (cueType) {
      case 'semantic':
        return Icons.lightbulb_outline_rounded;
      case 'phonemic':
        return Icons.record_voice_over_rounded;
      case 'visual':
        return Icons.visibility_rounded;
      case 'model':
        return Icons.school_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  /// Human-readable label for the cue type.
  String get _cueLabel {
    switch (cueType) {
      case 'semantic':
        return 'Hint — meaning';
      case 'phonemic':
        return 'Hint — sound';
      case 'visual':
        return 'Hint — visual';
      case 'model':
        return 'Answer revealed';
      default:
        return 'Hint';
    }
  }
}
