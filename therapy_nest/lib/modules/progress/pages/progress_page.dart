import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';
import '../viewmodels/progress_view_model.dart';
import '../widgets/achievements_tab_view.dart';
import '../widgets/milestone_timeline.dart';
import '../widgets/progress_history_tab_view.dart';
import '../widgets/radar_chart_widget.dart';
import '../widgets/weekly_bar_chart_widget.dart';

/// Progress Page refactored into a 4-tab StatefulWidget layout.
/// Features a centered title AppBar and horizontal scroll selector to jump between
/// Overview, Achievements, Recovery Milestones, and Progress History.
class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  int _activeTabIdx = 0;

  final List<String> _tabs = const [
    'Overview',
    'Achievements',
    'Milestones',
    'History',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<ProgressViewModel>();
      if (vm.weeklyStats == null) {
        vm.loadDashboard();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProgressViewModel>();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        debugPrint('[ProgressPage] back-button intercepted: switching to Home');
        context.go(AppRoutes.home);
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: vm.isLoading && vm.weeklyStats == null
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
              onRefresh: () => vm.loadDashboard(),
              color: AppColors.primary,
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.d16,
                  vertical: AppDimens.d16,
                ),
                children: [
                  // ── Top Horizontal Tab Scroll Bar ──────────────────────────
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: AppDimens.d20),
                      child: Row(
                        children: List.generate(_tabs.length, (idx) {
                          final label = _tabs[idx];
                          final isSelected = _activeTabIdx == idx;
                          return Padding(
                            padding: const EdgeInsets.only(right: AppDimens.d8),
                            child: GestureDetector(
                              onTap: () => setState(() => _activeTabIdx = idx),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.primary : AppColors.surfaceSoft,
                                  borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                                  border: Border.all(
                                    color: isSelected ? Colors.transparent : AppColors.hairline,
                                  ),
                                ),
                                child: Text(
                                  label,
                                  style: AppTextStyles.bodyMd.copyWith(
                                    color: isSelected ? AppColors.onPrimary : AppColors.muted,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),

                  // ── Selected Tab Content ───────────────────────────────────
                  _buildTabContent(vm),
                ],
              ),
            ),
          ),
      ),
    );
  }

  Widget _buildTabContent(ProgressViewModel vm) {
    switch (_activeTabIdx) {
      // ── Tab 0: Overview
      case 0:
        return Column(
          children: [
            // Cognitive Balance Radar Card
            _buildSection(
              child: RadarChartWidget(abilities: vm.domainAbilities),
            ),
            const SizedBox(height: AppDimens.d20),

            // Weekly Practice Bar Card
            if (vm.weeklyStats != null)
              _buildSection(
                child: WeeklyBarChartWidget(weeklyStats: vm.weeklyStats!),
              ),
            const SizedBox(height: AppDimens.d20),
          ],
        );

      // ── Tab 1: Achievements
      case 1:
        return AchievementsTabView(
          achievements: vm.recentAchievements,
          weeklyStats: vm.weeklyStats,
        );

      // ── Tab 2: Recovery Milestones
      case 2:
        return MilestoneTimeline(
          milestones: vm.milestones,
          currentThetas: {
            for (final a in vm.domainAbilities) a.domainCode: a.theta,
          },
        );

      // ── Tab 3: Progress History
      case 3:
        return ProgressHistoryTabView(
          sessions: vm.recentSessions,
          weeklyStats: vm.weeklyStats,
          accuracyTrends: vm.accuracyTrends,
          isLoadingMore: vm.isLoadingMore,
          hasMoreSessions: vm.hasMoreSessions,
          onLoadMore: () => vm.loadMoreSessions(),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildSection({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.d16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(color: AppColors.hairlineSoft),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}
