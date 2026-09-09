import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_dimens.dart';
import '../core/theme/theme.dart';
import '../modules/auth/viewmodels/auth_view_model.dart';
import '../modules/settings/viewmodels/accessibility_view_model.dart';
import 'routes/app_router.dart';

/// Root application widget.
class TherapyNestApp extends StatefulWidget {
  const TherapyNestApp({super.key});

  @override
  State<TherapyNestApp> createState() => _TherapyNestAppState();
}

class _TherapyNestAppState extends State<TherapyNestApp> {
  late final _router = createRouter(context.read<AuthViewModel>());

  @override
  Widget build(BuildContext context) {
    // Watch accessibility settings so the entire tree rebuilds
    // when text scale, high contrast, or dark mode changes.
    final a11y = context.watch<AccessibilityViewModel>();
    AppColors.isHighContrast = a11y.highContrastMode;
    AppColors.isDarkMode = a11y.isDarkMode;
    AppDimens.touchScale = a11y.touchTargetScale;

    return MaterialApp.router(
      title: 'Therapy Nest',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(
        highContrast: a11y.highContrastMode,
        touchTargetScale: a11y.touchTargetScale,
      ),
      darkTheme: buildAppTheme(
        highContrast: a11y.highContrastMode,
        isDark: true,
        touchTargetScale: a11y.touchTargetScale,
      ),
      themeMode: a11y.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      routerConfig: _router,
      builder: (context, child) {
        // Override the system text scale and motion preference with user settings.
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(a11y.textScaleFactor),
            disableAnimations: a11y.reduceMotion,
          ),
          child: child!,
        );
      },
    );
  }
}
