import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';

/// Line chart for accuracy trend per domain.
///
/// Shows raw data points and a 7-session rolling average overlay.
/// Domain selector chips above the chart allow switching domains.
class AccuracyLineChartWidget extends StatefulWidget {
  const AccuracyLineChartWidget({
    super.key,
    required this.trends,
  });

  /// Map of domain code → list of accuracy values (0–100, oldest first).
  final Map<String, List<double>> trends;

  @override
  State<AccuracyLineChartWidget> createState() =>
      _AccuracyLineChartWidgetState();
}

class _AccuracyLineChartWidgetState extends State<AccuracyLineChartWidget> {
  String? _selectedDomain;

  static const _domainLabels = {
    'overall': 'Overall',
    'language': 'Language',
    'memory': 'Memory',
    'attention': 'Attention',
    'speech': 'Speech',
    'reading_writing': 'R&W',
    'math': 'Math',
  };

  @override
  void initState() {
    super.initState();
    if (widget.trends.isNotEmpty) {
      _selectedDomain = widget.trends.keys.first;
    }
  }

  @override
  void didUpdateWidget(covariant AccuracyLineChartWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_selectedDomain != null &&
        !widget.trends.containsKey(_selectedDomain)) {
      _selectedDomain =
          widget.trends.isNotEmpty ? widget.trends.keys.first : null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.trends.isEmpty) {
      return _emptyState();
    }

    final data = _selectedDomain != null
        ? widget.trends[_selectedDomain] ?? []
        : <double>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.progressAccuracyTrend,
          style: AppTextStyles.titleLg.copyWith(color: AppColors.ink),
        ),
        const SizedBox(height: AppDimens.d12),

        // Domain selector chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: widget.trends.keys.map((domain) {
              final isSelected = domain == _selectedDomain;
              return Padding(
                padding: const EdgeInsets.only(right: AppDimens.d8),
                child: ChoiceChip(
                  label: Text(
                    _domainLabels[domain] ?? domain,
                    style: AppTextStyles.caption.copyWith(
                      color: isSelected
                          ? AppColors.onPrimary
                          : AppColors.body,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.surfaceCard,
                  side: BorderSide.none,
                  onSelected: (_) {
                    setState(() => _selectedDomain = domain);
                  },
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: AppDimens.d12),

        if (data.isEmpty)
          _emptyState()
        else
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: (data.length > 1 ? (data.length - 1).toDouble() : 1.0),
                minY: 0,
                maxY: 100,
                clipData: const FlClipData.all(),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => AppColors.surfaceDark,
                    tooltipRoundedRadius: AppDimens.radiusSm,
                    getTooltipItems: (spots) {
                      return spots.map((spot) {
                        return LineTooltipItem(
                          '${spot.y.toStringAsFixed(0)}%',
                          AppTextStyles.caption.copyWith(
                              color: AppColors.onDark),
                        );
                      }).toList();
                    },
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  horizontalInterval: 25,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppColors.hairlineSoft,
                    strokeWidth: 0.5,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: max(1, (data.length / 5).ceilToDouble()),
                      reservedSize: 24,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt() + 1}',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.muted,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 25,
                      reservedSize: 32,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}%',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.muted,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                lineBarsData: [
                  // Raw data
                  LineChartBarData(
                    spots: List.generate(
                      data.length,
                      (i) => FlSpot(i.toDouble(), data[i]),
                    ),
                    isCurved: true,
                    curveSmoothness: 0.3,
                    color: AppColors.primary.withValues(alpha: 0.4),
                    barWidth: 1.5,
                    dotData: FlDotData(
                      show: data.length <= 15,
                      getDotPainter: (spot, _, __, ___) =>
                          FlDotCirclePainter(
                        radius: 3,
                        color: AppColors.primary.withValues(alpha: 0.5),
                        strokeColor: AppColors.primary,
                        strokeWidth: 1,
                      ),
                    ),
                    belowBarData: BarAreaData(show: false),
                  ),
                  // 7-session rolling average
                  if (data.length >= 3)
                    LineChartBarData(
                      spots: _rollingAverage(data, 7),
                      isCurved: true,
                      curveSmoothness: 0.35,
                      color: AppColors.primary,
                      barWidth: 2.5,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.primary.withValues(alpha: 0.15),
                            AppColors.primary.withValues(alpha: 0.02),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

        // Accessible text description
        Semantics(
          label: _accessibilityText(data),
          child: const SizedBox.shrink(),
        ),
      ],
    );
  }

  List<FlSpot> _rollingAverage(List<double> data, int window) {
    final spots = <FlSpot>[];
    for (int i = 0; i < data.length; i++) {
      final start = max(0, i - window + 1);
      final slice = data.sublist(start, i + 1);
      final avg = slice.reduce((a, b) => a + b) / slice.length;
      spots.add(FlSpot(i.toDouble(), avg));
    }
    return spots;
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.d32),
        child: Text(
          AppStrings.progressNoData,
          style: AppTextStyles.bodyMd.copyWith(color: AppColors.muted),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  String _accessibilityText(List<double> data) {
    if (data.isEmpty) return 'No accuracy data available yet.';
    final latest = data.last.toStringAsFixed(0);
    final domain = _domainLabels[_selectedDomain] ?? _selectedDomain ?? '';
    return '$domain accuracy trend. Latest session: $latest%. '
        'Total data points: ${data.length}.';
  }
}
