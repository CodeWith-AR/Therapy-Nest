import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../viewmodels/domain_select_view_model.dart';
import '../viewmodels/therapy_session_view_model.dart';

/// Domain selection page — user picks 1+ domains before starting a session.
///
/// Route: `/therapy/domains`
class DomainSelectPage extends StatefulWidget {
  const DomainSelectPage({super.key});

  @override
  State<DomainSelectPage> createState() => _DomainSelectPageState();
}

class _DomainSelectPageState extends State<DomainSelectPage> {
  @override
  void initState() {
    super.initState();
    // Load domain data on first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DomainSelectViewModel>().loadDomainData();
    });
  }

  void _handleBack() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DomainSelectViewModel>();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _handleBack();
      },
      child: Scaffold(
        backgroundColor: AppColors.canvas,
        appBar: AppBar(
          backgroundColor: AppColors.surfaceWhite,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: AppColors.ink),
            onPressed: _handleBack,
            tooltip: 'Back to Home',
          ),
          title: Text(
            AppStrings.therapyDomainSelectTitle,
            style: AppTextStyles.appBarTitle.copyWith(color: AppColors.ink),
          ),
          centerTitle: true,
        ),
        body: vm.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // ── Subtitle ──────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppDimens.d24,
                      AppDimens.d20,
                      AppDimens.d24,
                      AppDimens.d16,
                    ),
                    child: Text(
                      AppStrings.therapyDomainSelectBody,
                      style: AppTextStyles.bodyMd.copyWith(color: AppColors.muted),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  // ── Domain Grid ───────────────────────────────────
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimens.d16,
                      ),
                      child: GridView.builder(
                        itemCount: vm.availableDomains.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: AppDimens.d12,
                          mainAxisSpacing: AppDimens.d12,
                          childAspectRatio: 1.1,
                        ),
                        itemBuilder: (context, index) {
                          final domain = vm.availableDomains[index];
                          final isSelected = vm.isDomainSelected(domain);
                          final progress = vm.thetaProgress(domain);

                          return _DomainCard(
                            domain: domain,
                            isSelected: isSelected,
                            progress: progress,
                            onTap: () => context
                                .read<DomainSelectViewModel>()
                                .toggleDomain(domain),
                          ).animate().fadeIn(
                                duration: 300.ms,
                                delay: Duration(milliseconds: 50 * index),
                              );
                        },
                      ),
                    ),
                  ),

                  // ── Start Button ──────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.all(AppDimens.d24),
                    child: AppButton(
                      label: AppStrings.therapyStartSession,
                      isEnabled: vm.canStartSession,
                      onPressed: vm.canStartSession
                          ? () {
                              context.read<TherapySessionViewModel>().reset();
                              context.go(
                                AppRoutes.session,
                                extra: vm.selectedDomains,
                              );
                            }
                          : null,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// A selectable domain card with icon, name, and ability progress bar.
class _DomainCard extends StatelessWidget {
  const _DomainCard({
    required this.domain,
    required this.isSelected,
    required this.progress,
    required this.onTap,
  });

  final String domain;
  final bool isSelected;
  final double progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(AppDimens.d16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.hairline,
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── Icon ──────────────────────────────────────────────
            Icon(
              _domainIcon(domain),
              size: AppDimens.iconLg,
              color: isSelected ? AppColors.primary : AppColors.muted,
            ),
            const SizedBox(height: AppDimens.d8),

            // ── Name ──────────────────────────────────────────────
            Text(
              _domainDisplayName(domain),
              style: AppTextStyles.titleSm.copyWith(
                color: isSelected ? AppColors.primaryDark : AppColors.ink,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimens.d12),

            // ── Progress Bar ──────────────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(AppDimens.radiusFull),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 4,
                backgroundColor: isSelected
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : AppColors.hairlineSoft,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isSelected ? AppColors.primary : AppColors.accentTeal,
                ),
              ),
            ),
            const SizedBox(height: AppDimens.d4),

            // ── Level Label ───────────────────────────────────────
            Text(
              _levelLabel(progress),
              style: AppTextStyles.caption.copyWith(
                color: AppColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _domainDisplayName(String domain) {
    switch (domain) {
      case 'language':
        return AppStrings.domainLanguage;
      case 'reading_writing':
        return AppStrings.domainReadingWriting;
      case 'memory':
        return AppStrings.domainMemory;
      case 'attention':
        return AppStrings.domainAttention;
      case 'speech':
        return AppStrings.domainSpeech;
      case 'math':
        return AppStrings.domainMath;
      default:
        return domain;
    }
  }

  IconData _domainIcon(String domain) {
    switch (domain) {
      case 'language':
        return Icons.translate_rounded;
      case 'reading_writing':
        return Icons.auto_stories_rounded;
      case 'memory':
        return Icons.psychology_rounded;
      case 'attention':
        return Icons.center_focus_strong_rounded;
      case 'speech':
        return Icons.record_voice_over_rounded;
      case 'math':
        return Icons.calculate_rounded;
      default:
        return Icons.extension_rounded;
    }
  }

  String _levelLabel(double progress) {
    if (progress < 0.25) return 'Beginner';
    if (progress < 0.5) return 'Developing';
    if (progress < 0.75) return 'Intermediate';
    return 'Advanced';
  }
}
