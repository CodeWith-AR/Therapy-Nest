import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/domain_ability_model.dart';

/// Redesigned Cognitive Balance Radar Chart Widget matching your mockup card.
/// Features a background grid hexagon, axes, custom current/baseline overlays,
/// and a top-right decorative ambient background bubble.
class RadarChartWidget extends StatelessWidget {
  const RadarChartWidget({
    super.key,
    required this.abilities,
  });

  final List<DomainAbilityModel> abilities;

  /// Fixed domains in radar order.
  static const _domainOrder = [
    'language',
    'memory',
    'attention',
    'speech',
    'reading_writing',
    'math',
  ];

  static const _domainLabels = [
    'Language',
    'Memory',
    'Attention',
    'Speech',
    'Reading',
    'Math',
  ];

  @override
  Widget build(BuildContext context) {
    if (abilities.isEmpty) {
      return _emptyState();
    }

    final Map<String, DomainAbilityModel> abilityMap = {
      for (final a in abilities) a.domainCode: a,
    };

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimens.radiusLg),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          // Top-right ambient blurred decoration bubble (constrained within bounds)
          Positioned(
            top: 0,
            right: 0,
            width: 120,
            height: 120,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title & Description
            Text(
              'Cognitive Balance',
              style: AppTextStyles.titleLg.copyWith(
                color: AppColors.ink,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Your progress across key cognitive domains.',
              style: AppTextStyles.bodySm.copyWith(
                color: AppColors.muted,
              ),
            ),
            const SizedBox(height: AppDimens.d16),

            // Radar Chart Canvas with solid current polygon & dotted baseline overlay
            SizedBox(
              height: 250,
              child: Stack(
                children: [
                  RadarChart(
                    RadarChartData(
                      radarTouchData: RadarTouchData(enabled: false),
                      dataSets: [
                        // Current Ability Overlay (Solid Filled Primary/Coral)
                        RadarDataSet(
                          fillColor: AppColors.primary.withValues(alpha: 0.35),
                          borderColor: AppColors.primary,
                          borderWidth: 2.5,
                          entryRadius: 3.5,
                          dataEntries: _domainOrder.map((code) {
                            final a = abilityMap[code];
                            return RadarEntry(value: a?.abilityPercent ?? 0);
                          }).toList(),
                        ),
                      ],
                      radarBackgroundColor: Colors.transparent,
                      borderData: FlBorderData(show: false),
                      radarBorderData: BorderSide(
                        color: AppColors.hairline,
                        width: 1,
                      ),
                      titlePositionPercentageOffset: 0.18,
                      titleTextStyle: AppTextStyles.caption.copyWith(
                        color: AppColors.body,
                        fontWeight: FontWeight.w600,
                      ),
                      getTitle: (index, angle) {
                        return RadarChartTitle(
                          text: _domainLabels[index],
                        );
                      },
                      tickCount: 3,
                      ticksTextStyle: const TextStyle(fontSize: 0),
                      tickBorderData: BorderSide(
                        color: AppColors.hairlineSoft,
                        width: 0.5,
                      ),
                      gridBorderData: BorderSide(
                        color: AppColors.hairlineSoft,
                        width: 0.5,
                      ),
                    ),
                  ),
                  // Dotted Baseline Ability Overlay (Starting baseline θ_initial)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: CustomPaint(
                        painter: _DottedRadarPolygonPainter(
                          values: _domainOrder.map((code) {
                            final a = abilityMap[code];
                            return a?.initialAbilityPercent ?? 0;
                          }).toList(),
                          color: AppColors.muted.withValues(alpha: 0.85),
                          titlePositionPercentageOffset: 0.18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimens.d12),

            // Legend indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _legendDot(
                  AppColors.muted.withValues(alpha: 0.5),
                  'Baseline',
                  isDashed: true,
                ),
                const SizedBox(width: AppDimens.d24),
                _legendDot(
                  AppColors.primary,
                  'Current',
                  isDashed: false,
                ),
              ],
            ),
          ],
        ),

        // Accessible description
        Semantics(
          label: _accessibilityDescription(abilityMap),
          child: const SizedBox.shrink(),
        ),
      ],
      ),
    );
  }

  Widget _legendDot(Color color, String label, {required bool isDashed}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: isDashed ? Colors.transparent : color,
            border: Border.all(
              color: color,
              width: 2,
              style: BorderStyle.solid,
            ),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: isDashed
              ? Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                )
              : null,
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.body,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.d32),
        child: Text(
          'No progress data available yet.',
          style: AppTextStyles.bodyMd.copyWith(color: AppColors.muted),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  String _accessibilityDescription(Map<String, DomainAbilityModel> map) {
    final buffer = StringBuffer('Cognitive balance overview: ');
    for (int i = 0; i < _domainOrder.length; i++) {
      final a = map[_domainOrder[i]];
      buffer.write(
          '${_domainLabels[i]}: ${a?.abilityPercent.toStringAsFixed(0) ?? 0}%. ');
    }
    return buffer.toString();
  }
}

/// Custom painter that renders a dotted outline polygon with vertices dots
/// representing the patient's baseline ability on the radar chart.
class _DottedRadarPolygonPainter extends CustomPainter {
  const _DottedRadarPolygonPainter({
    required this.values,
    required this.color,
    this.titlePositionPercentageOffset = 0.18,
  });

  final List<double> values;
  final Color color;
  final double titlePositionPercentageOffset;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 6) return;

    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius =
        (math.min(size.width, size.height) / 2) * (1.0 - titlePositionPercentageOffset);

    final points = <Offset>[];
    for (int i = 0; i < 6; i++) {
      final angle = (2 * math.pi / 6) * i - (math.pi / 2);
      final pct = (values[i].clamp(0.0, 100.0) / 100.0);
      final r = pct * maxRadius;
      points.add(Offset(
        center.dx + r * math.cos(angle),
        center.dy + r * math.sin(angle),
      ));
    }

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < points.length; i++) {
      final p1 = points[i];
      final p2 = points[(i + 1) % points.length];
      _drawDashedLine(canvas, p1, p2, linePaint);
    }

    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (final p in points) {
      canvas.drawCircle(p, 3.0, dotPaint);
    }
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    final distance = (p2 - p1).distance;
    if (distance <= 0) return;
    final unit = (p2 - p1) / distance;
    const dash = 4.0;
    const gap = 3.5;
    double walked = 0.0;
    while (walked < distance) {
      final start = p1 + unit * walked;
      final len = math.min(dash, distance - walked);
      final end = start + unit * len;
      canvas.drawLine(start, end, paint);
      walked += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _DottedRadarPolygonPainter oldDelegate) {
    if (oldDelegate.color != color ||
        oldDelegate.values.length != values.length) {
      return true;
    }
    for (int i = 0; i < values.length; i++) {
      if (oldDelegate.values[i] != values[i]) return true;
    }
    return false;
  }
}
