import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/exercise_item_model.dart';

/// 6C — Sentence Completion.
///
/// Displays a sentence with a `___` blank, user selects the correct
/// word from 4 options. Supports the clinical cueing hierarchy.
///
/// Stimulus schema:
/// ```json
/// {
///   "sentenceWithBlank": "The dog chased the ___.",
///   "options": ["cat", "cloud", "letter", "phone"]
/// }
/// ```
class SentenceCompletionWidget extends StatefulWidget {
  const SentenceCompletionWidget({
    super.key,
    required this.item,
    required this.onAnswer,
  });

  final ExerciseItemModel item;
  final void Function(String answer) onAnswer;

  @override
  State<SentenceCompletionWidget> createState() =>
      _SentenceCompletionWidgetState();
}

class _SentenceCompletionWidgetState extends State<SentenceCompletionWidget> {
  bool _answered = false;
  String? _selectedOption;
  int _cueLevel = -1;

  late String _sentence;
  late List<String> _options;

  @override
  void initState() {
    super.initState();
    _parseStimulus();
  }

  @override
  void didUpdateWidget(covariant SentenceCompletionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.id != widget.item.id) {
      _answered = false;
      _selectedOption = null;
      _cueLevel = -1;
      _parseStimulus();
    }
  }

  void _parseStimulus() {
    final stimulus = widget.item.stimulus;
    _sentence = (stimulus['sentenceWithBlank'] as String?) ?? '___';
    _options = List<String>.from(stimulus['options'] as List? ?? []);
  }

  void _selectOption(String option) {
    if (_answered) return;
    setState(() => _selectedOption = option);
  }

  void _showNextCue() {
    if (_cueLevel < widget.item.cues.length - 1) {
      setState(() => _cueLevel++);
    }
  }

  void _submitAnswer() {
    if (_answered || _selectedOption == null) return;
    setState(() => _answered = true);
    widget.onAnswer(_selectedOption!);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Title
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.short_text_rounded,
              size: AppDimens.iconMd,
              color: AppColors.accentPurple,
            ),
            const SizedBox(width: AppDimens.d8),
            Text(
              'Complete the Sentence',
              style: AppTextStyles.titleMd.copyWith(color: AppColors.ink),
            ),
          ],
        ).animate().fadeIn(duration: 300.ms),
        const SizedBox(height: AppDimens.d24),

        // Sentence with highlighted blank
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppDimens.d20),
          decoration: BoxDecoration(
            color: AppColors.surfaceSoft,
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          ),
          child: _buildSentenceRichText(),
        ).animate().fadeIn(duration: 300.ms, delay: 100.ms),
        const SizedBox(height: AppDimens.d24),

        // Cueing hint
        if (_cueLevel >= 0 && _cueLevel < widget.item.cues.length)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimens.d12),
            margin: const EdgeInsets.only(bottom: AppDimens.d16),
            decoration: BoxDecoration(
              color: AppColors.accentAmber.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
              border: Border.all(
                color: AppColors.accentAmber.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline_rounded,
                  size: AppDimens.iconSm,
                  color: AppColors.warning,
                ),
                const SizedBox(width: AppDimens.d8),
                Expanded(
                  child: Text(
                    widget.item.cues[_cueLevel]['text'] ?? '',
                    style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.bodyStrong,
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 200.ms),

        // Multiple choice options
        ...List.generate(_options.length, (i) {
          final option = _options[i];
          final isSelected = _selectedOption == option;
          final isCorrect = _answered && widget.item.isCorrect(option);
          final isWrong = _answered && isSelected && !isCorrect;

          Color bgColor;
          Color borderColor;
          Color textColor;

          if (_answered) {
            if (isCorrect) {
              bgColor = AppColors.success.withValues(alpha: 0.1);
              borderColor = AppColors.success;
              textColor = AppColors.success;
            } else if (isWrong) {
              bgColor = AppColors.error.withValues(alpha: 0.1);
              borderColor = AppColors.error;
              textColor = AppColors.error;
            } else {
              bgColor = AppColors.surfaceWhite;
              borderColor = AppColors.hairline;
              textColor = AppColors.muted;
            }
          } else {
            bgColor = isSelected ? AppColors.primaryLight : AppColors.surfaceWhite;
            borderColor = isSelected ? AppColors.primary : AppColors.hairline;
            textColor = isSelected ? AppColors.primary : AppColors.ink;
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: AppDimens.d8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _answered ? null : () => _selectOption(option),
                borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: double.infinity,
                  height: AppDimens.touchNormal,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                    border: Border.all(
                      color: borderColor,
                      width: isSelected || (isCorrect && _answered) ? 2.0 : 1.0,
                    ),
                  ),
                  child: Text(
                    option,
                    style: AppTextStyles.titleSm.copyWith(color: textColor),
                  ),
                ),
              ),
            ).animate().fadeIn(
                  duration: 200.ms,
                  delay: Duration(milliseconds: 50 * i),
                ),
          );
        }),
        const SizedBox(height: AppDimens.d12),

        // Action row
        if (!_answered)
          Row(
            children: [
              if (_cueLevel < widget.item.cues.length - 1)
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _showNextCue,
                      borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                      child: Container(
                        height: AppDimens.touchSmall,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSoft,
                          borderRadius:
                              BorderRadius.circular(AppDimens.radiusMd),
                        ),
                        child: Text(
                          'Show Hint',
                          style: AppTextStyles.buttonSm.copyWith(
                            color: AppColors.muted,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              if (_cueLevel < widget.item.cues.length - 1)
                const SizedBox(width: AppDimens.d12),
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _submitAnswer,
                    borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                    child: Container(
                      height: AppDimens.touchSmall,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius:
                            BorderRadius.circular(AppDimens.radiusMd),
                      ),
                      child: Text(
                        'Submit',
                        style: AppTextStyles.button.copyWith(
                          color: AppColors.onPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  /// Builds the sentence text with the `___` blank highlighted in accent color.
  Widget _buildSentenceRichText() {
    final parts = _sentence.split('___');
    if (parts.length < 2) {
      return Text(
        _sentence,
        style: AppTextStyles.displaySm.copyWith(color: AppColors.ink),
        textAlign: TextAlign.center,
      );
    }

    final blankText = _answered
        ? widget.item.correctAnswer
        : (_selectedOption ?? '___');
    final blankColor = _answered
        ? (widget.item.isCorrect(_selectedOption ?? '')
            ? AppColors.success
            : AppColors.error)
        : AppColors.primary;

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: AppTextStyles.displaySm.copyWith(
          color: AppColors.ink,
          height: 1.5,
        ),
        children: [
          TextSpan(text: parts[0]),
          TextSpan(
            text: blankText,
            style: AppTextStyles.displaySm.copyWith(
              color: blankColor,
              fontWeight: FontWeight.w700,
              decoration:
                  _answered ? null : TextDecoration.underline,
              decorationColor: blankColor,
            ),
          ),
          if (parts.length > 1) TextSpan(text: parts[1]),
        ],
      ),
    );
  }
}
