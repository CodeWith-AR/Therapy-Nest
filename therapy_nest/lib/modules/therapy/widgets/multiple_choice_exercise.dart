import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/exercise_item_model.dart';

/// Multiple-choice exercise widget.
///
/// Handles task types: wordMatch, sentenceCompletion,
/// readingComprehension, mathSelect.
///
/// Shows a prompt (text and optional icon) with 2–4 selectable options.
class MultipleChoiceExercise extends StatefulWidget {
  const MultipleChoiceExercise({
    super.key,
    required this.item,
    required this.onAnswer,
  });

  final ExerciseItemModel item;
  final void Function(String answer) onAnswer;

  @override
  State<MultipleChoiceExercise> createState() => _MultipleChoiceExerciseState();
}

class _MultipleChoiceExerciseState extends State<MultipleChoiceExercise> {
  String? _selectedOption;
  bool _answered = false;

  @override
  void didUpdateWidget(covariant MultipleChoiceExercise oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.id != widget.item.id) {
      _selectedOption = null;
      _answered = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final stimulus = widget.item.stimulus;
    final promptText = stimulus['promptText'] as String? ??
        stimulus['sentenceWithBlank'] as String? ??
        stimulus['mathPromptText'] as String? ??
        '';
    final options = List<String>.from(
      stimulus['options'] as List? ?? widget.item.acceptedAnswers,
    );
    final iconCodePoint = stimulus['icon'] as int?;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Icon (if present) ──────────────────────────────────────
        if (iconCodePoint != null) ...[
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(AppDimens.radiusLg),
              ),
              child: Icon(
                IconData(iconCodePoint, fontFamily: 'MaterialIcons'),
                size: AppDimens.iconXl,
                color: AppColors.primary,
              ),
            ),
          ).animate().scale(
                duration: 400.ms,
                curve: Curves.easeOutBack,
              ),
          const SizedBox(height: AppDimens.d20),
        ],

        // ── Prompt Text ───────────────────────────────────────────
        Text(
          promptText,
          style: AppTextStyles.titleLg.copyWith(color: AppColors.ink),
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: 300.ms),
        const SizedBox(height: AppDimens.d24),

        // ── Options ───────────────────────────────────────────────
        ...options.asMap().entries.map((entry) {
          final index = entry.key;
          final option = entry.value;
          final isSelected = _selectedOption == option;

          return Padding(
            padding: const EdgeInsets.only(bottom: AppDimens.d12),
            child: _OptionButton(
              label: option,
              isSelected: isSelected,
              isDisabled: _answered,
              onTap: () => _onOptionTap(option),
            ),
          ).animate().fadeIn(
                duration: 300.ms,
                delay: Duration(milliseconds: 100 + index * 80),
              );
        }),
      ],
    );
  }

  void _onOptionTap(String option) {
    if (_answered) return;
    setState(() {
      _selectedOption = option;
      _answered = true;
    });
    widget.onAnswer(option);
  }
}

/// A styled option button for multiple-choice exercises.
class _OptionButton extends StatelessWidget {
  const _OptionButton({
    required this.label,
    required this.isSelected,
    required this.isDisabled,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final bool isDisabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isDisabled ? null : onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          constraints: BoxConstraints(minHeight: AppDimens.touchNormal),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.d20,
            vertical: AppDimens.d12,
          ),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryLight : AppColors.canvas,
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.hairline,
              width: isSelected ? 2.0 : 1.0,
            ),
          ),
          child: Text(
            label,
            style: AppTextStyles.bodyLg.copyWith(
              color: isSelected ? AppColors.primaryDark : AppColors.body,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
