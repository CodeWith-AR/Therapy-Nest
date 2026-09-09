import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/exercise_item_model.dart';

/// 8F — Alphabetizing Words.
///
/// Shows 3–6 words in a random order. User drags/reorders them
/// into alphabetical order using [ReorderableListView].
/// Visual feedback: green checkmarks appear as items are placed
/// correctly in sequence.
///
/// Stimulus schema:
/// ```json
/// {
///   "words": ["banana", "apple", "cherry", "date"]
/// }
/// ```
///
/// Answer: comma-joined sorted order string.
class AlphabetizeWidget extends StatefulWidget {
  const AlphabetizeWidget({
    super.key,
    required this.item,
    required this.onAnswer,
  });

  final ExerciseItemModel item;
  final void Function(String answer) onAnswer;

  @override
  State<AlphabetizeWidget> createState() => _AlphabetizeWidgetState();
}

class _AlphabetizeWidgetState extends State<AlphabetizeWidget> {
  _Phase _phase = _Phase.sorting;
  bool _answered = false;

  late List<String> _currentOrder;
  late List<String> _correctOrder;

  @override
  void initState() {
    super.initState();
    _parseStimulus();
  }

  @override
  void didUpdateWidget(covariant AlphabetizeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.id != widget.item.id) {
      _phase = _Phase.sorting;
      _answered = false;
      _parseStimulus();
    }
  }

  void _parseStimulus() {
    final stimulus = widget.item.stimulus;
    final words = List<String>.from(stimulus['words'] as List? ?? []);
    _correctOrder = List<String>.from(words)
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    // Shuffle for presentation (avoid already-sorted)
    _currentOrder = List<String>.from(words);
  }

  void _onReorder(int oldIndex, int newIndex) {
    if (_answered) return;
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final item = _currentOrder.removeAt(oldIndex);
      _currentOrder.insert(newIndex, item);
    });
  }

  bool _isCorrectPosition(int index) {
    return _currentOrder[index].toLowerCase() ==
        _correctOrder[index].toLowerCase();
  }

  void _submitAnswer() {
    if (_answered) return;
    final answer = _currentOrder.join(',');
    setState(() {
      _answered = true;
      _phase = _Phase.result;
    });
    widget.onAnswer(answer);
  }

  @override
  Widget build(BuildContext context) {
    switch (_phase) {
      case _Phase.sorting:
        return _buildSorting();
      case _Phase.result:
        return _buildResult();
    }
  }

  // ── Sorting Phase ─────────────────────────────────────────────────

  Widget _buildSorting() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sort_by_alpha_rounded,
              size: AppDimens.iconMd,
              color: AppColors.accentTeal,
            ),
            const SizedBox(width: AppDimens.d8),
            Text(
              'Alphabetize',
              style: AppTextStyles.titleMd.copyWith(color: AppColors.ink),
            ),
          ],
        ),
        const SizedBox(height: AppDimens.d8),
        Text(
          'Drag the words into alphabetical order (A → Z).',
          style: AppTextStyles.bodySm.copyWith(color: AppColors.muted),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimens.d20),

        // Reorderable list
        SizedBox(
          height: _currentOrder.length * 60.0,
          child: ReorderableListView.builder(
            itemCount: _currentOrder.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            proxyDecorator: (child, index, animation) {
              return AnimatedBuilder(
                animation: animation,
                builder: (context, child) {
                  return Material(
                    elevation: 4,
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                    child: child,
                  );
                },
                child: child,
              );
            },
            onReorder: _onReorder,
            itemBuilder: (context, index) {
              final word = _currentOrder[index];
              final isCorrect = _isCorrectPosition(index);

              return Container(
                key: ValueKey(word),
                height: 52,
                margin: const EdgeInsets.only(bottom: AppDimens.d8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                  border: Border.all(
                    color: isCorrect ? AppColors.success : AppColors.hairline,
                    width: isCorrect ? 2.0 : 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    // Drag handle
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimens.d12,
                      ),
                      child: Icon(
                        Icons.drag_handle_rounded,
                        size: AppDimens.iconMd,
                        color: AppColors.muted,
                      ),
                    ),
                    // Word
                    Expanded(
                      child: Text(
                        word,
                        style: AppTextStyles.titleSm.copyWith(
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                    // Check mark for correct position
                    if (isCorrect)
                      Padding(
                        padding: const EdgeInsets.only(right: AppDimens.d12),
                        child: Icon(
                          Icons.check_circle_rounded,
                          size: AppDimens.iconSm,
                          color: AppColors.success,
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
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
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppDimens.radiusMd),
              ),
              child: Text(
                'Submit Order',
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

  // ── Result ─────────────────────────────────────────────────────────

  Widget _buildResult() {
    final isCorrect = widget.item.isCorrect(_currentOrder.join(','));

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

        // Show correct order
        if (!isCorrect) ...[
          Text(
            'Correct order:',
            style: AppTextStyles.bodyMd.copyWith(color: AppColors.body),
          ),
          const SizedBox(height: AppDimens.d8),
          ...List.generate(_correctOrder.length, (i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppDimens.d4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${i + 1}. ',
                    style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.muted,
                    ),
                  ),
                  Text(
                    _correctOrder[i],
                    style: AppTextStyles.titleSm.copyWith(
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ],
    ).animate().fadeIn(duration: 400.ms);
  }
}

enum _Phase { sorting, result }
