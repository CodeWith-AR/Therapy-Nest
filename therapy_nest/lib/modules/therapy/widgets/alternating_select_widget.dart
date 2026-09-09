import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/exercise_item_model.dart';

/// 5B — Selective Attention: Number/Letter Filter.
///
/// Displays a mixed list of numbers and letters. The user must tap all
/// items matching a given rule (e.g. "Tap all even numbers") within
/// a time limit.
///
/// Difficulty scales via rule complexity, list length, and time pressure.
class AlternatingSelectWidget extends StatefulWidget {
  const AlternatingSelectWidget({
    super.key,
    required this.item,
    required this.onAnswer,
  });

  final ExerciseItemModel item;
  final void Function(String answer) onAnswer;

  @override
  State<AlternatingSelectWidget> createState() =>
      _AlternatingSelectWidgetState();
}

class _AlternatingSelectWidgetState extends State<AlternatingSelectWidget> {
  _Phase _phase = _Phase.instructions;
  Timer? _countdownTimer;
  bool _answered = false;

  late String _rule;
  late List<String> _items;
  late Set<String> _targets;
  late int _timeLimitMs;

  final Set<int> _tappedIndices = {};
  int _remainingMs = 0;

  @override
  void initState() {
    super.initState();
    _parseStimulus();
  }

  @override
  void didUpdateWidget(covariant AlternatingSelectWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.id != widget.item.id) {
      _countdownTimer?.cancel();
      _phase = _Phase.instructions;
      _answered = false;
      _tappedIndices.clear();
      _parseStimulus();
    }
  }

  void _parseStimulus() {
    final stimulus = widget.item.stimulus;
    _rule = (stimulus['rule'] as String?) ?? 'Tap all even numbers';
    _items = List<String>.from(stimulus['items'] as List? ?? []);
    _targets = Set<String>.from(stimulus['targets'] as List? ?? []);
    _timeLimitMs = (stimulus['timeLimitMs'] as int?) ?? 20000;
    _remainingMs = _timeLimitMs;
  }

  void _startExercise() {
    setState(() => _phase = _Phase.playing);

    _countdownTimer = Timer.periodic(
      const Duration(milliseconds: 100),
      (timer) {
        _remainingMs -= 100;
        if (_remainingMs <= 0) {
          timer.cancel();
          _submitAnswer();
        } else {
          setState(() {});
        }
      },
    );
  }

  void _onItemTap(int index) {
    if (_answered || _phase != _Phase.playing) return;
    setState(() {
      if (_tappedIndices.contains(index)) {
        _tappedIndices.remove(index);
      } else {
        _tappedIndices.add(index);
      }
    });
  }

  void _onSubmitTap() {
    _countdownTimer?.cancel();
    _submitAnswer();
  }

  void _submitAnswer() {
    if (_answered) return;
    setState(() {
      _phase = _Phase.result;
      _answered = true;
    });

    // Count correct taps (tapped items that are actually targets)
    final correctTaps = _tappedIndices
        .where((i) => i < _items.length && _targets.contains(_items[i]))
        .length;
    final answer = '$correctTaps/${_targets.length}';
    widget.onAnswer(answer);
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
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
          Icons.filter_list_rounded,
          size: AppDimens.iconXl,
          color: AppColors.accentPurple,
        ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
        const SizedBox(height: AppDimens.d20),
        Text(
          'Number & Letter Filter',
          style: AppTextStyles.titleLg.copyWith(color: AppColors.ink),
        ),
        const SizedBox(height: AppDimens.d12),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.d20,
            vertical: AppDimens.d12,
          ),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          ),
          child: Text(
            _rule,
            style: AppTextStyles.titleSm.copyWith(color: AppColors.primary),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: AppDimens.d12),
        Text(
          'Select all matching items before time runs out.',
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
    final seconds = (_remainingMs / 1000).ceil();
    final progress = _remainingMs / _timeLimitMs;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Timer
        Row(
          children: [
            Icon(Icons.timer_outlined,
                size: AppDimens.iconSm, color: AppColors.muted),
            const SizedBox(width: AppDimens.d8),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: AppColors.hairlineSoft,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progress > 0.3 ? AppColors.accentPurple : AppColors.error,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppDimens.d8),
            Text(
              '${seconds}s',
              style: AppTextStyles.caption.copyWith(
                color: progress > 0.3 ? AppColors.muted : AppColors.error,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimens.d8),
        // Rule reminder
        Text(
          _rule,
          style: AppTextStyles.titleSm.copyWith(color: AppColors.accentPurple),
        ),
        const SizedBox(height: AppDimens.d16),
        // Items grid (4 columns)
        Wrap(
          alignment: WrapAlignment.center,
          spacing: AppDimens.d8,
          runSpacing: AppDimens.d8,
          children: _items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isSelected = _tappedIndices.contains(index);

            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _onItemTap(index),
                borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: AppDimens.touchNormal,
                  height: AppDimens.touchNormal,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryLight
                        : AppColors.surfaceWhite,
                    borderRadius:
                        BorderRadius.circular(AppDimens.radiusMd),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.accentPurple
                          : AppColors.hairline,
                      width: isSelected ? 2.5 : 1.0,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      item,
                      style: AppTextStyles.titleLg.copyWith(
                        color: isSelected
                            ? AppColors.accentPurple
                            : AppColors.ink,
                      ),
                    ),
                  ),
                ),
              ),
            ).animate().fadeIn(
                  duration: 200.ms,
                  delay: Duration(milliseconds: 25 * index),
                );
          }).toList(),
        ),
        const SizedBox(height: AppDimens.d20),
        // Submit button
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _onSubmitTap,
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            child: Container(
              height: AppDimens.touchSmall,
              alignment: Alignment.center,
              padding:
                  const EdgeInsets.symmetric(horizontal: AppDimens.d32),
              decoration: BoxDecoration(
                color: AppColors.accentTeal,
                borderRadius: BorderRadius.circular(AppDimens.radiusMd),
              ),
              child: Text(
                'Done',
                style: AppTextStyles.button
                    .copyWith(color: AppColors.onPrimary),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Result ─────────────────────────────────────────────────────────

  Widget _buildResult() {
    final tappedItems =
        _tappedIndices.where((i) => i < _items.length).map((i) => _items[i]);
    final hits = tappedItems.where((t) => _targets.contains(t)).length;
    final misses = _targets.length - hits;
    final falseAlarms = tappedItems.where((t) => !_targets.contains(t)).length;
    final perfect = hits == _targets.length && falseAlarms == 0;

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
        _ResultRow(label: 'Correct', value: '$hits / ${_targets.length}'),
        if (misses > 0) _ResultRow(label: 'Missed', value: '$misses'),
        if (falseAlarms > 0)
          _ResultRow(label: 'False taps', value: '$falseAlarms'),
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
