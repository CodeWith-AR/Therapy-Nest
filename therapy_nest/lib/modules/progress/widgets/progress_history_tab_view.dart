import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/weekly_stats_model.dart';
import '../../../data/repositories/progress_repository.dart';
import 'accuracy_line_chart_widget.dart';

/// Progress History Tab View matching the mockup progress history screen perfectly.
/// Displays a weekly snapshot banner, horizontal domain filter chips, a list/chart view toggle,
/// monthly grouped session items with accuracy borders, and custom sparklines.
class ProgressHistoryTabView extends StatefulWidget {
  const ProgressHistoryTabView({
    super.key,
    required this.sessions,
    required this.weeklyStats,
    required this.accuracyTrends,
    required this.isLoadingMore,
    required this.hasMoreSessions,
    required this.onLoadMore,
  });

  final List<SessionHistoryModel> sessions;
  final WeeklyStatsModel? weeklyStats;
  final Map<String, List<double>> accuracyTrends;
  final bool isLoadingMore;
  final bool hasMoreSessions;
  final VoidCallback onLoadMore;

  @override
  State<ProgressHistoryTabView> createState() => _ProgressHistoryTabViewState();
}

class _ProgressHistoryTabViewState extends State<ProgressHistoryTabView> {
  String _selectedDomainFilter = 'ALL';
  bool _isListView = true;

  final List<String> _filters = const [
    'ALL',
    'LANGUAGE',
    'READING & WRITING',
    'MEMORY',
    'ATTENTION',
    'SPEECH',
    'MATH',
  ];

  @override
  Widget build(BuildContext context) {
    // 1. Filter sessions
    final filteredSessions = widget.sessions.where((session) {
      if (_selectedDomainFilter == 'ALL') return true;
      final code = _mapFilterToCode(_selectedDomainFilter);
      return session.domains.any((d) => d.toLowerCase() == code);
    }).toList();

    // 2. Group sessions by month (e.g. "August", "July")
    final Map<String, List<SessionHistoryModel>> groupedSessions = {};
    for (final s in filteredSessions) {
      final monthName = DateFormat('MMMM').format(s.date);
      if (!groupedSessions.containsKey(monthName)) {
        groupedSessions[monthName] = [];
      }
      groupedSessions[monthName]!.add(s);
    }

    // Keep chronological ordering of groups based on session dates
    final orderedMonths = <String>[];
    for (final s in filteredSessions) {
      final monthName = DateFormat('MMMM').format(s.date);
      if (!orderedMonths.contains(monthName)) {
        orderedMonths.add(monthName);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Summary Snapshot Banner ────────────────────────────────────
        if (widget.weeklyStats != null) ...[
          Container(
            padding: const EdgeInsets.all(AppDimens.d16),
            decoration: BoxDecoration(
              color: AppColors.surfaceSoft,
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
              border: Border.all(color: AppColors.hairline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Weekly Snapshot',
                  style: AppTextStyles.titleLg.copyWith(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "You're making steady progress.",
                  style: AppTextStyles.bodyMd.copyWith(color: AppColors.muted),
                ),
                const SizedBox(height: AppDimens.d16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _bannerStat(
                      '${widget.weeklyStats!.totalSessions}',
                      'Sessions',
                      AppColors.primary,
                    ),
                    _bannerDivider(),
                    _bannerStat(
                      '${widget.weeklyStats!.totalMinutes}',
                      'Minutes',
                      AppColors.ink,
                    ),
                    _bannerDivider(),
                    _bannerStat(
                      '${widget.weeklyStats!.averageAccuracy.toStringAsFixed(0)}%',
                      'Avg Acc',
                      AppColors.success,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.d16),
        ],

        // ── Controls Row (Domain Filter Chips + List/Chart Toggle) ─────
        Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _filters.map((filter) {
                    final isSelected = _selectedDomainFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: AppDimens.d8),
                      child: ChoiceChip(
                        label: Text(
                          filter,
                          style: AppTextStyles.caption.copyWith(
                            color: isSelected ? AppColors.onPrimary : AppColors.ink,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        backgroundColor: AppColors.surfaceCard,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                          side: BorderSide(
                            color: isSelected ? Colors.transparent : AppColors.hairline,
                          ),
                        ),
                        showCheckmark: false,
                        onSelected: (val) {
                          if (val) {
                            setState(() => _selectedDomainFilter = filter);
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(width: AppDimens.d8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceSoft,
                borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                border: Border.all(color: AppColors.hairlineSoft),
              ),
              padding: const EdgeInsets.all(AppDimens.d4),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _isListView = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: _isListView ? AppColors.surfaceWhite : Colors.transparent,
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: _isListView
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 3,
                                  offset: const Offset(0, 1),
                                )
                              ]
                            : null,
                      ),
                      child: Icon(
                        Icons.view_list_rounded,
                        size: 20,
                        color: _isListView ? AppColors.ink : AppColors.muted,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _isListView = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: !_isListView ? AppColors.surfaceWhite : Colors.transparent,
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: !_isListView
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 3,
                                  offset: const Offset(0, 1),
                                )
                              ]
                            : null,
                      ),
                      child: Icon(
                        Icons.bar_chart_rounded,
                        size: 20,
                        color: !_isListView ? AppColors.ink : AppColors.muted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimens.d16),

        // ── Session List vs Chart View Display ──────────────────────────
        if (_isListView) ...[
          if (filteredSessions.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Text(
                  AppStrings.progressNoData,
                  style: AppTextStyles.bodyMd.copyWith(color: AppColors.muted),
                ),
              ),
            )
          else
            ...orderedMonths.map((month) {
              final monthSessions = groupedSessions[month] ?? [];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Month divider Header
                  Padding(
                    padding: const EdgeInsets.only(top: AppDimens.d12, bottom: AppDimens.d8),
                    child: Row(
                      children: [
                        Text(
                          month.toUpperCase(),
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.muted,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            height: 1,
                            color: AppColors.hairline,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...monthSessions.map((session) => _buildSessionCard(session)),
                ],
              );
            }),

          // Pagination button
          if (widget.hasMoreSessions && _isListView && filteredSessions.isNotEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: widget.isLoadingMore
                    ? const CircularProgressIndicator(strokeWidth: 2)
                    : TextButton(
                        onPressed: widget.onLoadMore,
                        child: Text(
                          'Load more',
                          style: AppTextStyles.buttonSm.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
              ),
            ),
        ] else ...[
          // Chart view
          _buildChartView(),
        ],
      ],
    );
  }

  Widget _bannerStat(String value, String label, Color valueColor) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.displayLg.copyWith(
            color: valueColor,
            fontFamily: 'Georgia',
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label.toUpperCase(),
          style: AppTextStyles.caption.copyWith(
            color: AppColors.muted,
            fontWeight: FontWeight.w600,
            fontSize: 10,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _bannerDivider() {
    return Container(
      width: 1,
      height: 48,
      color: AppColors.hairline,
    );
  }

  Widget _buildSessionCard(SessionHistoryModel session) {
    final int accuracy = session.accuracy.clamp(0.0, 100.0).round();
    final Color accuracyColor = accuracy >= 80
        ? AppColors.success
        : accuracy >= 70
            ? AppColors.warning
            : AppColors.error;

    final String timeOfDay = _getTimeOfDay(session.date);
    final String dateStr = DateFormat('EEEE, MMM dd').format(session.date);

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimens.d12),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(color: AppColors.hairlineSoft),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Left accent colored border line
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 4,
            child: Container(color: accuracyColor),
          ),
          Padding(
            padding: const EdgeInsets.all(AppDimens.d16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dateStr,
                          style: AppTextStyles.bodyLg.copyWith(
                            color: AppColors.ink,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: AppDimens.d4),
                        Row(
                          children: [
                            Icon(
                              Icons.schedule_rounded,
                              size: 15,
                              color: AppColors.mutedSoft,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${session.durationMs ~/ 60000} min',
                              style: AppTextStyles.bodySm.copyWith(
                                color: AppColors.muted,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(width: 4, height: 4, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.hairline)),
                            const SizedBox(width: 6),
                            Text(
                              timeOfDay,
                              style: AppTextStyles.bodySm.copyWith(
                                color: AppColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Text(
                      '$accuracy%',
                      style: AppTextStyles.displaySm.copyWith(
                        color: accuracyColor,
                        fontFamily: 'Georgia',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.d12),
                Container(
                  height: 1,
                  color: AppColors.hairline,
                ),
                const SizedBox(height: AppDimens.d8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Domain badges
                    Expanded(
                      child: Wrap(
                      spacing: AppDimens.d8,
                      runSpacing: 4,
                      children: session.domains.map((domain) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceSoft,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppColors.hairlineSoft),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getDomainIcon(domain),
                                size: 12,
                                color: AppColors.muted,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _getDomainName(domain),
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.body,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    ),
                    const SizedBox(width: AppDimens.d8),
                    // Sparkline
                    CustomPaint(
                      size: const Size(60, 24),
                      painter: SparklinePainter(
                        _generateSimulatedPoints(session.accuracy),
                        accuracyColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartView() {
    // 1. Gather all available trends (from repository and derived from sessions)
    final Map<String, List<double>> availableTrends =
        Map<String, List<double>>.from(widget.accuracyTrends);

    if (widget.sessions.isNotEmpty) {
      final chronological = widget.sessions.toList()
        ..sort((a, b) => a.date.compareTo(b.date));

      // Build overall trend across all completed sessions
      final overallAccuracies = chronological
          .map((s) => s.accuracy.clamp(0.0, 100.0))
          .toList();
      if (overallAccuracies.isNotEmpty) {
        availableTrends.putIfAbsent('overall', () => overallAccuracies);
      }

      // Populate per-domain trends if not already present
      for (final s in chronological) {
        for (final d in s.domains) {
          final code = d.toLowerCase();
          availableTrends
              .putIfAbsent(code, () => [])
              .add(s.accuracy.clamp(0.0, 100.0));
        }
      }
    }

    // 2. Filter trends based on selected chip
    Map<String, List<double>> filteredTrends = {};
    if (_selectedDomainFilter == 'ALL') {
      filteredTrends = availableTrends;
    } else {
      final code = _mapFilterToCode(_selectedDomainFilter).toLowerCase();
      if (availableTrends.containsKey(code)) {
        filteredTrends[code] = availableTrends[code]!;
      }
    }

    if (filteredTrends.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Text(
            'No trend data available for this selection.',
            style: AppTextStyles.bodyMd.copyWith(color: AppColors.muted),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppDimens.d16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(color: AppColors.hairlineSoft),
      ),
      child: AccuracyLineChartWidget(trends: filteredTrends),
    );
  }

  String _getTimeOfDay(DateTime date) {
    final hour = date.hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }

  IconData _getDomainIcon(String domainCode) {
    return switch (domainCode.toLowerCase()) {
      'memory' => Icons.psychology_rounded,
      'attention' => Icons.center_focus_strong_rounded,
      'speech' => Icons.record_voice_over_rounded,
      'language' => Icons.translate_rounded,
      'reading_writing' => Icons.menu_book_rounded,
      'math' => Icons.calculate_rounded,
      _ => Icons.stars_rounded,
    };
  }

  String _getDomainName(String domainCode) {
    return switch (domainCode.toLowerCase()) {
      'memory' => 'Memory',
      'attention' => 'Attention',
      'speech' => 'Speech',
      'language' => 'Language',
      'reading_writing' => 'Reading',
      'math' => 'Math',
      _ => domainCode,
    };
  }

  String _mapFilterToCode(String filter) {
    return switch (filter) {
      'LANGUAGE' => 'language',
      'READING & WRITING' => 'reading_writing',
      'MEMORY' => 'memory',
      'ATTENTION' => 'attention',
      'SPEECH' => 'speech',
      'MATH' => 'math',
      _ => 'all',
    };
  }

  List<double> _generateSimulatedPoints(double finalAccuracy) {
    return [
      finalAccuracy * 0.75,
      finalAccuracy * 0.85,
      finalAccuracy * 0.78,
      finalAccuracy * 0.92,
      finalAccuracy,
    ];
  }
}

// ── Custom Painter to draw sparkline on cards ───────────────────────────

class SparklinePainter extends CustomPainter {
  final List<double> data;
  final Color lineColor;

  SparklinePainter(this.data, this.lineColor);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    final double stepX = size.width / (data.length - 1);
    const double minVal = 0;
    const double maxVal = 100;
    const double valRange = maxVal - minVal;

    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      // Invert y because canvas y goes down
      final y = size.height - ((data[i] - minVal) / valRange * size.height);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
