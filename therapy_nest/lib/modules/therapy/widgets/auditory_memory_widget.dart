import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/exercise_item_model.dart';

/// Auditory memory exercise — TTS reads a list of words,
/// user selects all heard words from a larger list.
///
/// 1. **Listen phase**: TTS speaks target words one at a time.
///    Fallback: if TTS fails, words flash on-screen briefly.
/// 2. **Select phase**: User sees targets + distractors, taps all heard.
/// 3. Answer = comma-joined selected words.
class AuditoryMemoryWidget extends StatefulWidget {
  const AuditoryMemoryWidget({
    super.key,
    required this.item,
    required this.onAnswer,
  });

  final ExerciseItemModel item;
  final void Function(String answer) onAnswer;

  @override
  State<AuditoryMemoryWidget> createState() => _AuditoryMemoryWidgetState();
}

class _AuditoryMemoryWidgetState extends State<AuditoryMemoryWidget> {
  // Phases: listening → selecting → answered
  _Phase _phase = _Phase.listening;
  int _currentWordIndex = 0;
  bool _ttsAvailable = true;

  late FlutterTts _tts;
  late List<String> _targetWords;
  late List<String> _allOptions;

  final Set<String> _selected = {};
  Timer? _fallbackTimer;

  @override
  void initState() {
    super.initState();
    _tts = FlutterTts();
    _parseStimulus();
    _initTts();
  }

  @override
  void didUpdateWidget(covariant AuditoryMemoryWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.id != widget.item.id) {
      _tts.stop();
      _fallbackTimer?.cancel();
      _phase = _Phase.listening;
      _currentWordIndex = 0;
      _selected.clear();
      _parseStimulus();
      _startListeningPhase();
    }
  }

  void _parseStimulus() {
    final stimulus = widget.item.stimulus;
    _targetWords =
        List<String>.from(stimulus['targetWords'] as List? ?? []);
    _allOptions =
        List<String>.from(stimulus['options'] as List? ?? []);
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.45);
      await _tts.setPitch(1.0);
      _tts.setCompletionHandler(_onWordSpoken);
      _startListeningPhase();
    } catch (_) {
      _ttsAvailable = false;
      _startFallbackDisplay();
    }
  }

  void _startListeningPhase() {
    if (_targetWords.isEmpty) {
      _transitionToSelect();
      return;
    }
    _currentWordIndex = 0;
    if (_ttsAvailable) {
      _speakCurrentWord();
    } else {
      _startFallbackDisplay();
    }
  }

  Future<void> _speakCurrentWord() async {
    if (_currentWordIndex < _targetWords.length) {
      setState(() {}); // refresh UI to show speaking indicator
      await _tts.speak(_targetWords[_currentWordIndex]);
    }
  }

  void _onWordSpoken() {
    _currentWordIndex++;
    if (_currentWordIndex < _targetWords.length) {
      // Brief pause between words
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted && _phase == _Phase.listening) {
          _speakCurrentWord();
        }
      });
    } else {
      // All words spoken
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) _transitionToSelect();
      });
    }
  }

  void _startFallbackDisplay() {
    // Show each word for 1.5s, then transition
    _currentWordIndex = 0;
    setState(() {});
    _fallbackTimer = Timer.periodic(
      const Duration(milliseconds: 1800),
      (timer) {
        _currentWordIndex++;
        if (_currentWordIndex >= _targetWords.length) {
          timer.cancel();
          Future.delayed(const Duration(milliseconds: 400), () {
            if (mounted) _transitionToSelect();
          });
        } else {
          setState(() {});
        }
      },
    );
  }

  void _transitionToSelect() {
    if (mounted) {
      setState(() => _phase = _Phase.selecting);
    }
  }

  @override
  void dispose() {
    _tts.stop();
    _fallbackTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (_phase) {
      case _Phase.listening:
        return _buildListeningPhase();
      case _Phase.selecting:
      case _Phase.answered:
        return _buildSelectPhase();
    }
  }

  Widget _buildListeningPhase() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          _ttsAvailable ? Icons.volume_up_rounded : Icons.visibility_rounded,
          size: AppDimens.iconXl,
          color: AppColors.primary,
        ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
              begin: const Offset(1.0, 1.0),
              end: const Offset(1.15, 1.15),
              duration: 800.ms,
            ),
        const SizedBox(height: AppDimens.d20),
        Text(
          _ttsAvailable ? 'Listen carefully…' : 'Remember these words…',
          style: AppTextStyles.titleMd.copyWith(color: AppColors.ink),
        ),
        const SizedBox(height: AppDimens.d16),
        // If fallback, show the current word
        if (!_ttsAvailable &&
            _currentWordIndex < _targetWords.length)
          Text(
            _targetWords[_currentWordIndex],
            style: AppTextStyles.displayMd.copyWith(color: AppColors.primary),
          ).animate().fadeIn(duration: 300.ms).scale(
                duration: 300.ms,
                curve: Curves.easeOutBack,
              ),
        const SizedBox(height: AppDimens.d20),
        // Progress dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_targetWords.length, (i) {
            return Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.symmetric(horizontal: AppDimens.d4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i <= _currentWordIndex
                    ? AppColors.primary
                    : AppColors.hairline,
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildSelectPhase() {
    final isAnswered = _phase == _Phase.answered;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Select all the words you heard',
          style: AppTextStyles.titleMd.copyWith(color: AppColors.ink),
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: 300.ms),
        const SizedBox(height: AppDimens.d20),

        Wrap(
          alignment: WrapAlignment.center,
          spacing: AppDimens.d8,
          runSpacing: AppDimens.d8,
          children: _allOptions.asMap().entries.map((entry) {
            final index = entry.key;
            final word = entry.value;
            final isSelected = _selected.contains(word);

            return _WordChip(
              word: word,
              isSelected: isSelected,
              isDisabled: isAnswered,
              onTap: () => _onWordToggle(word),
            ).animate().fadeIn(
                  duration: 250.ms,
                  delay: Duration(milliseconds: 50 + index * 40),
                );
          }).toList(),
        ),
        const SizedBox(height: AppDimens.d24),

        // Submit button
        if (!isAnswered)
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _selected.isNotEmpty ? _onSubmit : null,
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: AppDimens.touchSmall,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _selected.isNotEmpty
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
          ).animate().fadeIn(duration: 300.ms, delay: 200.ms),
      ],
    );
  }

  void _onWordToggle(String word) {
    if (_phase == _Phase.answered) return;
    setState(() {
      if (_selected.contains(word)) {
        _selected.remove(word);
      } else {
        _selected.add(word);
      }
    });
  }

  void _onSubmit() {
    setState(() => _phase = _Phase.answered);
    // Sort selected to match accepted_answers format
    final sortedSelected = _selected.toList()..sort();
    widget.onAnswer(sortedSelected.join(', '));
  }
}

enum _Phase { listening, selecting, answered }

class _WordChip extends StatelessWidget {
  const _WordChip({
    required this.word,
    required this.isSelected,
    required this.isDisabled,
    required this.onTap,
  });

  final String word;
  final bool isSelected;
  final bool isDisabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isDisabled ? null : onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusFull),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.d16,
            vertical: AppDimens.d12,
          ),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryLight : AppColors.canvas,
            borderRadius: BorderRadius.circular(AppDimens.radiusFull),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.hairline,
              width: isSelected ? 2.0 : 1.0,
            ),
          ),
          child: Text(
            word,
            style: AppTextStyles.bodyMd.copyWith(
              color: isSelected ? AppColors.primaryDark : AppColors.body,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}
