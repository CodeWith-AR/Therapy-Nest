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

/// 7A — Word Repetition (speech_repeat).
///
/// TTS speaks a target word → user taps mic → repeats → Vosk transcribes →
/// Jaro-Winkler similarity → color-coded feedback.
///
/// Stimulus schema:
/// ```json
/// {
///   "targetWord": "cat",
///   "ttsRate": 0.8
/// }
/// ```
class WordRepetitionWidget extends StatefulWidget {
  const WordRepetitionWidget({
    super.key,
    required this.item,
    required this.onAnswer,
  });

  final ExerciseItemModel item;
  final void Function(String answer) onAnswer;

  @override
  State<WordRepetitionWidget> createState() => _WordRepetitionWidgetState();
}

class _WordRepetitionWidgetState extends State<WordRepetitionWidget> {
  _Phase _phase = _Phase.listen;
  bool _answered = false;
  bool _ttsAvailable = true;
  int _cueLevel = -1;

  late FlutterTts _tts;
  late String _targetWord;
  late double _ttsRate;

  String? _transcription;
  SpeechErrorType? _errorType;
  double? _similarity;

  @override
  void initState() {
    super.initState();
    _tts = FlutterTts();
    _parseStimulus();
    _speakTarget();
  }

  @override
  void didUpdateWidget(covariant WordRepetitionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.id != widget.item.id) {
      _tts.stop();
      _phase = _Phase.listen;
      _answered = false;
      _cueLevel = -1;
      _transcription = null;
      _errorType = null;
      _similarity = null;
      _parseStimulus();
      _speakTarget();
    }
  }

  void _parseStimulus() {
    final s = widget.item.stimulus;
    _targetWord = (s['targetWord'] as String?) ?? widget.item.correctAnswer;
    _ttsRate = (s['ttsRate'] as num?)?.toDouble() ?? 0.8;
  }

  Future<void> _speakTarget() async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(_ttsRate);
      await _tts.setPitch(1.0);

      _tts.setCompletionHandler(() {
        if (mounted) setState(() => _phase = _Phase.record);
      });

      await _tts.speak(_targetWord);
    } catch (_) {
      _ttsAvailable = false;
      if (mounted) setState(() => _phase = _Phase.record);
    }
  }

  void _replayTTS() {
    _tts.speak(_targetWord);
  }

  void _showNextCue() {
    if (_cueLevel < widget.item.cues.length - 1) {
      setState(() => _cueLevel++);
    }
  }

  Future<void> _toggleRecording() async {
    final speech = context.read<SpeechService>();

    if (speech.isListening) {
      final transcription = await speech.stopListening(expectedText: _targetWord);
      _processTranscription(transcription, speech);
    } else {
      await speech.startListening();
      if (mounted) setState(() {});
    }
  }

  void _processTranscription(String transcription, SpeechService speech) {
    if (_answered) return;

    final similarity = speech.computeSimilarity(_targetWord, transcription);
    final errorType = speech.classifyError(_targetWord, transcription);
    speech.setPreviousAnswer(_targetWord);

    setState(() {
      _transcription = transcription;
      _similarity = similarity;
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
          'Listen carefully…',
          style: AppTextStyles.titleLg.copyWith(color: AppColors.ink),
        ),
        const SizedBox(height: AppDimens.d12),
        if (!_ttsAvailable) ...[
          Text(
            _targetWord,
            style: AppTextStyles.displayMd.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: AppDimens.d16),
          _buildContinueButton(() => setState(() => _phase = _Phase.record)),
        ] else
          Text(
            'The word is being spoken…',
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
              'Say the word:',
              style: AppTextStyles.titleMd.copyWith(color: AppColors.ink),
            ),
            const SizedBox(height: AppDimens.d8),
            Text(
              _targetWord,
              style:
                  AppTextStyles.displayLg.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: AppDimens.d24),

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
            Material(
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
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Cueing hint
            if (_cueLevel >= 0 && _cueLevel < widget.item.cues.length) ...[
              const SizedBox(height: AppDimens.d12),
              _buildCueHint(),
            ],

            // Hint button
            if (!_answered && _cueLevel < widget.item.cues.length - 1) ...[
              const SizedBox(height: AppDimens.d12),
              _buildHintButton(),
            ],
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
          'Target: $_targetWord',
          style: AppTextStyles.titleMd.copyWith(color: AppColors.ink),
        ),
        const SizedBox(height: AppDimens.d16),
        if (_errorType != null)
          SpeechFeedbackCard(
            errorType: _errorType!,
            transcription: _transcription,
            similarity: _similarity,
          ),
        if (_cueLevel >= 0) ...[
          const SizedBox(height: AppDimens.d8),
          Text(
            'Hints used: ${_cueLevel + 1}',
            style: AppTextStyles.caption.copyWith(color: AppColors.muted),
          ),
        ],
        const SizedBox(height: AppDimens.d24),
        _buildContinueButton(() {
          widget.onAnswer(_transcription ?? '');
        }),
      ],
    ).animate().fadeIn(duration: 400.ms);
  }

  // ── Shared widgets ─────────────────────────────────────────────────

  Widget _buildContinueButton(VoidCallback onTap) {
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
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          ),
          child: Text(
            'Continue',
            style: AppTextStyles.button.copyWith(color: AppColors.onPrimary),
          ),
        ),
      ),
    );
  }

  Widget _buildCueHint() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimens.d12),
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
              style:
                  AppTextStyles.bodySm.copyWith(color: AppColors.bodyStrong),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms);
  }

  Widget _buildHintButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _showNextCue,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        child: Container(
          height: AppDimens.touchSmall,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.d24),
          decoration: BoxDecoration(
            color: AppColors.surfaceSoft,
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          ),
          child: Text(
            'Show Hint',
            style: AppTextStyles.buttonSm.copyWith(color: AppColors.muted),
          ),
        ),
      ),
    );
  }
}

enum _Phase { listen, record, result }
