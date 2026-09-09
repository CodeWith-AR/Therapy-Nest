import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/exercise_item_model.dart';

/// 8C — Functional Reading (Real-World Text).
///
/// Shows a styled text card simulating a real-world document
/// (menu, medication label, street sign, map) followed by a
/// comprehension MC question.
///
/// Stimulus schema:
/// ```json
/// {
///   "docType": "menu",
///   "documentText": "Today's Special:\\nGrilled Chicken $9.99\\nSoup of the Day $4.50",
///   "question": "How much is the grilled chicken?",
///   "options": ["$9.99", "$4.50", "$12.00", "$7.99"]
/// }
/// ```
class FunctionalReadingWidget extends StatefulWidget {
  const FunctionalReadingWidget({
    super.key,
    required this.item,
    required this.onAnswer,
  });

  final ExerciseItemModel item;
  final void Function(String answer) onAnswer;

  @override
  State<FunctionalReadingWidget> createState() =>
      _FunctionalReadingWidgetState();
}

class _FunctionalReadingWidgetState extends State<FunctionalReadingWidget> {
  _Phase _phase = _Phase.reading;
  bool _answered = false;
  String? _selectedOption;

  late String _docType;
  late String _documentText;
  late String _question;
  late List<String> _options;

  @override
  void initState() {
    super.initState();
    _parseStimulus();
  }

  @override
  void didUpdateWidget(covariant FunctionalReadingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.id != widget.item.id) {
      _phase = _Phase.reading;
      _answered = false;
      _selectedOption = null;
      _parseStimulus();
    }
  }

  void _parseStimulus() {
    final stimulus = widget.item.stimulus;
    _docType = (stimulus['docType'] as String?) ?? 'sign';
    _documentText = (stimulus['documentText'] as String?) ?? '';
    _question = (stimulus['question'] as String?) ?? '';
    _options = List<String>.from(stimulus['options'] as List? ?? []);
  }

  IconData _docTypeIcon() {
    switch (_docType) {
      case 'menu':
        return Icons.restaurant_menu_rounded;
      case 'label':
        return Icons.medication_rounded;
      case 'sign':
        return Icons.signpost_rounded;
      case 'map':
        return Icons.map_rounded;
      default:
        return Icons.description_rounded;
    }
  }

  String _docTypeLabel() {
    switch (_docType) {
      case 'menu':
        return 'Menu';
      case 'label':
        return 'Medication Label';
      case 'sign':
        return 'Street Sign';
      case 'map':
        return 'Map / Directory';
      default:
        return 'Document';
    }
  }

  Color _docBgColor() {
    switch (_docType) {
      case 'menu':
        return AppColors.accentAmber.withValues(alpha: 0.08);
      case 'label':
        return AppColors.accentTeal.withValues(alpha: 0.08);
      case 'sign':
        return AppColors.accentGreen.withValues(alpha: 0.08);
      case 'map':
        return AppColors.primaryLight;
      default:
        return AppColors.surfaceSoft;
    }
  }

  Color _docBorderColor() {
    switch (_docType) {
      case 'menu':
        return AppColors.accentAmber.withValues(alpha: 0.3);
      case 'label':
        return AppColors.accentTeal.withValues(alpha: 0.3);
      case 'sign':
        return AppColors.accentGreen.withValues(alpha: 0.3);
      default:
        return AppColors.hairline;
    }
  }

  void _advanceToQuestion() {
    setState(() => _phase = _Phase.question);
  }

  void _selectOption(String option) {
    if (_answered) return;
    setState(() => _selectedOption = option);
  }

  void _submitAnswer() {
    if (_answered || _selectedOption == null) return;
    setState(() {
      _answered = true;
      _phase = _Phase.result;
    });
    widget.onAnswer(_selectedOption!);
  }

  @override
  Widget build(BuildContext context) {
    switch (_phase) {
      case _Phase.reading:
        return _buildReading();
      case _Phase.question:
        return _buildQuestion();
      case _Phase.result:
        return _buildResult();
    }
  }

  // ── Phase 1: Reading ──────────────────────────────────────────────

  Widget _buildReading() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _docTypeIcon(),
              size: AppDimens.iconMd,
              color: AppColors.accentTeal,
            ),
            const SizedBox(width: AppDimens.d8),
            Text(
              _docTypeLabel(),
              style: AppTextStyles.titleMd.copyWith(color: AppColors.ink),
            ),
          ],
        ),
        const SizedBox(height: AppDimens.d8),
        Text(
          'Read the text carefully, then answer the question.',
          style: AppTextStyles.bodySm.copyWith(color: AppColors.muted),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimens.d20),

        // Document card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppDimens.d20),
          decoration: BoxDecoration(
            color: _docBgColor(),
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            border: Border.all(color: _docBorderColor()),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Doc type badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.d8,
                  vertical: AppDimens.d4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _docTypeIcon(),
                      size: AppDimens.iconSm - 4,
                      color: AppColors.muted,
                    ),
                    const SizedBox(width: AppDimens.d4),
                    Text(
                      _docTypeLabel().toUpperCase(),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.muted,
                        fontSize: 10,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimens.d16),
              // Document text
              Text(
                _documentText,
                style: AppTextStyles.bodyLg.copyWith(
                  color: AppColors.ink,
                  height: 1.8,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 400.ms),
        const SizedBox(height: AppDimens.d20),

        // Continue button
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _advanceToQuestion,
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            child: Container(
              width: double.infinity,
              height: AppDimens.touchSmall,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppDimens.radiusMd),
              ),
              child: Text(
                'Answer Question',
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

  // ── Phase 2: Question ─────────────────────────────────────────────

  Widget _buildQuestion() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _question,
          style: AppTextStyles.titleMd.copyWith(color: AppColors.ink),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimens.d20),

        // Options
        ...List.generate(_options.length, (i) {
          final option = _options[i];
          final isSelected = _selectedOption == option;

          return Padding(
            padding: const EdgeInsets.only(bottom: AppDimens.d8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _selectOption(option),
                borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: double.infinity,
                  height: AppDimens.touchNormal,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.d16,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryLight
                        : AppColors.surfaceWhite,
                    borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                    border: Border.all(
                      color:
                          isSelected ? AppColors.primary : AppColors.hairline,
                      width: isSelected ? 2.0 : 1.0,
                    ),
                  ),
                  child: Text(
                    option,
                    style: AppTextStyles.titleSm.copyWith(
                      color: isSelected ? AppColors.primary : AppColors.ink,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ).animate().fadeIn(
                  duration: 200.ms,
                  delay: Duration(milliseconds: 50 * i),
                ),
          );
        }),
        const SizedBox(height: AppDimens.d12),

        // Submit
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
                color: _selectedOption != null
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

  // ── Result ────────────────────────────────────────────────────────

  Widget _buildResult() {
    final isCorrect = widget.item.isCorrect(_selectedOption ?? '');

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

enum _Phase { reading, question, result }
