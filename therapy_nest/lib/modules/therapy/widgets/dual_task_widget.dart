import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/exercise_item_model.dart';

/// 5C — Divided Attention: Dual Task.
///
/// Presents a two-channel task:
/// 1. **Color channel** — colored squares appear one at a time; user taps
///    when the color matches a target color.
/// 2. **Word channel** — words are displayed visually alongside the color
///    squares; after the sequence, user selects which words they remember.
///
/// TTS audio for word presentation is deferred to Module 7. Words are
/// currently shown visually, but the widget architecture is designed for
/// easy TTS drop-in.
class DualTaskWidget extends StatefulWidget {
  const DualTaskWidget({
    super.key,
    required this.item,
    required this.onAnswer,
  });

  final ExerciseItemModel item;
  final void Function(String answer) onAnswer;

  @override
  State<DualTaskWidget> createState() => _DualTaskWidgetState();
}

class _DualTaskWidgetState extends State<DualTaskWidget> {
  _Phase _phase = _Phase.instructions;
  Timer? _sequenceTimer;
  bool _answered = false;

  late String _targetColor;
  late List<String> _colorSequence;
  late int _intervalMs;
  late List<String> _words;
  late List<String> _targetWords;

  int _currentIndex = -1;
  bool _tappedForCurrent = false;

  // Color channel scoring
  int _colorHits = 0;
  int _colorFalseAlarms = 0;
  late Set<int> _colorTargetIndices;

  // Word channel
  int _wordIndex = 0; // which word to show alongside current color
  final Set<String> _selectedWords = {};
  late List<String> _allWordOptions;

  @override
  void initState() {
    super.initState();
    _parseStimulus();
  }

  @override
  void didUpdateWidget(covariant DualTaskWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.id != widget.item.id) {
      _sequenceTimer?.cancel();
      _phase = _Phase.instructions;
      _answered = false;
      _currentIndex = -1;
      _colorHits = 0;
      _colorFalseAlarms = 0;
      _tappedForCurrent = false;
      _wordIndex = 0;
      _selectedWords.clear();
      _parseStimulus();
    }
  }

  void _parseStimulus() {
    final stimulus = widget.item.stimulus;
    _targetColor = (stimulus['targetColor'] as String?) ?? 'blue';
    _colorSequence =
        List<String>.from(stimulus['colorSequence'] as List? ?? []);
    _intervalMs = (stimulus['intervalMs'] as int?) ?? 1500;
    _words = List<String>.from(stimulus['words'] as List? ?? []);
    _targetWords = List<String>.from(stimulus['targetWords'] as List? ?? []);

    // Pre-compute color target indices
    _colorTargetIndices = <int>{};
    for (var i = 0; i < _colorSequence.length; i++) {
      if (_colorSequence[i] == _targetColor) {
        _colorTargetIndices.add(i);
      }
    }

    // Build word options for recall phase: targets + some distractors
    final distractors = <String>[];
    for (final w in _words) {
      if (!_targetWords.contains(w) && distractors.length < 3) {
        distractors.add(w);
      }
    }
    // Add a few more plausible distractors if needed
    final extraDistractors = ['house', 'river', 'lamp', 'bird', 'stone'];
    for (final d in extraDistractors) {
      if (distractors.length >= 3) break;
      if (!_targetWords.contains(d) && !distractors.contains(d)) {
        distractors.add(d);
      }
    }
    _allWordOptions = [..._targetWords, ...distractors]..shuffle();
  }

  void _startExercise() {
    setState(() {
      _phase = _Phase.playing;
      _currentIndex = 0;
      _tappedForCurrent = false;
      _wordIndex = 0;
    });

    _sequenceTimer = Timer.periodic(
      Duration(milliseconds: _intervalMs),
      (timer) {
        _currentIndex++;
        if (_currentIndex >= _colorSequence.length) {
          timer.cancel();
          setState(() => _phase = _Phase.wordRecall);
        } else {
          setState(() {
            _tappedForCurrent = false;
            // Advance word display every 2 color steps
            if (_currentIndex % 2 == 0 && _wordIndex < _words.length - 1) {
              _wordIndex++;
            }
          });
        }
      },
    );
  }

  void _onColorTap() {
    if (_tappedForCurrent ||
        _answered ||
        _phase != _Phase.playing) {
      return;
    }
    setState(() => _tappedForCurrent = true);

    if (_colorTargetIndices.contains(_currentIndex)) {
      _colorHits++;
    } else {
      _colorFalseAlarms++;
    }
  }

  void _onWordToggle(String word) {
    setState(() {
      if (_selectedWords.contains(word)) {
        _selectedWords.remove(word);
      } else {
        _selectedWords.add(word);
      }
    });
  }

  void _submitWordRecall() {
    if (_answered) return;
    setState(() {
      _phase = _Phase.result;
      _answered = true;
    });

    final wordHits =
        _selectedWords.where((w) => _targetWords.contains(w)).length;
    final answer =
        '$_colorHits/${_colorTargetIndices.length}|$wordHits/${_targetWords.length}';
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
      case _Phase.instructions:
        return _buildInstructions();
      case _Phase.playing:
        return _buildPlaying();
      case _Phase.wordRecall:
        return _buildWordRecall();
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
          Icons.call_split_rounded,
          size: AppDimens.iconXl,
          color: AppColors.accentTeal,
        ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
        const SizedBox(height: AppDimens.d20),
        Text(
          'Dual Task',
          style: AppTextStyles.titleLg.copyWith(color: AppColors.ink),
        ),
        const SizedBox(height: AppDimens.d12),
        Container(
          padding: const EdgeInsets.all(AppDimens.d16),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  _ColorDot(colorName: _targetColor, size: AppDimens.iconMd),
                  const SizedBox(width: AppDimens.d12),
                  Expanded(
                    child: Text(
                      'Tap when you see a $_targetColor square',
                      style: AppTextStyles.bodySm
                          .copyWith(color: AppColors.body),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.d12),
              Row(
                children: [
                  Icon(Icons.visibility_rounded,
                      size: AppDimens.iconMd, color: AppColors.accentPurple),
                  const SizedBox(width: AppDimens.d12),
                  Expanded(
                    child: Text(
                      'Remember the words shown alongside',
                      style: AppTextStyles.bodySm
                          .copyWith(color: AppColors.body),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimens.d24),
        _StartButton(onTap: _startExercise),
      ],
    );
  }

  // ── Playing ────────────────────────────────────────────────────────

  Widget _buildPlaying() {
    final hasItem =
        _currentIndex >= 0 && _currentIndex < _colorSequence.length;
    final currentColor =
        hasItem ? _colorSequence[_currentIndex] : 'gray';
    final showWord = _wordIndex < _words.length;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Progress
        Text(
          '${_currentIndex + 1} / ${_colorSequence.length}',
          style: AppTextStyles.caption.copyWith(color: AppColors.muted),
        ),
        const SizedBox(height: AppDimens.d16),

        // Color square
        GestureDetector(
          onTap: _onColorTap,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, animation) =>
                ScaleTransition(scale: animation, child: child),
            child: Container(
              key: ValueKey('color_$_currentIndex'),
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: _getColorValue(currentColor),
                borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                border: Border.all(
                  color: _tappedForCurrent
                      ? AppColors.accentAmber
                      : AppColors.hairline,
                  width: _tappedForCurrent ? 3.0 : 1.0,
                ),
              ),
              child: _tappedForCurrent
                  ? Center(
                      child: Icon(
                        Icons.touch_app_rounded,
                        size: AppDimens.iconLg,
                        color: AppColors.onPrimary.withValues(alpha: 0.8),
                      ),
                    )
                  : null,
            ),
          ),
        ),
        const SizedBox(height: AppDimens.d16),

        // Tap instruction
        Text(
          _tappedForCurrent
              ? 'Tapped!'
              : 'Tap if $_targetColor',
          style: AppTextStyles.caption.copyWith(
            color: _tappedForCurrent ? AppColors.success : AppColors.muted,
          ),
        ),
        const SizedBox(height: AppDimens.d20),

        // Word display
        if (showWord)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.d20,
              vertical: AppDimens.d8,
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceSoft,
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.hearing_rounded,
                    size: AppDimens.iconSm, color: AppColors.accentPurple),
                const SizedBox(width: AppDimens.d8),
                Text(
                  _words[_wordIndex],
                  style:
                      AppTextStyles.titleMd.copyWith(color: AppColors.ink),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms),
      ],
    );
  }

  // ── Word Recall ────────────────────────────────────────────────────

  Widget _buildWordRecall() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.psychology_rounded,
          size: AppDimens.iconXl,
          color: AppColors.accentPurple,
        ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
        const SizedBox(height: AppDimens.d16),
        Text(
          'Which words did you see?',
          style: AppTextStyles.titleMd.copyWith(color: AppColors.ink),
        ),
        const SizedBox(height: AppDimens.d16),

        Wrap(
          alignment: WrapAlignment.center,
          spacing: AppDimens.d8,
          runSpacing: AppDimens.d8,
          children: _allWordOptions.map((word) {
            final isSelected = _selectedWords.contains(word);
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _onWordToggle(word),
                borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
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
                    word,
                    style: AppTextStyles.titleSm.copyWith(
                      color:
                          isSelected ? AppColors.primary : AppColors.ink,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: AppDimens.d24),

        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _submitWordRecall,
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
                'Submit',
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
    final wordHits =
        _selectedWords.where((w) => _targetWords.contains(w)).length;
    final colorAccuracy = _colorTargetIndices.isNotEmpty
        ? (_colorHits / _colorTargetIndices.length * 100).round()
        : 100;
    final wordAccuracy = _targetWords.isNotEmpty
        ? (wordHits / _targetWords.length * 100).round()
        : 100;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          (colorAccuracy >= 80 && wordAccuracy >= 80)
              ? Icons.check_circle_rounded
              : Icons.info_outline_rounded,
          size: AppDimens.iconXl,
          color: (colorAccuracy >= 80 && wordAccuracy >= 80)
              ? AppColors.success
              : AppColors.warning,
        ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
        const SizedBox(height: AppDimens.d16),
        Text(
          'Dual Task Results',
          style: AppTextStyles.titleLg.copyWith(color: AppColors.ink),
        ),
        const SizedBox(height: AppDimens.d16),
        // Color results
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppDimens.d12),
          decoration: BoxDecoration(
            color: AppColors.surfaceSoft,
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          ),
          child: Column(
            children: [
              Text(
                'Color Task — $colorAccuracy%',
                style: AppTextStyles.titleSm.copyWith(color: AppColors.ink),
              ),
              const SizedBox(height: AppDimens.d4),
              Text(
                'Hits: $_colorHits / ${_colorTargetIndices.length}'
                '${_colorFalseAlarms > 0 ? '  •  False: $_colorFalseAlarms' : ''}',
                style: AppTextStyles.bodySm.copyWith(color: AppColors.body),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimens.d8),
        // Word results
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppDimens.d12),
          decoration: BoxDecoration(
            color: AppColors.surfaceSoft,
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          ),
          child: Column(
            children: [
              Text(
                'Word Recall — $wordAccuracy%',
                style: AppTextStyles.titleSm.copyWith(color: AppColors.ink),
              ),
              const SizedBox(height: AppDimens.d4),
              Text(
                'Recalled: $wordHits / ${_targetWords.length}',
                style: AppTextStyles.bodySm.copyWith(color: AppColors.body),
              ),
            ],
          ),
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

class _ColorDot extends StatelessWidget {
  const _ColorDot({required this.colorName, this.size = 24});
  final String colorName;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _getColorValue(colorName),
        borderRadius: BorderRadius.circular(size * 0.25),
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

enum _Phase { instructions, playing, wordRecall, result }
