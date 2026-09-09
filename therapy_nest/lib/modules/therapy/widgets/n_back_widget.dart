import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/exercise_item_model.dart';

/// N-Back visual memory exercise.
///
/// Presents a stream of icons one at a time. The user taps "Match!" when
/// the current item matches the item shown N steps ago.
///
/// After the full sequence plays, the answer is scored as the fraction of
/// correct match identifications. Correct if ≥ 80% accuracy.
class NBackWidget extends StatefulWidget {
  const NBackWidget({
    super.key,
    required this.item,
    required this.onAnswer,
  });

  final ExerciseItemModel item;
  final void Function(String answer) onAnswer;

  @override
  State<NBackWidget> createState() => _NBackWidgetState();
}

class _NBackWidgetState extends State<NBackWidget> {
  _NBackPhase _phase = _NBackPhase.instructions;
  Timer? _sequenceTimer;
  bool _answered = false;

  late int _nBack;
  late List<int> _iconCodes;
  late int _intervalMs;

  int _currentIndex = -1;
  int _totalExpectedMatches = 0;
  int _correctHits = 0;
  int _falseAlarms = 0;
  bool _tappedForCurrent = false;

  // Track which indices are true matches
  final Set<int> _matchIndices = {};

  @override
  void initState() {
    super.initState();
    _parseStimulus();
  }

  @override
  void didUpdateWidget(covariant NBackWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.id != widget.item.id) {
      _sequenceTimer?.cancel();
      _phase = _NBackPhase.instructions;
      _answered = false;
      _currentIndex = -1;
      _correctHits = 0;
      _falseAlarms = 0;
      _tappedForCurrent = false;
      _matchIndices.clear();
      _parseStimulus();
    }
  }

  void _parseStimulus() {
    final stimulus = widget.item.stimulus;
    _nBack = (stimulus['nBack'] as int?) ?? 1;
    _iconCodes = List<int>.from(stimulus['iconCodes'] as List? ?? []);
    _intervalMs = (stimulus['intervalMs'] as int?) ?? 2500;

    // Pre-compute which indices are matches
    _matchIndices.clear();
    for (var i = _nBack; i < _iconCodes.length; i++) {
      if (_iconCodes[i] == _iconCodes[i - _nBack]) {
        _matchIndices.add(i);
      }
    }
    _totalExpectedMatches = _matchIndices.length;
  }

  void _startSequence() {
    setState(() {
      _phase = _NBackPhase.playing;
      _currentIndex = 0;
      _tappedForCurrent = false;
    });

    _sequenceTimer = Timer.periodic(
      Duration(milliseconds: _intervalMs),
      (timer) {
        // Before advancing, check if this was a match that was missed
        _currentIndex++;
        if (_currentIndex >= _iconCodes.length) {
          timer.cancel();
          _finishExercise();
        } else {
          setState(() {
            _tappedForCurrent = false;
          });
        }
      },
    );
  }

  void _onMatchTap() {
    if (_tappedForCurrent || _answered || _phase != _NBackPhase.playing) return;
    setState(() => _tappedForCurrent = true);

    if (_matchIndices.contains(_currentIndex)) {
      _correctHits++;
    } else {
      _falseAlarms++;
    }
  }

  void _finishExercise() {
    setState(() {
      _phase = _NBackPhase.result;
      _answered = true;
    });

    // Answer format: "correctHits/totalExpected"
    final answer = '$_correctHits/$_totalExpectedMatches';
    widget.onAnswer(answer);
  }

  @override
  void dispose() {
    _sequenceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (_phase) {
      case _NBackPhase.instructions:
        return _buildInstructions();
      case _NBackPhase.playing:
        return _buildPlaying();
      case _NBackPhase.result:
        return _buildResult();
    }
  }

  Widget _buildInstructions() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.psychology_rounded,
          size: AppDimens.iconXl,
          color: AppColors.primary,
        ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
        const SizedBox(height: AppDimens.d20),
        Text(
          '$_nBack-Back Challenge',
          style: AppTextStyles.titleLg.copyWith(color: AppColors.ink),
        ),
        const SizedBox(height: AppDimens.d12),
        Text(
          'You will see icons one at a time.\n'
          'Tap "Match!" when the current icon is the same as\n'
          'the one shown $_nBack step${_nBack > 1 ? 's' : ''} ago.',
          style: AppTextStyles.bodyMd.copyWith(color: AppColors.body),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimens.d24),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _startSequence,
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
                style: AppTextStyles.button
                    .copyWith(color: AppColors.onPrimary),
              ),
            ),
          ),
        ).animate().fadeIn(duration: 300.ms, delay: 200.ms),
      ],
    );
  }

  Widget _buildPlaying() {
    final hasIcon = _currentIndex >= 0 && _currentIndex < _iconCodes.length;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Progress
        Text(
          '${_currentIndex + 1} / ${_iconCodes.length}',
          style: AppTextStyles.caption.copyWith(color: AppColors.muted),
        ),
        const SizedBox(height: AppDimens.d12),

        // Current icon
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return ScaleTransition(scale: animation, child: child);
          },
          child: hasIcon
              ? Container(
                  key: ValueKey('icon_$_currentIndex'),
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                    border: Border.all(
                      color: _tappedForCurrent
                          ? AppColors.accentAmber
                          : AppColors.hairline,
                      width: _tappedForCurrent ? 3.0 : 1.0,
                    ),
                  ),
                  child: Icon(
                    IconData(_iconCodes[_currentIndex],
                        fontFamily: 'MaterialIcons'),
                    size: AppDimens.d64,
                    color: AppColors.primary,
                  ),
                )
              : const SizedBox.shrink(),
        ),
        const SizedBox(height: AppDimens.d24),

        // Match button
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _tappedForCurrent ? null : _onMatchTap,
            borderRadius: BorderRadius.circular(AppDimens.radiusFull),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: AppDimens.touchMin,
              width: 160,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _tappedForCurrent
                    ? AppColors.surfaceSoft
                    : AppColors.accentTeal,
                borderRadius: BorderRadius.circular(AppDimens.radiusFull),
              ),
              child: Text(
                _tappedForCurrent ? 'Tapped!' : 'Match!',
                style: AppTextStyles.button.copyWith(
                  color: _tappedForCurrent
                      ? AppColors.muted
                      : AppColors.onPrimary,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppDimens.d16),

        // N-back hint
        Text(
          'Tap when current = $_nBack step${_nBack > 1 ? 's' : ''} ago',
          style: AppTextStyles.caption.copyWith(color: AppColors.mutedSoft),
        ),
      ],
    );
  }

  Widget _buildResult() {
    final accuracy = _totalExpectedMatches > 0
        ? (_correctHits / _totalExpectedMatches * 100).round()
        : 100;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          accuracy >= 80
              ? Icons.check_circle_rounded
              : Icons.info_outline_rounded,
          size: AppDimens.iconXl,
          color: accuracy >= 80 ? AppColors.success : AppColors.warning,
        ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
        const SizedBox(height: AppDimens.d16),
        Text(
          '$accuracy% Accuracy',
          style: AppTextStyles.titleLg.copyWith(color: AppColors.ink),
        ),
        const SizedBox(height: AppDimens.d8),
        Text(
          'Correct matches: $_correctHits / $_totalExpectedMatches\n'
          'False alarms: $_falseAlarms',
          style: AppTextStyles.bodyMd.copyWith(color: AppColors.body),
          textAlign: TextAlign.center,
        ),
      ],
    ).animate().fadeIn(duration: 400.ms);
  }
}

enum _NBackPhase { instructions, playing, result }
