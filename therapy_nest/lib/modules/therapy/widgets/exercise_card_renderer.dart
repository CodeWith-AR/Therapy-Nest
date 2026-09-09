import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/exercise_item_model.dart';
import 'alternating_select_widget.dart';
import 'auditory_memory_widget.dart';
import 'dual_task_widget.dart';
import 'follow_instruction_widget.dart';
import 'multiple_choice_exercise.dart';
import 'n_back_widget.dart';
import 'oral_reading_widget.dart';
import 'phrase_repetition_widget.dart';
import 'picture_naming_widget.dart';
import 'reading_comprehension_widget.dart';
import 'script_training_widget.dart';
import 'sentence_completion_widget.dart';
import 'sequence_recall_exercise.dart';
import 'spelling_widget.dart';
import 'story_memory_widget.dart';
import 'symbol_search_widget.dart';
import 'task_switch_widget.dart';
import 'visual_sequence_widget.dart';
import 'word_fluency_widget.dart';
import 'word_pair_widget.dart';
import 'word_repetition_widget.dart';
import 'alphabetize_widget.dart';
import 'copy_writing_widget.dart';
import 'functional_reading_widget.dart';
import 'sentence_reading_widget.dart';
import 'spelling_dictation_widget.dart';
import 'word_picture_match_widget.dart';
import 'arithmetic_widget.dart';
import 'clock_reading_widget.dart';
import 'money_calculation_widget.dart';
import 'number_recognition_widget.dart';
import 'number_sequence_widget.dart';
import 'word_problem_widget.dart';

/// Factory widget that renders the correct exercise widget
/// based on the item's [ExerciseTaskType].
///
/// This is the plugin point — exercise modules (Module 4–9)
/// add their specialised widgets here.
class ExerciseCardRenderer extends StatelessWidget {
  const ExerciseCardRenderer({
    super.key,
    required this.item,
    required this.onAnswer,
  });

  /// The exercise item to render.
  final ExerciseItemModel item;

  /// Callback when user submits an answer.
  final void Function(String answer) onAnswer;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.d24),
        child: _buildExerciseWidget(),
      ),
    );
  }

  Widget _buildExerciseWidget() {
    switch (item.taskType) {
      case ExerciseTaskType.wordMatch:
        return MultipleChoiceExercise(
          item: item,
          onAnswer: onAnswer,
        );

      case ExerciseTaskType.sequenceRecall:
        // Use the enhanced grid-tap widget for items with 'gridRecall'
        // flag, otherwise fall back to the legacy sequence recall.
        if (item.stimulus['gridRecall'] == true) {
          return VisualSequenceWidget(
            item: item,
            onAnswer: onAnswer,
          );
        }
        return SequenceRecallExercise(
          item: item,
          onAnswer: onAnswer,
        );

      // ── Module 4: Memory exercises ──────────────────────────────
      case ExerciseTaskType.wordPairMatch:
        return WordPairWidget(
          item: item,
          onAnswer: onAnswer,
        );

      case ExerciseTaskType.auditoryMatch:
        return AuditoryMemoryWidget(
          item: item,
          onAnswer: onAnswer,
        );

      case ExerciseTaskType.nBackVisual:
        return NBackWidget(
          item: item,
          onAnswer: onAnswer,
        );

      case ExerciseTaskType.storyMemory:
        return StoryMemoryWidget(
          item: item,
          onAnswer: onAnswer,
        );

      // ── Module 5: Attention exercises ───────────────────────────
      case ExerciseTaskType.symbolSearch:
        return SymbolSearchWidget(
          item: item,
          onAnswer: onAnswer,
        );

      case ExerciseTaskType.numberLetterFilter:
        return AlternatingSelectWidget(
          item: item,
          onAnswer: onAnswer,
        );

      case ExerciseTaskType.dualTask:
        return DualTaskWidget(
          item: item,
          onAnswer: onAnswer,
        );

      case ExerciseTaskType.taskSwitch:
        return TaskSwitchWidget(
          item: item,
          onAnswer: onAnswer,
        );

      // ── Module 6: Language exercises ────────────────────────────
      case ExerciseTaskType.pictureNaming:
        return PictureNamingWidget(
          item: item,
          onAnswer: onAnswer,
        );

      case ExerciseTaskType.wordFluency:
        return WordFluencyWidget(
          item: item,
          onAnswer: onAnswer,
        );

      case ExerciseTaskType.sentenceCompletion:
        return SentenceCompletionWidget(
          item: item,
          onAnswer: onAnswer,
        );

      case ExerciseTaskType.followInstruction:
        return FollowInstructionWidget(
          item: item,
          onAnswer: onAnswer,
        );

      case ExerciseTaskType.readingComprehension:
        return ReadingComprehensionWidget(
          item: item,
          onAnswer: onAnswer,
        );

      case ExerciseTaskType.spelling:
        return SpellingWidget(
          item: item,
          onAnswer: onAnswer,
        );

      // ── Module 7: Speech exercises ─────────────────────────────
      case ExerciseTaskType.speechRepeat:
        return WordRepetitionWidget(
          item: item,
          onAnswer: onAnswer,
        );

      case ExerciseTaskType.phraseRepeat:
        return PhraseRepetitionWidget(
          item: item,
          onAnswer: onAnswer,
        );

      case ExerciseTaskType.oralReading:
        return OralReadingWidget(
          item: item,
          onAnswer: onAnswer,
        );

      case ExerciseTaskType.scriptTraining:
        return ScriptTrainingWidget(
          item: item,
          onAnswer: onAnswer,
        );

      // ── Module 8: Reading & Writing exercises ──────────────
      case ExerciseTaskType.wordPictureMatch:
        return WordPictureMatchWidget(
          item: item,
          onAnswer: onAnswer,
        );

      case ExerciseTaskType.sentenceReading:
        return SentenceReadingWidget(
          item: item,
          onAnswer: onAnswer,
        );

      case ExerciseTaskType.functionalReading:
        return FunctionalReadingWidget(
          item: item,
          onAnswer: onAnswer,
        );

      case ExerciseTaskType.spellingDictation:
        return SpellingDictationWidget(
          item: item,
          onAnswer: onAnswer,
        );

      case ExerciseTaskType.copyWriting:
        return CopyWritingWidget(
          item: item,
          onAnswer: onAnswer,
        );

      case ExerciseTaskType.alphabetizeWords:
        return AlphabetizeWidget(
          item: item,
          onAnswer: onAnswer,
        );

      // ── Module 9: Math & Numeracy exercises ───────────────
      case ExerciseTaskType.numberRecognition:
        return NumberRecognitionWidget(
          item: item,
          onAnswer: onAnswer,
        );

      case ExerciseTaskType.visualArithmetic:
        return ArithmeticWidget(
          item: item,
          onAnswer: onAnswer,
        );

      case ExerciseTaskType.moneyCalculation:
        return MoneyCalculationWidget(
          item: item,
          onAnswer: onAnswer,
        );

      case ExerciseTaskType.clockReading:
        return ClockReadingWidget(
          item: item,
          onAnswer: onAnswer,
        );

      case ExerciseTaskType.numberSequence:
        return NumberSequenceWidget(
          item: item,
          onAnswer: onAnswer,
        );

      case ExerciseTaskType.wordProblem:
        return WordProblemWidget(
          item: item,
          onAnswer: onAnswer,
        );

      // Future modules will provide dedicated widgets for these types.
      case ExerciseTaskType.multipleChoiceImage:
      case ExerciseTaskType.sortOrder:
      case ExerciseTaskType.targetFind:
        return _ComingSoonPlaceholder(taskType: item.taskType);
    }
  }
}

/// Placeholder for task types not yet implemented.
class _ComingSoonPlaceholder extends StatelessWidget {
  const _ComingSoonPlaceholder({required this.taskType});

  final ExerciseTaskType taskType;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.construction_rounded,
          size: AppDimens.iconXl,
          color: AppColors.muted,
        ),
        const SizedBox(height: AppDimens.d16),
        Text(
          'Coming Soon',
          style: AppTextStyles.titleMd.copyWith(color: AppColors.body),
        ),
        const SizedBox(height: AppDimens.d8),
        Text(
          '${exerciseTaskTypeToCode(taskType)} exercises\nwill be available in a future update.',
          style: AppTextStyles.bodySm.copyWith(color: AppColors.muted),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
