import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_motion.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/connectivity_banner.dart';
import '../../modules/settings/viewmodels/accessibility_view_model.dart';
import 'app_routes.dart';

/// Centralized navigation shell wrapping all tabbed content.
///
/// Implements per skillV3.md:
/// - **Rule E**: Persistent bottom nav with 2 tabs (Home, Progress).
/// - **Rule F**: Centralized [PopScope] back handler.
/// - **Rule G**: Facebook-pattern icon-only bottom nav with [_BouncyNavIcon].
/// - **Rule H**: Directional branch slide via [SharedAxisTransition].
class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.navigationShell,
    required this.branchNavigatorKeys,
  });

  final StatefulNavigationShell navigationShell;
  final List<GlobalKey<NavigatorState>> branchNavigatorKeys;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _previousIndex = 0;

  @override
  Widget build(BuildContext context) {
    final a11y = context.watch<AccessibilityViewModel>();
    final isDark = a11y.isDarkMode;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _handleBackButton();
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        // ── Top App Bar (Only shown on Home tab) ───────────────────
        appBar: widget.navigationShell.currentIndex == 0
            ? AppBar(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                elevation: 0,
                scrolledUnderElevation: 0,
                toolbarHeight: 62,
                automaticallyImplyLeading: false,
                centerTitle: false,
                titleSpacing: AppDimens.d16,
                title: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.asset(
                          AppAssets.appBarLogo,
                          width: 46,
                          height: 46,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 46,
                              height: 46,
                              color: AppColors.primary,
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.psychology_rounded,
                                color: AppColors.onPrimary,
                                size: 26,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimens.d12),
                    Text(
                      AppStrings.appName,
                      style: AppTextStyles.displayMd.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 23,
                      ),
                    ),
                  ],
                ),
                actions: [
                  // Moon / Sun icon — dark mode toggle
                  IconButton(
                    icon: Icon(
                      isDark
                          ? Icons.light_mode_rounded
                          : Icons.dark_mode_rounded,
                      color: Theme.of(context).colorScheme.onSurface,
                      size: AppDimens.iconMd,
                    ),
                    tooltip:
                        isDark ? 'Switch to light mode' : 'Switch to dark mode',
                    onPressed: () => a11y.toggleDarkMode(),
                  ),
                  // Settings gear icon
                  IconButton(
                    icon: Icon(
                      Icons.settings_outlined,
                      color: Theme.of(context).colorScheme.onSurface,
                      size: AppDimens.iconMd,
                    ),
                    tooltip: 'Settings',
                    onPressed: () => context.push(AppRoutes.settings),
                  ),
                  const SizedBox(width: AppDimens.d4),
                ],
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(1.0),
                  child: Container(
                    color: AppColors.hairlineSoft,
                    height: 1.0,
                  ),
                ),
              )
            : null,
        // ── Body with connectivity banner + branch transition ────────
        body: Column(
          children: [
            const ConnectivityBanner(),
            Expanded(
              child: _BranchTransition(
                currentIndex: widget.navigationShell.currentIndex,
                previousIndex: _previousIndex,
                child: widget.navigationShell,
              ),
            ),
          ],
        ),
        // ── Bottom Navigation Bar ────────────────────────────────────
        bottomNavigationBar: _buildBottomNav(context),
      ),
    );
  }

  /// Centralized back-button handler per skillV3.md Rule F:
  /// 1. If active tab has pushed routes (e.g. DomainDetailPage) → pop it first.
  /// 2. If not on Home tab (index 0) → switch to Home tab.
  /// 3. If on Home root → exit app.
  void _handleBackButton() {
    final currentIndex = widget.navigationShell.currentIndex;
    final currentKey = currentIndex < widget.branchNavigatorKeys.length
        ? widget.branchNavigatorKeys[currentIndex]
        : null;
    final canPop = currentKey?.currentState?.canPop() ?? false;

    debugPrint(
      '[AppShell] back-button: tab=$currentIndex, branchCanPop=$canPop',
    );

    // 1. If active tab's navigator can pop, pop the child route
    if (canPop) {
      debugPrint('[AppShell] back-button: popping active tab child route');
      currentKey!.currentState!.pop();
      return;
    }

    // 2. If not on Home tab (index 0), switch to Home tab
    if (currentIndex != 0) {
      debugPrint('[AppShell] back-button: switching to Home tab (index 0)');
      _onTabTap(0);
      return;
    }

    // 3. On Home root → exit app
    debugPrint('[AppShell] back-button: on Home root, exiting app');
    SystemNavigator.pop();
  }

  void _onTabTap(int index) {
    setState(() {
      _previousIndex = widget.navigationShell.currentIndex;
    });
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    final currentIndex = widget.navigationShell.currentIndex;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceCard : AppColors.surfaceWhite,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkHairline : AppColors.hairline,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 56,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _BouncyNavIcon(
                icon: Icons.home_rounded,
                label: 'Home',
                isSelected: currentIndex == 0,
                onTap: () => _onTabTap(0),
              ),
              _BouncyNavIcon(
                icon: Icons.analytics_rounded,
                label: 'Progress',
                isSelected: currentIndex == 1,
                onTap: () => _onTabTap(1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Branch Transition (Rule H) ─────────────────────────────────────────
/// Wraps the navigation shell with a directional slide transition.
/// Left-to-right when moving to a higher index; right-to-left for lower.
class _BranchTransition extends StatelessWidget {
  const _BranchTransition({
    required this.currentIndex,
    required this.previousIndex,
    required this.child,
  });

  final int currentIndex;
  final int previousIndex;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PageTransitionSwitcher(
      duration: AppMotion.sharedAxis,
      reverse: currentIndex < previousIndex,
      transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
        return SharedAxisTransition(
          animation: primaryAnimation,
          secondaryAnimation: secondaryAnimation,
          transitionType: SharedAxisTransitionType.horizontal,
          child: child,
        );
      },
      child: child,
    );
  }
}

// ── Bouncy Nav Icon (Rule G) ───────────────────────────────────────────
/// Facebook-pattern icon-only navigation item with a scale bounce animation.
/// Uses [AppMotion.navBounce] and [AppMotion.bounceCurve].
class _BouncyNavIcon extends StatefulWidget {
  const _BouncyNavIcon({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_BouncyNavIcon> createState() => _BouncyNavIconState();
}

class _BouncyNavIconState extends State<_BouncyNavIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppMotion.navBounce,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(
        parent: _controller,
        curve: AppMotion.bounceCurve,
      ),
    );
  }

  @override
  void didUpdateWidget(covariant _BouncyNavIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected && !oldWidget.isSelected) {
      _controller.forward().then((_) => _controller.reverse());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isSelected
        ? AppColors.primary
        : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5);

    return Expanded(
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _scaleAnimation,
              child: Icon(
                widget.icon,
                size: AppDimens.iconMd,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              widget.label,
              style: AppTextStyles.caption.copyWith(
                color: color,
                fontWeight: widget.isSelected
                    ? FontWeight.w600
                    : FontWeight.w400,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
