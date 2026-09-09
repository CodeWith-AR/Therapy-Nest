import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/exercise_item_model.dart';

/// 5D — Alternating Attention: Task Switching.
///
/// Presents a sequence of colored shapes. The user must apply alternating
/// rules per item:
/// - **Rule A** (e.g. red item → say the shape name)
/// - **Rule B** (e.g. blue item → say the color name)
///
/// The two rules alternate each trial. The widget tracks correct answers,
/// response time, and errors to measure cognitive flexibility.
class TaskSwitchWidget extends StatefulWidget {
  const TaskSwitchWidget({
    super.key,
    required this.item,
    required this.onAnswer,
  });

  final ExerciseItemModel item;
  final void Function(String answer) onAnswer;

  @override
  State<TaskSwitchWidget> createState() => _TaskSwitchWidgetState();
}

class _TaskSwitchWidgetState extends State<TaskSwitchWidget> {
  _Phase _phase = _Phase.instructions;
  bool _answered = false;

  late String _ruleA;
  late String _ruleB;
  late List<Map<String, String>> _trials;

  int _currentTrial = 0;
  int _correctCount = 0;
  int _totalTrials = 0;
  final List<bool> _trialResults = [];

  @override
  void initState() {
    super.initState();
    _parseStimulus();
  }

  @override
  void didUpdateWidget(covariant TaskSwitchWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.id != widget.item.id) {
      _phase = _Phase.instructions;
      _answered = false;
      _currentTrial = 0;
      _correctCount = 0;
      _trialResults.clear();
      _parseStimulus();
    }
  }

  void _parseStimulus() {
    final stimulus = widget.item.stimulus;
    _ruleA = (stimulus['ruleA'] as String?) ?? 'Red → Name the SHAPE';
    _ruleB = (stimulus['ruleB'] as String?) ?? 'Blue → Name the COLOR';

    final rawTrials = stimulus['trials'] as List? ?? [];
    _trials = rawTrials
        .map((t) => Map<String, String>.from(t as Map))
        .toList();
    _totalTrials = _trials.length;
  }

  void _startExercise() {
    setState(() {
      _phase = _Phase.playing;
      _currentTrial = 0;
    });
  }

  String _currentRule() {
    // Alternates: even index → Rule A, odd index → Rule B
    return _currentTrial.isEven ? _ruleA : _ruleB;
  }

  void _onOptionTap(String selected) {
    if (_answered || _phase != _Phase.playing) return;
    if (_currentTrial >= _trials.length) return;

    final trial = _trials[_currentTrial];
    final correct = trial['answer'] ?? '';
    final isCorrect = selected.toLowerCase().trim() ==
        correct.toLowerCase().trim();

    _trialResults.add(isCorrect);
    if (isCorrect) _correctCount++;

    setState(() {
      _currentTrial++;
    });

    if (_currentTrial >= _totalTrials) {
      _submitAnswer();
    }
  }

  void _submitAnswer() {
    if (_answered) return;
    setState(() {
      _phase = _Phase.result;
      _answered = true;
    });

    final answer = '$_correctCount/$_totalTrials';
    widget.onAnswer(answer);
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
          Icons.swap_horiz_rounded,
          size: AppDimens.iconXl,
          color: AppColors.accentPurple,
        ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
        const SizedBox(height: AppDimens.d20),
        Text(
          'Task Switching',
          style: AppTextStyles.titleLg.copyWith(color: AppColors.ink),
        ),
        const SizedBox(height: AppDimens.d12),
        // Rule cards
        _RuleCard(
          label: 'Rule A',
          description: _ruleA,
          color: AppColors.primary,
        ),
        const SizedBox(height: AppDimens.d8),
        _RuleCard(
          label: 'Rule B',
          description: _ruleB,
          color: AppColors.accentPurple,
        ),
        const SizedBox(height: AppDimens.d12),
        Text(
          'Rules alternate each trial.\nPay close attention to which rule applies!',
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
    if (_currentTrial >= _trials.length) {
      return const SizedBox.shrink();
    }

    final trial = _trials[_currentTrial];
    final shapeName = trial['shape'] ?? '?';
    final colorName = trial['color'] ?? 'gray';
    final options = trial['options']?.split(',') ?? [];
    final isRuleA = _currentTrial.isEven;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Progress
        Row(
          children: [
            Text(
              'Trial ${_currentTrial + 1} / $_totalTrials',
              style: AppTextStyles.caption.copyWith(color: AppColors.muted),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.d12,
                vertical: AppDimens.d4,
              ),
              decoration: BoxDecoration(
                color: isRuleA
                    ? AppColors.primary.withValues(alpha: 0.12)
                    : AppColors.accentPurple.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppDimens.radiusSm),
              ),
              child: Text(
                isRuleA ? 'Rule A' : 'Rule B',
                style: AppTextStyles.caption.copyWith(
                  color: isRuleA ? AppColors.primary : AppColors.accentPurple,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimens.d8),
        // Active rule reminder
        Text(
          _currentRule(),
          style: AppTextStyles.titleSm.copyWith(
            color: isRuleA ? AppColors.primary : AppColors.accentPurple,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimens.d20),

        // Shape display
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) =>
              ScaleTransition(scale: animation, child: child),
          child: Container(
            key: ValueKey('trial_$_currentTrial'),
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: _getColorValue(colorName),
              borderRadius: _getShapeRadius(shapeName),
            ),
            child: Center(
              child: Icon(
                _getShapeIcon(shapeName),
                size: AppDimens.iconLg,
                color: AppColors.onPrimary.withValues(alpha: 0.9),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppDimens.d8),
        // Shape label (helpful context)
        Text(
          '$colorName $shapeName',
          style: AppTextStyles.caption.copyWith(color: AppColors.muted),
        ),
        const SizedBox(height: AppDimens.d20),

        // Options
        Wrap(
          alignment: WrapAlignment.center,
          spacing: AppDimens.d8,
          runSpacing: AppDimens.d8,
          children: options.map((opt) {
            final option = opt.trim();
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _onOptionTap(option),
                borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.d20,
                    vertical: AppDimens.d12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceWhite,
                    borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                    border: Border.all(
                      color: AppColors.hairline,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    option,
                    style:
                        AppTextStyles.titleSm.copyWith(color: AppColors.ink),
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        // Trial history dots
        if (_trialResults.isNotEmpty) ...[
          const SizedBox(height: AppDimens.d20),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: AppDimens.d4,
            children: _trialResults.map((correct) {
              return Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: correct ? AppColors.success : AppColors.error,
                  shape: BoxShape.circle,
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  // ── Result ─────────────────────────────────────────────────────────

  Widget _buildResult() {
    final accuracy =
        _totalTrials > 0 ? (_correctCount / _totalTrials * 100).round() : 0;
    final perfect = _correctCount == _totalTrials;

    // Count switch errors (errors on odd-index trials where rule changed)
    int switchErrors = 0;
    for (var i = 0; i < _trialResults.length; i++) {
      if (i.isOdd && !_trialResults[i]) switchErrors++;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          perfect
              ? Icons.check_circle_rounded
              : Icons.info_outline_rounded,
          size: AppDimens.iconXl,
          color: perfect ? AppColors.success : AppColors.warning,
        ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
        const SizedBox(height: AppDimens.d16),
        Text(
          perfect ? 'Perfect!' : 'Results',
          style: AppTextStyles.titleLg.copyWith(color: AppColors.ink),
        ),
        const SizedBox(height: AppDimens.d12),
        _ResultRow(label: 'Accuracy', value: '$accuracy%'),
        _ResultRow(
          label: 'Correct',
          value: '$_correctCount / $_totalTrials',
        ),
        if (switchErrors > 0)
          _ResultRow(label: 'Switch errors', value: '$switchErrors'),
        const SizedBox(height: AppDimens.d12),
        // Trial-by-trial dots
        Wrap(
          alignment: WrapAlignment.center,
          spacing: AppDimens.d4,
          children: _trialResults.asMap().entries.map((entry) {
            final i = entry.key;
            final correct = entry.value;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: correct ? AppColors.success : AppColors.error,
                    borderRadius: BorderRadius.circular(AppDimens.radiusXs),
                  ),
                  child: Center(
                    child: Text(
                      '${i + 1}',
                      style: const TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  i.isEven ? 'A' : 'B',
                  style: TextStyle(
                    fontSize: 7,
                    fontWeight: FontWeight.w600,
                    color: AppColors.muted,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms);
  }
}

// ── Helpers ─────────────────────────────────────────────────────────

Color _getColorValue(String name) {
  switch (name) {
    case 'red':
      return AppColors.error;
    case 'blue':
      return AppColors.primary;
    case 'green':
      return AppColors.success;
    case 'yellow':
      return AppColors.accentAmber;
    case 'purple':
      return AppColors.accentPurple;
    case 'teal':
      return AppColors.accentTeal;
    default:
      return AppColors.muted;
  }
}

BorderRadius _getShapeRadius(String shape) {
  switch (shape) {
    case 'circle':
      return BorderRadius.circular(AppDimens.radiusFull);
    case 'diamond':
      return BorderRadius.circular(AppDimens.radiusMd);
    case 'triangle':
      return BorderRadius.circular(AppDimens.radiusSm);
    default: // square
      return BorderRadius.circular(AppDimens.radiusMd);
  }
}

IconData _getShapeIcon(String shape) {
  switch (shape) {
    case 'circle':
      return Icons.circle_outlined;
    case 'diamond':
      return Icons.diamond_outlined;
    case 'triangle':
      return Icons.change_history_rounded;
    case 'star':
      return Icons.star_outline_rounded;
    default:
      return Icons.square_outlined;
  }
}

class _RuleCard extends StatelessWidget {
  const _RuleCard({
    required this.label,
    required this.description,
    required this.color,
  });
  final String label;
  final String description;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimens.d12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.d8,
              vertical: AppDimens.d4,
            ),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(AppDimens.radiusSm),
            ),
            child: Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.onPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: AppDimens.d12),
          Expanded(
            child: Text(
              description,
              style: AppTextStyles.bodySm.copyWith(color: AppColors.body),
            ),
          ),
        ],
      ),
    );
  }
}

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

class _ResultRow extends StatelessWidget {
  const _ResultRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimens.d4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$label: ',
            style: AppTextStyles.bodyMd.copyWith(color: AppColors.body),
          ),
          Text(
            value,
            style: AppTextStyles.titleSm.copyWith(color: AppColors.ink),
          ),
        ],
      ),
    );
  }
}

enum _Phase { instructions, playing, result }
