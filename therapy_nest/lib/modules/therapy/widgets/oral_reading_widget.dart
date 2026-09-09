import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/services/speech_service.dart';
import '../../../core/widgets/microphone_button.dart';
import '../../../core/widgets/speech_feedback_card.dart';
import '../../../core/widgets/waveform_visualizer.dart';
import '../../../data/models/exercise_item_model.dart';

/// 7D — Oral Reading Aloud (oralReading).
///
/// Display a sentence on screen → user reads aloud → Vosk transcribes →
/// word-by-word accuracy is computed.
///
/// Stimulus schema:
/// ```json
/// {
///   "sentence": "The dog ran to the park.",
///   "wordCount": 7
/// }
/// ```
class OralReadingWidget extends StatefulWidget {
  const OralReadingWidget({
    super.key,
    required this.item,
    required this.onAnswer,
  });

  final ExerciseItemModel item;
  final void Function(String answer) onAnswer;

  @override
  State<OralReadingWidget> createState() => _OralReadingWidgetState();
}

class _OralReadingWidgetState extends State<OralReadingWidget> {
  _Phase _phase = _Phase.reading;
  bool _answered = false;

  late String _sentence;

  String? _transcription;
  List<WordScore>? _wordScores;
  double? _accuracy;
  SpeechErrorType? _errorType;

  @override
  void initState() {
    super.initState();
    _parseStimulus();
  }

  @override
  void didUpdateWidget(covariant OralReadingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.id != widget.item.id) {
      _phase = _Phase.reading;
      _answered = false;
      _transcription = null;
      _wordScores = null;
      _accuracy = null;
      _errorType = null;
      _parseStimulus();
    }
  }

  void _parseStimulus() {
    final s = widget.item.stimulus;
    _sentence = (s['sentence'] as String?) ?? widget.item.correctAnswer;
  }

  Future<void> _toggleRecording() async {
    final speech = context.read<SpeechService>();

    if (speech.isListening) {
      final transcription = await speech.stopListening(expectedText: _sentence);
      _processTranscription(transcription, speech);
    } else {
      await speech.startListening();
      if (mounted) setState(() {});
    }
  }

  void _processTranscription(String transcription, SpeechService speech) {
    if (_answered) return;

    final wordScores = speech.scoreWordByWord(_sentence, transcription);
    final accuracy = speech.overallAccuracy(wordScores);
    final errorType = speech.classifyError(_sentence, transcription);

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
  Widget build(BuildContext context) {
    switch (_phase) {
      case _Phase.reading:
        return _buildReading();
      case _Phase.result:
        return _buildResult();
    }
  }

  // ── Reading phase ──────────────────────────────────────────────────

  Widget _buildReading() {
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.menu_book_rounded,
                    size: AppDimens.iconMd, color: AppColors.accentPurple),
                const SizedBox(width: AppDimens.d8),
                Text(
                  'Read Aloud',
                  style: AppTextStyles.titleMd.copyWith(color: AppColors.ink),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.d20),

            // Sentence display — large readable text
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.d24,
                vertical: AppDimens.d20,
              ),
              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,
                borderRadius: BorderRadius.circular(AppDimens.radiusMd),
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
              speech.isListening
                  ? 'Reading… tap when done'
                  : 'Tap and read the sentence aloud',
              style: AppTextStyles.caption.copyWith(color: AppColors.muted),
            ),
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
          'Reading Result',
          style: AppTextStyles.titleMd.copyWith(color: AppColors.ink),
        ),
        const SizedBox(height: AppDimens.d16),

        // Original sentence
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppDimens.d12),
          decoration: BoxDecoration(
            color: AppColors.surfaceSoft,
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          ),
          child: Text(
            _sentence,
            style: AppTextStyles.bodyMd.copyWith(color: AppColors.body),
            textAlign: TextAlign.center,
          ),
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
        _buildContinueButton(() {
          widget.onAnswer(_transcription ?? '');
        }),
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
          '$pct% Word Accuracy',
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
}

enum _Phase { reading, result }
