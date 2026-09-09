import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/exercise_item_model.dart';

/// 6E — Reading Comprehension.
///
/// Phase 1: User reads a short passage (scrollable text card).
/// Phase 2: Passage hidden, question + 4 MC options shown.
///
/// Optional "Re-read" button reveals the passage again (counts as cue).
/// Full cueing hierarchy accessible via "Show Hint".
///
/// Stimulus schema:
/// ```json
/// {
///   "passage": "The cat sat on the mat. It was a sunny day...",
///   "question": "Where did the cat sit?",
///   "options": ["On the mat", "On the chair", "In the garden", "Under the table"]
/// }
/// ```
class ReadingComprehensionWidget extends StatefulWidget {
  const ReadingComprehensionWidget({
    super.key,
    required this.item,
    required this.onAnswer,
  });

  final ExerciseItemModel item;
  final void Function(String answer) onAnswer;

  @override
  State<ReadingComprehensionWidget> createState() =>
      _ReadingComprehensionWidgetState();
}

class _ReadingComprehensionWidgetState
    extends State<ReadingComprehensionWidget> {
  _Phase _phase = _Phase.reading;
  bool _answered = false;
  String? _selectedOption;
  int _cueLevel = -1;
  bool _showingPassage = false; // "Re-read" toggle in question phase

  late String _passage;
  late String _question;
  late List<String> _options;

  @override
  void initState() {
    super.initState();
    _parseStimulus();
  }

  @override
  void didUpdateWidget(covariant ReadingComprehensionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.id != widget.item.id) {
      _phase = _Phase.reading;
      _answered = false;
      _selectedOption = null;
      _cueLevel = -1;
      _showingPassage = false;
      _parseStimulus();
    }
  }

  void _parseStimulus() {
    final stimulus = widget.item.stimulus;
    _passage = (stimulus['passage'] as String?) ?? '';
    _question = (stimulus['question'] as String?) ??
        (stimulus['promptText'] as String?) ??
        '';
    _options = List<String>.from(stimulus['options'] as List? ?? []);
  }

  void _goToQuestion() {
    setState(() => _phase = _Phase.question);
  }

  void _toggleReread() {
    setState(() {
      _showingPassage = !_showingPassage;
      if (_showingPassage && _cueLevel < 0) {
        // Counts as first cue level usage
        _cueLevel = 0;
      }
    });
  }

  void _showNextCue() {
    if (_cueLevel < widget.item.cues.length - 1) {
      setState(() => _cueLevel++);
    }
  }

  void _selectOption(String option) {
    if (_answered) return;
    setState(() => _selectedOption = option);
  }

  void _submitAnswer() {
    if (_answered || _selectedOption == null) return;
    setState(() {
      _answered = true;
      _phase = _Phase.result;
    });
    widget.onAnswer(_selectedOption!);
  }

  @override
  Widget build(BuildContext context) {
    switch (_phase) {
      case _Phase.reading:
        return _buildReading();
      case _Phase.question:
        return _buildQuestion();
      case _Phase.result:
        return _buildResult();
    }
  }

  // ── Reading Phase ──────────────────────────────────────────────────

  Widget _buildReading() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.menu_book_rounded,
              size: AppDimens.iconMd,
              color: AppColors.accentPurple,
            ),
            const SizedBox(width: AppDimens.d8),
            Text(
              'Read the Passage',
              style: AppTextStyles.titleMd.copyWith(color: AppColors.ink),
            ),
          ],
        ).animate().fadeIn(duration: 300.ms),
        const SizedBox(height: AppDimens.d20),

        // Passage card
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxHeight: 280),
          padding: const EdgeInsets.all(AppDimens.d20),
          decoration: BoxDecoration(
            color: AppColors.surfaceSoft,
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            border: Border.all(color: AppColors.hairline),
          ),
          child: SingleChildScrollView(
            child: Text(
              _passage,
              style: AppTextStyles.bodyLg.copyWith(
                color: AppColors.bodyStrong,
                height: 1.7,
              ),
            ),
          ),
        ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
        const SizedBox(height: AppDimens.d20),

        Text(
          'Read carefully, then press Ready when you\'re done.',
          style: AppTextStyles.bodySm.copyWith(color: AppColors.muted),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimens.d20),

        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _goToQuestion,
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            child: Container(
              height: AppDimens.touchSmall,
              alignment: Alignment.center,
              padding:
                  const EdgeInsets.symmetric(horizontal: AppDimens.d32),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppDimens.radiusMd),
              ),
              child: Text(
                'Ready',
                style: AppTextStyles.button.copyWith(
                    color: AppColors.onPrimary),
              ),
            ),
          ),
        ).animate().fadeIn(duration: 300.ms, delay: 200.ms),
      ],
    );
  }

  // ── Question Phase ─────────────────────────────────────────────────

  Widget _buildQuestion() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Question text
        Text(
          _question,
          style: AppTextStyles.titleMd.copyWith(color: AppColors.ink),
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: 300.ms),
        const SizedBox(height: AppDimens.d20),

        // Re-read passage toggle
        if (_showingPassage)
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxHeight: 180),
            padding: const EdgeInsets.all(AppDimens.d16),
            margin: const EdgeInsets.only(bottom: AppDimens.d16),
            decoration: BoxDecoration(
              color: AppColors.surfaceSoft,
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
              border: Border.all(color: AppColors.hairline),
            ),
            child: SingleChildScrollView(
              child: Text(
                _passage,
                style:
                    AppTextStyles.bodySm.copyWith(color: AppColors.bodyStrong),
              ),
            ),
          ).animate().fadeIn(duration: 200.ms),

        // Cueing hint
        if (_cueLevel > 0 && _cueLevel < widget.item.cues.length)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimens.d12),
            margin: const EdgeInsets.only(bottom: AppDimens.d12),
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

        // Options
        ...List.generate(_options.length, (i) {
          final option = _options[i];
          final isSelected = _selectedOption == option;

          return Padding(
            padding: const EdgeInsets.only(bottom: AppDimens.d8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _selectOption(option),
                borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.d16,
                    vertical: AppDimens.d12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryLight
                        : AppColors.surfaceWhite,
                    borderRadius:
                        BorderRadius.circular(AppDimens.radiusMd),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.hairline,
                      width: isSelected ? 2.0 : 1.0,
                    ),
                  ),
                  child: Text(
                    option,
                    style: AppTextStyles.bodyMd.copyWith(
                      color:
                          isSelected ? AppColors.primary : AppColors.ink,
                    ),
                  ),
                ),
              ),
            ).animate().fadeIn(
                  duration: 200.ms,
                  delay: Duration(milliseconds: 50 * i),
                ),
          );
        }),
        const SizedBox(height: AppDimens.d12),

        // Action row: Re-read, Hint, Submit
        Row(
          children: [
            // Re-read toggle
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _toggleReread,
                borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                child: Container(
                  height: AppDimens.touchSmall,
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.d12),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _showingPassage
                        ? AppColors.primaryLight
                        : AppColors.surfaceSoft,
                    borderRadius:
                        BorderRadius.circular(AppDimens.radiusMd),
                    border: _showingPassage
                        ? Border.all(color: AppColors.primary)
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.menu_book_rounded,
                        size: AppDimens.iconSm,
                        color: _showingPassage
                            ? AppColors.primary
                            : AppColors.muted,
                      ),
                      const SizedBox(width: AppDimens.d4),
                      Text(
                        'Re-read',
                        style: AppTextStyles.buttonSm.copyWith(
                          color: _showingPassage
                              ? AppColors.primary
                              : AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppDimens.d8),
            // Hint
            if (_cueLevel < widget.item.cues.length - 1)
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _showNextCue,
                  borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                  child: Container(
                    height: AppDimens.touchSmall,
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppDimens.d12),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSoft,
                      borderRadius:
                          BorderRadius.circular(AppDimens.radiusMd),
                    ),
                    child: Text(
                      'Hint',
                      style: AppTextStyles.buttonSm.copyWith(
                        color: AppColors.muted,
                      ),
                    ),
                  ),
                ),
              ),
            const Spacer(),
            // Submit
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _submitAnswer,
                borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                child: Container(
                  height: AppDimens.touchSmall,
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.d24),
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
          ],
        ),
      ],
    );
  }

  // ── Result ─────────────────────────────────────────────────────────

  Widget _buildResult() {
    final isCorrect = widget.item.isCorrect(_selectedOption ?? '');

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
        const SizedBox(height: AppDimens.d8),
        if (!isCorrect)
          Text(
            'The answer is: ${widget.item.correctAnswer}',
            style: AppTextStyles.bodyMd.copyWith(color: AppColors.body),
          ),
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

enum _Phase { reading, question, result }
