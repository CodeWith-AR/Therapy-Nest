import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/exercise_item_model.dart';

/// Word-picture pair memory exercise.
///
/// 1. **Study phase**: Shows N word-icon pairs for [displayTimeMs].
/// 2. **Match phase**: Words and icons are shuffled; user taps pairs to match.
/// 3. Answer is `"correct"` if all pairs matched, `"incorrect"` otherwise.
class WordPairWidget extends StatefulWidget {
  const WordPairWidget({
    super.key,
    required this.item,
    required this.onAnswer,
  });

  final ExerciseItemModel item;
  final void Function(String answer) onAnswer;

  @override
  State<WordPairWidget> createState() => _WordPairWidgetState();
}

class _WordPairWidgetState extends State<WordPairWidget> {
  bool _studying = true;
  Timer? _studyTimer;
  bool _answered = false;

  late List<Map<String, dynamic>> _pairs;
  late int _displayTimeMs;

  // Match-phase state
  late List<String> _shuffledWords;
  late List<int> _shuffledIconCodes;
  int? _selectedWordIndex;
  int? _selectedIconIndex;
  final Map<int, int> _matchedPairs = {}; // wordIdx → iconIdx
  int _correctMatches = 0;

  @override
  void initState() {
    super.initState();
    _parseStimulus();
    _startStudyPhase();
  }

  @override
  void didUpdateWidget(covariant WordPairWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.id != widget.item.id) {
      _studyTimer?.cancel();
      _studying = true;
      _answered = false;
      _selectedWordIndex = null;
      _selectedIconIndex = null;
      _matchedPairs.clear();
      _correctMatches = 0;
      _parseStimulus();
      _startStudyPhase();
    }
  }

  void _parseStimulus() {
    final stimulus = widget.item.stimulus;
    _pairs = List<Map<String, dynamic>>.from(
      (stimulus['pairs'] as List?)?.map((e) => Map<String, dynamic>.from(e as Map)) ?? [],
    );
    _displayTimeMs = (stimulus['displayTimeMs'] as int?) ?? 5000;

    // Build shuffled columns
    _shuffledWords = _pairs.map((p) => p['word'] as String).toList()..shuffle();
    _shuffledIconCodes =
        _pairs.map((p) => p['icon'] as int).toList()..shuffle();
  }

  void _startStudyPhase() {
    _studyTimer = Timer(Duration(milliseconds: _displayTimeMs), () {
      if (mounted) {
        setState(() => _studying = false);
      }
    });
  }

  @override
  void dispose() {
    _studyTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_studying) return _buildStudyPhase();
    return _buildMatchPhase();
  }

  Widget _buildStudyPhase() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Remember these pairs',
          style: AppTextStyles.titleMd.copyWith(color: AppColors.ink),
        ),
        const SizedBox(height: AppDimens.d24),
        ..._pairs.asMap().entries.map((entry) {
          final index = entry.key;
          final pair = entry.value;
          final word = pair['word'] as String;
          final iconCode = pair['icon'] as int;

          return Padding(
            padding: const EdgeInsets.only(bottom: AppDimens.d12),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.d20,
                vertical: AppDimens.d12,
              ),
              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,
                borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                border: Border.all(color: AppColors.hairline),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    IconData(iconCode, fontFamily: 'MaterialIcons'),
                    size: AppDimens.iconLg,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: AppDimens.d16),
                  Text(
                    word,
                    style: AppTextStyles.titleMd.copyWith(color: AppColors.ink),
                  ),
                ],
              ),
            ).animate().fadeIn(
                  duration: 300.ms,
                  delay: Duration(milliseconds: 100 + index * 100),
                ),
          );
        }),
        const SizedBox(height: AppDimens.d12),
        // Countdown indicator
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 1.0, end: 0.0),
          duration: Duration(milliseconds: _displayTimeMs),
          builder: (context, value, child) {
            return LinearProgressIndicator(
              value: value,
              backgroundColor: AppColors.hairline,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              borderRadius: BorderRadius.circular(AppDimens.radiusSm),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMatchPhase() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Match each word with its picture',
          style: AppTextStyles.titleMd.copyWith(color: AppColors.ink),
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: 300.ms),
        const SizedBox(height: AppDimens.d20),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left column — words
            Expanded(
              child: Column(
                children: _shuffledWords.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final word = entry.value;
                  final isMatched = _matchedPairs.containsKey(idx);
                  final isSelected = _selectedWordIndex == idx;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppDimens.d8),
                    child: _MatchTile(
                      label: word,
                      isSelected: isSelected,
                      isMatched: isMatched,
                      isDisabled: _answered || isMatched,
                      onTap: () => _onWordTap(idx),
                    ),
                  ).animate().fadeIn(
                        duration: 300.ms,
                        delay: Duration(milliseconds: 50 + idx * 60),
                      );
                }).toList(),
              ),
            ),
            const SizedBox(width: AppDimens.d12),
            // Right column — icons
            Expanded(
              child: Column(
                children: _shuffledIconCodes.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final iconCode = entry.value;
                  final isMatched = _matchedPairs.containsValue(idx);
                  final isSelected = _selectedIconIndex == idx;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppDimens.d8),
                    child: _IconMatchTile(
                      iconCode: iconCode,
                      isSelected: isSelected,
                      isMatched: isMatched,
                      isDisabled: _answered || isMatched,
                      onTap: () => _onIconTap(idx),
                    ),
                  ).animate().fadeIn(
                        duration: 300.ms,
                        delay: Duration(milliseconds: 80 + idx * 60),
                      );
                }).toList(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _onWordTap(int index) {
    if (_answered || _matchedPairs.containsKey(index)) return;
    setState(() => _selectedWordIndex = index);
    _tryMatch();
  }

  void _onIconTap(int index) {
    if (_answered || _matchedPairs.containsValue(index)) return;
    setState(() => _selectedIconIndex = index);
    _tryMatch();
  }

  void _tryMatch() {
    if (_selectedWordIndex == null || _selectedIconIndex == null) return;

    final wordIdx = _selectedWordIndex!;
    final iconIdx = _selectedIconIndex!;

    // Check if this is a correct pair
    final selectedWord = _shuffledWords[wordIdx];
    final selectedIcon = _shuffledIconCodes[iconIdx];

    // Find the original pair for this word
    final originalPair = _pairs.firstWhere(
      (p) => p['word'] == selectedWord,
      orElse: () => <String, dynamic>{},
    );
    final isCorrectPair = originalPair.isNotEmpty &&
        originalPair['icon'] == selectedIcon;

    setState(() {
      _matchedPairs[wordIdx] = iconIdx;
      if (isCorrectPair) _correctMatches++;
      _selectedWordIndex = null;
      _selectedIconIndex = null;
    });

    // Check if all pairs have been attempted
    if (_matchedPairs.length >= _pairs.length) {
      setState(() => _answered = true);
      final answer = _correctMatches == _pairs.length ? 'correct' : 'incorrect';
      widget.onAnswer(answer);
    }
  }
}

class _MatchTile extends StatelessWidget {
  const _MatchTile({
    required this.label,
    required this.isSelected,
    required this.isMatched,
    required this.isDisabled,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final bool isMatched;
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
          height: AppDimens.touchSmall,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isMatched
                ? AppColors.surfaceSoft
                : isSelected
                    ? AppColors.primaryLight
                    : AppColors.canvas,
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            border: Border.all(
              color: isMatched
                  ? AppColors.success
                  : isSelected
                      ? AppColors.primary
                      : AppColors.hairline,
              width: isSelected ? 2.0 : 1.0,
            ),
          ),
          child: Text(
            label,
            style: AppTextStyles.bodyMd.copyWith(
              color: isMatched ? AppColors.muted : AppColors.ink,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class _IconMatchTile extends StatelessWidget {
  const _IconMatchTile({
    required this.iconCode,
    required this.isSelected,
    required this.isMatched,
    required this.isDisabled,
    required this.onTap,
  });

  final int iconCode;
  final bool isSelected;
  final bool isMatched;
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
          height: AppDimens.touchSmall,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isMatched
                ? AppColors.surfaceSoft
                : isSelected
                    ? AppColors.primaryLight
                    : AppColors.canvas,
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            border: Border.all(
              color: isMatched
                  ? AppColors.success
                  : isSelected
                      ? AppColors.primary
                      : AppColors.hairline,
              width: isSelected ? 2.0 : 1.0,
            ),
          ),
          child: Icon(
            IconData(iconCode, fontFamily: 'MaterialIcons'),
            size: AppDimens.iconMd,
            color: isMatched ? AppColors.muted : AppColors.primary,
          ),
        ),
      ),
    );
  }
}
