import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/exercise_item_model.dart';

/// 9D — Clock Reading.
///
/// Draws an analog clock face via [CustomPainter] with hour and minute
/// hands, tick marks, and numbers 1–12. The user selects the correct
/// time from 4 text options.
///
/// Difficulty: exact hours → half/quarter → 5-minute → any minute.
///
/// Stimulus schema:
/// ```json
/// {
///   "hour": 3,
///   "minute": 0,
///   "options": ["3:00", "6:00", "9:00", "12:00"]
/// }
/// ```
class ClockReadingWidget extends StatefulWidget {
  const ClockReadingWidget({
    super.key,
    required this.item,
    required this.onAnswer,
  });

  final ExerciseItemModel item;
  final void Function(String answer) onAnswer;

  @override
  State<ClockReadingWidget> createState() => _ClockReadingWidgetState();
}

class _ClockReadingWidgetState extends State<ClockReadingWidget> {
  _Phase _phase = _Phase.stimulus;
  bool _answered = false;
  String? _selectedAnswer;

  late int _hour;
  late int _minute;
  late List<String> _options;

  @override
  void initState() {
    super.initState();
    _parseStimulus();
  }

  @override
  void didUpdateWidget(covariant ClockReadingWidget oldWidget) {
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
    _hour = (stimulus['hour'] as int?) ?? 12;
    _minute = (stimulus['minute'] as int?) ?? 0;
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
              Icons.access_time_rounded,
              size: AppDimens.iconMd,
              color: AppColors.accentPurple,
            ),
            const SizedBox(width: AppDimens.d8),
            Text(
              'Clock Reading',
              style: AppTextStyles.titleMd.copyWith(color: AppColors.ink),
            ),
          ],
        ),
        const SizedBox(height: AppDimens.d8),
        Text(
          'What time does the clock show?',
          style: AppTextStyles.bodySm.copyWith(color: AppColors.muted),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimens.d20),

        // Analog clock face
        SizedBox(
          width: 200,
          height: 200,
          child: CustomPaint(
            painter: _AnalogClockPainter(
              hour: _hour,
              minute: _minute,
              faceColor: AppColors.surfaceWhite,
              rimColor: AppColors.ink,
              tickColor: AppColors.body,
              numberColor: AppColors.ink,
              hourHandColor: AppColors.ink,
              minuteHandColor: AppColors.primary,
              centerDotColor: AppColors.error,
            ),
          ),
        ).animate().fadeIn(duration: 400.ms).scale(
              begin: const Offset(0.85, 0.85),
              end: const Offset(1, 1),
              duration: 400.ms,
              curve: Curves.easeOutBack,
            ),

        const SizedBox(height: AppDimens.d24),

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
                      fontSize: 24,
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

// ═══════════════════════════════════════════════════════════════════════
// Analog Clock Painter
// ═══════════════════════════════════════════════════════════════════════

/// Custom painter that draws an analog clock face with a hand-drawn
/// aesthetic — thick rim, hour numbers, tick marks, and distinct
/// hour/minute hands.
class _AnalogClockPainter extends CustomPainter {
  _AnalogClockPainter({
    required this.hour,
    required this.minute,
    required this.faceColor,
    required this.rimColor,
    required this.tickColor,
    required this.numberColor,
    required this.hourHandColor,
    required this.minuteHandColor,
    required this.centerDotColor,
  });

  final int hour;
  final int minute;
  final Color faceColor;
  final Color rimColor;
  final Color tickColor;
  final Color numberColor;
  final Color hourHandColor;
  final Color minuteHandColor;
  final Color centerDotColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // ── Face ──────────────────────────────────────────────────────────
    final facePaint = Paint()..color = faceColor;
    canvas.drawCircle(center, radius - 2, facePaint);

    // ── Rim ───────────────────────────────────────────────────────────
    final rimPaint = Paint()
      ..color = rimColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;
    canvas.drawCircle(center, radius - 2, rimPaint);

    // ── Tick marks ────────────────────────────────────────────────────
    for (int i = 0; i < 60; i++) {
      final angle = (i * 6 - 90) * math.pi / 180;
      final isHour = i % 5 == 0;
      final outerR = radius - 6;
      final innerR = isHour ? radius - 18 : radius - 12;

      final outer = Offset(
        center.dx + outerR * math.cos(angle),
        center.dy + outerR * math.sin(angle),
      );
      final inner = Offset(
        center.dx + innerR * math.cos(angle),
        center.dy + innerR * math.sin(angle),
      );

      final tickPaint = Paint()
        ..color = tickColor
        ..strokeWidth = isHour ? 2.5 : 1.0
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(inner, outer, tickPaint);
    }

    // ── Numbers 1–12 ─────────────────────────────────────────────────
    for (int i = 1; i <= 12; i++) {
      final angle = (i * 30 - 90) * math.pi / 180;
      final numberRadius = radius - 30;
      final pos = Offset(
        center.dx + numberRadius * math.cos(angle),
        center.dy + numberRadius * math.sin(angle),
      );

      final textPainter = TextPainter(
        text: TextSpan(
          text: '$i',
          style: TextStyle(
            fontFamily: 'JetBrains Mono',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: numberColor,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(
          pos.dx - textPainter.width / 2,
          pos.dy - textPainter.height / 2,
        ),
      );
    }

    // ── Hour hand ────────────────────────────────────────────────────
    final hourAngle =
        ((hour % 12) * 30 + minute * 0.5 - 90) * math.pi / 180;
    final hourLength = radius * 0.48;
    final hourEnd = Offset(
      center.dx + hourLength * math.cos(hourAngle),
      center.dy + hourLength * math.sin(hourAngle),
    );
    final hourPaint = Paint()
      ..color = hourHandColor
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center, hourEnd, hourPaint);

    // ── Minute hand ──────────────────────────────────────────────────
    final minuteAngle = (minute * 6 - 90) * math.pi / 180;
    final minuteLength = radius * 0.68;
    final minuteEnd = Offset(
      center.dx + minuteLength * math.cos(minuteAngle),
      center.dy + minuteLength * math.sin(minuteAngle),
    );
    final minutePaint = Paint()
      ..color = minuteHandColor
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center, minuteEnd, minutePaint);

    // ── Center dot ───────────────────────────────────────────────────
    final dotPaint = Paint()..color = centerDotColor;
    canvas.drawCircle(center, 5, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _AnalogClockPainter oldDelegate) =>
      oldDelegate.hour != hour || oldDelegate.minute != minute;
}
