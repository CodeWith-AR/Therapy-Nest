import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/services/notification_service.dart';
import '../viewmodels/accessibility_view_model.dart';

/// Notification settings page — daily reminder, milestone,
/// weekly summary, and inactivity toggles.
///
/// Wires each toggle to both:
/// 1. [AccessibilityViewModel] — persists the user preference
/// 2. [NotificationService] — actually schedules/cancels notifications
class NotificationSettingsPage extends StatelessWidget {
  const NotificationSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AccessibilityViewModel>();
    final notif = vm.notifications;

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.notifTitle)),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.d16,
          vertical: AppDimens.d16,
        ),
        children: [
          // ── Daily Reminder ────────────────────────────────────────
          _NotifToggleCard(
            icon: Icons.alarm_rounded,
            title: AppStrings.notifDailyReminder,
            subtitle: AppStrings.notifDailyReminderDesc,
            value: notif.dailyReminder,
            onChanged: (v) {
              vm.setDailyReminder(v);
              final notifService = context.read<NotificationService>();
              if (v) {
                notifService.scheduleDailyReminder(
                  notif.dailyReminderTime.hour,
                  notif.dailyReminderTime.minute,
                );
              } else {
                notifService.cancelDailyReminder();
              }
            },
          ),
          const SizedBox(height: AppDimens.d12),

          // ── Reminder Time (only shown when daily reminder is on) ──
          if (notif.dailyReminder) ...[
            _TimePickerTile(
              title: AppStrings.notifReminderTime,
              time: notif.dailyReminderTime,
              onTap: () => _pickTime(context, vm),
            ),
            const SizedBox(height: AppDimens.d12),
          ],

          // ── Milestone Notifications ──────────────────────────────
          _NotifToggleCard(
            icon: Icons.emoji_events_rounded,
            title: AppStrings.notifMilestone,
            subtitle: AppStrings.notifMilestoneDesc,
            value: notif.milestoneNotifications,
            onChanged: (v) => vm.setMilestoneNotifications(v),
          ),
          const SizedBox(height: AppDimens.d12),

          // ── Weekly Summary ───────────────────────────────────────
          _NotifToggleCard(
            icon: Icons.summarize_rounded,
            title: AppStrings.notifWeeklySummary,
            subtitle: AppStrings.notifWeeklySummaryDesc,
            value: notif.weeklySummary,
            onChanged: (v) {
              vm.setWeeklySummary(v);
              final notifService = context.read<NotificationService>();
              if (v) {
                notifService.scheduleWeeklySummary();
              } else {
                notifService.cancelWeeklySummary();
              }
            },
          ),
          const SizedBox(height: AppDimens.d12),

          // ── Inactivity Reminder ──────────────────────────────────
          _NotifToggleCard(
            icon: Icons.notifications_paused_rounded,
            title: AppStrings.notifInactivity,
            subtitle: AppStrings.notifInactivityDesc,
            value: notif.inactivityReminder,
            onChanged: (v) {
              vm.setInactivityReminder(v);
              final notifService = context.read<NotificationService>();
              if (v) {
                notifService.scheduleInactivityReminder();
              } else {
                notifService.cancelInactivityReminder();
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _pickTime(
      BuildContext context, AccessibilityViewModel vm) async {
    final notifService = context.read<NotificationService>();
    final picked = await showTimePicker(
      context: context,
      initialTime: vm.notifications.dailyReminderTime,
      builder: (ctx, child) {
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: Theme.of(ctx).colorScheme.copyWith(
                  primary: AppColors.primary,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      vm.setDailyReminderTime(picked);
      // Reschedule with the new time
      if (vm.notifications.dailyReminder) {
        notifService.scheduleDailyReminder(picked.hour, picked.minute);
      }
    }
  }
}

// ── Notification Toggle Card ───────────────────────────────────────────

class _NotifToggleCard extends StatelessWidget {
  const _NotifToggleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.d16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        border: Border.all(color: AppColors.hairlineSoft),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accentAmber, size: AppDimens.iconMd),
          const SizedBox(width: AppDimens.d12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.titleSm.copyWith(color: AppColors.ink),
                ),
                const SizedBox(height: AppDimens.d4),
                Text(
                  subtitle,
                  style:
                      AppTextStyles.bodySm.copyWith(color: AppColors.muted),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimens.d12),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

// ── Time Picker Tile ───────────────────────────────────────────────────

class _TimePickerTile extends StatelessWidget {
  const _TimePickerTile({
    required this.title,
    required this.time,
    required this.onTap,
  });

  final String title;
  final TimeOfDay time;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final formatted = time.format(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.radiusLg),
      child: Container(
        padding: const EdgeInsets.all(AppDimens.d16),
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          border: Border.all(color: AppColors.hairlineSoft),
        ),
        child: Row(
          children: [
            Icon(Icons.schedule_rounded,
                color: AppColors.primary, size: AppDimens.iconMd),
            const SizedBox(width: AppDimens.d12),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.titleSm.copyWith(color: AppColors.ink),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.d12,
                vertical: AppDimens.d8,
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(AppDimens.radiusMd),
              ),
              child: Text(
                formatted,
                style: AppTextStyles.titleSm.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
