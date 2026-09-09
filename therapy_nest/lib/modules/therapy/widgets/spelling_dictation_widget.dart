import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/exercise_item_model.dart';

/// 8D — Spelling from Dictation.
///
/// TTS speaks a word → user types the spelling using a custom
/// oversized-key keyboard widget (designed for motor-impaired users).
///
/// Distinct from Module 6's [SpellingWidget] which shows the word.
/// This widget uses TTS-only input (no visual word shown) and has a
/// custom large-key keyboard instead of the system keyboard.
///
/// Stimulus schema:
/// ```json
/// {
///   "word": "elephant",
///   "hint": "a large grey animal"
/// }
/// ```
class SpellingDictationWidget extends StatefulWidget {
  const SpellingDictationWidget({
    super.key,
    required this.item,
    required this.onAnswer,
  });

  final ExerciseItemModel item;
  final void Function(String answer) onAnswer;

  @override
  State<SpellingDictationWidget> createState() =>
      _SpellingDictationWidgetState();
}

class _SpellingDictationWidgetState extends State<SpellingDictationWidget> {
  _Phase _phase = _Phase.listening;
  bool _answered = false;

  late FlutterTts _tts;
  late String _word;
  late String? _hint;

  final List<String> _typedLetters = [];

  static const List<String> _topRow = [
    'Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P',
  ];
  static const List<String> _midRow = [
    'A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L',
  ];
  static const List<String> _botRow = [
    'Z', 'X', 'C', 'V', 'B', 'N', 'M',
  ];

  @override
  void initState() {
    super.initState();
    _tts = FlutterTts();
    _parseStimulus();
    _speakWord();
  }

  @override
  void didUpdateWidget(covariant SpellingDictationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.id != widget.item.id) {
      _tts.stop();
      _phase = _Phase.listening;
      _answered = false;
      _typedLetters.clear();
      _parseStimulus();
      _speakWord();
    }
  }

  void _parseStimulus() {
    final stimulus = widget.item.stimulus;
    _word = (stimulus['word'] as String?) ?? '';
    _hint = stimulus['hint'] as String?;
  }

  Future<void> _speakWord() async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.35);
      await _tts.setPitch(1.0);

      _tts.setCompletionHandler(() {
        if (mounted) {
          setState(() => _phase = _Phase.spelling);
        }
      });

      await _tts.speak(_word);
    } catch (_) {
      if (mounted) {
        setState(() => _phase = _Phase.spelling);
      }
    }
  }

  void _replayWord() {
    _tts.speak(_word);
  }

  void _onKeyTap(String letter) {
    if (_answered) return;
    setState(() => _typedLetters.add(letter));
  }

  void _onBackspace() {
    if (_answered || _typedLetters.isEmpty) return;
    setState(() => _typedLetters.removeLast());
  }

  void _submitAnswer() {
    if (_answered || _typedLetters.isEmpty) return;
    final answer = _typedLetters.join();
    setState(() {
      _answered = true;
      _phase = _Phase.result;
    });
    widget.onAnswer(answer);
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (_phase) {
      case _Phase.listening:
        return _buildListening();
      case _Phase.spelling:
        return _buildSpelling();
      case _Phase.result:
        return _buildResult();
    }
  }

  // ── Listening ──────────────────────────────────────────────────────

  Widget _buildListening() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.hearing_rounded,
          size: AppDimens.iconXl,
          color: AppColors.accentTeal,
        ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
              begin: const Offset(1, 1),
              end: const Offset(1.15, 1.15),
              duration: 800.ms,
            ),
        const SizedBox(height: AppDimens.d20),
        Text(
          'Listen to the word…',
          style: AppTextStyles.titleLg.copyWith(color: AppColors.ink),
        ),
        const SizedBox(height: AppDimens.d8),
        Text(
          'Then spell it using the keyboard.',
          style: AppTextStyles.bodySm.copyWith(color: AppColors.muted),
        ),
      ],
    );
  }

  // ── Spelling ───────────────────────────────────────────────────────

  Widget _buildSpelling() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.spellcheck_rounded,
              size: AppDimens.iconMd,
              color: AppColors.accentTeal,
            ),
            const SizedBox(width: AppDimens.d8),
            Text(
              'Spell the Word',
              style: AppTextStyles.titleMd.copyWith(color: AppColors.ink),
            ),
          ],
        ),
        const SizedBox(height: AppDimens.d16),

        // Replay button
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _replayWord,
            borderRadius: BorderRadius.circular(AppDimens.radiusFull),
            child: Container(
              width: AppDimens.d64,
              height: AppDimens.d64,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.hairline),
              ),
              child: Icon(
                Icons.volume_up_rounded,
                size: AppDimens.iconLg,
                color: AppColors.primary,
              ),
            ),
          ),
        ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack),
        const SizedBox(height: AppDimens.d4),
        Text(
          'Tap to hear again',
          style: AppTextStyles.caption.copyWith(color: AppColors.muted),
        ),
        const SizedBox(height: AppDimens.d16),

        // Optional hint
        if (_hint != null && _hint!.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimens.d8),
            margin: const EdgeInsets.only(bottom: AppDimens.d12),
            decoration: BoxDecoration(
              color: AppColors.accentAmber.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppDimens.radiusSm),
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
                    _hint!,
                    style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.bodyStrong,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Letter display area
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: AppDimens.d48),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.d16,
            vertical: AppDimens.d12,
          ),
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            border: Border.all(color: AppColors.hairline),
          ),
          child: Wrap(
            spacing: AppDimens.d4,
            children: _typedLetters.isEmpty
                ? [
                    Text(
                      'Tap the letters below…',
                      style: AppTextStyles.bodyMd.copyWith(
                        color: AppColors.mutedSoft,
                      ),
                    ),
                  ]
                : _typedLetters
                    .map((l) => Text(
                          l,
                          style: AppTextStyles.displaySm.copyWith(
                            color: AppColors.ink,
                            letterSpacing: 2.0,
                          ),
                        ))
                    .toList(),
          ),
        ),
        const SizedBox(height: AppDimens.d12),

        // Custom large-key keyboard
        _buildKeyboardRow(_topRow),
        const SizedBox(height: AppDimens.d4),
        _buildKeyboardRow(_midRow),
        const SizedBox(height: AppDimens.d4),
        _buildKeyboardRowWithActions(_botRow),
        const SizedBox(height: AppDimens.d12),

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
                color: _typedLetters.isNotEmpty
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

  Widget _buildKeyboardRow(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: keys.map((key) => _buildKey(key)).toList(),
    );
  }

  Widget _buildKeyboardRowWithActions(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Backspace key
        Padding(
          padding: const EdgeInsets.all(2),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _onBackspace,
              borderRadius: BorderRadius.circular(AppDimens.radiusSm),
              child: Container(
                width: AppDimens.d48,
                height: AppDimens.d40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.surfaceSoft,
                  borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                ),
                child: Icon(
                  Icons.backspace_rounded,
                  size: AppDimens.iconSm,
                  color: AppColors.body,
                ),
              ),
            ),
          ),
        ),
        ...keys.map((key) => _buildKey(key)),
      ],
    );
  }

  Widget _buildKey(String letter) {
    return Padding(
      padding: const EdgeInsets.all(2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onKeyTap(letter),
          borderRadius: BorderRadius.circular(AppDimens.radiusSm),
          child: Container(
            width: AppDimens.d32,
            height: AppDimens.d40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surfaceWhite,
              borderRadius: BorderRadius.circular(AppDimens.radiusSm),
              border: Border.all(color: AppColors.hairline),
            ),
            child: Text(
              letter,
              style: AppTextStyles.titleSm.copyWith(color: AppColors.ink),
            ),
          ),
        ),
      ),
    );
  }

  // ── Result ─────────────────────────────────────────────────────────

  Widget _buildResult() {
    final userAnswer = _typedLetters.join();
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
                'Correct: ',
                style: AppTextStyles.bodyMd.copyWith(color: AppColors.body),
              ),
              Text(
                widget.item.correctAnswer,
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

enum _Phase { listening, spelling, result }
