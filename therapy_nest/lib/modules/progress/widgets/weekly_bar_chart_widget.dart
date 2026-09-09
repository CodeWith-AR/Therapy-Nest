import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../data/models/weekly_stats_model.dart';

/// Redesigned Weekly Bar Chart Widget matching your mockup weekly practice card.
/// Features a target dashed line, custom primary-colored bars for practice days,
/// and a summary card at the bottom showing sessions, minutes, and accuracy with insights.
class WeeklyBarChartWidget extends StatelessWidget {
  const WeeklyBarChartWidget({
    super.key,
    required this.weeklyStats,
    this.targetMinutes = 15,
  });

  final WeeklyStatsModel weeklyStats;
  final int targetMinutes;

  static const _dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final dailyActivity = weeklyStats.dailyActivity;
    if (dailyActivity.isEmpty) {
      return _emptyState();
    }

    final maxMinutes = dailyActivity.fold<int>(
        targetMinutes, (max, d) => d.minutesPracticed > max ? d.minutesPracticed : max);
    final maxY = (maxMinutes + 5).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Weekly Practice',
              style: AppTextStyles.titleLg.copyWith(
                color: AppColors.ink,
                fontWeight: FontWeight.w600,
              ),
            ),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_horiz_rounded, color: AppColors.muted),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimens.radiusMd),
              ),
              onSelected: (value) {
                switch (value) {
                  case 'details':
                    _showDetailsModal(context);
                    break;
                  case 'share':
                    AppToast.show(
                      context,
                      message: 'Share Progress is coming soon!',
                      type: AppToastType.info,
                    );
                    break;
                  case 'export':
                    AppToast.show(
                      context,
                      message: 'Export Summary is coming soon!',
                      type: AppToastType.info,
                    );
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'details',
                  child: Text('View Details'),
                ),
                const PopupMenuItem(
                  value: 'share',
                  child: Text('Share Progress'),
                ),
                const PopupMenuItem(
                  value: 'export',
                  child: Text('Export Summary'),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppDimens.d8),

        // Bar Chart
        SizedBox(
          height: 180,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxY,
              minY: 0,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => AppColors.surfaceDark,
                  tooltipRoundedRadius: AppDimens.radiusSm,
                  getTooltipItem: (group, groupIdx, rod, rodIdx) {
                    return BarTooltipItem(
                      '${rod.toY.toInt()} min',
                      AppTextStyles.caption.copyWith(color: AppColors.onDark),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), // Hide left axes ticks per mockup
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final idx = value.toInt();
                      if (idx < 0 || idx >= dailyActivity.length) {
                        return const SizedBox.shrink();
                      }
                      final weekday = dailyActivity[idx].date.weekday;
                      final isToday = dailyActivity[idx].date.day == DateTime.now().day &&
                          dailyActivity[idx].date.month == DateTime.now().month;

                      return Padding(
                        padding: const EdgeInsets.only(top: AppDimens.d8),
                        child: Text(
                          _dayLabels[weekday - 1],
                          style: AppTextStyles.label.copyWith(
                            color: isToday ? AppColors.primary : AppColors.muted,
                            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      );
                    },
                    reservedSize: 28,
                  ),
                ),
              ),
              gridData: const FlGridData(show: false), // Hide background grid lines per mockup
              borderData: FlBorderData(show: false),
              barGroups: List.generate(dailyActivity.length, (i) {
                final minutes = dailyActivity[i].minutesPracticed.toDouble();
                final hasPracticed = minutes > 0;
                final isSunday = dailyActivity[i].date.weekday == 7;

                return BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: minutes == 0 ? 2 : minutes, // Give a tiny visual base if 0
                      width: 22,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(4),
                      ),
                      color: hasPracticed
                          ? AppColors.primary
                          : (isSunday
                              ? AppColors.primary.withValues(alpha: 0.15)
                              : AppColors.surfaceSoft),
                    ),
                  ],
                );
              }),
              extraLinesData: ExtraLinesData(
                horizontalLines: [
                  HorizontalLine(
                    y: targetMinutes.toDouble(),
                    color: AppColors.muted.withValues(alpha: 0.3),
                    strokeWidth: 1.0,
                    dashArray: [4, 4],
                    label: HorizontalLineLabel(
                      show: true,
                      alignment: Alignment.topRight,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.muted,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                      labelResolver: (_) => 'Target',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: AppDimens.d16),

        // Summary Card
        Container(
          padding: const EdgeInsets.all(AppDimens.d12),
          decoration: BoxDecoration(
            color: AppColors.canvas,
            borderRadius: BorderRadius.circular(AppDimens.radiusSm),
            border: Border.all(color: AppColors.hairline),
          ),
          child: Row(
            children: [
              Icon(
                Icons.insights_rounded,
                color: AppColors.primary,
                size: AppDimens.iconLg,
              ),
              const SizedBox(width: AppDimens.d12),
              Container(
                width: 1,
                height: 32,
                color: AppColors.hairline,
              ),
              const SizedBox(width: AppDimens.d12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Last 7 Days',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.muted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${weeklyStats.totalSessions} sessions · ${weeklyStats.totalMinutes} min · ${weeklyStats.averageAccuracy.toStringAsFixed(0)}% accuracy',
                      style: AppTextStyles.bodyMd.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
          AppStrings.progressNoData,
          style: AppTextStyles.bodyMd.copyWith(color: AppColors.muted),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  void _showDetailsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppDimens.radiusLg),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(
          AppDimens.d20,
          AppDimens.d16,
          AppDimens.d20,
          AppDimens.d24,
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pull handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.hairline,
                    borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                  ),
                ),
              ),
              const SizedBox(height: AppDimens.d16),

              // Title Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Weekly Practice Details',
                        style: AppTextStyles.titleLg.copyWith(
                          color: AppColors.ink,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Daily session breakdown for this week',
                        style: AppTextStyles.bodySm.copyWith(
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(ctx).pop(),
                    color: AppColors.muted,
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.d16),

              // Weekly Summary banner
              Container(
                padding: const EdgeInsets.all(AppDimens.d12),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _summaryMetric(
                      '${weeklyStats.totalSessions}',
                      'Total Sessions',
                    ),
                    _summaryMetric(
                      '${weeklyStats.totalMinutes}m',
                      'Total Time',
                    ),
                    _summaryMetric(
                      '${weeklyStats.averageAccuracy.toStringAsFixed(0)}%',
                      'Avg Accuracy',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimens.d16),

              // Day-by-Day List
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(ctx).size.height * 0.45,
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: weeklyStats.dailyActivity.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppDimens.d8),
                  itemBuilder: (context, i) {
                    final day = weeklyStats.dailyActivity[i];
                    final dayName = DateFormat('EEEE, MMM d').format(day.date);
                    final hasPracticed = day.sessionCount > 0;

                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimens.d16,
                        vertical: AppDimens.d12,
                      ),
                      decoration: BoxDecoration(
                        color: hasPracticed
                            ? AppColors.surfaceCard
                            : AppColors.surfaceSoft,
                        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                        border: Border.all(
                          color: hasPracticed
                              ? AppColors.hairlineSoft
                              : AppColors.hairline,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: hasPracticed
                                  ? AppColors.primary.withValues(alpha: 0.12)
                                  : AppColors.surfaceWhite,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              hasPracticed
                                  ? Icons.check_circle_rounded
                                  : Icons.circle_outlined,
                              size: 20,
                              color: hasPracticed
                                  ? AppColors.primary
                                  : AppColors.mutedSoft,
                            ),
                          ),
                          const SizedBox(width: AppDimens.d12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  dayName,
                                  style: AppTextStyles.bodyMd.copyWith(
                                    color: AppColors.ink,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  hasPracticed
                                      ? '${day.sessionCount} session${day.sessionCount > 1 ? 's' : ''} · ${day.minutesPracticed} min'
                                      : 'Rest Day (0 sessions)',
                                  style: AppTextStyles.caption.copyWith(
                                    color: hasPracticed
                                        ? AppColors.body
                                        : AppColors.muted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (hasPracticed)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppDimens.d8,
                                vertical: AppDimens.d4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.success
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(
                                    AppDimens.radiusFull),
                              ),
                              child: Text(
                                '${day.averageAccuracy.toStringAsFixed(0)}%',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryMetric(String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: AppTextStyles.titleMd.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.muted,
          ),
        ),
      ],
    );
  }
}
