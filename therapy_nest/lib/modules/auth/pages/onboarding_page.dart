import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../data/repositories/assessment_repository.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../../data/storage/local_store.dart';
import '../viewmodels/auth_view_model.dart';
import '../viewmodels/onboarding_view_model.dart';
import '../widgets/condition_step.dart';
import '../widgets/goals_step.dart';
import '../widgets/schedule_step.dart';
import '../widgets/severity_step.dart';
import '../widgets/welcome_step.dart';

/// 5-step onboarding flow wrapped in a PageView with step indicators.
class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authVM = context.read<AuthViewModel>();
    final userId = authVM.currentUser?.id ?? '';

    return ChangeNotifierProvider<OnboardingViewModel>(
      create: (ctx) => OnboardingViewModel(
        profileRepo: ctx.read<ProfileRepository>(),
        localStore: ctx.read<LocalStore>(),
        userId: userId,
      ),
      child: const _OnboardingBody(),
    );
  }
}

class _OnboardingBody extends StatefulWidget {
  const _OnboardingBody();

  @override
  State<_OnboardingBody> createState() => _OnboardingBodyState();
}

class _OnboardingBodyState extends State<_OnboardingBody> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _animateToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _handleNext() async {
    final vm = context.read<OnboardingViewModel>();

    if (vm.isLastStep) {
      // Complete onboarding
      final success = await vm.completeOnboarding();
      if (!mounted) return;

      if (success) {
        final assessmentRepo = context.read<AssessmentRepository>();
        final assessmentDone = await assessmentRepo.hasCompletedBaseline();
        if (!mounted) return;

        if (assessmentDone) {
          context.go(AppRoutes.home);
        } else {
          context.go(AppRoutes.assessment);
        }
      } else if (vm.error != null) {
        AppToast.error(context, vm.error!.message);
      }
    } else {
      vm.nextStep();
      _animateToPage(vm.currentStep);
    }
  }

  void _handleBack() {
    final vm = context.read<OnboardingViewModel>();
    if (!vm.isFirstStep) {
      vm.previousStep();
      _animateToPage(vm.currentStep);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OnboardingViewModel>();

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar with back + step indicator ─────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.d16,
                vertical: AppDimens.d12,
              ),
              child: Row(
                children: [
                  // Back button
                  if (!vm.isFirstStep)
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          size: AppDimens.iconMd),
                      onPressed: _handleBack,
                    )
                  else
                    const SizedBox(width: AppDimens.d48),

                  // Step indicator dots
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        vm.totalSteps,
                        (index) => _StepDot(
                          isActive: index == vm.currentStep,
                          isCompleted: index < vm.currentStep,
                        ),
                      ),
                    ),
                  ),

                  // Step counter
                  SizedBox(
                    width: AppDimens.d48,
                    child: Text(
                      '${vm.currentStep + 1}/${vm.totalSteps}',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.muted,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),

            // ── Page content ──────────────────────────────────
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: const [
                  ConditionStep(),
                  SeverityStep(),
                  GoalsStep(),
                  ScheduleStep(),
                  WelcomeStep(),
                ],
              ),
            ),

            // ── Bottom navigation ─────────────────────────────
            if (!vm.isLastStep)
              Padding(
                padding: const EdgeInsets.all(AppDimens.d24),
                child: AppButton(
                  label: AppStrings.onboardingNext,
                  onPressed: _handleNext,
                  isLoading: vm.isLoading,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Step indicator dot widget.
class _StepDot extends StatelessWidget {
  const _StepDot({required this.isActive, required this.isCompleted});

  final bool isActive;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(horizontal: 3),
      width: isActive ? 24 : 10,
      height: 6,
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.primary
            : (isCompleted
                ? AppColors.primary.withValues(alpha: 0.5)
                : AppColors.hairline),
        borderRadius: BorderRadius.circular(AppDimens.radiusFull),
      ),
    );
  }
}
