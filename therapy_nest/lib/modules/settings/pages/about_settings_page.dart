import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../viewmodels/accessibility_view_model.dart';

/// About & Legal page — app version, open source acknowledgments,
/// privacy policy, terms of service, research consent toggle,
/// and the always-visible medical disclaimer card.
class AboutSettingsPage extends StatelessWidget {
  const AboutSettingsPage({super.key});

  static const String _appVersion = '1.0.0';
  static const String _privacyPolicyUrl =
      'https://therapy-nest-web.vercel.app/privacy';
  static const String _termsUrl = 'https://therapy-nest-web.vercel.app/terms';

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AccessibilityViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.aboutTitle)),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.d16,
          vertical: AppDimens.d16,
        ),
        children: [
          // ── App Version ────────────────────────────────────────────
          _InfoTile(
            icon: Icons.info_outline_rounded,
            iconColor: AppColors.primary,
            title: AppStrings.aboutAppVersion,
            trailing: Text(
              'v$_appVersion',
              style: AppTextStyles.titleSm.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: AppDimens.d12),

          // ── Open Source Acknowledgments ─────────────────────────────
          _InfoTile(
            icon: Icons.code_rounded,
            iconColor: AppColors.accentPurple,
            title: AppStrings.aboutOpenSource,
            trailing: Icon(
              Icons.chevron_right_rounded,
              color: AppColors.muted,
              size: AppDimens.iconMd,
            ),
            onTap: () => _showLicenses(context),
          ),
          const SizedBox(height: AppDimens.d12),

          // ── Privacy Policy ─────────────────────────────────────────
          _InfoTile(
            icon: Icons.privacy_tip_outlined,
            iconColor: AppColors.info,
            title: AppStrings.aboutPrivacyPolicy,
            trailing: Icon(
              Icons.open_in_new_rounded,
              color: AppColors.muted,
              size: AppDimens.iconSm,
            ),
            onTap: () => _openUrl(_privacyPolicyUrl),
          ),
          const SizedBox(height: AppDimens.d12),

          // ── Terms of Service ───────────────────────────────────────
          _InfoTile(
            icon: Icons.description_outlined,
            iconColor: AppColors.accentTeal,
            title: AppStrings.aboutTermsOfService,
            trailing: Icon(
              Icons.open_in_new_rounded,
              color: AppColors.muted,
              size: AppDimens.iconSm,
            ),
            onTap: () => _openUrl(_termsUrl),
          ),
          const SizedBox(height: AppDimens.d16),
          const Divider(),
          const SizedBox(height: AppDimens.d16),

          // ── Research Consent Toggle ────────────────────────────────
          _ToggleTile(
            icon: Icons.science_outlined,
            iconColor: AppColors.accentAmber,
            title: AppStrings.aboutResearchConsent,
            subtitle: AppStrings.aboutResearchConsentDesc,
            value: vm.researchConsent,
            onChanged: (val) => vm.setResearchConsent(val),
          ),
          const SizedBox(height: AppDimens.d24),

          // ── Medical Disclaimer (always visible) ───────────────────
          _DisclaimerCard(),
          const SizedBox(height: AppDimens.d32),
        ],
      ),
    );
  }

  void _showLicenses(BuildContext context) {
    showLicensePage(
      context: context,
      applicationName: AppStrings.appName,
      applicationVersion: 'v$_appVersion',
      applicationLegalese: '© 2026 Therapy Nest',
    );
  }

  Future<void> _openUrl(String url, [BuildContext? ctx]) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (ctx != null && ctx.mounted) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            const SnackBar(
              content: Text('Could not open the link. Please try again later.'),
            ),
          );
        }
      }
    } catch (e) {
      if (ctx != null && ctx.mounted) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          const SnackBar(
            content: Text('Could not open the link. Please try again later.'),
          ),
        );
      }
    }
  }
}

// ── Info Tile ──────────────────────────────────────────────────────────

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.trailing,
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final Widget trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
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
            Container(
              width: AppDimens.d40,
              height: AppDimens.d40,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppDimens.radiusMd),
              ),
              child: Icon(icon, color: iconColor, size: AppDimens.iconMd),
            ),
            const SizedBox(width: AppDimens.d12),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.titleSm.copyWith(color: AppColors.ink),
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}

// ── Toggle Tile ────────────────────────────────────────────────────────

class _ToggleTile extends StatelessWidget {
  const _ToggleTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final Color iconColor;
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
          Container(
            width: AppDimens.d40,
            height: AppDimens.d40,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            ),
            child: Icon(icon, color: iconColor, size: AppDimens.iconMd),
          ),
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

// ── Medical Disclaimer Card (always visible) ───────────────────────────

class _DisclaimerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.d16),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.medical_information_rounded,
                color: AppColors.warning,
                size: AppDimens.iconMd,
              ),
              const SizedBox(width: AppDimens.d12),
              Text(
                AppStrings.aboutMedicalDisclaimer,
                style: AppTextStyles.titleSm.copyWith(
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.d12),
          Text(
            AppStrings.medicalDisclaimerText,
            style: AppTextStyles.bodySm.copyWith(
              color: AppColors.body,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
