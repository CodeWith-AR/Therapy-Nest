import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/services/speech_service.dart';
import '../../../core/widgets/microphone_button.dart';
import '../../../core/widgets/waveform_visualizer.dart';
import '../../../data/models/assessment_item_model.dart';
import '../viewmodels/assessment_view_model.dart';
import '../widgets/domain_progress_bar.dart';
import '../widgets/option_button.dart';
import '../widgets/overall_progress_indicator.dart';
import '../widgets/sequence_display.dart';
import '../widgets/stimulus_card.dart';
import '../widgets/symbol_grid.dart';

/// Main assessment exercise page — runs through all domains.
///
/// Adapts its display per task type:
/// - Multiple choice (Language/Comprehension): stimulus + 4 option buttons
/// - Sequence recall (Memory): show shapes → select correct sequence
/// - Symbol search (Attention): grid with tappable targets
/// - Number recognition (Math): large display + 4 options
/// - Speech (placeholder — skip-only for now)
class AssessmentExercisePage extends StatefulWidget {
  const AssessmentExercisePage({super.key});

  @override
  State<AssessmentExercisePage> createState() => _AssessmentExercisePageState();
}

class _AssessmentExercisePageState extends State<AssessmentExercisePage> {
  @override
  void initState() {
    super.initState();
    // Start the assessment flow
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AssessmentViewModel>().startAssessment();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AssessmentViewModel>();

    // Navigate to completion when done
    if (vm.isComplete) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.go(AppRoutes.assessmentComplete);
        }
      });
      // Return immediately — don't try to render currentItem
      return Scaffold(
        backgroundColor: AppColors.canvas,
        body: const SizedBox.shrink(),
      );
    }

    final item = vm.currentItem;
    if (item == null) {
      return Scaffold(
        backgroundColor: AppColors.canvas,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.d20),
          child: Column(
            children: [
              const SizedBox(height: AppDimens.d12),

              // ── Overall progress ──
              OverallProgressIndicator(
                currentDomainIndex: vm.currentDomainIndex,
                totalDomains: vm.domainOrder.length,
                currentDomainProgress: vm.domainProgress,
              ),

              const SizedBox(height: AppDimens.d16),

              // ── Domain progress ──
              DomainProgressBar(
                domainName: AssessmentViewModel.domainDisplayName(
                    vm.currentDomain),
                currentItem: vm.currentItemIndex + 1,
                totalItems: vm.currentItems.length,
                progress: vm.domainProgress,
              ),

              const SizedBox(height: AppDimens.d20),

              // ── Content area ──
              Expanded(
                child: _buildTaskContent(context, vm, item),
              ),

              // ── Skip domain button ──
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: AppDimens.d12),
                child: AppButton(
                  label: AppStrings.assessmentSkipDomain,
                  variant: AppButtonVariant.text,
                  onPressed: vm.showingFeedback
                      ? null
                      : () => vm.skipDomain(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the task-specific content based on the item's task type.
  Widget _buildTaskContent(
    BuildContext context,
    AssessmentViewModel vm,
    AssessmentItemModel item,
  ) {
    switch (item.taskType) {
      case AssessmentTaskType.multipleChoice:
        return _MultipleChoiceTask(vm: vm, item: item);
      case AssessmentTaskType.auditoryChoice:
        return _AuditoryChoiceTask(vm: vm, item: item);
      case AssessmentTaskType.sequenceRecall:
        return _SequenceRecallTask(vm: vm, item: item);
      case AssessmentTaskType.symbolSearch:
        return _SymbolSearchTask(vm: vm, item: item);
      case AssessmentTaskType.speechRepetition:
        return _SpeechRepetitionTask(vm: vm, item: item);
      case AssessmentTaskType.numberRecognition:
        return _NumberRecognitionTask(vm: vm, item: item);
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════
// TASK-SPECIFIC WIDGETS
// ═══════════════════════════════════════════════════════════════════════

/// Multiple choice: show icon stimulus + 4 option buttons.
class _MultipleChoiceTask extends StatelessWidget {
  const _MultipleChoiceTask({required this.vm, required this.item});
  final AssessmentViewModel vm;
  final AssessmentItemModel item;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Stimulus
        Expanded(
          flex: 3,
          child: Center(
            child: StimulusCard(item: item)
                .animate()
                .fadeIn(duration: 300.ms),
          ),
        ),

        const SizedBox(height: AppDimens.d16),

        // Options
        Expanded(
          flex: 4,
          child: ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: item.options.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: AppDimens.d12),
            itemBuilder: (context, index) {
              final option = item.options[index];
              bool? feedbackState;

              if (vm.showingFeedback) {
                if (option == item.correctAnswer) {
                  feedbackState = true;
                } else if (vm.lastAnswerCorrect == false &&
                    vm.currentItem?.id == item.id) {
                  // Show the selected wrong answer
                  // We don't have direct access to which was selected,
                  // but correct answer feedback is most important
                  feedbackState = null;
                }
              }

              return OptionButton(
                label: option,
                feedbackState: feedbackState,
                isDisabled: vm.showingFeedback,
                onTap: () => vm.submitAnswer(option),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Auditory choice: TTS speaks, user selects matching option.
class _AuditoryChoiceTask extends StatefulWidget {
  const _AuditoryChoiceTask({required this.vm, required this.item});
  final AssessmentViewModel vm;
  final AssessmentItemModel item;

  @override
  State<_AuditoryChoiceTask> createState() => _AuditoryChoiceTaskState();
}

class _AuditoryChoiceTaskState extends State<_AuditoryChoiceTask> {
  @override
  void initState() {
    super.initState();
    // Auto-speak the TTS text when the item loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ttsText = widget.item.stimulus['ttsText'] as String? ?? '';
      if (ttsText.isNotEmpty) {
        widget.vm.speak(ttsText);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ttsText = widget.item.stimulus['ttsText'] as String? ?? '';

    return Column(
      children: [
        // Stimulus card with replay button
        Expanded(
          flex: 3,
          child: Center(
            child: GestureDetector(
              onTap: () => widget.vm.speak(ttsText),
              child: StimulusCard(item: widget.item)
                  .animate()
                  .fadeIn(duration: 300.ms),
            ),
          ),
        ),

        const SizedBox(height: AppDimens.d16),

        // Options
        Expanded(
          flex: 4,
          child: ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.item.options.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: AppDimens.d12),
            itemBuilder: (context, index) {
              final option = widget.item.options[index];
              bool? feedbackState;

              if (widget.vm.showingFeedback &&
                  option == widget.item.correctAnswer) {
                feedbackState = true;
              }

              return OptionButton(
                label: option,
                feedbackState: feedbackState,
                isDisabled: widget.vm.showingFeedback,
                onTap: () => widget.vm.submitAnswer(option),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Sequence recall: show shapes → hide → pick correct sequence.
class _SequenceRecallTask extends StatelessWidget {
  const _SequenceRecallTask({required this.vm, required this.item});
  final AssessmentViewModel vm;
  final AssessmentItemModel item;

  @override
  Widget build(BuildContext context) {
    final sequence = (item.stimulus['sequence'] as List<dynamic>?)
            ?.cast<String>() ??
        [];
    final displayMs =
        (item.stimulus['displayMs'] as int?) ?? 3000;

    if (vm.showingSequence) {
      // Phase 1: Display the sequence
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            AppStrings.assessmentRememberSeq,
            style: AppTextStyles.titleLg.copyWith(color: AppColors.ink),
          ),
          const SizedBox(height: AppDimens.d32),
          SequenceDisplay(
            sequence: sequence,
            displayDurationMs: displayMs,
            onComplete: () => vm.onSequenceDisplayComplete(),
          ),
          const SizedBox(height: AppDimens.d32),
          // Countdown-style visual feedback
          SizedBox(
            width: AppDimens.d48,
            height: AppDimens.d48,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor:
                  AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ],
      );
    }

    // Phase 2: Pick the correct sequence
    return Column(
      children: [
        const SizedBox(height: AppDimens.d24),
        Text(
          'Which sequence was shown?',
          style: AppTextStyles.titleLg.copyWith(color: AppColors.ink),
        ).animate().fadeIn(duration: 300.ms),
        const SizedBox(height: AppDimens.d24),
        Expanded(
          child: ListView.separated(
            itemCount: item.options.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: AppDimens.d12),
            itemBuilder: (context, index) {
              final option = item.options[index];
              bool? feedbackState;

              if (vm.showingFeedback &&
                  option == item.correctAnswer) {
                feedbackState = true;
              }

              return OptionButton(
                label: _formatSequenceLabel(option),
                feedbackState: feedbackState,
                isDisabled: vm.showingFeedback,
                onTap: () => vm.submitAnswer(option),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Converts "red_circle, blue_square" into "🔴 🟦" for display.
  String _formatSequenceLabel(String option) {
    final shapes = option.split(', ');
    return shapes.map((s) {
      switch (s.trim()) {
        case 'red_circle':
          return '🔴';
        case 'blue_square':
          return '🟦';
        case 'green_triangle':
          return '🔺';
        case 'yellow_star':
          return '⭐';
        default:
          return '⬜';
      }
    }).join(' ');
  }
}

/// Symbol search: grid of symbols, tap the targets.
class _SymbolSearchTask extends StatelessWidget {
  const _SymbolSearchTask({required this.vm, required this.item});
  final AssessmentViewModel vm;
  final AssessmentItemModel item;

  @override
  Widget build(BuildContext context) {
    final grid = (item.stimulus['grid'] as List<dynamic>?)
            ?.cast<String>() ??
        [];
    final target = item.stimulus['target'] as String? ?? '';
    final gridCols = (item.stimulus['gridCols'] as int?) ?? 4;
    final targetCount =
        (item.stimulus['targetCount'] as int?) ?? 0;

    return Column(
      children: [
        const SizedBox(height: AppDimens.d8),
        Text(
          AppStrings.assessmentFindTarget,
          style: AppTextStyles.titleLg.copyWith(color: AppColors.ink),
        ),
        const SizedBox(height: AppDimens.d16),
        Expanded(
          child: Center(
            child: SymbolGrid(
              key: ValueKey('${item.id}_${vm.currentItemIndex}'),
              grid: grid,
              target: target,
              gridCols: gridCols,
              foundCount: vm.attentionFoundCount,
              targetCount: targetCount,
              onTargetTapped: () => vm.tapAttentionTarget(),
            ),
          ),
        ),
      ],
    );
  }
}

/// Speech repetition task: TTS plays word, user repeats via microphone or manual confirmation.
class _SpeechRepetitionTask extends StatefulWidget {
  const _SpeechRepetitionTask({required this.vm, required this.item});
  final AssessmentViewModel vm;
  final AssessmentItemModel item;

  @override
  State<_SpeechRepetitionTask> createState() => _SpeechRepetitionTaskState();
}

class _SpeechRepetitionTaskState extends State<_SpeechRepetitionTask> {
  String? _transcription;
  double? _similarity;
  bool _answered = false;

  String get _targetWord =>
      (widget.item.stimulus['ttsText'] as String?) ?? widget.item.correctAnswer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.vm.speak(_targetWord);
      }
    });
  }

  @override
  void didUpdateWidget(_SpeechRepetitionTask oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.id != widget.item.id) {
      _transcription = null;
      _similarity = null;
      _answered = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.vm.speak(_targetWord);
        }
      });
    }
  }

  Future<void> _toggleRecording() async {
    if (_answered || widget.vm.showingFeedback) return;
    final speech = context.read<SpeechService>();

    if (speech.isListening) {
      final transcription =
          await speech.stopListening(expectedText: _targetWord);
      _processTranscription(transcription, speech);
    } else {
      await speech.startListening();
      if (mounted) setState(() {});
    }
  }

  void _processTranscription(String transcription, SpeechService speech) {
    if (_answered) return;

    final similarity = speech.computeSimilarity(_targetWord, transcription);
    setState(() {
      _transcription = transcription;
      _similarity = similarity;
    });

    // Auto-advance if match is close or recognized
    if (similarity >= 0.70 ||
        transcription.toLowerCase().trim() == _targetWord.toLowerCase().trim()) {
      _confirmAnswer(widget.item.correctAnswer);
    }
  }

  void _confirmAnswer(String answer) {
    if (_answered || widget.vm.showingFeedback) return;
    setState(() => _answered = true);
    widget.vm.submitAnswer(answer);
  }

  @override
  Widget build(BuildContext context) {
    final speech = context.watch<SpeechService>();
    final micState = speech.isProcessing
        ? MicButtonState.processing
        : speech.isListening
            ? MicButtonState.listening
            : MicButtonState.idle;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.d16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: AppDimens.d12),
          Text(
            'Repeat the word:',
            style: AppTextStyles.titleMd.copyWith(color: AppColors.ink),
          ),
          const SizedBox(height: AppDimens.d12),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.d24,
              vertical: AppDimens.d16,
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceWhite,
              borderRadius: BorderRadius.circular(AppDimens.radiusLg),
              border: Border.all(color: AppColors.hairlineSoft),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Text(
              _targetWord,
              style: AppTextStyles.displayLg.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ).animate().fadeIn(duration: 300.ms).scale(
                begin: const Offset(0.95, 0.95),
                end: const Offset(1, 1),
              ),
          const SizedBox(height: AppDimens.d16),

          // Replay audio button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => widget.vm.speak(_targetWord),
              borderRadius: BorderRadius.circular(AppDimens.radiusFull),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.d12,
                  vertical: 6,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.volume_up_rounded,
                      size: AppDimens.iconSm,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Hear again',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: AppDimens.d20),

          // Waveform indicator
          SizedBox(
            height: 48,
            child: WaveformVisualizer(isActive: speech.isListening),
          ),

          const SizedBox(height: AppDimens.d16),

          // Microphone Button
          MicrophoneButton(
            state: micState,
            onTap: _toggleRecording,
          ),

          const SizedBox(height: AppDimens.d12),
          Text(
            speech.isListening
                ? 'Listening… tap to stop'
                : 'Tap microphone and speak',
            style: AppTextStyles.caption.copyWith(
              color: speech.isListening ? AppColors.error : AppColors.muted,
              fontWeight:
                  speech.isListening ? FontWeight.w600 : FontWeight.normal,
            ),
          ),

          // Transcription display if any
          if (_transcription != null && _transcription!.isNotEmpty) ...[
            const SizedBox(height: AppDimens.d16),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.d16,
                vertical: AppDimens.d8,
              ),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(AppDimens.radiusMd),
              ),
              child: Text(
                _similarity != null
                    ? 'Heard: "$_transcription" (${(_similarity! * 100).toStringAsFixed(0)}% match)'
                    : 'Heard: "$_transcription"',
                style: AppTextStyles.bodySm.copyWith(color: AppColors.body),
              ),
            ),
          ],

          const SizedBox(height: AppDimens.d24),

          // Accessible manual confirmation button (for patients with dysarthria, soft voice, or background noise)
          AppButton(
            label: 'I Said It',
            icon: Icons.check_circle_outline_rounded,
            variant: AppButtonVariant.secondary,
            isEnabled: !_answered && !widget.vm.showingFeedback,
            onPressed: () => _confirmAnswer(widget.item.correctAnswer),
          ),

          const SizedBox(height: AppDimens.d16),
        ],
      ),
    );
  }
}

/// Number recognition: large display + 4 options.
class _NumberRecognitionTask extends StatelessWidget {
  const _NumberRecognitionTask({required this.vm, required this.item});
  final AssessmentViewModel vm;
  final AssessmentItemModel item;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Stimulus
        Expanded(
          flex: 3,
          child: Center(
            child: StimulusCard(item: item)
                .animate()
                .fadeIn(duration: 300.ms),
          ),
        ),

        const SizedBox(height: AppDimens.d16),

        // Options
        Expanded(
          flex: 4,
          child: ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: item.options.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: AppDimens.d12),
            itemBuilder: (context, index) {
              final option = item.options[index];
              bool? feedbackState;

              if (vm.showingFeedback &&
                  option == item.correctAnswer) {
                feedbackState = true;
              }

              return OptionButton(
                label: option,
                feedbackState: feedbackState,
                isDisabled: vm.showingFeedback,
                onTap: () => vm.submitAnswer(option),
              );
            },
          ),
        ),
      ],
    );
  }
}
