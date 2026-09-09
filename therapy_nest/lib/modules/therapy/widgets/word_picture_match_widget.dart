import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/exercise_item_model.dart';

/// 8A — Word-Picture Matching.
///
/// Mode A (`wordToImage`): Written word displayed → user selects matching
/// image from a 2×2 grid of Material icons.
/// Mode B (`imageToWord`): Image (Material icon) displayed → user selects
/// matching word from 4 text options.
///
/// Stimulus schema:
/// ```json
/// {
///   "word": "apple",
///   "targetIcon": 58123,
///   "mode": "wordToImage",
///   "options": [
///     {"icon": 58123, "label": "apple"},
///     {"icon": 58456, "label": "car"},
///     {"icon": 58789, "label": "house"},
///     {"icon": 59000, "label": "star"}
///   ]
/// }
/// ```
class WordPictureMatchWidget extends StatefulWidget {
  const WordPictureMatchWidget({
    super.key,
    required this.item,
    required this.onAnswer,
  });

  final ExerciseItemModel item;
  final void Function(String answer) onAnswer;

  @override
  State<WordPictureMatchWidget> createState() => _WordPictureMatchWidgetState();
}

class _WordPictureMatchWidgetState extends State<WordPictureMatchWidget> {
  _Phase _phase = _Phase.stimulus;
  bool _answered = false;
  String? _selectedAnswer;

  late FlutterTts _tts;
  late String _word;
  late int _targetIcon;
  late String _mode; // 'wordToImage' or 'imageToWord'
  late List<Map<String, dynamic>> _options;

  @override
  void initState() {
    super.initState();
    _tts = FlutterTts();
    _parseStimulus();
    _speakWord();
  }

  @override
  void didUpdateWidget(covariant WordPictureMatchWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.id != widget.item.id) {
      _tts.stop();
      _phase = _Phase.stimulus;
      _answered = false;
      _selectedAnswer = null;
      _parseStimulus();
      _speakWord();
    }
  }

  void _parseStimulus() {
    final stimulus = widget.item.stimulus;
    _word = (stimulus['word'] as String?) ?? '';
    _targetIcon = (stimulus['targetIcon'] as int?) ?? Icons.image.codePoint;
    _mode = (stimulus['mode'] as String?) ?? 'wordToImage';
    _options = (stimulus['options'] as List?)
            ?.map((e) => Map<String, dynamic>.from(e as Map))
            .toList() ??
        [];
  }

  Future<void> _speakWord() async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.4);
      await _tts.speak(_word);
    } catch (_) {}
  }

  void _selectOption(String label) {
    if (_answered) return;
    setState(() => _selectedAnswer = label);
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
  void dispose() {
    _tts.stop();
    super.dispose();
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
              Icons.image_search_rounded,
              size: AppDimens.iconMd,
              color: AppColors.accentTeal,
            ),
            const SizedBox(width: AppDimens.d8),
            Text(
              'Word-Picture Match',
              style: AppTextStyles.titleMd.copyWith(color: AppColors.ink),
            ),
          ],
        ),
        const SizedBox(height: AppDimens.d20),

        // Prompt: show word or icon depending on mode
        if (_mode == 'wordToImage') ...[
          // Show word, pick from icon grid
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.d24,
              vertical: AppDimens.d16,
            ),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            ),
            child: Text(
              _word,
              style: AppTextStyles.displayMd.copyWith(color: AppColors.ink),
            ),
          ).animate().fadeIn(duration: 300.ms),
          const SizedBox(height: AppDimens.d20),

          // 2×2 icon grid
          _buildIconGrid(),
        ] else ...[
          // Show icon, pick from word options
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(AppDimens.radiusLg),
              border: Border.all(color: AppColors.hairline),
            ),
            child: Center(
              child: Icon(
                IconData(_targetIcon, fontFamily: 'MaterialIcons'),
                size: AppDimens.d64,
                color: AppColors.primary,
              ),
            ),
          ).animate().fadeIn(duration: 300.ms).scale(
                begin: const Offset(0.9, 0.9),
                end: const Offset(1, 1),
                duration: 300.ms,
              ),
          const SizedBox(height: AppDimens.d20),

          // Word options
          ..._buildWordOptions(),
        ],

        const SizedBox(height: AppDimens.d16),

        // Submit button
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
                style: AppTextStyles.button.copyWith(
                  color: AppColors.onPrimary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIconGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppDimens.d12,
      crossAxisSpacing: AppDimens.d12,
      childAspectRatio: 1.0,
      children: List.generate(_options.length, (i) {
        final option = _options[i];
        final label = option['label'] as String? ?? '';
        final iconCode = option['icon'] as int? ?? Icons.help.codePoint;
        final isSelected = _selectedAnswer == label;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _selectOption(label),
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryLight
                    : AppColors.surfaceWhite,
                borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.hairline,
                  width: isSelected ? 2.0 : 1.0,
                ),
              ),
              child: Center(
                child: Icon(
                  IconData(iconCode, fontFamily: 'MaterialIcons'),
                  size: AppDimens.d48,
                  color: isSelected ? AppColors.primary : AppColors.body,
                ),
              ),
            ),
          ),
        ).animate().fadeIn(
              duration: 200.ms,
              delay: Duration(milliseconds: 80 * i),
            );
      }),
    );
  }

  List<Widget> _buildWordOptions() {
    return List.generate(_options.length, (i) {
      final option = _options[i];
      final label = option['label'] as String? ?? '';
      final isSelected = _selectedAnswer == label;

      return Padding(
        padding: const EdgeInsets.only(bottom: AppDimens.d8),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _selectOption(label),
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: double.infinity,
              height: AppDimens.touchNormal,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryLight
                    : AppColors.surfaceWhite,
                borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.hairline,
                  width: isSelected ? 2.0 : 1.0,
                ),
              ),
              child: Text(
                label,
                style: AppTextStyles.titleSm.copyWith(
                  color: isSelected ? AppColors.primary : AppColors.ink,
                ),
              ),
            ),
          ),
        ).animate().fadeIn(
              duration: 200.ms,
              delay: Duration(milliseconds: 50 * i),
            ),
      );
    });
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
