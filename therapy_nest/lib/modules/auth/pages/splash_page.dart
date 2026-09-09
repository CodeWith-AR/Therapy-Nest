import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/config/app_config.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/routes/route_guards.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../viewmodels/auth_view_model.dart';

/// Splash screen — shows logo, checks auth, redirects.
/// Displays for a minimum of [AppConfig.splashDurationMs].
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    _scaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );

    _animController.forward();
    // Defer auth check so notifyListeners() doesn't fire during build
    WidgetsBinding.instance.addPostFrameCallback((_) => _initApp());
  }

  Future<void> _initApp() async {
    final stopwatch = Stopwatch()..start();

    // Check auth status
    await context.read<AuthViewModel>().checkAuth();

    // Ensure minimum display time
    final elapsed = stopwatch.elapsedMilliseconds;
    if (elapsed < AppConfig.splashDurationMs) {
      await Future.delayed(
        Duration(milliseconds: AppConfig.splashDurationMs - elapsed),
      );
    }

    if (!mounted) return;

    final authVM = context.read<AuthViewModel>();

    if (authVM.isLoggedIn) {
      final destination = await resolvePostAuthRoute(context);
      if (!mounted) return;
      context.go(destination);
    } else {
      context.go(AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceWhite,
      body: Center(
        child: AnimatedBuilder(
          animation: _animController,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnim.value,
              child: Transform.scale(
                scale: _scaleAnim.value,
                child: child,
              ),
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo
              Image.asset(
                AppAssets.logo,
                width: 120,
                height: 120,
              ),
              const SizedBox(height: AppDimens.d24),
              // App name
              Text(
                AppStrings.appName,
                style: AppTextStyles.displayLg.copyWith(
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppDimens.d8),
              // Tagline
              Text(
                AppStrings.appTagline,
                style: AppTextStyles.bodyMd.copyWith(
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
