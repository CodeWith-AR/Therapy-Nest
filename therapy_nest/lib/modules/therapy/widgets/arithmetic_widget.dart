import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/exercise_item_model.dart';

/// 9B — Simple Arithmetic with Visual Aids.
///
/// Displays an equation (e.g. "3 + 2 = ?") with optional visual aids —
/// Material icons rendered as countable objects for concrete support.
/// At higher difficulty, `showVisuals` is false and only the equation
/// is shown.
///
/// Stimulus schema:
/// ```json
/// {
///   "equation": "3 + 2 = ?",
///   "objectIcon": 58089,
///   "leftCount": 3,
///   "rightCount": 2,
///   "operation": "+",
///   "showVisuals": true,
///   "options": ["4", "5", "6", "7"]
/// }
/// ```
class ArithmeticWidget extends StatefulWidget {
  const ArithmeticWidget({
    super.key,
    required this.item,
    required this.onAnswer,
  });

  final ExerciseItemModel item;
  final void Function(String answer) onAnswer;

  @override
  State<ArithmeticWidget> createState() => _ArithmeticWidgetState();
}

class _ArithmeticWidgetState extends State<ArithmeticWidget> {
  _Phase _phase = _Phase.stimulus;
  bool _answered = false;
  String? _selectedAnswer;

  late String _equation;
  late int _objectIcon;
  late int _leftCount;
  late int _rightCount;
  late String _operation;
  late bool _showVisuals;
  late List<String> _options;

  @override
  void initState() {
    super.initState();
    _parseStimulus();
  }

  @override
  void didUpdateWidget(covariant ArithmeticWidget oldWidget) {
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
    _equation = (stimulus['equation'] as String?) ?? '';
    _objectIcon =
        (stimulus['objectIcon'] as int?) ?? Icons.circle.codePoint;
    _leftCount = (stimulus['leftCount'] as int?) ?? 0;
    _rightCount = (stimulus['rightCount'] as int?) ?? 0;
    _operation = (stimulus['operation'] as String?) ?? '+';
    _showVisuals = (stimulus['showVisuals'] as bool?) ?? true;
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
              Icons.calculate_rounded,
              size: AppDimens.iconMd,
              color: AppColors.accentTeal,
            ),
            const SizedBox(width: AppDimens.d8),
            Text(
              'Arithmetic',
              style: AppTextStyles.titleMd.copyWith(color: AppColors.ink),
            ),
          ],
        ),
        const SizedBox(height: AppDimens.d8),
        Text(
          'Solve the equation.',
          style: AppTextStyles.bodySm.copyWith(color: AppColors.muted),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimens.d20),

        // Equation display
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.d24,
            vertical: AppDimens.d16,
          ),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(AppDimens.radiusLg),
            border: Border.all(color: AppColors.hairline),
          ),
          child: Text(
            _equation,
            style: const TextStyle(
              fontFamily: 'JetBrains Mono',
              fontSize: 32,
              fontWeight: FontWeight.w700,
            ).copyWith(color: AppColors.ink),
            textAlign: TextAlign.center,
          ),
        ).animate().fadeIn(duration: 300.ms),

        // Visual aids (countable objects)
        if (_showVisuals) ...[
          const SizedBox(height: AppDimens.d16),
          _buildVisualAids(),
        ],

        const SizedBox(height: AppDimens.d20),

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

  Widget _buildVisualAids() {
    final icon = IconData(_objectIcon, fontFamily: 'MaterialIcons');
    final operationSymbol =
        _operation == '-' ? '−' : (_operation == '*' ? '×' : '+');

    return Container(
      padding: const EdgeInsets.all(AppDimens.d12),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(color: AppColors.hairlineSoft),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Left group
          Flexible(
            child: Wrap(
              spacing: AppDimens.d4,
              runSpacing: AppDimens.d4,
              children: List.generate(
                _leftCount,
                (i) => Icon(icon, size: AppDimens.iconMd, color: AppColors.primary)
                    .animate()
                    .fadeIn(
                      duration: 200.ms,
                      delay: Duration(milliseconds: 50 * i),
                    ),
              ),
            ),
          ),
          // Operation symbol
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimens.d12),
            child: Text(
              operationSymbol,
              style: const TextStyle(
                fontFamily: 'JetBrains Mono',
                fontSize: 28,
                fontWeight: FontWeight.w700,
              ).copyWith(color: AppColors.body),
            ),
          ),
          // Right group
          Flexible(
            child: Wrap(
              spacing: AppDimens.d4,
              runSpacing: AppDimens.d4,
              children: List.generate(
                _rightCount,
                (i) => Icon(icon,
                        size: AppDimens.iconMd, color: AppColors.accentTeal)
                    .animate()
                    .fadeIn(
                      duration: 200.ms,
                      delay: Duration(milliseconds: 50 * (_leftCount + i)),
                    ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
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
