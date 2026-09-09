/// API endpoint string constants — only paths, no logic.
/// Used with [ApiClient] for custom backend (Render/Koyeb FastAPI).
class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const String login   = '/auth/login';
  static const String profile = '/user/profile';

  // TODO: Add endpoints as Render/Koyeb backend is developed
}
