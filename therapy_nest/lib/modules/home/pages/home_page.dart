import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../data/models/weekly_stats_model.dart';
import '../../auth/viewmodels/auth_view_model.dart';
import '../../progress/viewmodels/progress_view_model.dart';
import '../../progress/widgets/domain_ability_card.dart';
import '../../progress/widgets/session_history_card.dart';
import '../../progress/widgets/tip_of_day_card.dart';

/// Home dashboard — the primary landing screen after login.
///
/// Layout:
/// 1. Greeting: "Good morning, [Name]!" + date
/// 2. Streak card (🔥 7-day streak!)
/// 3. "Today's Goal" card with target domains + estimated time + Start button
/// 4. Domain summary: horizontal scroll of domain ability cards
/// 5. Recent activity: last 3 session summaries
/// 6. Tip of the day card
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProgressViewModel>().loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProgressViewModel>();
    final userName =
        context.read<AuthViewModel>().currentUser?.fullName ?? 'there';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: vm.isLoading && vm.weeklyStats == null
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
                  // 1. Greeting
                  _buildGreeting(userName),
                  const SizedBox(height: AppDimens.d20),

                  // 2. Unified Hero Card (Streak + 7-Day Tracker + Today's Goal + Start CTA)
                  _buildHeroCard(vm),
                  const SizedBox(height: AppDimens.d24),

                  // 3. Domain summary
                  _buildDomainSummary(vm),
                  const SizedBox(height: AppDimens.d24),

                  // 4. Recent activity
                  _buildRecentActivity(vm),
                  const SizedBox(height: AppDimens.d24),

                  // 5. Tip of the day
                  const TipOfDayCard(),
                  const SizedBox(height: AppDimens.d32),
                ],
              ),
            ),
    );
  }

  Widget _buildGreeting(String name) {
    final now = DateTime.now();
    final greeting = now.hour < 12
        ? AppStrings.homeGreetingMorning
        : now.hour < 17
        ? AppStrings.homeGreetingAfternoon
        : AppStrings.homeGreetingEvening;
    final dateStr = DateFormat('EEEE, MMMM d').format(now);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$greeting, $name!',
          style: AppTextStyles.displayMd.copyWith(
            color: AppColors.ink,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppDimens.d8),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: AppColors.surfaceSoft,
                borderRadius: BorderRadius.circular(AppDimens.radiusFull),
              ),
              child: Text(
                'Today',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.body,
                  fontWeight: FontWeight.w600,
                  fontSize: 11.5,
                ),
              ),
            ),
            const SizedBox(width: AppDimens.d8),
            Text(
              dateStr,
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.muted,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeroCard(ProgressViewModel vm) {
    final streak = vm.weeklyStats?.currentStreak ?? 0;
    final domains = vm.domainAbilities;
    final targetDomains = domains.length > 3 ? domains.sublist(0, 3) : domains;
    final displayLabels = targetDomains.isNotEmpty
        ? targetDomains.map((d) => d.domainLabel).toList()
        : ['Attention', 'Language', 'Math'];

    return Container(
      padding: const EdgeInsets.all(AppDimens.d20),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.hairlineSoft, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Streak Row
          Row(
            children: [
              Icon(
                Icons.local_fire_department_rounded,
                color: AppColors.primary,
                size: 32,
              ),
              const SizedBox(width: AppDimens.d12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '$streak-day streak!',
                          style: AppTextStyles.titleLg.copyWith(
                            color: AppColors.ink,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(width: AppDimens.d8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius:
                                BorderRadius.circular(AppDimens.radiusFull),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.25),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            'Day ${streak == 0 ? 1 : streak}',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.primaryDark,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      streak == 0
                          ? 'Every session counts, no matter how short'
                          : 'Great momentum! Keep up your daily therapy',
                      style: AppTextStyles.bodySm.copyWith(
                        color: AppColors.muted,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.d16),

          // Hairline divider
          Container(
            height: 1,
            color: AppColors.hairlineSoft,
          ),
          const SizedBox(height: AppDimens.d16),

          // 2. Weekly Day Tracker (M T W T F S S)
          _buildWeeklyDayTracker(vm.weeklyStats),
          const SizedBox(height: AppDimens.d24),

          // 3. Today's Goal Header
          Row(
            children: [
              Icon(
                Icons.flag_rounded,
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: AppDimens.d8),
              Text(
                AppStrings.homeTodaysGoal,
                style: AppTextStyles.titleLg.copyWith(
                  color: AppColors.ink,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.d12),

          // 4. Domain Chips
          Wrap(
            spacing: AppDimens.d8,
            runSpacing: AppDimens.d8,
            children: displayLabels.map((label) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.22),
                    width: 1,
                  ),
                ),
                child: Text(
                  label,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w600,
                    fontSize: 13.5,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppDimens.d16),

          // 5. Estimated Time Row
          Row(
            children: [
              Icon(
                Icons.access_time_rounded,
                size: 18,
                color: AppColors.muted,
              ),
              const SizedBox(width: 6),
              Text.rich(
                TextSpan(
                  text: 'Estimated time: ',
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.muted,
                    fontSize: 13,
                  ),
                  children: [
                    TextSpan(
                      text: '~15 min',
                      style: AppTextStyles.bodySm.copyWith(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.d20),

          // 6. Start Today's Session CTA
          AppButton(
            label: AppStrings.homeStartSession,
            icon: Icons.play_arrow_rounded,
            onPressed: () => context.push(AppRoutes.domainSelect),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyDayTracker(WeeklyStatsModel? weeklyStats) {
    final now = DateTime.now();
    // Monday of current week
    final monday = now.subtract(Duration(days: now.weekday - 1));
    const dayLetters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    final dailyActivity = weeklyStats?.dailyActivity ?? [];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        final dayDate = DateTime(monday.year, monday.month, monday.day)
            .add(Duration(days: i));
        final isToday = dayDate.year == now.year &&
            dayDate.month == now.month &&
            dayDate.day == now.day;

        // Check if user practiced on this day
        final activity = dailyActivity
            .where((a) =>
                a.date.year == dayDate.year &&
                a.date.month == dayDate.month &&
                a.date.day == dayDate.day)
            .firstOrNull;
        final bool isPracticed = (activity?.sessionCount ?? 0) > 0;

        return Column(
          children: [
            Text(
              dayLetters[i],
              style: AppTextStyles.caption.copyWith(
                color: isToday ? AppColors.primary : AppColors.muted,
                fontWeight: isToday ? FontWeight.bold : FontWeight.w600,
                fontSize: 12.5,
              ),
            ),
            const SizedBox(height: AppDimens.d8),
            if (isPracticed)
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.check_rounded,
                  size: 18,
                  color: AppColors.onPrimary,
                ),
              )
            else if (isToday)
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryLight,
                  border: Border.all(
                    color: AppColors.primary,
                    width: 2.0,
                  ),
                ),
                alignment: Alignment.center,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary,
                  ),
                ),
              )
            else
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surfaceSoft,
                ),
                child: CustomPaint(
                  painter: _DashedCirclePainter(
                    color: AppColors.hairline,
                    strokeWidth: 1.2,
                    dashCount: 12,
                  ),
                  child: Center(
                    child: Text(
                      '-',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.muted,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildDomainSummary(ProgressViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.homeDomainSummary,
          style: AppTextStyles.titleLg.copyWith(color: AppColors.ink),
        ),
        const SizedBox(height: AppDimens.d12),

        if (vm.domainAbilities.isEmpty)
          Text(
            AppStrings.homeNoSessionsYet,
            style: AppTextStyles.bodyMd.copyWith(color: AppColors.muted),
          )
        else
          SizedBox(
            height: 180,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: vm.domainAbilities.length,
              separatorBuilder: (_, __) => const SizedBox(width: AppDimens.d12),
              itemBuilder: (context, i) {
                final ability = vm.domainAbilities[i];
                return DomainAbilityCard(
                  ability: ability,
                  onTap: () => context.go('/progress/${ability.domainCode}'),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildRecentActivity(ProgressViewModel vm) {
    final sessions = vm.recentSessions.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.homeRecentActivity,
          style: AppTextStyles.titleLg.copyWith(color: AppColors.ink),
        ),
        const SizedBox(height: AppDimens.d12),

        if (sessions.isEmpty)
          Text(
            AppStrings.homeNoSessionsYet,
            style: AppTextStyles.bodyMd.copyWith(color: AppColors.muted),
          )
        else
          ...sessions.map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: AppDimens.d8),
              child: GestureDetector(
                onTap: () => context.go('/progress'),
                child: SessionHistoryCard(session: s),
              ),
            ),
          ),
      ],
    );
  }
}

/// Paints a dashed circular outline with specified dash count and stroke width.
class _DashedCirclePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final int dashCount;

  _DashedCirclePainter({
    required this.color,
    this.strokeWidth = 1.2,
    this.dashCount = 12,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final sweepAngle = (2 * math.pi) / (dashCount * 2);

    for (int i = 0; i < dashCount; i++) {
      final startAngle = i * (2 * sweepAngle);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DashedCirclePainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.dashCount != dashCount;
}
