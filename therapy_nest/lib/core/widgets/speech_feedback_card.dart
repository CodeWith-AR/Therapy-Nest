import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/services/speech_service.dart';

/// Shows transcribed speech feedback with color-coded scoring.
///
/// - **Green** ([AppColors.success]) = exact match
/// - **Amber** ([AppColors.warning]) = close match (phonemic / semantic error)
/// - **Red** ([AppColors.error]) = error / mismatch
///
/// Supports both single-word and word-by-word highlighting for
/// phrase / sentence exercises.
class SpeechFeedbackCard extends StatelessWidget {
  const SpeechFeedbackCard({
    super.key,
    required this.errorType,
    this.transcription,
    this.wordScores,
    this.similarity,
  });

  /// The classified error type from [SpeechService.classifyError].
  final SpeechErrorType errorType;

  /// Single-word transcription text (for word repetition exercises).
  final String? transcription;

  /// Per-word scores (for phrase / sentence exercises).
  final List<WordScore>? wordScores;

  /// Overall similarity score (0.0–1.0).
  final double? similarity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimens.d16),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(color: _borderColor, width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Status icon + label
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(_statusIcon, size: AppDimens.iconMd, color: _statusColor),
              const SizedBox(width: AppDimens.d8),
              Text(
                _statusLabel,
                style: AppTextStyles.titleSm.copyWith(color: _statusColor),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.d12),

          // Word-by-word scores (phrase/sentence exercises)
          if (wordScores != null && wordScores!.isNotEmpty)
            _buildWordByWord()
          // Single transcription (word repetition)
          else if (transcription != null)
            Text(
              '"$transcription"',
              style: AppTextStyles.displaySm.copyWith(color: _statusColor),
              textAlign: TextAlign.center,
            ),

          // Similarity percentage
          if (similarity != null) ...[
            const SizedBox(height: AppDimens.d8),
            Text(
              '${(similarity! * 100).toStringAsFixed(0)}% match',
              style: AppTextStyles.caption.copyWith(color: AppColors.muted),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(
          begin: 0.1,
          end: 0,
          duration: 300.ms,
          curve: Curves.easeOut,
        );
  }

  Widget _buildWordByWord() {
    return Wrap(
      spacing: AppDimens.d4,
      runSpacing: AppDimens.d4,
      alignment: WrapAlignment.center,
      children: wordScores!.map((ws) {
        final color =
            ws.isMatch ? AppColors.success : AppColors.error;
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.d8,
            vertical: AppDimens.d4,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(AppDimens.radiusSm),
            border: Border.all(color: color.withValues(alpha: 0.30)),
          ),
          child: Text(
            ws.expected,
            style: AppTextStyles.bodyMd.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────

  Color get _statusColor {
    switch (errorType) {
      case SpeechErrorType.exactMatch:
        return AppColors.success;
      case SpeechErrorType.phonemicError:
      case SpeechErrorType.semanticError:
        return AppColors.warning;
      case SpeechErrorType.perseveration:
      case SpeechErrorType.noResponse:
      case SpeechErrorType.unintelligible:
        return AppColors.error;
    }
  }

  Color get _backgroundColor {
    return _statusColor.withValues(alpha: 0.06);
  }

  Color get _borderColor {
    return _statusColor.withValues(alpha: 0.25);
  }

  IconData get _statusIcon {
    switch (errorType) {
      case SpeechErrorType.exactMatch:
        return Icons.check_circle_rounded;
      case SpeechErrorType.phonemicError:
      case SpeechErrorType.semanticError:
        return Icons.info_rounded;
      case SpeechErrorType.perseveration:
        return Icons.replay_rounded;
      case SpeechErrorType.noResponse:
        return Icons.mic_off_rounded;
      case SpeechErrorType.unintelligible:
        return Icons.error_outline_rounded;
    }
  }

  String get _statusLabel {
    switch (errorType) {
      case SpeechErrorType.exactMatch:
        return 'Great Match!';
      case SpeechErrorType.phonemicError:
        return 'Close — Try Again';
      case SpeechErrorType.semanticError:
        return 'Related Word';
      case SpeechErrorType.perseveration:
        return 'Repeated Previous';
      case SpeechErrorType.noResponse:
        return 'No Speech Detected';
      case SpeechErrorType.unintelligible:
        return 'Try Again';
    }
  }
}
