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

/// 7E — Conversational Script Training (scriptTraining).
///
/// Displays a functional script (e.g. "Ordering Coffee") → TTS models each
/// line → user reads/repeats → cue fading across attempts.
///
/// Three cue levels:
/// - `full` — entire text shown
/// - `firstLetters` — only the first letter of each word
/// - `blank` — no text, user recalls from memory
///
/// Stimulus schema:
/// ```json
/// {
///   "scriptTitle": "Ordering Coffee",
///   "lines": [
///     "I would like a coffee please.",
///     "Can I have it with milk?",
///     "Thank you very much."
///   ],
///   "cueLevel": "full"
/// }
/// ```
class ScriptTrainingWidget extends StatefulWidget {
  const ScriptTrainingWidget({
    super.key,
    required this.item,
    required this.onAnswer,
  });

  final ExerciseItemModel item;
  final void Function(String answer) onAnswer;

  @override
  State<ScriptTrainingWidget> createState() => _ScriptTrainingWidgetState();
}

class _ScriptTrainingWidgetState extends State<ScriptTrainingWidget> {
  _Phase _phase = _Phase.intro;
  bool _ttsAvailable = true;

  late FlutterTts _tts;
  late String _scriptTitle;
  late List<String> _lines;
  late String _cueLevel;

  int _currentLineIndex = 0;
  final List<_LineResult> _lineResults = [];
  bool _lineRecorded = false;
  double _finalAccuracy = 0.0;

  @override
  void initState() {
    super.initState();
    _tts = FlutterTts();
    _parseStimulus();
  }

  @override
  void didUpdateWidget(covariant ScriptTrainingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.id != widget.item.id) {
      _tts.stop();
      _phase = _Phase.intro;
      _currentLineIndex = 0;
      _lineResults.clear();
      _lineRecorded = false;
      _parseStimulus();
    }
  }

  void _parseStimulus() {
    final s = widget.item.stimulus;
    _scriptTitle = (s['scriptTitle'] as String?) ?? 'Script';
    _lines = ((s['lines'] as List<dynamic>?) ?? [])
        .map((e) => e.toString())
        .toList();
    _cueLevel = (s['cueLevel'] as String?) ?? 'full';
  }

  Future<void> _speakCurrentLine() async {
    if (_currentLineIndex >= _lines.length) return;
    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.45);
      await _tts.setPitch(1.0);

      _tts.setCompletionHandler(() {
        if (mounted) {
          setState(() => _phase = _Phase.record);
        }
      });

      await _tts.speak(_lines[_currentLineIndex]);
    } catch (_) {
      _ttsAvailable = false;
      if (mounted) setState(() => _phase = _Phase.record);
    }
  }

  Future<void> _toggleRecording() async {
    final speech = context.read<SpeechService>();

    if (speech.isListening) {
      final transcription = await speech.stopListening(expectedText: _lines[_currentLineIndex]);
      _processLineResult(transcription, speech);
    } else {
      await speech.startListening();
      if (mounted) setState(() {});
    }
  }

  void _processLineResult(String transcription, SpeechService speech) {
    if (_lineRecorded) return;

    final expected = _lines[_currentLineIndex];
    final wordScores = speech.scoreWordByWord(expected, transcription);
    final accuracy = speech.overallAccuracy(wordScores);
    final errorType = speech.classifyError(expected, transcription);

    setState(() {
      _lineResults.add(_LineResult(
        lineText: expected,
        transcription: transcription,
        wordScores: wordScores,
        accuracy: accuracy,
        errorType: errorType,
      ));
      _lineRecorded = true;
      _phase = _Phase.lineFeedback;
    });
  }

  void _advanceToNextLine() {
    if (_currentLineIndex < _lines.length - 1) {
      setState(() {
        _currentLineIndex++;
        _lineRecorded = false;
        _phase = _Phase.lineModel;
      });
      _speakCurrentLine();
    } else {
      // All lines done — compute overall score and submit
      _submitOverallResult();
    }
  }

  void _submitOverallResult() {
    final overallAcc = _lineResults.isEmpty
        ? 0.0
        : _lineResults.map((r) => r.accuracy).reduce((a, b) => a + b) /
            _lineResults.length;

    setState(() {
      _finalAccuracy = overallAcc;
      _phase = _Phase.summary;
    });
  }

  void _startScript() {
    setState(() => _phase = _Phase.lineModel);
    _speakCurrentLine();
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (_phase) {
      case _Phase.intro:
        return _buildIntro();
      case _Phase.lineModel:
        return _buildLineModel();
      case _Phase.record:
        return _buildRecord();
      case _Phase.lineFeedback:
        return _buildLineFeedback();
      case _Phase.summary:
        return _buildSummary();
    }
  }

  // ── Intro ──────────────────────────────────────────────────────────

  Widget _buildIntro() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.chat_bubble_outline_rounded,
          size: AppDimens.iconXl,
          color: AppColors.accentPurple,
        ),
        const SizedBox(height: AppDimens.d16),
        Text(
          _scriptTitle,
          style: AppTextStyles.displaySm.copyWith(color: AppColors.ink),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimens.d8),
        Text(
          '${_lines.length} lines · $_cueLevelLabel',
          style: AppTextStyles.bodySm.copyWith(color: AppColors.muted),
        ),
        const SizedBox(height: AppDimens.d20),

        // Preview lines
        ...List.generate(_lines.length, (i) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppDimens.d8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: AppDimens.d24,
                  height: AppDimens.d24,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${i + 1}',
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(width: AppDimens.d12),
                Expanded(
                  child: Text(
                    _getDisplayText(_lines[i]),
                    style:
                        AppTextStyles.bodyMd.copyWith(color: AppColors.body),
                  ),
                ),
              ],
            ),
          );
        }),

        const SizedBox(height: AppDimens.d20),
        _buildActionButton('Start Practice', AppColors.primary, _startScript),
      ],
    ).animate().fadeIn(duration: 400.ms);
  }

  // ── Line Model (TTS speaking) ──────────────────────────────────────

  Widget _buildLineModel() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLineIndicator(),
        const SizedBox(height: AppDimens.d16),
        Icon(
          Icons.hearing_rounded,
          size: AppDimens.iconXl,
          color: AppColors.accentTeal,
        ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
              begin: const Offset(1, 1),
              end: const Offset(1.15, 1.15),
              duration: 800.ms,
            ),
        const SizedBox(height: AppDimens.d16),
        Text(
          'Listen to line ${_currentLineIndex + 1}…',
          style: AppTextStyles.titleMd.copyWith(color: AppColors.ink),
        ),
        const SizedBox(height: AppDimens.d12),
        if (!_ttsAvailable) ...[
          _buildLineDisplay(),
          const SizedBox(height: AppDimens.d16),
          _buildActionButton(
            'Ready to speak',
            AppColors.primary,
            () => setState(() => _phase = _Phase.record),
          ),
        ] else
          Text(
            'The line is being spoken…',
            style: AppTextStyles.bodySm.copyWith(color: AppColors.muted),
          ),
      ],
    );
  }

  // ── Record ─────────────────────────────────────────────────────────

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
            _buildLineIndicator(),
            const SizedBox(height: AppDimens.d12),

            Text(
              'Your turn — say:',
              style: AppTextStyles.titleMd.copyWith(color: AppColors.ink),
            ),
            const SizedBox(height: AppDimens.d12),

            // Show text with cue fading
            _buildLineDisplay(),
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
          ],
        );
      },
    );
  }

  // ── Line Feedback ──────────────────────────────────────────────────

  Widget _buildLineFeedback() {
    final result = _lineResults.last;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLineIndicator(),
        const SizedBox(height: AppDimens.d16),

        SpeechFeedbackCard(
          errorType: result.errorType,
          wordScores: result.wordScores,
          similarity: result.accuracy,
        ),

        const SizedBox(height: AppDimens.d20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildActionButton(
              'Retry',
              AppColors.warning,
              _retryCurrentLine,
            ),
            const SizedBox(width: AppDimens.d16),
            _buildActionButton(
              _currentLineIndex < _lines.length - 1
                  ? 'Next Line'
                  : 'See Results',
              AppColors.primary,
              _advanceToNextLine,
            ),
          ],
        ),
      ],
    ).animate().fadeIn(duration: 300.ms);
  }

  void _retryCurrentLine() {
    setState(() {
      if (_lineResults.isNotEmpty) {
        _lineResults.removeLast();
      }
      _lineRecorded = false;
      _phase = _Phase.record;
    });
  }

  // ── Summary ────────────────────────────────────────────────────────

  Widget _buildSummary() {
    final overallAcc = _lineResults.isEmpty
        ? 0.0
        : _lineResults.map((r) => r.accuracy).reduce((a, b) => a + b) /
            _lineResults.length;
    final pct = (overallAcc * 100).toStringAsFixed(0);
    final color = overallAcc >= 0.85
        ? AppColors.success
        : overallAcc >= 0.50
            ? AppColors.warning
            : AppColors.error;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          overallAcc >= 0.85
              ? Icons.check_circle_rounded
              : Icons.info_rounded,
          size: AppDimens.iconXl,
          color: color,
        ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
        const SizedBox(height: AppDimens.d16),
        Text(
          '$pct% Overall Accuracy',
          style: AppTextStyles.titleLg.copyWith(color: color),
        ),
        const SizedBox(height: AppDimens.d8),
        Text(
          _scriptTitle,
          style: AppTextStyles.bodySm.copyWith(color: AppColors.muted),
        ),
        const SizedBox(height: AppDimens.d20),

        // Per-line breakdown
        ...List.generate(_lineResults.length, (i) {
          final r = _lineResults[i];
          final linePct = (r.accuracy * 100).toStringAsFixed(0);
          final lineColor = r.accuracy >= 0.85
              ? AppColors.success
              : r.accuracy >= 0.50
                  ? AppColors.warning
                  : AppColors.error;

          return Padding(
            padding: const EdgeInsets.only(bottom: AppDimens.d8),
            child: Row(
              children: [
                Container(
                  width: AppDimens.d24,
                  height: AppDimens.d24,
                  decoration: BoxDecoration(
                    color: lineColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${i + 1}',
                      style: AppTextStyles.caption.copyWith(color: lineColor),
                    ),
                  ),
                ),
                const SizedBox(width: AppDimens.d12),
                Expanded(
                  child: Text(
                    r.lineText,
                    style:
                        AppTextStyles.bodySm.copyWith(color: AppColors.body),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '$linePct%',
                  style: AppTextStyles.titleSm.copyWith(color: lineColor),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: AppDimens.d24),
        _buildActionButton(
          'Finish',
          AppColors.primary,
          () => widget.onAnswer('accuracy:${_finalAccuracy.toStringAsFixed(2)}'),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms);
  }

  // ── Shared widgets ─────────────────────────────────────────────────

  Widget _buildLineIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_lines.length, (i) {
        final isCompleted = i < _currentLineIndex ||
            (i == _currentLineIndex && _lineRecorded);
        final isCurrent = i == _currentLineIndex && !_lineRecorded;
        return Container(
          width: AppDimens.d8,
          height: AppDimens.d8,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted
                ? AppColors.success
                : isCurrent
                    ? AppColors.primary
                    : AppColors.hairline,
          ),
        );
      }),
    );
  }

  Widget _buildLineDisplay() {
    final text = _getDisplayText(_lines[_currentLineIndex]);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimens.d16),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
      ),
      child: Text(
        text,
        style: AppTextStyles.bodyLg.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
          letterSpacing: _cueLevel == 'firstLetters' ? 2.0 : 0,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  /// Applies cue fading to a line of text.
  String _getDisplayText(String line) {
    switch (_cueLevel) {
      case 'full':
        return line;
      case 'firstLetters':
        return line.split(' ').map((w) {
          if (w.isEmpty) return w;
          return '${w[0]}${'_' * (w.length - 1)}';
        }).join(' ');
      case 'blank':
        return '• • •';
      default:
        return line;
    }
  }

  String get _cueLevelLabel {
    switch (_cueLevel) {
      case 'full':
        return 'Full text';
      case 'firstLetters':
        return 'First letters only';
      case 'blank':
        return 'From memory';
      default:
        return _cueLevel;
    }
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
}

// ─────────────────────────────────────────────────────────────────────────────
// Internal models
// ─────────────────────────────────────────────────────────────────────────────

enum _Phase { intro, lineModel, record, lineFeedback, summary }

class _LineResult {
  const _LineResult({
    required this.lineText,
    required this.transcription,
    required this.wordScores,
    required this.accuracy,
    required this.errorType,
  });

  final String lineText;
  final String transcription;
  final List<WordScore> wordScores;
  final double accuracy;
  final SpeechErrorType errorType;
}
