import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../viewmodels/progress_view_model.dart';

/// Per-domain deep dive page (/progress/:domainId).
///
/// Shows:
/// - Domain ability history line chart
/// - Item type accuracy breakdown (bar chart per exercise type)
/// - Encouragement text (never negative framing)
/// - Empty state: "Complete your first session to see your progress!"
class DomainDetailPage extends StatefulWidget {
  const DomainDetailPage({
    super.key,
    required this.domainCode,
  });

  final String domainCode;

  @override
  State<DomainDetailPage> createState() => _DomainDetailPageState();
}

class _DomainDetailPageState extends State<DomainDetailPage> {
  static const _domainLabels = {
    'language': 'Language',
    'memory': 'Memory',
    'attention': 'Attention',
    'speech': 'Speech',
    'reading_writing': 'Reading & Writing',
    'math': 'Math',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProgressViewModel>().loadDomainDetail(widget.domainCode);
    });
  }

  void _handleBack() {
    debugPrint('[DomainDetailPage] _handleBack: canPop=${Navigator.of(context).canPop()}');
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      context.go(AppRoutes.progress);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProgressViewModel>();
    final label = _domainLabels[widget.domainCode] ?? widget.domainCode;
    final ability = vm.domainAbility(widget.domainCode);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _handleBack();
      },
      child: Scaffold(
        backgroundColor: AppColors.canvas,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: AppColors.ink),
            onPressed: _handleBack,
            tooltip: 'Back to Progress',
          ),
          title: Text(
            label,
            style: AppTextStyles.appBarTitle.copyWith(color: AppColors.ink),
          ),
          backgroundColor: AppColors.canvas,
          elevation: 0,
          iconTheme: IconThemeData(color: AppColors.ink),
        ),
      body: vm.isLoading && ability == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(AppDimens.d16),
              children: [
                // Empty state only when genuinely no sessions or data exist
                if (!((ability != null && ability.sessionCount > 0) ||
                    vm.domainAccuracyHistory.isNotEmpty ||
                    vm.exerciseTypeAccuracy.isNotEmpty ||
                    vm.itemsToReview.isNotEmpty)) ...[
                  const SizedBox(height: AppDimens.d32),
                  Center(
                    child: Column(
                      children: [
                        const Text(
                          '🌱',
                          style: TextStyle(fontSize: 64),
                        ),
                        const SizedBox(height: AppDimens.d16),
                        Text(
                          'Complete your first session\nto see your progress!',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.titleLg.copyWith(
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: AppDimens.d8),
                        Text(
                          'Your journey starts with one step. 🎯',
                          style: AppTextStyles.bodyMd.copyWith(
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimens.d32),
                ] else ...[
                  // Ability summary card
                  if (ability != null) ...[
                    _buildAbilitySummary(ability),
                    const SizedBox(height: AppDimens.d24),
                  ],

                  // Accuracy history line chart
                  _buildAccuracyHistory(vm),
                  const SizedBox(height: AppDimens.d24),

                  // Exercise type breakdown
                  _buildExerciseBreakdown(vm),
                  const SizedBox(height: AppDimens.d24),

                  // Items to review (2+ hints)
                  _buildItemsToReview(vm),
                  const SizedBox(height: AppDimens.d24),
                ],

                // Encouragement
                _buildEncouragement(ability),
                const SizedBox(height: AppDimens.d32),
              ],
            ),
      ),
    );
  }

  Widget _buildAbilitySummary(dynamic ability) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.d16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(color: AppColors.hairlineSoft),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statColumn(
                '${ability.abilityPercent.toStringAsFixed(0)}%',
                AppStrings.progressCurrentAbility,
                AppColors.primary,
              ),
              Container(width: 1, height: 40, color: AppColors.hairlineSoft),
              _statColumn(
                '${ability.initialAbilityPercent.toStringAsFixed(0)}%',
                AppStrings.progressInitialBaseline,
                AppColors.accentTeal,
              ),
              Container(width: 1, height: 40, color: AppColors.hairlineSoft),
              _statColumn(
                '${ability.sessionCount}',
                AppStrings.progressSessions,
                AppColors.accentPurple,
              ),
            ],
          ),
          const SizedBox(height: AppDimens.d12),
          // Ability bar
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimens.radiusFull),
            child: LinearProgressIndicator(
              value: ability.abilityPercent / 100,
              minHeight: 8,
              backgroundColor: AppColors.surfaceCard,
              valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primary),
            ),
          ),
          const SizedBox(height: AppDimens.d8),
          Text(
            ability.changeText,
            style: AppTextStyles.bodyMd.copyWith(color: AppColors.body),
          ),
        ],
      ),
    );
  }

  Widget _statColumn(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.displaySm.copyWith(
            color: color,
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppDimens.d4),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(color: AppColors.muted),
        ),
      ],
    );
  }

  Widget _buildAccuracyHistory(ProgressViewModel vm) {
    final data = vm.domainAccuracyHistory;

    return Container(
      padding: const EdgeInsets.all(AppDimens.d16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(color: AppColors.hairlineSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.domainDetailHistory,
            style: AppTextStyles.titleLg.copyWith(color: AppColors.ink),
          ),
          const SizedBox(height: AppDimens.d16),

          if (data.isEmpty)
            Padding(
              padding: const EdgeInsets.all(AppDimens.d24),
              child: Center(
                child: Text(
                  AppStrings.progressNoData,
                  style: AppTextStyles.bodyMd.copyWith(color: AppColors.muted),
                ),
              ),
            )
          else
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: 100,
                  minX: 0,
                  maxX: data.length > 1 ? (data.length - 1).toDouble() : 1.0,
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
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(
                        data.length,
                        (i) => FlSpot(i.toDouble(), data[i]),
                      ),
                      isCurved: true,
                      curveSmoothness: 0.3,
                      color: AppColors.primary,
                      barWidth: 2.5,
                      dotData: FlDotData(
                        show: data.length <= 15,
                        getDotPainter: (spot, _, __, ___) =>
                            FlDotCirclePainter(
                          radius: 3,
                          color: AppColors.surfaceWhite,
                          strokeColor: AppColors.primary,
                          strokeWidth: 2,
                        ),
                      ),
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
        ],
      ),
    );
  }

  Widget _buildExerciseBreakdown(ProgressViewModel vm) {
    final breakdown = vm.exerciseTypeAccuracy;

    if (breakdown.isEmpty) return const SizedBox.shrink();

    final entries = breakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(AppDimens.d16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(color: AppColors.hairlineSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.domainDetailAccuracyBreakdown,
            style: AppTextStyles.titleLg.copyWith(color: AppColors.ink),
          ),
          const SizedBox(height: AppDimens.d16),
          ...entries.map((entry) {
            final label = _formatExerciseType(entry.key);
            return Padding(
              padding: const EdgeInsets.only(bottom: AppDimens.d12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        label,
                        style: AppTextStyles.bodySm
                            .copyWith(color: AppColors.bodyStrong),
                      ),
                      Text(
                        '${entry.value.toStringAsFixed(0)}%',
                        style: AppTextStyles.bodySm.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimens.d4),
                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(AppDimens.radiusFull),
                    child: LinearProgressIndicator(
                      value: entry.value / 100,
                      minHeight: 6,
                      backgroundColor: AppColors.surfaceCard,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _barColor(entry.value),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildItemsToReview(ProgressViewModel vm) {
    final items = vm.itemsToReview;

    return Container(
      padding: const EdgeInsets.all(AppDimens.d16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(color: AppColors.hairlineSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline_rounded,
                size: AppDimens.iconMd,
                color: AppColors.accentAmber,
              ),
              const SizedBox(width: AppDimens.d8),
              Text(
                'Items to Review',
                style: AppTextStyles.titleLg.copyWith(color: AppColors.ink),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.d4),
          Text(
            'Items where 2 or more hints were needed during practice',
            style: AppTextStyles.caption.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: AppDimens.d16),

          if (items.isEmpty)
            Container(
              padding: const EdgeInsets.all(AppDimens.d16),
              decoration: BoxDecoration(
                color: AppColors.surfaceSoft,
                borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                border: Border.all(color: AppColors.hairlineSoft),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    size: AppDimens.iconLg,
                    color: AppColors.accentGreen,
                  ),
                  const SizedBox(width: AppDimens.d12),
                  Expanded(
                    child: Text(
                      'No items need review right now! You answered with minimal hints. Great job! 🌟',
                      style: AppTextStyles.bodySm.copyWith(
                        color: AppColors.bodyStrong,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppDimens.d12),
              itemBuilder: (context, i) {
                final item = items[i];
                return Container(
                  padding: const EdgeInsets.all(AppDimens.d12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSoft,
                    borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                    border: Border.all(color: AppColors.hairlineSoft),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimens.d8,
                              vertical: AppDimens.d4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius:
                                  BorderRadius.circular(AppDimens.radiusFull),
                            ),
                            child: Text(
                              item.subtypeLabel,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimens.d8,
                              vertical: AppDimens.d4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accentAmber
                                  .withValues(alpha: 0.15),
                              borderRadius:
                                  BorderRadius.circular(AppDimens.radiusFull),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.lightbulb_rounded,
                                  size: 13,
                                  color: AppColors.accentAmber,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  item.hintBadgeText,
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.accentAmber,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimens.d8),
                      Text(
                        item.prompt,
                        style: AppTextStyles.bodyMd.copyWith(
                          color: AppColors.ink,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (item.targetWord.isNotEmpty) ...[
                        const SizedBox(height: AppDimens.d4),
                        Text(
                          'Answer: ${item.targetWord}',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildEncouragement(dynamic ability) {
    String message;
    if (ability == null || ability.sessionCount == 0) {
      message = AppStrings.progressNoData;
    } else if (ability.theta > ability.initialTheta + 0.3) {
      message = AppStrings.domainDetailGreatProgress;
    } else {
      message = AppStrings.domainDetailKeepGoing;
    }

    return Container(
      padding: const EdgeInsets.all(AppDimens.d16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.accentGreen.withValues(alpha: 0.1),
            AppColors.accentGreen.withValues(alpha: 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(
          color: AppColors.accentGreen.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.emoji_emotions_rounded,
              size: AppDimens.iconLg, color: AppColors.accentGreen),
          const SizedBox(width: AppDimens.d12),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.bodyStrong,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatExerciseType(String type) {
    return type
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isNotEmpty
            ? '${w[0].toUpperCase()}${w.substring(1)}'
            : '')
        .join(' ');
  }

  Color _barColor(double accuracy) {
    if (accuracy >= 80) return AppColors.accentGreen;
    if (accuracy >= 60) return AppColors.primary;
    return AppColors.accentTeal;
  }
}
