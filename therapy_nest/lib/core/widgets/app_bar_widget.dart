import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimens.dart';
import '../constants/app_text_styles.dart';

/// Consistent app bar with back button and optional action support.
class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  const AppBarWidget({
    super.key,
    required this.title,
    this.showBack = true,
    this.actions,
    this.onBack,
    this.centerTitle = true,
    this.backgroundColor,
  });

  final String title;
  final bool showBack;
  final List<Widget>? actions;
  final VoidCallback? onBack;
  final bool centerTitle;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: AppTextStyles.appBarTitle.copyWith(color: AppColors.ink),
      ),
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? AppColors.surfaceWhite,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      leading: showBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: AppDimens.iconMd),
              onPressed: onBack ?? () => Navigator.of(context).maybePop(),
            )
          : null,
      automaticallyImplyLeading: showBack,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
