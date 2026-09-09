import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/exercise_item_model.dart';

/// 9A — Number Recognition.
///
/// Mode A (`digitToWord`): Display a large digit (JetBrains Mono 48pt) →
/// user selects the matching word form from 4 text options.
/// Mode B (`wordToDigit`): Display a number word → user selects the
/// matching digit from 4 options.
///
/// Stimulus schema:
/// ```json
/// {
///   "displayValue": "7",
///   "mode": "digitToWord",
///   "options": ["seven", "five", "nine", "three"]
/// }
/// ```
class NumberRecognitionWidget extends StatefulWidget {
  const NumberRecognitionWidget({
    super.key,
    required this.item,
    required this.onAnswer,
  });

  final ExerciseItemModel item;
  final void Function(String answer) onAnswer;

  @override
  State<NumberRecognitionWidget> createState() =>
      _NumberRecognitionWidgetState();
}

class _NumberRecognitionWidgetState extends State<NumberRecognitionWidget> {
  _Phase _phase = _Phase.stimulus;
  bool _answered = false;
  String? _selectedAnswer;

  late FlutterTts _tts;
  late String _displayValue;
  late String _mode; // 'digitToWord' or 'wordToDigit'
  late List<String> _options;

  @override
  void initState() {
    super.initState();
    _tts = FlutterTts();
    _parseStimulus();
    _speakPrompt();
  }

  @override
  void didUpdateWidget(covariant NumberRecognitionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.id != widget.item.id) {
      _tts.stop();
      _phase = _Phase.stimulus;
      _answered = false;
      _selectedAnswer = null;
      _parseStimulus();
      _speakPrompt();
    }
  }

  void _parseStimulus() {
    final stimulus = widget.item.stimulus;
    _displayValue = (stimulus['displayValue'] as String?) ?? '';
    _mode = (stimulus['mode'] as String?) ?? 'digitToWord';
    _options = List<String>.from(stimulus['options'] as List? ?? []);
  }

  Future<void> _speakPrompt() async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.4);
      if (_mode == 'digitToWord') {
        await _tts.speak('What is this number? $_displayValue');
      } else {
        await _tts.speak(_displayValue);
      }
    } catch (_) {}
  }

  void _selectOption(String option) {
    if (_answered) return;
    setState(() => _selectedAnswer = option);
  }

  void _submitAnswer() {
    if (_answered || _selectedAnswer == null) return;
    setState(() {
      _answered = true;
      _phase = _Phase.result;
    });
    widget.onAnswer(_selectedAnswer!);
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (_phase) {
      case _Phase.stimulus:
        return _buildStimulus();
      case _Phase.result:
        return _buildResult();
    }
  }

  // ── Stimulus Phase ──────────────────────────────────────────────────

  Widget _buildStimulus() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pin_rounded,
              size: AppDimens.iconMd,
              color: AppColors.accentTeal,
            ),
            const SizedBox(width: AppDimens.d8),
            Text(
              'Number Recognition',
              style: AppTextStyles.titleMd.copyWith(color: AppColors.ink),
            ),
          ],
        ),
        const SizedBox(height: AppDimens.d8),
        Text(
          _mode == 'digitToWord'
              ? 'Select the word for this number.'
              : 'Select the digit for this word.',
          style: AppTextStyles.bodySm.copyWith(color: AppColors.muted),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimens.d20),

        // Display value — large prominent number or word
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.d32,
            vertical: AppDimens.d24,
          ),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(AppDimens.radiusLg),
            border: Border.all(color: AppColors.hairline),
          ),
          child: Text(
            _displayValue,
            style: _mode == 'digitToWord'
                ? const TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: 48,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.0,
                  ).copyWith(color: AppColors.ink)
                : AppTextStyles.displayLg.copyWith(color: AppColors.ink),
          ),
        ).animate().fadeIn(duration: 300.ms).scale(
              begin: const Offset(0.9, 0.9),
              end: const Offset(1, 1),
              duration: 300.ms,
            ),

        const SizedBox(height: AppDimens.d8),

        // TTS replay button
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _speakPrompt,
            borderRadius: BorderRadius.circular(AppDimens.radiusFull),
            child: Padding(
              padding: const EdgeInsets.all(AppDimens.d8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.volume_up_rounded,
                    size: AppDimens.iconSm,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: AppDimens.d4),
                  Text(
                    'Listen',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: AppDimens.d16),

        // Options
        ...List.generate(_options.length, (i) {
          final option = _options[i];
          final isSelected = _selectedAnswer == option;

          return Padding(
            padding: const EdgeInsets.only(bottom: AppDimens.d8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _selectOption(option),
                borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: double.infinity,
                  height: AppDimens.touchNormal,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryLight
                        : AppColors.surfaceWhite,
                    borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                    border: Border.all(
                      color:
                          isSelected ? AppColors.primary : AppColors.hairline,
                      width: isSelected ? 2.0 : 1.0,
                    ),
                  ),
                  child: Text(
                    option,
                    style: (_mode == 'wordToDigit'
                            ? const TextStyle(
                                fontFamily: 'JetBrains Mono',
                                fontSize: 28,
                                fontWeight: FontWeight.w600,
                              )
                            : AppTextStyles.titleSm)
                        .copyWith(
                      color: isSelected ? AppColors.primary : AppColors.ink,
                    ),
                  ),
                ),
              ),
            ).animate().fadeIn(
                  duration: 200.ms,
                  delay: Duration(milliseconds: 60 * i),
                ),
          );
        }),

        const SizedBox(height: AppDimens.d8),

        // Submit
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
                color: _selectedAnswer != null
                    ? AppColors.primary
                    : AppColors.primaryDisabled,
                borderRadius: BorderRadius.circular(AppDimens.radiusMd),
              ),
              child: Text(
                'Submit',
                style:
                    AppTextStyles.button.copyWith(color: AppColors.onPrimary),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Result Phase ────────────────────────────────────────────────────

  Widget _buildResult() {
    final isCorrect = widget.item.isCorrect(_selectedAnswer ?? '');

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
        const SizedBox(height: AppDimens.d8),
        if (!isCorrect)
          Text(
            'The answer is: ${widget.item.correctAnswer}',
            style: AppTextStyles.bodyMd.copyWith(color: AppColors.body),
          ),
      ],
    ).animate().fadeIn(duration: 400.ms);
  }
}

enum _Phase { stimulus, result }
