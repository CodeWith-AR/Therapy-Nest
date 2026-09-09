import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/exercise_item_model.dart';

/// 6F — Spelling / Writing.
///
/// TTS speaks a word, user types the correct spelling.
/// Optionally shows a Material icon as a visual cue.
///
/// Stimulus schema:
/// ```json
/// {
///   "word": "elephant",
///   "icon": 58123,            // optional Material icon codePoint
///   "fontFamily": "MaterialIcons"
/// }
/// ```
class SpellingWidget extends StatefulWidget {
  const SpellingWidget({
    super.key,
    required this.item,
    required this.onAnswer,
  });

  final ExerciseItemModel item;
  final void Function(String answer) onAnswer;

  @override
  State<SpellingWidget> createState() => _SpellingWidgetState();
}

class _SpellingWidgetState extends State<SpellingWidget> {
  _Phase _phase = _Phase.listening;
  bool _answered = false;
  bool _ttsAvailable = true;
  int _cueLevel = -1;

  late FlutterTts _tts;
  late String _word;
  late int? _iconCodePoint;
  late String? _fontFamily;

  final TextEditingController _inputController = TextEditingController();
  final FocusNode _inputFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _tts = FlutterTts();
    _parseStimulus();
    _speakWord();
  }

  @override
  void didUpdateWidget(covariant SpellingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.id != widget.item.id) {
      _tts.stop();
      _phase = _Phase.listening;
      _answered = false;
      _cueLevel = -1;
      _inputController.clear();
      _parseStimulus();
      _speakWord();
    }
  }

  void _parseStimulus() {
    final stimulus = widget.item.stimulus;
    _word = (stimulus['word'] as String?) ?? '';
    _iconCodePoint = stimulus['icon'] as int?;
    _fontFamily = stimulus['fontFamily'] as String?;
  }

  Future<void> _speakWord() async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.4);
      await _tts.setPitch(1.0);

      _tts.setCompletionHandler(() {
        if (mounted) {
          setState(() => _phase = _Phase.spelling);
          _inputFocus.requestFocus();
        }
      });

      await _tts.speak(_word);
    } catch (_) {
      _ttsAvailable = false;
      if (mounted) {
        setState(() => _phase = _Phase.spelling);
      }
    }
  }

  void _replayWord() {
    _tts.speak(_word);
  }

  void _showNextCue() {
    if (_cueLevel < widget.item.cues.length - 1) {
      setState(() => _cueLevel++);
    }
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
    _tts.stop();
    _inputController.dispose();
    _inputFocus.dispose();
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
        const SizedBox(height: AppDimens.d12),
        if (!_ttsAvailable) ...[
          Text(
            'TTS is not available. The word will be shown.',
            style: AppTextStyles.bodySm.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: AppDimens.d16),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => setState(() => _phase = _Phase.spelling),
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
              child: Container(
                height: AppDimens.touchSmall,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.d32),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                ),
                child: Text(
                  'Continue',
                  style: AppTextStyles.button.copyWith(
                      color: AppColors.onPrimary),
                ),
              ),
            ),
          ),
        ] else
          Text(
            'The word is being spoken…',
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
        const SizedBox(height: AppDimens.d20),

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
        const SizedBox(height: AppDimens.d8),
        Text(
          'Tap to hear again',
          style: AppTextStyles.caption.copyWith(color: AppColors.muted),
        ),
        const SizedBox(height: AppDimens.d20),

        // Optional icon hint
        if (_iconCodePoint != null)
          Container(
            width: 80,
            height: 80,
            margin: const EdgeInsets.only(bottom: AppDimens.d16),
            decoration: BoxDecoration(
              color: AppColors.surfaceSoft,
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            ),
            child: Center(
              child: Icon(
                IconData(
                  _iconCodePoint!,
                  fontFamily: _fontFamily ?? 'MaterialIcons',
                ),
                size: AppDimens.d48,
                color: AppColors.body,
              ),
            ),
          ).animate().fadeIn(duration: 300.ms),

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

        // Text input
        TextField(
          controller: _inputController,
          focusNode: _inputFocus,
          textCapitalization: TextCapitalization.none,
          autocorrect: false,
          decoration: InputDecoration(
            hintText: 'Type the spelling…',
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
              borderSide:
                  BorderSide(color: AppColors.accentTeal, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppDimens.d16,
              vertical: AppDimens.d12,
            ),
          ),
          style: AppTextStyles.displaySm.copyWith(
            color: AppColors.ink,
            letterSpacing: 2.0,
          ),
          onSubmitted: (_) => _submitAnswer(),
        ),
        const SizedBox(height: AppDimens.d16),

        // Action row
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

  // ── Result ─────────────────────────────────────────────────────────

  Widget _buildResult() {
    final userAnswer = _inputController.text.trim();
    final isCorrect = widget.item.isCorrect(userAnswer);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isCorrect
              ? Icons.check_circle_rounded
              : Icons.cancel_rounded,
          size: AppDimens.iconXl,
          color: isCorrect ? AppColors.success : AppColors.error,
        ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
        const SizedBox(height: AppDimens.d16),
        Text(
          isCorrect ? 'Correct!' : 'Not quite',
          style: AppTextStyles.titleLg.copyWith(color: AppColors.ink),
        ),
        const SizedBox(height: AppDimens.d12),

        // Show user's answer vs correct
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
        if (_cueLevel >= 0) ...[
          const SizedBox(height: AppDimens.d8),
          Text(
            'Hints used: ${_cueLevel + 1}',
            style: AppTextStyles.caption.copyWith(color: AppColors.muted),
          ),
        ],
      ],
    ).animate().fadeIn(duration: 400.ms);
  }
}

enum _Phase { listening, spelling, result }
