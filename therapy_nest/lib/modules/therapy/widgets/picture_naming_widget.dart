import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/exercise_item_model.dart';

/// 6A — Confrontation Naming (Picture Naming).
///
/// Displays a Material icon as the "picture" stimulus.
/// Two input modes controlled by `stimulus['inputMode']`:
/// - **mc** (default): 4-choice multiple choice
/// - **type**: User types the word, matched against [acceptedAnswers]
///
/// Progressive cueing hierarchy accessible via "Show Hint" button.
class PictureNamingWidget extends StatefulWidget {
  const PictureNamingWidget({
    super.key,
    required this.item,
    required this.onAnswer,
  });

  final ExerciseItemModel item;
  final void Function(String answer) onAnswer;

  @override
  State<PictureNamingWidget> createState() => _PictureNamingWidgetState();
}

class _PictureNamingWidgetState extends State<PictureNamingWidget> {
  _Phase _phase = _Phase.instructions;
  bool _answered = false;
  String? _selectedOption;
  int _cueLevel = -1; // -1 = no cue shown yet

  late int _iconCodePoint;
  late String _fontFamily;
  late String _inputMode;
  late List<String> _options;

  final TextEditingController _typeController = TextEditingController();
  final FocusNode _typeFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _parseStimulus();
  }

  @override
  void didUpdateWidget(covariant PictureNamingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.id != widget.item.id) {
      _phase = _Phase.instructions;
      _answered = false;
      _selectedOption = null;
      _cueLevel = -1;
      _typeController.clear();
      _parseStimulus();
    }
  }

  void _parseStimulus() {
    final stimulus = widget.item.stimulus;
    _iconCodePoint = (stimulus['icon'] as int?) ?? Icons.image.codePoint;
    _fontFamily = (stimulus['fontFamily'] as String?) ?? 'MaterialIcons';
    _inputMode = (stimulus['inputMode'] as String?) ?? 'mc';
    _options = List<String>.from(stimulus['options'] as List? ?? []);
  }

  void _startExercise() {
    setState(() => _phase = _Phase.playing);
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
    if (_answered) return;

    String answer;
    if (_inputMode == 'type') {
      answer = _typeController.text.trim();
      if (answer.isEmpty) return;
    } else {
      if (_selectedOption == null) return;
      answer = _selectedOption!;
    }

    setState(() {
      _answered = true;
      _phase = _Phase.result;
    });
    widget.onAnswer(answer);
  }

  @override
  void dispose() {
    _typeController.dispose();
    _typeFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (_phase) {
      case _Phase.instructions:
        return _buildInstructions();
      case _Phase.playing:
        return _buildPlaying();
      case _Phase.result:
        return _buildResult();
    }
  }

  // ── Instructions ───────────────────────────────────────────────────

  Widget _buildInstructions() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.image_search_rounded,
          size: AppDimens.iconXl,
          color: AppColors.primary,
        ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
        const SizedBox(height: AppDimens.d20),
        Text(
          'Picture Naming',
          style: AppTextStyles.titleLg.copyWith(color: AppColors.ink),
        ),
        const SizedBox(height: AppDimens.d12),
        Text(
          _inputMode == 'type'
              ? 'Look at the picture and type its name.'
              : 'Look at the picture and select its name.',
          style: AppTextStyles.bodySm.copyWith(color: AppColors.muted),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimens.d24),
        _StartButton(onTap: _startExercise),
      ],
    );
  }

  // ── Playing ────────────────────────────────────────────────────────

  Widget _buildPlaying() {
    final promptText =
        (widget.item.stimulus['promptText'] as String?) ?? 'What is this?';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Prompt text
        Text(
          promptText,
          style: AppTextStyles.titleMd.copyWith(color: AppColors.body),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimens.d20),

        // Icon / picture
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(AppDimens.radiusLg),
            border: Border.all(color: AppColors.hairline),
          ),
          child: Center(
            child: Icon(
              IconData(_iconCodePoint, fontFamily: _fontFamily),
              size: AppDimens.d64,
              color: AppColors.primary,
            ),
          ),
        ).animate().fadeIn(duration: 300.ms).scale(
              begin: const Offset(0.9, 0.9),
              end: const Offset(1, 1),
              duration: 300.ms,
              curve: Curves.easeOut,
            ),
        const SizedBox(height: AppDimens.d24),

        // Cueing hint area
        if (_cueLevel >= 0 && _cueLevel < widget.item.cues.length)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimens.d12),
            margin: const EdgeInsets.only(bottom: AppDimens.d16),
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

        // Input: MC or typing
        if (_inputMode == 'type') ...[
          TextField(
            controller: _typeController,
            focusNode: _typeFocus,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              hintText: 'Type the name…',
              filled: true,
              fillColor: AppColors.surfaceWhite,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                borderSide: BorderSide(color: AppColors.hairline),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                borderSide: BorderSide(color: AppColors.hairline),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppDimens.d16,
                vertical: AppDimens.d12,
              ),
            ),
            style: AppTextStyles.bodyLg.copyWith(color: AppColors.ink),
            onSubmitted: (_) => _submitAnswer(),
          ),
        ] else ...[
          // Multiple choice grid
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
                    height: AppDimens.touchNormal,
                    alignment: Alignment.center,
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
                      style: AppTextStyles.titleSm.copyWith(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.ink,
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
        ],
        const SizedBox(height: AppDimens.d12),

        // Action row: Hint + Submit
        Row(
          children: [
            // Show Hint button
            if (_cueLevel < widget.item.cues.length - 1)
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _showNextCue,
                    borderRadius:
                        BorderRadius.circular(AppDimens.radiusMd),
                    child: Container(
                      height: AppDimens.touchSmall,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSoft,
                        borderRadius:
                            BorderRadius.circular(AppDimens.radiusMd),
                      ),
                      child: Text(
                        'Show Hint',
                        style: AppTextStyles.buttonSm.copyWith(
                          color: AppColors.muted,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            if (_cueLevel < widget.item.cues.length - 1)
              const SizedBox(width: AppDimens.d12),
            // Submit button
            Expanded(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _submitAnswer,
                  borderRadius:
                      BorderRadius.circular(AppDimens.radiusMd),
                  child: Container(
                    height: AppDimens.touchSmall,
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
            ),
          ],
        ),
      ],
    );
  }

  // ── Result ─────────────────────────────────────────────────────────

  Widget _buildResult() {
    final isCorrect = widget.item.isCorrect(
      _inputMode == 'type' ? _typeController.text.trim() : _selectedOption!,
    );

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

// ── Shared helpers ──────────────────────────────────────────────────

class _StartButton extends StatelessWidget {
  const _StartButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
            'Start',
            style: AppTextStyles.button.copyWith(color: AppColors.onPrimary),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms, delay: 200.ms);
  }
}

enum _Phase { instructions, playing, result }
