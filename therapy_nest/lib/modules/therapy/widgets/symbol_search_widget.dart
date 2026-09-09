import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/exercise_item_model.dart';

/// 5A — Sustained Attention: Symbol Search.
///
/// Displays a grid of symbols. The user must find and tap ALL instances
/// of a target symbol within a time limit.
///
/// Difficulty scales via grid size, distractor similarity, and time pressure.
class SymbolSearchWidget extends StatefulWidget {
  const SymbolSearchWidget({
    super.key,
    required this.item,
    required this.onAnswer,
  });

  final ExerciseItemModel item;
  final void Function(String answer) onAnswer;

  @override
  State<SymbolSearchWidget> createState() => _SymbolSearchWidgetState();
}

class _SymbolSearchWidgetState extends State<SymbolSearchWidget> {
  _Phase _phase = _Phase.instructions;
  Timer? _countdownTimer;
  bool _answered = false;

  late String _target;
  late List<String> _grid;
  late int _gridSize;
  late int _timeLimitMs;
  late Set<int> _targetIndices;

  final Set<int> _tappedIndices = {};
  int _remainingMs = 0;

  @override
  void initState() {
    super.initState();
    _parseStimulus();
  }

  @override
  void didUpdateWidget(covariant SymbolSearchWidget oldWidget) {
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
    _target = (stimulus['target'] as String?) ?? '★';
    _grid = List<String>.from(stimulus['grid'] as List? ?? []);
    _gridSize = (stimulus['gridSize'] as int?) ?? 3;
    _timeLimitMs = (stimulus['timeLimitMs'] as int?) ?? 15000;
    _remainingMs = _timeLimitMs;

    // Pre-compute target indices
    _targetIndices = <int>{};
    for (var i = 0; i < _grid.length; i++) {
      if (_grid[i] == _target) {
        _targetIndices.add(i);
      }
    }
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

  void _onCellTap(int index) {
    if (_answered || _phase != _Phase.playing) return;

    setState(() {
      if (_tappedIndices.contains(index)) {
        _tappedIndices.remove(index);
      } else {
        _tappedIndices.add(index);
      }
    });

    // Auto-submit when all targets found
    if (_tappedIndices.containsAll(_targetIndices) &&
        _tappedIndices.length == _targetIndices.length) {
      _countdownTimer?.cancel();
      Future.delayed(const Duration(milliseconds: 300), _submitAnswer);
    }
  }

  void _submitAnswer() {
    if (_answered) return;
    setState(() {
      _phase = _Phase.result;
      _answered = true;
    });

    final correctTaps =
        _tappedIndices.intersection(_targetIndices).length;
    final answer = '$correctTaps/${_targetIndices.length}';
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
          Icons.search_rounded,
          size: AppDimens.iconXl,
          color: AppColors.primary,
        ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
        const SizedBox(height: AppDimens.d20),
        Text(
          'Symbol Search',
          style: AppTextStyles.titleLg.copyWith(color: AppColors.ink),
        ),
        const SizedBox(height: AppDimens.d12),
        // Target preview
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.d24,
            vertical: AppDimens.d12,
          ),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Find all:  ',
                style: AppTextStyles.bodyMd.copyWith(color: AppColors.body),
              ),
              Text(
                _target,
                style: AppTextStyles.displayMd.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimens.d12),
        Text(
          'Tap every matching symbol as fast as you can.',
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
        // Timer bar
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
                    progress > 0.3 ? AppColors.primary : AppColors.error,
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
        // Target reminder
        Text(
          'Find all  $_target',
          style: AppTextStyles.titleSm.copyWith(color: AppColors.primary),
        ),
        const SizedBox(height: AppDimens.d16),
        // Symbol grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _gridSize,
            mainAxisSpacing: AppDimens.d8,
            crossAxisSpacing: AppDimens.d8,
          ),
          itemCount: _grid.length,
          itemBuilder: (context, index) {
            final isSelected = _tappedIndices.contains(index);
            final symbol = _grid[index];

            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _onCellTap(index),
                borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
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
                      width: isSelected ? 2.5 : 1.0,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      symbol,
                      style: AppTextStyles.displaySm.copyWith(
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                ),
              ),
            ).animate().fadeIn(
                  duration: 200.ms,
                  delay: Duration(milliseconds: 30 * index),
                );
          },
        ),
      ],
    );
  }

  // ── Result ─────────────────────────────────────────────────────────

  Widget _buildResult() {
    final hits = _tappedIndices.intersection(_targetIndices).length;
    final misses = _targetIndices.length - hits;
    final falseAlarms =
        _tappedIndices.difference(_targetIndices).length;
    final perfect = hits == _targetIndices.length && falseAlarms == 0;

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
        _ResultRow(label: 'Hits', value: '$hits / ${_targetIndices.length}'),
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
