import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/exercise_item_model.dart';

/// 9C — Money Calculation.
///
/// Mode A (`totalCost`): Show 2–4 items with price tags → user selects
/// the total cost from 4 options.
/// Mode B (`makeChange`): "You paid $X. Items cost $Y. How much change?"
///
/// Real-world grocery/coffee shop context. Currency: USD ($).
///
/// Stimulus schema:
/// ```json
/// {
///   "mode": "totalCost",
///   "items": [
///     {"name": "Coffee", "price": 3.50, "icon": 60232},
///     {"name": "Muffin", "price": 2.25, "icon": 58732}
///   ],
///   "paidAmount": null,
///   "question": "What is the total cost?",
///   "options": ["$5.25", "$5.75", "$6.00", "$6.25"]
/// }
/// ```
class MoneyCalculationWidget extends StatefulWidget {
  const MoneyCalculationWidget({
    super.key,
    required this.item,
    required this.onAnswer,
  });

  final ExerciseItemModel item;
  final void Function(String answer) onAnswer;

  @override
  State<MoneyCalculationWidget> createState() =>
      _MoneyCalculationWidgetState();
}

class _MoneyCalculationWidgetState extends State<MoneyCalculationWidget> {
  _Phase _phase = _Phase.stimulus;
  bool _answered = false;
  String? _selectedAnswer;

  late String _mode;
  late List<Map<String, dynamic>> _items;
  late double? _paidAmount;
  late String _question;
  late List<String> _options;

  @override
  void initState() {
    super.initState();
    _parseStimulus();
  }

  @override
  void didUpdateWidget(covariant MoneyCalculationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.id != widget.item.id) {
      _phase = _Phase.stimulus;
      _answered = false;
      _selectedAnswer = null;
      _parseStimulus();
    }
  }

  void _parseStimulus() {
    final stimulus = widget.item.stimulus;
    _mode = (stimulus['mode'] as String?) ?? 'totalCost';
    _items = (stimulus['items'] as List?)
            ?.map((e) => Map<String, dynamic>.from(e as Map))
            .toList() ??
        [];
    _paidAmount = (stimulus['paidAmount'] as num?)?.toDouble();
    _question = (stimulus['question'] as String?) ?? 'What is the total cost?';
    _options = List<String>.from(stimulus['options'] as List? ?? []);
  }

  void _selectOption(String option) {
    if (_answered) return;
    setState(() => _selectedAnswer = option);
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
              Icons.attach_money_rounded,
              size: AppDimens.iconMd,
              color: AppColors.accentGreen,
            ),
            const SizedBox(width: AppDimens.d8),
            Text(
              'Money Calculation',
              style: AppTextStyles.titleMd.copyWith(color: AppColors.ink),
            ),
          ],
        ),
        const SizedBox(height: AppDimens.d8),
        Text(
          _question,
          style: AppTextStyles.bodySm.copyWith(color: AppColors.muted),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimens.d16),

        // Item list with price tags
        ..._buildItemCards(),

        // Paid amount banner (for makeChange mode)
        if (_mode == 'makeChange' && _paidAmount != null) ...[
          const SizedBox(height: AppDimens.d12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.d16,
              vertical: AppDimens.d12,
            ),
            decoration: BoxDecoration(
              color: AppColors.accentAmber.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
              border: Border.all(
                color: AppColors.accentAmber.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.payment_rounded,
                  size: AppDimens.iconSm,
                  color: AppColors.accentAmber,
                ),
                const SizedBox(width: AppDimens.d8),
                Text(
                  'You paid: \$${_paidAmount!.toStringAsFixed(2)}',
                  style: AppTextStyles.titleSm.copyWith(
                    color: AppColors.ink,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(
                duration: 300.ms,
                delay: Duration(milliseconds: 100 * _items.length),
              ),
        ],

        const SizedBox(height: AppDimens.d20),

        // Options
        ...List.generate(_options.length, (i) {
          final option = _options[i];
          final isSelected = _selectedAnswer == option;

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
                    style: const TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ).copyWith(
                      color: isSelected ? AppColors.primary : AppColors.ink,
                    ),
                  ),
                ),
              ),
            ).animate().fadeIn(
                  duration: 200.ms,
                  delay: Duration(milliseconds: 60 * i),
                ),
          );
        }),

        const SizedBox(height: AppDimens.d8),

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
                color: _selectedAnswer != null
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
        ),
      ],
    );
  }

  List<Widget> _buildItemCards() {
    return List.generate(_items.length, (i) {
      final itemData = _items[i];
      final name = itemData['name'] as String? ?? 'Item';
      final price = (itemData['price'] as num?)?.toDouble() ?? 0.0;
      final iconCode =
          (itemData['icon'] as int?) ?? Icons.shopping_bag.codePoint;

      return Padding(
        padding: const EdgeInsets.only(bottom: AppDimens.d8),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.d16,
            vertical: AppDimens.d12,
          ),
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            border: Border.all(color: AppColors.hairline),
          ),
          child: Row(
            children: [
              Icon(
                IconData(iconCode, fontFamily: 'MaterialIcons'),
                size: AppDimens.iconLg,
                color: AppColors.primary,
              ),
              const SizedBox(width: AppDimens.d12),
              Expanded(
                child: Text(
                  name,
                  style: AppTextStyles.titleSm.copyWith(color: AppColors.ink),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.d12,
                  vertical: AppDimens.d4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accentGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                ),
                child: Text(
                  '\$${price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ).copyWith(color: AppColors.accentGreen),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(
              duration: 250.ms,
              delay: Duration(milliseconds: 80 * i),
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
