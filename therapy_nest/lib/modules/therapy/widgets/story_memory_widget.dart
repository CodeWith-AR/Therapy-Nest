import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/exercise_item_model.dart';

/// Story memory exercise — TTS reads a short story, then asks
/// multiple-choice questions after an optional delay.
///
/// 1. **Listen phase**: TTS reads the story (fallback: text displayed).
/// 2. **Delay phase**: Optional wait period (0–30s) before question.
/// 3. **Question phase**: Standard multiple-choice about the story.
class StoryMemoryWidget extends StatefulWidget {
  const StoryMemoryWidget({
    super.key,
    required this.item,
    required this.onAnswer,
  });

  final ExerciseItemModel item;
  final void Function(String answer) onAnswer;

  @override
  State<StoryMemoryWidget> createState() => _StoryMemoryWidgetState();
}

class _StoryMemoryWidgetState extends State<StoryMemoryWidget> {
  _StoryPhase _phase = _StoryPhase.listening;
  bool _ttsAvailable = true;
  bool _answered = false;
  String? _selectedOption;

  late FlutterTts _tts;
  late String _storyText;
  late String _questionText;
  late List<String> _options;
  late int _delayMs;

  Timer? _delayTimer;
  int _delayRemaining = 0;

  @override
  void initState() {
    super.initState();
    _tts = FlutterTts();
    _parseStimulus();
    _initTts();
  }

  @override
  void didUpdateWidget(covariant StoryMemoryWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.id != widget.item.id) {
      _tts.stop();
      _delayTimer?.cancel();
      _phase = _StoryPhase.listening;
      _answered = false;
      _selectedOption = null;
      _parseStimulus();
      _startListening();
    }
  }

  void _parseStimulus() {
    final stimulus = widget.item.stimulus;
    _storyText = stimulus['storyText'] as String? ?? '';
    _questionText = stimulus['questionText'] as String? ?? '';
    _options = List<String>.from(stimulus['options'] as List? ?? []);
    _delayMs = (stimulus['delayMs'] as int?) ?? 0;
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.42);
      await _tts.setPitch(1.0);
      _tts.setCompletionHandler(_onStoryFinished);
      _startListening();
    } catch (_) {
      _ttsAvailable = false;
      _startListening();
    }
  }

  void _startListening() {
    if (_ttsAvailable) {
      _tts.speak(_storyText);
    } else {
      // Fallback: show text for ~4s per sentence (rough heuristic)
      final sentences = _storyText.split(RegExp(r'[.!?]+')).length;
      final readTimeMs = sentences * 3000;
      Future.delayed(Duration(milliseconds: readTimeMs), () {
        if (mounted && _phase == _StoryPhase.listening) {
          _onStoryFinished();
        }
      });
    }
  }

  void _onStoryFinished() {
    if (!mounted) return;
    if (_delayMs > 0) {
      _startDelay();
    } else {
      setState(() => _phase = _StoryPhase.question);
    }
  }

  void _startDelay() {
    setState(() {
      _phase = _StoryPhase.delay;
      _delayRemaining = (_delayMs / 1000).ceil();
    });

    _delayTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _delayRemaining--;
      if (_delayRemaining <= 0) {
        timer.cancel();
        if (mounted) {
          setState(() => _phase = _StoryPhase.question);
        }
      } else {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tts.stop();
    _delayTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (_phase) {
      case _StoryPhase.listening:
        return _buildListeningPhase();
      case _StoryPhase.delay:
        return _buildDelayPhase();
      case _StoryPhase.question:
        return _buildQuestionPhase();
    }
  }

  Widget _buildListeningPhase() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          _ttsAvailable ? Icons.auto_stories_rounded : Icons.menu_book_rounded,
          size: AppDimens.iconXl,
          color: AppColors.primary,
        ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
              begin: const Offset(1.0, 1.0),
              end: const Offset(1.1, 1.1),
              duration: 1000.ms,
            ),
        const SizedBox(height: AppDimens.d20),
        Text(
          _ttsAvailable ? 'Listen to the story…' : 'Read the story carefully',
          style: AppTextStyles.titleMd.copyWith(color: AppColors.ink),
        ),
        const SizedBox(height: AppDimens.d16),

        // Show text if TTS not available
        if (!_ttsAvailable)
          Container(
            padding: const EdgeInsets.all(AppDimens.d16),
            decoration: BoxDecoration(
              color: AppColors.surfaceWhite,
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
              border: Border.all(color: AppColors.hairline),
            ),
            child: Text(
              _storyText,
              style: AppTextStyles.bodyLg.copyWith(
                color: AppColors.ink,
                height: 1.8,
              ),
            ),
          ).animate().fadeIn(duration: 400.ms),

        if (_ttsAvailable) ...[
          const SizedBox(height: AppDimens.d12),
          // Animated listening indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              return Container(
                width: 4,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                ),
              )
                  .animate(
                    onPlay: (c) => c.repeat(reverse: true),
                  )
                  .custom(
                    duration: Duration(milliseconds: 400 + i * 100),
                    builder: (context, value, child) {
                      return SizedBox(
                        width: 4,
                        height: 12 + 16 * value,
                        child: child,
                      );
                    },
                  );
            }),
          ),
        ],
      ],
    );
  }

  Widget _buildDelayPhase() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.hourglass_top_rounded,
          size: AppDimens.iconXl,
          color: AppColors.accentAmber,
        ).animate(onPlay: (c) => c.repeat()).rotate(duration: 2000.ms),
        const SizedBox(height: AppDimens.d20),
        Text(
          'Please wait…',
          style: AppTextStyles.titleMd.copyWith(color: AppColors.ink),
        ),
        const SizedBox(height: AppDimens.d12),
        Text(
          '$_delayRemaining',
          style: AppTextStyles.displayLg.copyWith(color: AppColors.primary),
        ),
        const SizedBox(height: AppDimens.d8),
        Text(
          'The question will appear shortly',
          style: AppTextStyles.bodySm.copyWith(color: AppColors.muted),
        ),
      ],
    );
  }

  Widget _buildQuestionPhase() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          _questionText,
          style: AppTextStyles.titleMd.copyWith(color: AppColors.ink),
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: 300.ms),
        const SizedBox(height: AppDimens.d24),

        ..._options.asMap().entries.map((entry) {
          final index = entry.key;
          final option = entry.value;
          final isSelected = _selectedOption == option;

          return Padding(
            padding: const EdgeInsets.only(bottom: AppDimens.d12),
            child: _StoryOptionButton(
              label: option,
              isSelected: isSelected,
              isDisabled: _answered,
              onTap: () => _onOptionTap(option),
            ),
          ).animate().fadeIn(
                duration: 300.ms,
                delay: Duration(milliseconds: 100 + index * 80),
              );
        }),
      ],
    );
  }

  void _onOptionTap(String option) {
    if (_answered) return;
    setState(() {
      _selectedOption = option;
      _answered = true;
    });
    widget.onAnswer(option);
  }
}

enum _StoryPhase { listening, delay, question }

class _StoryOptionButton extends StatelessWidget {
  const _StoryOptionButton({
    required this.label,
    required this.isSelected,
    required this.isDisabled,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final bool isDisabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isDisabled ? null : onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.d20,
            vertical: AppDimens.d16,
          ),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryLight : AppColors.canvas,
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.hairline,
              width: isSelected ? 2.0 : 1.0,
            ),
          ),
          child: Text(
            label,
            style: AppTextStyles.bodyLg.copyWith(
              color: isSelected ? AppColors.primaryDark : AppColors.body,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
