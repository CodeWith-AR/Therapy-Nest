/// All route path constants — the single source of truth for navigation paths.
/// No hardcoded route strings anywhere else in the codebase.
class AppRoutes {
  AppRoutes._();

  static const String splash         = '/';
  static const String login          = '/auth/login';
  static const String register       = '/auth/register';
  static const String forgotPassword = '/auth/forgot-password';
  static const String onboarding     = '/onboarding';
  static const String assessment         = '/assessment';
  static const String assessmentExercise = '/assessment/exercise';
  static const String assessmentComplete = '/assessment/complete';
  static const String home           = '/home';
  static const String domainSelect   = '/therapy/domains';
  static const String session        = '/therapy/session';
  static const String sessionResult  = '/therapy/session/result';
  static const String progress       = '/progress';
  static const String progressDetail = '/progress/:domainId';
  static const String achievements   = '/achievements';
  static const String settings       = '/settings';
  static const String profile        = '/settings/profile';
  static const String accessibility  = '/settings/accessibility';
  static const String notifications  = '/settings/notifications';
  static const String about          = '/settings/about';
}
