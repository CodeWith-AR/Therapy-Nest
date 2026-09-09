import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/exercise_item_model.dart';

/// 6B — Word Fluency / Category Generation.
///
/// "Name as many [animals] as you can in 60 seconds."
///
/// - Visible countdown timer (configurable via `stimulus['timeLimitMs']`)
/// - Text input → chips list of submitted words
/// - Duplicate detection, silence prompts after 10s
/// - Scored against `stimulus['validItems']` (case-insensitive)
/// - Answer format: `"validCount/totalSubmitted"`
class WordFluencyWidget extends StatefulWidget {
  const WordFluencyWidget({
    super.key,
    required this.item,
    required this.onAnswer,
  });

  final ExerciseItemModel item;
  final void Function(String answer) onAnswer;

  @override
  State<WordFluencyWidget> createState() => _WordFluencyWidgetState();
}

class _WordFluencyWidgetState extends State<WordFluencyWidget> {
  _Phase _phase = _Phase.instructions;
  bool _answered = false;

  late String _category;
  late int _timeLimitMs;
  late Set<String> _validItemsLower;
  late int _minTarget;

  int _remainingMs = 0;
  Timer? _countdownTimer;
  Timer? _silenceTimer;
  bool _showNudge = false;

  final List<String> _submittedWords = [];
  final Set<String> _submittedLower = {};
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _inputFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _parseStimulus();
  }

  @override
  void didUpdateWidget(covariant WordFluencyWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.id != widget.item.id) {
      _countdownTimer?.cancel();
      _silenceTimer?.cancel();
      _phase = _Phase.instructions;
      _answered = false;
      _submittedWords.clear();
      _submittedLower.clear();
      _inputController.clear();
      _showNudge = false;
      _parseStimulus();
    }
  }

  void _parseStimulus() {
    final stimulus = widget.item.stimulus;
    _category = (stimulus['category'] as String?) ?? 'items';
    _timeLimitMs = (stimulus['timeLimitMs'] as int?) ?? 60000;
    _remainingMs = _timeLimitMs;
    final validItems = List<String>.from(stimulus['validItems'] as List? ?? []);
    _validItemsLower = validItems.map((e) => e.toLowerCase().trim()).toSet();
    _minTarget = (stimulus['minTarget'] as int?) ?? 5;
  }

  void _startExercise() {
    setState(() => _phase = _Phase.playing);
    _inputFocus.requestFocus();
    _resetSilenceTimer();

    _countdownTimer = Timer.periodic(
      const Duration(milliseconds: 100),
      (timer) {
        _remainingMs -= 100;
        if (_remainingMs <= 0) {
          timer.cancel();
          _submitFinal();
        } else {
          setState(() {});
        }
      },
    );
  }

  void _resetSilenceTimer() {
    _silenceTimer?.cancel();
    setState(() => _showNudge = false);
    _silenceTimer = Timer(const Duration(seconds: 10), () {
      if (!_answered && mounted) {
        setState(() => _showNudge = true);
      }
    });
  }

  void _addWord() {
    final word = _inputController.text.trim();
    if (word.isEmpty) return;
    final lower = word.toLowerCase();

    // Duplicate check
    if (_submittedLower.contains(lower)) {
      _inputController.clear();
      return;
    }

    setState(() {
      _submittedWords.add(word);
      _submittedLower.add(lower);
    });
    _inputController.clear();
    _inputFocus.requestFocus();
    _resetSilenceTimer();
  }

  void _submitFinal() {
    if (_answered) return;
    _countdownTimer?.cancel();
    _silenceTimer?.cancel();

    final validCount =
        _submittedLower.where((w) => _validItemsLower.contains(w)).length;
    final total = _submittedWords.length;

    setState(() {
      _answered = true;
      _phase = _Phase.result;
    });
    widget.onAnswer('$validCount/$total');
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _silenceTimer?.cancel();
    _inputController.dispose();
    _inputFocus.dispose();
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
    final seconds = (_timeLimitMs / 1000).round();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.category_rounded,
          size: AppDimens.iconXl,
          color: AppColors.accentTeal,
        ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
        const SizedBox(height: AppDimens.d20),
        Text(
          'Word Fluency',
          style: AppTextStyles.titleLg.copyWith(color: AppColors.ink),
        ),
        const SizedBox(height: AppDimens.d12),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.d24,
            vertical: AppDimens.d12,
          ),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          ),
          child: Text(
            'Name as many $_category as you can\nin $seconds seconds',
            style: AppTextStyles.bodyMd.copyWith(color: AppColors.body),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: AppDimens.d12),
        Text(
          'Type each word and press Enter or Submit.',
          style: AppTextStyles.bodySm.copyWith(color: AppColors.muted),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimens.d24),
        _ActionButton(label: 'Start', onTap: _startExercise),
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
                    progress > 0.3 ? AppColors.accentTeal : AppColors.error,
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
        const SizedBox(height: AppDimens.d12),

        // Category reminder
        Text(
          'Category: $_category',
          style: AppTextStyles.titleSm.copyWith(color: AppColors.primary),
        ),
        const SizedBox(height: AppDimens.d16),

        // Silence nudge
        if (_showNudge)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.d12,
              vertical: AppDimens.d8,
            ),
            margin: const EdgeInsets.only(bottom: AppDimens.d12),
            decoration: BoxDecoration(
              color: AppColors.accentAmber.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppDimens.radiusSm),
            ),
            child: Row(
              children: [
                Icon(Icons.emoji_events_rounded,
                    size: AppDimens.iconSm, color: AppColors.warning),
                const SizedBox(width: AppDimens.d8),
                Text(
                  'Keep going! Think of more $_category.',
                  style:
                      AppTextStyles.bodySm.copyWith(color: AppColors.bodyStrong),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms),

        // Input row
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _inputController,
                focusNode: _inputFocus,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  hintText: 'Type a word…',
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
                    borderSide:
                        BorderSide(color: AppColors.accentTeal, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.d16,
                    vertical: AppDimens.d12,
                  ),
                ),
                style: AppTextStyles.bodyLg.copyWith(color: AppColors.ink),
                onSubmitted: (_) => _addWord(),
              ),
            ),
            const SizedBox(width: AppDimens.d8),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _addWord,
                borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                child: Container(
                  width: AppDimens.touchSmall,
                  height: AppDimens.touchSmall,
                  decoration: BoxDecoration(
                    color: AppColors.accentTeal,
                    borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                  ),
                  child: Icon(
                    Icons.add_rounded,
                    color: AppColors.onPrimary,
                    size: AppDimens.iconMd,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimens.d16),

        // Submitted words chips
        if (_submittedWords.isNotEmpty)
          Wrap(
            spacing: AppDimens.d8,
            runSpacing: AppDimens.d8,
            children: _submittedWords
                .map(
                  (w) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.d12,
                      vertical: AppDimens.d4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius:
                          BorderRadius.circular(AppDimens.radiusFull),
                      border: Border.all(color: AppColors.hairline),
                    ),
                    child: Text(
                      w,
                      style: AppTextStyles.bodySm.copyWith(
                        color: AppColors.bodyStrong,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),

        const SizedBox(height: AppDimens.d16),

        // Word count
        Text(
          '${_submittedWords.length} words',
          style: AppTextStyles.caption.copyWith(color: AppColors.muted),
        ),
      ],
    );
  }

  // ── Result ─────────────────────────────────────────────────────────

  Widget _buildResult() {
    final validCount =
        _submittedLower.where((w) => _validItemsLower.contains(w)).length;
    final total = _submittedWords.length;
    final met = validCount >= _minTarget;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          met ? Icons.check_circle_rounded : Icons.info_outline_rounded,
          size: AppDimens.iconXl,
          color: met ? AppColors.success : AppColors.warning,
        ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
        const SizedBox(height: AppDimens.d16),
        Text(
          met ? 'Great Job!' : 'Results',
          style: AppTextStyles.titleLg.copyWith(color: AppColors.ink),
        ),
        const SizedBox(height: AppDimens.d12),
        _ResultRow(label: 'Valid words', value: '$validCount'),
        _ResultRow(label: 'Total submitted', value: '$total'),
        _ResultRow(label: 'Target', value: '$_minTarget'),
      ],
    ).animate().fadeIn(duration: 400.ms);
  }
}

// ── Shared helpers ──────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.label, required this.onTap});
  final String label;
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
            label,
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
