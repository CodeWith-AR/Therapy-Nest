import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../../data/api/api_client.dart';
import '../../data/local_db/app_database.dart';
import '../../data/repositories/assessment_repository.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/exercise_repository.dart';
import '../../data/repositories/profile_repository.dart';
import '../../data/repositories/session_repository.dart';
import '../../data/repositories/progress_repository.dart';
import '../../data/storage/local_store.dart';
import '../../data/storage/token_store.dart';
import '../../modules/auth/viewmodels/auth_view_model.dart';
import '../../modules/settings/viewmodels/accessibility_view_model.dart';
import '../../core/services/speech_service.dart';
import '../../core/services/sync_service.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/gamification_service.dart';
import '../../modules/progress/viewmodels/progress_view_model.dart';

/// Composition root — the ONLY place where dependencies are wired.
/// Nothing else in the app creates repositories or services.
List<SingleChildWidget> appProviders() => [
      // ── Infrastructure ───────────────────────────────────────────
      Provider<LocalStore>(create: (_) => LocalStore()),
      Provider<TokenStore>(create: (_) => TokenStore()),
      Provider<ApiClient>(
        create: (ctx) => ApiClient(ctx.read<TokenStore>()),
      ),

      // ── Local Database (Drift) ────────────────────────────────────
      Provider<AppDatabase>(create: (_) => AppDatabase()),

      // ── Repositories ─────────────────────────────────────────────
      Provider<AuthRepository>(
        create: (ctx) => AuthRepository(
          ctx.read<TokenStore>(),
          ctx.read<AppDatabase>(),
          ctx.read<LocalStore>(),
        ),
      ),
      Provider<ProfileRepository>(
        create: (_) => ProfileRepository(),
      ),
      Provider<AssessmentRepository>(
        create: (ctx) => AssessmentRepository(ctx.read<AppDatabase>()),
      ),
      Provider<ExerciseRepository>(
        create: (ctx) => ExerciseRepository(ctx.read<AppDatabase>()),
      ),
      Provider<SessionRepository>(
        create: (ctx) => SessionRepository(ctx.read<AppDatabase>()),
      ),
      Provider<ProgressRepository>(
        create: (ctx) => ProgressRepository(ctx.read<AppDatabase>()),
      ),

      // ── App-wide ViewModels ──────────────────────────────────────
      ChangeNotifierProvider<AuthViewModel>(
        create: (ctx) => AuthViewModel(ctx.read<AuthRepository>()),
      ),
      ChangeNotifierProvider<AccessibilityViewModel>(
        create: (ctx) =>
            AccessibilityViewModel(ctx.read<LocalStore>())..loadSettings(),
      ),
      ChangeNotifierProvider<SpeechService>(
        create: (_) => SpeechService()..init(),
      ),
      ChangeNotifierProvider<ProgressViewModel>(
        create: (ctx) =>
            ProgressViewModel(ctx.read<ProgressRepository>())..loadDashboard(),
      ),

      // ── Sync Service ─────────────────────────────────────────────
      ChangeNotifierProvider<SyncService>(
        create: (ctx) => SyncService(
          ctx.read<AppDatabase>(),
          ctx.read<ExerciseRepository>(),
        )..startListening(),
      ),

      // ── Notification Service (Module 14) ─────────────────────────
      ChangeNotifierProvider<NotificationService>(
        create: (ctx) =>
            NotificationService(ctx.read<LocalStore>())..init(),
      ),

      // ── Gamification Service (Module 14) ─────────────────────────
      Provider<GamificationService>(
        create: (ctx) => GamificationService(
          ctx.read<AppDatabase>(),
          ctx.read<LocalStore>(),
        ),
      ),
    ];


