import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/exercise_item_model.dart';

/// 8B — Sentence-Level Reading.
///
/// Phase 1: Sentence displayed in a large text card (TTS reads aloud).
/// Phase 2: MC question with 4 options (yes/no or content-based).
///
/// Stimulus schema:
/// ```json
/// {
///   "sentence": "The cat is sitting on the mat.",
///   "question": "Where is the cat?",
///   "options": ["On the mat", "Under the table", "In the box", "On the roof"]
/// }
/// ```
class SentenceReadingWidget extends StatefulWidget {
  const SentenceReadingWidget({
    super.key,
    required this.item,
    required this.onAnswer,
  });

  final ExerciseItemModel item;
  final void Function(String answer) onAnswer;

  @override
  State<SentenceReadingWidget> createState() => _SentenceReadingWidgetState();
}

class _SentenceReadingWidgetState extends State<SentenceReadingWidget> {
  _Phase _phase = _Phase.reading;
  bool _answered = false;
  String? _selectedOption;

  late FlutterTts _tts;
  late String _sentence;
  late String _question;
  late List<String> _options;

  @override
  void initState() {
    super.initState();
    _tts = FlutterTts();
    _parseStimulus();
    _speakSentence();
  }

  @override
  void didUpdateWidget(covariant SentenceReadingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.id != widget.item.id) {
      _tts.stop();
      _phase = _Phase.reading;
      _answered = false;
      _selectedOption = null;
      _parseStimulus();
      _speakSentence();
    }
  }

  void _parseStimulus() {
    final stimulus = widget.item.stimulus;
    _sentence = (stimulus['sentence'] as String?) ?? '';
    _question = (stimulus['question'] as String?) ?? '';
    _options = List<String>.from(stimulus['options'] as List? ?? []);
  }

  Future<void> _speakSentence() async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.38);
      await _tts.setPitch(1.0);
      await _tts.speak(_sentence);
    } catch (_) {}
  }

  void _advanceToQuestion() {
    setState(() => _phase = _Phase.question);
  }

  void _selectOption(String option) {
    if (_answered) return;
    setState(() => _selectedOption = option);
  }

  void _submitAnswer() {
    if (_answered || _selectedOption == null) return;
    setState(() {
      _answered = true;
      _phase = _Phase.result;
    });
    widget.onAnswer(_selectedOption!);
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (_phase) {
      case _Phase.reading:
        return _buildReading();
      case _Phase.question:
        return _buildQuestion();
      case _Phase.result:
        return _buildResult();
    }
  }

  // ── Phase 1: Reading ──────────────────────────────────────────────

  Widget _buildReading() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.menu_book_rounded,
              size: AppDimens.iconMd,
              color: AppColors.accentTeal,
            ),
            const SizedBox(width: AppDimens.d8),
            Text(
              'Read the Sentence',
              style: AppTextStyles.titleMd.copyWith(color: AppColors.ink),
            ),
          ],
        ),
        const SizedBox(height: AppDimens.d24),

        // Sentence card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppDimens.d24),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(AppDimens.radiusLg),
            border: Border.all(color: AppColors.hairline),
          ),
          child: Text(
            _sentence,
            style: AppTextStyles.displaySm.copyWith(
              color: AppColors.ink,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ).animate().fadeIn(duration: 400.ms),
        const SizedBox(height: AppDimens.d16),

        // Replay button
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _tts.speak(_sentence),
            borderRadius: BorderRadius.circular(AppDimens.radiusFull),
            child: Container(
              width: AppDimens.d48,
              height: AppDimens.d48,
              decoration: BoxDecoration(
                color: AppColors.surfaceSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.volume_up_rounded,
                size: AppDimens.iconMd,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppDimens.d20),

        // Continue button
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _advanceToQuestion,
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            child: Container(
              width: double.infinity,
              height: AppDimens.touchSmall,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppDimens.radiusMd),
              ),
              child: Text(
                'Continue to Question',
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

  // ── Phase 2: Question ─────────────────────────────────────────────

  Widget _buildQuestion() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _question,
          style: AppTextStyles.titleMd.copyWith(color: AppColors.ink),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimens.d20),

        // MC options
        ...List.generate(_options.length, (i) {
          final option = _options[i];
          final isSelected = _selectedOption == option;

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
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.d16,
                  ),
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
                    style: AppTextStyles.titleSm.copyWith(
                      color: isSelected ? AppColors.primary : AppColors.ink,
                    ),
                    textAlign: TextAlign.center,
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
                color: _selectedOption != null
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

  // ── Result ────────────────────────────────────────────────────────

  Widget _buildResult() {
    final isCorrect = widget.item.isCorrect(_selectedOption ?? '');

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

enum _Phase { reading, question, result }
