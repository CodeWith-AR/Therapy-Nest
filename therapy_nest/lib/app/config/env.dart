/// Environment configuration — Supabase credentials and API URLs.
class Env {
  Env._();

  static const String supabaseUrl = 'https://ztkniuwsdopkmxjckgmv.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inp0a25pdXdzZG9wa214amNrZ212Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODY2OTk2OTAsImV4cCI6MjEwMjI3NTY5MH0.tzpv3eeEiIHonpGVcM_RKLRDo03UoAhsqtbSS52OMqY';

  // Render / Koyeb FastAPI backend (to be configured in Module 11)
  static const String apiBaseUrl =
      ''; // TODO: Set when Render/Koyeb is deployed
}
