import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_motion.dart';

import '../../core/services/gamification_service.dart';
import '../../core/services/notification_service.dart';
import '../../data/repositories/assessment_repository.dart';
import '../../data/repositories/exercise_repository.dart';
import '../../data/repositories/session_repository.dart';
import '../../modules/assessment/pages/assessment_complete_page.dart';
import '../../modules/assessment/pages/assessment_exercise_page.dart';
import '../../modules/assessment/pages/assessment_intro_page.dart';
import '../../modules/assessment/viewmodels/assessment_view_model.dart';
import '../../modules/auth/pages/forgot_password_page.dart';
import '../../modules/auth/pages/login_page.dart';
import '../../modules/auth/pages/onboarding_page.dart';
import '../../modules/auth/pages/register_page.dart';
import '../../modules/auth/pages/splash_page.dart';
import '../../modules/auth/viewmodels/auth_view_model.dart';
import '../../modules/therapy/pages/domain_select_page.dart';
import '../../modules/therapy/pages/session_page.dart';
import '../../modules/therapy/pages/session_result_page.dart';
import '../../modules/therapy/viewmodels/domain_select_view_model.dart';
import '../../modules/therapy/viewmodels/therapy_session_view_model.dart';
import '../../modules/home/pages/home_page.dart';
import '../../modules/progress/pages/progress_page.dart';
import '../../modules/progress/pages/domain_detail_page.dart';
import '../../data/repositories/progress_repository.dart';
import '../../modules/settings/pages/settings_page.dart';
import '../../modules/settings/pages/accessibility_settings_page.dart';
import '../../modules/settings/pages/notification_settings_page.dart';
import '../../modules/settings/pages/profile_settings_page.dart';
import '../../modules/settings/pages/about_settings_page.dart';
import 'app_routes.dart';
import 'app_shell.dart';

/// Shared fade transition for all routes.
CustomTransitionPage<T> fadePage<T>({
  required Widget child,
  required GoRouterState state,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        FadeTransition(opacity: animation, child: child),
    transitionDuration: AppMotion.fadeTransition,
  );
}

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'rootNav');
final _homeNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'homeNav');
final _progressNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'progressNav');

/// Creates the app's [GoRouter] instance.
///
/// Navigation architecture:
/// - 2-tab [StatefulShellRoute]: Home, Progress
/// - Settings pushed from the app bar (not a tab)
/// - Assessment and Therapy are separate shell routes
GoRouter createRouter(AuthViewModel authViewModel) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    refreshListenable: authViewModel,
    redirect: (context, state) {
      final isLoggedIn = authViewModel.isLoggedIn;
      final isAuthRoute = state.matchedLocation.startsWith('/auth');
      final isSplash = state.matchedLocation == AppRoutes.splash;

      // Don't redirect from splash — it handles its own navigation
      if (isSplash) return null;

      // Not logged in and trying to access protected route
      if (!isLoggedIn && !isAuthRoute) {
        return AppRoutes.login;
      }

      // Logged in but on auth route → redirect to home
      if (isLoggedIn && isAuthRoute) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
      // ── Splash ─────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.splash,
        pageBuilder: (context, state) =>
            fadePage(child: const SplashPage(), state: state),
      ),

      // ── Auth ───────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.login,
        pageBuilder: (context, state) =>
            fadePage(child: const LoginPage(), state: state),
      ),
      GoRoute(
        path: AppRoutes.register,
        pageBuilder: (context, state) =>
            fadePage(child: const RegisterPage(), state: state),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        pageBuilder: (context, state) =>
            fadePage(child: const ForgotPasswordPage(), state: state),
      ),

      // ── Onboarding ────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.onboarding,
        pageBuilder: (context, state) =>
            fadePage(child: const OnboardingPage(), state: state),
      ),

      // ── 2-Tab Navigation Shell (Home + Progress) ──────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(
            navigationShell: navigationShell,
            branchNavigatorKeys: [
              _homeNavigatorKey,
              _progressNavigatorKey,
            ],
          );
        },
        branches: [
          // ── Branch 0: Home ──────────────────────────────────────
          StatefulShellBranch(
            navigatorKey: _homeNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.home,
                pageBuilder: (context, state) => fadePage(
                  child: const HomePage(),
                  state: state,
                ),
              ),
            ],
          ),
          // ── Branch 1: Progress ─────────────────────────────────
          StatefulShellBranch(
            navigatorKey: _progressNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.progress,
                pageBuilder: (context, state) => fadePage(
                  child: const ProgressPage(),
                  state: state,
                ),
                routes: [
                  GoRoute(
                    path: ':domainId',
                    pageBuilder: (context, state) {
                      final domainId =
                          state.pathParameters['domainId'] ?? 'language';
                      return fadePage(
                        child: DomainDetailPage(domainCode: domainId),
                        state: state,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),

      // ── Settings (pushed from app bar, not a tab) ──────────────
      GoRoute(
        path: AppRoutes.settings,
        pageBuilder: (context, state) => fadePage(
          child: const SettingsPage(),
          state: state,
        ),
        routes: [
          GoRoute(
            path: 'accessibility',
            pageBuilder: (context, state) => fadePage(
              child: const AccessibilitySettingsPage(),
              state: state,
            ),
          ),
          GoRoute(
            path: 'notifications',
            pageBuilder: (context, state) => fadePage(
              child: const NotificationSettingsPage(),
              state: state,
            ),
          ),
          GoRoute(
            path: 'profile',
            pageBuilder: (context, state) => fadePage(
              child: const ProfileSettingsPage(),
              state: state,
            ),
          ),
          GoRoute(
            path: 'about',
            pageBuilder: (context, state) => fadePage(
              child: const AboutSettingsPage(),
              state: state,
            ),
          ),
        ],
      ),

      // ── Assessment ─────────────────────────────────────────────────
      ShellRoute(
        builder: (context, state, child) {
          return ChangeNotifierProvider<AssessmentViewModel>(
            create: (ctx) => AssessmentViewModel(
              ctx.read<AssessmentRepository>(),
            ),
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: AppRoutes.assessment,
            pageBuilder: (context, state) => fadePage(
              child: const AssessmentIntroPage(),
              state: state,
            ),
          ),
          GoRoute(
            path: AppRoutes.assessmentExercise,
            pageBuilder: (context, state) => fadePage(
              child: const AssessmentExercisePage(),
              state: state,
            ),
          ),
          GoRoute(
            path: AppRoutes.assessmentComplete,
            pageBuilder: (context, state) => fadePage(
              child: const AssessmentCompletePage(),
              state: state,
            ),
          ),
        ],
      ),

      // ── Therapy Session ────────────────────────────────────────────
      ShellRoute(
        builder: (context, state, child) {
          return MultiProvider(
            providers: [
              ChangeNotifierProvider<DomainSelectViewModel>(
                create: (ctx) => DomainSelectViewModel(
                  ctx.read<ExerciseRepository>(),
                ),
              ),
              ChangeNotifierProvider<TherapySessionViewModel>(
                create: (ctx) => TherapySessionViewModel(
                  ctx.read<ExerciseRepository>(),
                  ctx.read<SessionRepository>(),
                  ctx.read<GamificationService>(),
                  ctx.read<NotificationService>(),
                  ctx.read<ProgressRepository>(),
                ),
              ),
            ],
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: AppRoutes.domainSelect,
            pageBuilder: (context, state) => fadePage(
              child: const DomainSelectPage(),
              state: state,
            ),
          ),
          GoRoute(
            path: AppRoutes.session,
            pageBuilder: (context, state) {
              final domains = state.extra as List<String>? ?? ['language'];
              return fadePage(
                child: SessionPage(
                  key: UniqueKey(),
                  domains: domains,
                ),
                state: state,
              );
            },
          ),
          GoRoute(
            path: AppRoutes.sessionResult,
            pageBuilder: (context, state) => fadePage(
              child: const SessionResultPage(),
              state: state,
            ),
          ),
        ],
      ),
    ],
  );
}
