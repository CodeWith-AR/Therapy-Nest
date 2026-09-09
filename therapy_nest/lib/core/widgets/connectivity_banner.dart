import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimens.dart';
import '../constants/app_motion.dart';
import '../constants/app_text_styles.dart';
import '../services/sync_service.dart';

// ═══════════════════════════════════════════════════════════════════════
// CONNECTIVITY BANNER
// ═══════════════════════════════════════════════════════════════════════

/// A slim, non-blocking banner that slides in/out to indicate
/// offline status or active syncing.
///
/// - **Offline**: amber background — "Offline mode — syncing when connected"
/// - **Syncing**: green dot + "Syncing..." text
/// - **Online**: completely hidden (collapses to 0 height, taking zero space)
///
/// Usage: Place above the main content via a [Column] or [Stack].
/// It reactively watches [SyncService] via Provider.
class ConnectivityBanner extends StatelessWidget {
  const ConnectivityBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final status = context.watch<SyncService>().status;
    final isVisible = status != ConnectivityStatus.online;

    return ClipRect(
      child: AnimatedCrossFade(
        firstChild: _buildBannerContent(status),
        secondChild: const SizedBox(width: double.infinity, height: 0),
        crossFadeState:
            isVisible ? CrossFadeState.showFirst : CrossFadeState.showSecond,
        duration: AppMotion.dMedium,
        firstCurve: AppMotion.easeDefault,
        secondCurve: AppMotion.easeIn,
        sizeCurve: AppMotion.easeInOut,
      ),
    );
  }

  Widget _buildBannerContent(ConnectivityStatus status) {
    final bool isOffline = status == ConnectivityStatus.offline;

    final Color backgroundColor = isOffline
        ? AppColors.warning.withValues(alpha: 0.12)
        : AppColors.success.withValues(alpha: 0.12);

    final Color borderColor = isOffline
        ? AppColors.warning.withValues(alpha: 0.3)
        : AppColors.success.withValues(alpha: 0.3);

    final Color textColor = isOffline ? AppColors.warning : AppColors.success;

    final IconData icon = isOffline ? Icons.cloud_off_rounded : Icons.sync_rounded;

    final String message = isOffline
        ? 'Offline mode — syncing when connected'
        : 'Syncing...';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.d16,
        vertical: AppDimens.d8,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(
          bottom: BorderSide(color: borderColor, width: 1),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated icon — spinning for sync, static for offline.
            _StatusIcon(icon: icon, isSyncing: !isOffline),
            const SizedBox(width: AppDimens.d8),
            Text(
              message,
              style: AppTextStyles.caption.copyWith(color: textColor),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// STATUS ICON (spinning when syncing)
// ═══════════════════════════════════════════════════════════════════════

class _StatusIcon extends StatefulWidget {
  const _StatusIcon({required this.icon, required this.isSyncing});

  final IconData icon;
  final bool isSyncing;

  @override
  State<_StatusIcon> createState() => _StatusIconState();
}

class _StatusIconState extends State<_StatusIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    if (widget.isSyncing) _controller.repeat();
  }

  @override
  void didUpdateWidget(covariant _StatusIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSyncing && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isSyncing && _controller.isAnimating) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isSyncing) {
      return Icon(widget.icon, size: AppDimens.iconSm, color: AppColors.warning);
    }

    return RotationTransition(
      turns: _controller,
      child: Icon(widget.icon, size: AppDimens.iconSm, color: AppColors.success),
    );
  }
}
