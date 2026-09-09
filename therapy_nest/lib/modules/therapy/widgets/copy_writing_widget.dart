import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/exercise_item_model.dart';

/// 8E — Copy Writing.
///
/// Shows a word/phrase in a styled card → user types to copy it.
/// Reference text stays visible throughout. Character-by-character
/// visual match indicator (green/red per letter) provides real-time
/// feedback during typing.
///
/// Designed for severe agraphia recovery — basic transcription practice.
///
/// Stimulus schema:
/// ```json
/// {
///   "text": "apple",
///   "fontSize": "large"
/// }
/// ```
class CopyWritingWidget extends StatefulWidget {
  const CopyWritingWidget({
    super.key,
    required this.item,
    required this.onAnswer,
  });

  final ExerciseItemModel item;
  final void Function(String answer) onAnswer;

  @override
  State<CopyWritingWidget> createState() => _CopyWritingWidgetState();
}

class _CopyWritingWidgetState extends State<CopyWritingWidget> {
  _Phase _phase = _Phase.copying;
  bool _answered = false;

  late String _targetText;

  final TextEditingController _inputController = TextEditingController();
  final FocusNode _inputFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _parseStimulus();
    _inputController.addListener(() => setState(() {}));
  }

  @override
  void didUpdateWidget(covariant CopyWritingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.id != widget.item.id) {
      _phase = _Phase.copying;
      _answered = false;
      _inputController.clear();
      _parseStimulus();
    }
  }

  void _parseStimulus() {
    final stimulus = widget.item.stimulus;
    _targetText = (stimulus['text'] as String?) ?? '';
  }

  void _submitAnswer() {
    final answer = _inputController.text.trim();
    if (_answered || answer.isEmpty) return;
    setState(() {
      _answered = true;
      _phase = _Phase.result;
    });
    widget.onAnswer(answer);
  }

  @override
  void dispose() {
    _inputController.dispose();
    _inputFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (_phase) {
      case _Phase.copying:
        return _buildCopying();
      case _Phase.result:
        return _buildResult();
    }
  }

  // ── Copying Phase ─────────────────────────────────────────────────

  Widget _buildCopying() {
    final typed = _inputController.text;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.edit_note_rounded,
              size: AppDimens.iconMd,
              color: AppColors.accentTeal,
            ),
            const SizedBox(width: AppDimens.d8),
            Text(
              'Copy the Text',
              style: AppTextStyles.titleMd.copyWith(color: AppColors.ink),
            ),
          ],
        ),
        const SizedBox(height: AppDimens.d8),
        Text(
          'Type exactly what you see below.',
          style: AppTextStyles.bodySm.copyWith(color: AppColors.muted),
        ),
        const SizedBox(height: AppDimens.d20),

        // Target text card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppDimens.d20),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            border: Border.all(color: AppColors.hairline),
          ),
          child: Text(
            _targetText,
            style: AppTextStyles.displayMd.copyWith(
              color: AppColors.ink,
              letterSpacing: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ).animate().fadeIn(duration: 300.ms),
        const SizedBox(height: AppDimens.d20),

        // Character-by-character match display
        if (typed.isNotEmpty) ...[
          Wrap(
            spacing: AppDimens.d4,
            runSpacing: AppDimens.d4,
            alignment: WrapAlignment.center,
            children: List.generate(typed.length, (i) {
              final isMatch = i < _targetText.length &&
                  typed[i].toLowerCase() == _targetText[i].toLowerCase();
              return Container(
                width: AppDimens.d32,
                height: AppDimens.d40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isMatch
                      ? AppColors.success.withValues(alpha: 0.12)
                      : AppColors.error.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppDimens.radiusXs),
                  border: Border.all(
                    color: isMatch
                        ? AppColors.success.withValues(alpha: 0.4)
                        : AppColors.error.withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  typed[i],
                  style: AppTextStyles.titleSm.copyWith(
                    color: isMatch ? AppColors.success : AppColors.error,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: AppDimens.d16),
        ],

        // Text input
        TextField(
          controller: _inputController,
          focusNode: _inputFocus,
          textCapitalization: TextCapitalization.none,
          autocorrect: false,
          decoration: InputDecoration(
            hintText: 'Type here…',
            filled: true,
            fillColor: AppColors.surfaceWhite,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
              borderSide: BorderSide(color: AppColors.hairline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
              borderSide: BorderSide(color: AppColors.hairline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
              borderSide: BorderSide(color: AppColors.accentTeal, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppDimens.d16,
              vertical: AppDimens.d12,
            ),
          ),
          style: AppTextStyles.displaySm.copyWith(
            color: AppColors.ink,
            letterSpacing: 1.5,
          ),
          onSubmitted: (_) => _submitAnswer(),
        ),
        const SizedBox(height: AppDimens.d16),

        // Submit button
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _submitAnswer,
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            child: Container(
              width: double.infinity,
              height: AppDimens.touchSmall,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: typed.isNotEmpty
                    ? AppColors.primary
                    : AppColors.primaryDisabled,
                borderRadius: BorderRadius.circular(AppDimens.radiusMd),
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
      ],
    );
  }

  // ── Result ─────────────────────────────────────────────────────────

  Widget _buildResult() {
    final userAnswer = _inputController.text.trim();
    final isCorrect = widget.item.isCorrect(userAnswer);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
          size: AppDimens.iconXl,
          color: isCorrect ? AppColors.success : AppColors.error,
        ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
        const SizedBox(height: AppDimens.d16),
        Text(
          isCorrect ? 'Correct!' : 'Not quite',
          style: AppTextStyles.titleLg.copyWith(color: AppColors.ink),
        ),
        const SizedBox(height: AppDimens.d12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'You typed: ',
              style: AppTextStyles.bodyMd.copyWith(color: AppColors.body),
            ),
            Text(
              userAnswer,
              style: AppTextStyles.titleSm.copyWith(
                color: isCorrect ? AppColors.success : AppColors.error,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        if (!isCorrect) ...[
          const SizedBox(height: AppDimens.d8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Target: ',
                style: AppTextStyles.bodyMd.copyWith(color: AppColors.body),
              ),
              Text(
                _targetText,
                style: AppTextStyles.titleSm.copyWith(
                  color: AppColors.success,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ],
      ],
    ).animate().fadeIn(duration: 400.ms);
  }
}

enum _Phase { copying, result }
