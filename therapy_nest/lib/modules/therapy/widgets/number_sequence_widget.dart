import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/exercise_item_model.dart';

/// 9E — Number Sequencing.
///
/// Displays an arithmetic sequence with one missing value (shown as
/// "___"). User selects the correct number from 4 options.
///
/// Difficulty: small steps → larger steps → decreasing → skip-count.
///
/// Stimulus schema:
/// ```json
/// {
///   "sequence": ["5", "10", "___", "20", "25"],
///   "blankIndex": 2,
///   "options": ["12", "15", "18", "14"]
/// }
/// ```
class NumberSequenceWidget extends StatefulWidget {
  const NumberSequenceWidget({
    super.key,
    required this.item,
    required this.onAnswer,
  });

  final ExerciseItemModel item;
  final void Function(String answer) onAnswer;

  @override
  State<NumberSequenceWidget> createState() => _NumberSequenceWidgetState();
}

class _NumberSequenceWidgetState extends State<NumberSequenceWidget> {
  _Phase _phase = _Phase.stimulus;
  bool _answered = false;
  String? _selectedAnswer;

  late List<String> _sequence;
  late int _blankIndex;
  late List<String> _options;

  @override
  void initState() {
    super.initState();
    _parseStimulus();
  }

  @override
  void didUpdateWidget(covariant NumberSequenceWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.id != widget.item.id) {
      _phase = _Phase.stimulus;
      _answered = false;
      _selectedAnswer = null;
      _parseStimulus();
    }
  }

  void _parseStimulus() {
    final stimulus = widget.item.stimulus;
    _sequence = List<String>.from(stimulus['sequence'] as List? ?? []);
    _blankIndex = (stimulus['blankIndex'] as int?) ?? 0;
    _options = List<String>.from(stimulus['options'] as List? ?? []);
  }

  void _selectOption(String option) {
    if (_answered) return;
    setState(() => _selectedAnswer = option);
  }

  void _submitAnswer() {
    if (_answered || _selectedAnswer == null) return;
    setState(() {
      _answered = true;
      _phase = _Phase.result;
    });
    widget.onAnswer(_selectedAnswer!);
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
              Icons.format_list_numbered_rounded,
              size: AppDimens.iconMd,
              color: AppColors.accentTeal,
            ),
            const SizedBox(width: AppDimens.d8),
            Text(
              'Number Sequence',
              style: AppTextStyles.titleMd.copyWith(color: AppColors.ink),
            ),
          ],
        ),
        const SizedBox(height: AppDimens.d8),
        Text(
          'Find the missing number in the pattern.',
          style: AppTextStyles.bodySm.copyWith(color: AppColors.muted),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimens.d20),

        // Sequence display
        Wrap(
          spacing: AppDimens.d8,
          runSpacing: AppDimens.d8,
          alignment: WrapAlignment.center,
          children: List.generate(_sequence.length, (i) {
            final isBlank = i == _blankIndex;
            final value = isBlank
                ? (_selectedAnswer ?? '?')
                : _sequence[i];

            return Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isBlank
                    ? (_selectedAnswer != null
                        ? AppColors.primaryLight
                        : AppColors.surfaceSoft)
                    : AppColors.surfaceWhite,
                borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                border: Border.all(
                  color: isBlank ? AppColors.primary : AppColors.hairline,
                  width: isBlank ? 2.0 : 1.0,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                value,
                style: const TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ).copyWith(
                  color: isBlank
                      ? (_selectedAnswer != null
                          ? AppColors.primary
                          : AppColors.muted)
                      : AppColors.ink,
                ),
              ),
            ).animate().fadeIn(
                  duration: 200.ms,
                  delay: Duration(milliseconds: 80 * i),
                );
          }),
        ),

        // Arrow connectors hint
        const SizedBox(height: AppDimens.d8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _sequence.length - 1,
            (_) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimens.d16),
              child: Icon(
                Icons.arrow_forward_rounded,
                size: AppDimens.iconSm,
                color: AppColors.mutedSoft,
              ),
            ),
          ),
        ),

        const SizedBox(height: AppDimens.d24),

        // Options — 2×2 grid
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppDimens.d8,
          crossAxisSpacing: AppDimens.d8,
          childAspectRatio: 2.5,
          children: List.generate(_options.length, (i) {
            final option = _options[i];
            final isSelected = _selectedAnswer == option;

            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _selectOption(option),
                borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
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
                      fontSize: 28,
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
                );
          }),
        ),

        const SizedBox(height: AppDimens.d16),

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
