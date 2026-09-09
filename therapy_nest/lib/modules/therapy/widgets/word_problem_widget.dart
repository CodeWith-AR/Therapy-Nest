import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/exercise_item_model.dart';

/// 9F — Word Problems.
///
/// Real-world multi-step math problems with TTS read-aloud support.
/// Problem text displayed in a readable card with a speaker button,
/// and 4 multiple-choice answer options.
///
/// Stimulus schema:
/// ```json
/// {
///   "problemText": "You have 10 apples. You give 3 to your friend and 2 to your sister. How many apples do you have left?",
///   "options": ["4", "5", "6", "7"]
/// }
/// ```
class WordProblemWidget extends StatefulWidget {
  const WordProblemWidget({
    super.key,
    required this.item,
    required this.onAnswer,
  });

  final ExerciseItemModel item;
  final void Function(String answer) onAnswer;

  @override
  State<WordProblemWidget> createState() => _WordProblemWidgetState();
}

class _WordProblemWidgetState extends State<WordProblemWidget> {
  _Phase _phase = _Phase.stimulus;
  bool _answered = false;
  String? _selectedAnswer;
  bool _isSpeaking = false;

  late FlutterTts _tts;
  late String _problemText;
  late List<String> _options;

  @override
  void initState() {
    super.initState();
    _tts = FlutterTts();
    _parseStimulus();
    _configureTts();
  }

  @override
  void didUpdateWidget(covariant WordProblemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.id != widget.item.id) {
      _tts.stop();
      _phase = _Phase.stimulus;
      _answered = false;
      _selectedAnswer = null;
      _isSpeaking = false;
      _parseStimulus();
    }
  }

  void _parseStimulus() {
    final stimulus = widget.item.stimulus;
    _problemText = (stimulus['problemText'] as String?) ?? '';
    _options = List<String>.from(stimulus['options'] as List? ?? []);
  }

  Future<void> _configureTts() async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.4);
      _tts.setCompletionHandler(() {
        if (mounted) setState(() => _isSpeaking = false);
      });
    } catch (_) {}
  }

  Future<void> _speakProblem() async {
    if (_isSpeaking) {
      await _tts.stop();
      setState(() => _isSpeaking = false);
      return;
    }
    try {
      setState(() => _isSpeaking = true);
      await _tts.speak(_problemText);
    } catch (_) {
      setState(() => _isSpeaking = false);
    }
  }

  void _selectOption(String option) {
    if (_answered) return;
    setState(() => _selectedAnswer = option);
  }

  void _submitAnswer() {
    if (_answered || _selectedAnswer == null) return;
    _tts.stop();
    setState(() {
      _answered = true;
      _isSpeaking = false;
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
              Icons.menu_book_rounded,
              size: AppDimens.iconMd,
              color: AppColors.accentPurple,
            ),
            const SizedBox(width: AppDimens.d8),
            Text(
              'Word Problem',
              style: AppTextStyles.titleMd.copyWith(color: AppColors.ink),
            ),
          ],
        ),
        const SizedBox(height: AppDimens.d8),
        Text(
          'Read the problem and choose the answer.',
          style: AppTextStyles.bodySm.copyWith(color: AppColors.muted),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimens.d16),

        // Problem card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppDimens.d20),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(AppDimens.radiusLg),
            border: Border.all(color: AppColors.hairline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _problemText,
                style: AppTextStyles.bodyLg.copyWith(
                  color: AppColors.ink,
                  height: 1.7,
                ),
              ),
              const SizedBox(height: AppDimens.d12),
              // TTS button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _speakProblem,
                  borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.d12,
                      vertical: AppDimens.d8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceWhite,
                      borderRadius:
                          BorderRadius.circular(AppDimens.radiusFull),
                      border: Border.all(color: AppColors.hairline),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isSpeaking
                              ? Icons.stop_rounded
                              : Icons.volume_up_rounded,
                          size: AppDimens.iconSm,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: AppDimens.d4),
                        Text(
                          _isSpeaking ? 'Stop' : 'Read Aloud',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 400.ms),

        const SizedBox(height: AppDimens.d20),

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
                    style: const TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ).copyWith(
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
