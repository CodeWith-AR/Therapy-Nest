import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimens.dart';
import '../constants/app_text_styles.dart';

/// User/entity avatar with fallback initials.
class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.size = AppDimens.d48,
  });

  final String? imageUrl;
  final String? name;
  final double size;

  String get _initials {
    if (name == null || name!.isEmpty) return '?';
    final parts = name!.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.hairlineSoft, width: 1.5),
      ),
      child: imageUrl != null && imageUrl!.isNotEmpty
          ? ClipOval(
              child: Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _initialsWidget(),
              ),
            )
          : _initialsWidget(),
    );
  }

  Widget _initialsWidget() {
    return Center(
      child: Text(
        _initials,
        style: AppTextStyles.titleMd.copyWith(
          color: AppColors.primary,
          fontSize: size * 0.38,
        ),
      ),
    );
  }
}
