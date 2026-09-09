import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/utils/logger.dart';
import '../../data/repositories/assessment_repository.dart';
import '../../data/repositories/profile_repository.dart';
import '../../data/storage/local_store.dart';
import '../../modules/auth/viewmodels/auth_view_model.dart';
import 'app_routes.dart';

/// Pure guard functions and auth route resolution.

/// Redirects unauthenticated users to login.
/// Returns null if user is logged in; redirect path if not.
String? authGuard(BuildContext context, GoRouterState state) {
  final auth = context.read<AuthViewModel>();
  if (!auth.isLoggedIn) {
    return AppRoutes.login;
  }
  return null;
}

/// Redirects logged-in users away from auth screens.
/// Returns null if user is NOT logged in; redirect path if yes.
String? guestGuard(BuildContext context, GoRouterState state) {
  final auth = context.read<AuthViewModel>();
  if (auth.isLoggedIn) {
    return AppRoutes.home;
  }
  return null;
}

/// Redirects users who haven't completed onboarding.
/// Returns null if onboarding is complete; redirect path if not.
Future<String?> onboardingGuard(BuildContext context, GoRouterState state) async {
  final localStore = context.read<LocalStore>();
  final isComplete = await localStore.isOnboardingComplete;
  if (!isComplete) {
    return AppRoutes.onboarding;
  }
  return null;
}

/// Resolves the destination route for an authenticated user.
/// Checks local state first, and queries Supabase as the authoritative source
/// of truth if local state was wiped or not yet initialized (e.g. after logout or fresh install).
Future<String> resolvePostAuthRoute(BuildContext context) async {
  final auth = context.read<AuthViewModel>();
  final localStore = context.read<LocalStore>();
  final profileRepo = context.read<ProfileRepository>();
  final assessmentRepo = context.read<AssessmentRepository>();
  final userId = auth.currentUser?.id;

  var onboardingDone = await localStore.isOnboardingComplete;

  // If local store does not show onboarding as complete, verify with Supabase
  if (!onboardingDone && userId != null) {
    try {
      final profile = await profileRepo.getPatientProfile(userId);
      if (profile != null &&
          (profile.onboardingCompletedAt != null ||
              profile.conditions.isNotEmpty ||
              profile.goals.isNotEmpty)) {
        onboardingDone = true;
        await localStore.setOnboardingComplete(true);
        AppLogger.info(
          'Restored onboarding completion status from Supabase for $userId',
          tag: 'RouteGuards',
        );
      }
    } catch (e) {
      AppLogger.warn(
        'Failed to verify remote patient profile: $e',
        tag: 'RouteGuards',
      );
    }
  }

  if (!onboardingDone) {
    return AppRoutes.onboarding;
  }

  // Onboarding is complete — verify if baseline assessment was completed
  final assessmentDone = await assessmentRepo.hasCompletedBaseline();
  if (!assessmentDone) {
    return AppRoutes.assessment;
  }

  return AppRoutes.home;
}
