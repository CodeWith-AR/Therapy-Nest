import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/services/speech_service.dart';
import '../../../core/widgets/microphone_button.dart';
import '../../../core/widgets/speech_feedback_card.dart';
import '../../../core/widgets/waveform_visualizer.dart';
import '../../../data/models/exercise_item_model.dart';

/// 7C — Phrase Repetition (phraseRepeat).
///
/// TTS speaks a phrase (2–8 words) → user repeats → word-by-word scoring
/// via Vosk + Jaro-Winkler. Each word is independently color-coded.
///
/// Stimulus schema:
/// ```json
/// {
///   "phrase": "the cat sat on the mat",
///   "wordCount": 6
/// }
/// ```
class PhraseRepetitionWidget extends StatefulWidget {
  const PhraseRepetitionWidget({
    super.key,
    required this.item,
    required this.onAnswer,
  });

  final ExerciseItemModel item;
  final void Function(String answer) onAnswer;

  @override
  State<PhraseRepetitionWidget> createState() => _PhraseRepetitionWidgetState();
}

class _PhraseRepetitionWidgetState extends State<PhraseRepetitionWidget> {
  _Phase _phase = _Phase.listen;
  bool _answered = false;
  bool _ttsAvailable = true;

  late FlutterTts _tts;
  late String _phrase;

  String? _transcription;
  List<WordScore>? _wordScores;
  double? _accuracy;
  SpeechErrorType? _errorType;

  @override
  void initState() {
    super.initState();
    _tts = FlutterTts();
    _parseStimulus();
    _speakPhrase();
  }

  @override
  void didUpdateWidget(covariant PhraseRepetitionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.id != widget.item.id) {
      _tts.stop();
      _phase = _Phase.listen;
      _answered = false;
      _transcription = null;
      _wordScores = null;
      _accuracy = null;
      _errorType = null;
      _parseStimulus();
      _speakPhrase();
    }
  }

  void _parseStimulus() {
    final s = widget.item.stimulus;
    _phrase = (s['phrase'] as String?) ?? widget.item.correctAnswer;
  }

  Future<void> _speakPhrase() async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.45);
      await _tts.setPitch(1.0);

      _tts.setCompletionHandler(() {
        if (mounted) setState(() => _phase = _Phase.record);
      });

      await _tts.speak(_phrase);
    } catch (_) {
      _ttsAvailable = false;
      if (mounted) setState(() => _phase = _Phase.record);
    }
  }

  void _replayTTS() {
    _tts.speak(_phrase);
  }

  Future<void> _toggleRecording() async {
    final speech = context.read<SpeechService>();

    if (speech.isListening) {
      final transcription = await speech.stopListening(expectedText: _phrase);
      _processTranscription(transcription, speech);
    } else {
      await speech.startListening();
      if (mounted) setState(() {});
    }
  }

  void _processTranscription(String transcription, SpeechService speech) {
    if (_answered) return;

    final wordScores = speech.scoreWordByWord(_phrase, transcription);
    final accuracy = speech.overallAccuracy(wordScores);
    final errorType = speech.classifyError(_phrase, transcription);

    setState(() {
      _transcription = transcription;
      _wordScores = wordScores;
      _accuracy = accuracy;
      _errorType = errorType;
      _answered = true;
      _phase = _Phase.result;
    });
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (_phase) {
      case _Phase.listen:
        return _buildListen();
      case _Phase.record:
        return _buildRecord();
      case _Phase.result:
        return _buildResult();
    }
  }

  // ── Listen phase ───────────────────────────────────────────────────

  Widget _buildListen() {
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
          'Listen to the phrase…',
          style: AppTextStyles.titleLg.copyWith(color: AppColors.ink),
        ),
        const SizedBox(height: AppDimens.d12),
        if (!_ttsAvailable) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimens.d16),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            ),
            child: Text(
              _phrase,
              style: AppTextStyles.titleMd.copyWith(color: AppColors.primary),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppDimens.d16),
          _buildActionButton(
            'Continue',
            AppColors.primary,
            () => setState(() => _phase = _Phase.record),
          ),
        ] else
          Text(
            'The phrase is being spoken…',
            style: AppTextStyles.bodySm.copyWith(color: AppColors.muted),
          ),
      ],
    );
  }

  // ── Record phase ───────────────────────────────────────────────────

  Widget _buildRecord() {
    return Consumer<SpeechService>(
      builder: (context, speech, _) {
        final micState = speech.isProcessing
            ? MicButtonState.processing
            : speech.isListening
                ? MicButtonState.listening
                : MicButtonState.idle;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Repeat the phrase:',
              style: AppTextStyles.titleMd.copyWith(color: AppColors.ink),
            ),
            const SizedBox(height: AppDimens.d12),

            // Show phrase for reference
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppDimens.d16),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(AppDimens.radiusMd),
              ),
              child: Text(
                _phrase,
                style: AppTextStyles.bodyLg.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: AppDimens.d20),

            // Waveform
            SizedBox(
              height: 60,
              child: WaveformVisualizer(isActive: speech.isListening),
            ),
            const SizedBox(height: AppDimens.d20),

            // Mic button
            MicrophoneButton(
              state: micState,
              onTap: _toggleRecording,
            ),
            const SizedBox(height: AppDimens.d12),
            Text(
              speech.isListening ? 'Tap to stop' : 'Tap to speak',
              style: AppTextStyles.caption.copyWith(color: AppColors.muted),
            ),

            // Replay
            const SizedBox(height: AppDimens.d16),
            _buildReplayButton(),
          ],
        );
      },
    );
  }

  // ── Result phase ───────────────────────────────────────────────────

  Widget _buildResult() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Phrase Repetition',
          style: AppTextStyles.titleMd.copyWith(color: AppColors.ink),
        ),
        const SizedBox(height: AppDimens.d16),

        if (_errorType != null)
          SpeechFeedbackCard(
            errorType: _errorType!,
            wordScores: _wordScores,
            similarity: _accuracy,
          ),

        const SizedBox(height: AppDimens.d12),

        // Accuracy bar
        if (_accuracy != null) _buildAccuracyBar(),
        const SizedBox(height: AppDimens.d24),
        _buildActionButton(
          'Continue',
          AppColors.primary,
          () => widget.onAnswer(_transcription ?? ''),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms);
  }

  // ── Shared widgets ─────────────────────────────────────────────────

  Widget _buildAccuracyBar() {
    final pct = (_accuracy! * 100).toStringAsFixed(0);
    final color = _accuracy! >= 0.85
        ? AppColors.success
        : _accuracy! >= 0.50
            ? AppColors.warning
            : AppColors.error;

    return Column(
      children: [
        Text(
          '$pct% Accuracy',
          style: AppTextStyles.titleSm.copyWith(color: color),
        ),
        const SizedBox(height: AppDimens.d8),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppDimens.radiusSm),
          child: LinearProgressIndicator(
            value: _accuracy!,
            minHeight: 8,
            backgroundColor: AppColors.surfaceSoft,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(String label, Color bg, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        child: Container(
          height: AppDimens.touchSmall,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.d32),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          ),
          child: Text(
            label,
            style: AppTextStyles.button.copyWith(color: AppColors.onPrimary),
          ),
        ),
      ),
    );
  }

  Widget _buildReplayButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _replayTTS,
        borderRadius: BorderRadius.circular(AppDimens.radiusFull),
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.d8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.volume_up_rounded,
                  size: AppDimens.iconSm, color: AppColors.primary),
              const SizedBox(width: AppDimens.d4),
              Text(
                'Hear again',
                style:
                    AppTextStyles.caption.copyWith(color: AppColors.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _Phase { listen, record, result }
