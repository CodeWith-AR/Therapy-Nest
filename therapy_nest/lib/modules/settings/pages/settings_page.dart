import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../modules/auth/viewmodels/auth_view_model.dart';
import '../../../app/routes/app_routes.dart';
import '../viewmodels/accessibility_view_model.dart';

/// Redesigned Settings screen matching mockup perfectly.
/// Contains profile header, accessibility settings card, notification
/// settings card, and about settings card inline.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  static const String _privacyPolicyUrl = 'https://therapy-nest-web.vercel.app/privacy';
  static const String _termsUrl = 'https://therapy-nest-web.vercel.app/terms';

  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AuthViewModel>();
    final currentUser = authVm.currentUser;
    final user = currentUser?.fullName;
    final email = currentUser?.email;

    final vm = context.watch<AccessibilityViewModel>();
    final a11y = vm.accessibility;
    final notif = vm.notifications;

    final isHc = a11y.highContrastMode;

    return Scaffold(
      backgroundColor: isHc ? AppColors.hcBackground : AppColors.canvas,
      appBar: AppBar(
        backgroundColor: isHc ? AppColors.hcBackground : AppColors.canvas,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: isHc ? AppColors.hcText : AppColors.ink),
          onPressed: () {
            // Standard back navigation if popped, otherwise fallback to home
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go(AppRoutes.home);
            }
          },
        ),
        title: Text(
          AppStrings.settingsTitle,
          style: AppTextStyles.appBarTitle.copyWith(color: isHc ? AppColors.hcText : AppColors.ink),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: isHc ? AppColors.hcBorder : AppColors.hairline,
            height: isHc ? 2.0 : 1.0,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.d16,
          vertical: AppDimens.d20,
        ),
        children: [
          // ── Profile Section ───────────────────────────────────────
          _ProfileHeaderCard(
            userId: currentUser?.id,
            name: user ?? 'User',
            email: email ?? '',
            avatarUrl: currentUser?.avatarUrl,
            onTap: () async {
              await context.push(AppRoutes.profile);
              if (context.mounted) {
                await context.read<AuthViewModel>().checkAuth();
              }
            },
          ),
          const SizedBox(height: AppDimens.d24),

          // ── Accessibility Section ──────────────────────────────────
          _buildSectionHeader(AppStrings.settingsAccessibility),
          const SizedBox(height: AppDimens.d8),
          _GroupCard(
            children: [
              _SettingsToggleRow(
                title: AppStrings.a11yHighContrast,
                value: a11y.highContrastMode,
                onChanged: (v) => vm.setHighContrastMode(v),
              ),
              _buildDivider(),
              _SettingsToggleRow(
                title: AppStrings.a11yVoiceInput,
                value: a11y.voiceInputMode,
                onChanged: (v) => vm.setVoiceInputMode(v),
              ),
              _buildDivider(),
              _SettingsToggleRow(
                title: AppStrings.a11yReduceMotion,
                value: a11y.reduceMotion,
                onChanged: (v) => vm.setReduceMotion(v),
              ),
              _buildDivider(),
              _SettingsActionRow(
                title: 'View More',
                onTap: () => context.push(AppRoutes.accessibility),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.d24),

          // ── Notifications Section ──────────────────────────────────
          _buildSectionHeader(AppStrings.settingsNotifications),
          const SizedBox(height: AppDimens.d8),
          _GroupCard(
            children: [
              _SettingsToggleRow(
                title: AppStrings.notifDailyReminder,
                subtitle: notif.dailyReminder ? notif.dailyReminderTime.format(context) : null,
                value: notif.dailyReminder,
                onChanged: (v) => vm.setDailyReminder(v),
              ),
              _buildDivider(),
              _SettingsToggleRow(
                title: AppStrings.notifMilestone,
                value: notif.milestoneNotifications,
                onChanged: (v) => vm.setMilestoneNotifications(v),
              ),
              _buildDivider(),
              _SettingsToggleRow(
                title: AppStrings.notifWeeklySummary,
                value: notif.weeklySummary,
                onChanged: (v) => vm.setWeeklySummary(v),
              ),
              _buildDivider(),
              _SettingsActionRow(
                title: AppStrings.notifReminderTime,
                trailingText: notif.dailyReminderTime.format(context),
                onTap: () => _pickTime(context, vm),
              ),
              _buildDivider(),
              _SettingsToggleRow(
                title: AppStrings.notifInactivity,
                value: notif.inactivityReminder,
                onChanged: (v) => vm.setInactivityReminder(v),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.d24),

          // ── About Section ──────────────────────────────────────────
          _buildSectionHeader('About'),
          const SizedBox(height: AppDimens.d8),
          _GroupCard(
            children: [
              _SettingsActionRow(
                title: AppStrings.aboutPrivacyPolicy,
                onTap: () => _openUrl(_privacyPolicyUrl),
              ),
              _buildDivider(),
              _SettingsActionRow(
                title: AppStrings.aboutTermsOfService,
                onTap: () => _openUrl(_termsUrl),
              ),
              _buildDivider(),
              _SettingsInfoRow(
                title: AppStrings.aboutAppVersion,
                value: '1.0.0',
              ),
              _buildDivider(),
              _SettingsToggleRow(
                title: AppStrings.aboutResearchConsent,
                value: a11y.researchConsent,
                onChanged: (v) => vm.setResearchConsent(v),
              ),
              _buildDivider(),
              _SettingsActionRow(
                title: AppStrings.aboutMedicalDisclaimer,
                onTap: () => _showMedicalDisclaimer(context),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.d24),

          // ── Sign Out ─────────────────────────────────────────────
          _buildSignOutButton(context),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: AppDimens.d16),
      child: Text(
        title,
        style: AppTextStyles.label.copyWith(
          color: AppColors.muted,
          letterSpacing: 1.0,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDivider() => const _SettingsDivider();

  Widget _buildSignOutButton(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: AppDimens.d16, bottom: AppDimens.d40),
        child: InkWell(
          onTap: () => _confirmSignOut(context),
          borderRadius: BorderRadius.circular(AppDimens.radiusFull),
          child: Container(
            height: AppDimens.touchMin,
            padding: const EdgeInsets.symmetric(horizontal: AppDimens.d32),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppDimens.radiusFull),
            ),
            alignment: Alignment.center,
            child: Text(
              AppStrings.settingsSignOut,
              style: AppTextStyles.bodyLg.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          AppStrings.settingsSignOutConfirmTitle,
          style: AppTextStyles.titleLg.copyWith(color: AppColors.ink),
        ),
        content: Text(
          AppStrings.settingsSignOutConfirm,
          style: AppTextStyles.bodyMd.copyWith(color: AppColors.body),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              AppStrings.settingsSignOut,
              style: AppTextStyles.buttonSm.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      final router = GoRouter.of(context);
      await context.read<AuthViewModel>().logout();
      router.go(AppRoutes.login);
    }
  }

  Future<void> _pickTime(BuildContext context, AccessibilityViewModel vm) async {
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
    }
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showMedicalDisclaimer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.canvas,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimens.radiusLg)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(AppDimens.d24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.medical_information_rounded,
                  color: AppColors.warning,
                  size: AppDimens.iconLg,
                ),
                const SizedBox(width: AppDimens.d12),
                Text(
                  AppStrings.aboutMedicalDisclaimer,
                  style: AppTextStyles.titleLg.copyWith(color: AppColors.ink),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.d16),
            Text(
              AppStrings.medicalDisclaimerText,
              style: AppTextStyles.bodyMd.copyWith(color: AppColors.body, height: 1.6),
            ),
            const SizedBox(height: AppDimens.d24),
            SizedBox(
              width: double.infinity,
              height: AppDimens.touchNormal,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                  ),
                ),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Profile Header Card Widget ──────────────────────────────────────────

class _ProfileHeaderCard extends StatefulWidget {
  const _ProfileHeaderCard({
    required this.name,
    required this.email,
    this.avatarUrl,
    this.userId,
    required this.onTap,
  });

  final String name;
  final String email;
  final String? avatarUrl;
  final String? userId;
  final VoidCallback onTap;

  @override
  State<_ProfileHeaderCard> createState() => _ProfileHeaderCardState();
}

class _ProfileHeaderCardState extends State<_ProfileHeaderCard> {
  String? _resolvedAvatar;

  @override
  void initState() {
    super.initState();
    _loadAvatar();
  }

  @override
  void didUpdateWidget(covariant _ProfileHeaderCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.avatarUrl != widget.avatarUrl || oldWidget.userId != widget.userId) {
      _loadAvatar();
    }
  }

  Future<void> _loadAvatar() async {
    String? localPath;
    if (widget.userId != null) {
      try {
        final prefs = await SharedPreferences.getInstance();
        localPath = prefs.getString('avatar_local_${widget.userId}');
        if (localPath != null && localPath.isNotEmpty && File(localPath).existsSync()) {
          if (mounted) setState(() => _resolvedAvatar = localPath);
          return;
        }
      } catch (_) {}
    }
    if (mounted) {
      setState(() => _resolvedAvatar = widget.avatarUrl);
    }
  }

  Widget _buildInitials(String initials) {
    return Center(
      child: Text(
        initials,
        style: AppTextStyles.titleLg.copyWith(
          color: AppColors.primary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final initials = widget.name.isNotEmpty
        ? widget.name
            .split(' ')
            .where((w) => w.isNotEmpty)
            .take(2)
            .map((w) => w[0].toUpperCase())
            .join()
        : '?';

    final isHc = context.watch<AccessibilityViewModel>().accessibility.highContrastMode;

    return Container(
      decoration: BoxDecoration(
        color: isHc ? AppColors.hcSurface : AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(
          color: isHc ? AppColors.hcBorder : AppColors.hairlineSoft,
          width: isHc ? 2.0 : 1.0,
        ),
        boxShadow: isHc
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            widget.onTap();
            // Re-check local avatar on tap/return
            await _loadAvatar();
          },
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          child: Padding(
            padding: const EdgeInsets.all(AppDimens.d16),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryLight,
                  ),
                  child: ClipOval(
                    child: _resolvedAvatar != null && _resolvedAvatar!.isNotEmpty
                        ? (_resolvedAvatar!.startsWith('http')
                            ? Image.network(
                                _resolvedAvatar!,
                                fit: BoxFit.cover,
                                width: 64,
                                height: 64,
                                errorBuilder: (context, error, stackTrace) =>
                                    _buildInitials(initials),
                              )
                            : Image.file(
                                File(_resolvedAvatar!),
                                fit: BoxFit.cover,
                                width: 64,
                                height: 64,
                                errorBuilder: (context, error, stackTrace) =>
                                    _buildInitials(initials),
                              ))
                        : _buildInitials(initials),
                  ),
                ),
                const SizedBox(width: AppDimens.d16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.name,
                        style: AppTextStyles.displaySm.copyWith(
                          color: isHc ? AppColors.hcText : AppColors.ink,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (widget.email.isNotEmpty) ...[
                        const SizedBox(height: AppDimens.d4),
                        Text(
                          widget.email,
                          style: AppTextStyles.bodySm.copyWith(
                            color: isHc ? AppColors.hcMuted : AppColors.muted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.muted,
                  size: AppDimens.iconLg,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Group Card Wrapper Widget ───────────────────────────────────────────

class _GroupCard extends StatelessWidget {
  const _GroupCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final isHc = context.watch<AccessibilityViewModel>().accessibility.highContrastMode;

    return Container(
      decoration: BoxDecoration(
        color: isHc ? AppColors.hcSurface : AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(
          color: isHc ? AppColors.hcBorder : AppColors.hairlineSoft,
          width: isHc ? 2.0 : 1.0,
        ),
        boxShadow: isHc
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

class _SettingsDivider extends StatelessWidget {
  const _SettingsDivider();

  @override
  Widget build(BuildContext context) {
    final isHc = context.watch<AccessibilityViewModel>().accessibility.highContrastMode;
    return Container(
      height: isHc ? 2.0 : 1.0,
      margin: const EdgeInsets.symmetric(horizontal: AppDimens.d16),
      color: isHc ? AppColors.hcBorder : AppColors.hairline,
    );
  }
}

// ── Settings Toggle Row Widget ──────────────────────────────────────────

class _SettingsToggleRow extends StatelessWidget {
  const _SettingsToggleRow({
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final isHc = context.watch<AccessibilityViewModel>().accessibility.highContrastMode;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.d16,
        vertical: AppDimens.d12,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyLg.copyWith(
                    color: isHc ? AppColors.hcText : AppColors.ink,
                    fontWeight: isHc ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  const SizedBox(height: AppDimens.d4),
                  Text(
                    subtitle!,
                    style: AppTextStyles.bodySm.copyWith(
                      color: isHc ? AppColors.hcMuted : AppColors.muted,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppDimens.d12),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeTrackColor: isHc ? AppColors.hcPrimary : AppColors.primary,
          ),
        ],
      ),
    );
  }
}

// ── Settings Action Navigation Row Widget ───────────────────────────────

class _SettingsActionRow extends StatelessWidget {
  const _SettingsActionRow({
    required this.title,
    this.trailingText,
    required this.onTap,
  });

  final String title;
  final String? trailingText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.d16,
          vertical: AppDimens.d16,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.bodyLg.copyWith(
                  color: trailingText == null ? AppColors.muted : AppColors.ink,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (trailingText != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.d12,
                  vertical: AppDimens.d4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSoft,
                  borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                ),
                child: Text(
                  trailingText!,
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.body,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: AppDimens.d8),
            ],
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.muted,
              size: AppDimens.iconMd,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Settings Info Row (Non-clickable) Widget ───────────────────────────

class _SettingsInfoRow extends StatelessWidget {
  const _SettingsInfoRow({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.d16,
        vertical: AppDimens.d16,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTextStyles.bodyLg.copyWith(
              color: AppColors.ink,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodyLg.copyWith(
              color: AppColors.muted,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
