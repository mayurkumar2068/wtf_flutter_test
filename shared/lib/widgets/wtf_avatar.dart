import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

/// Avatar without repeated network decode on parent rebuilds.
class WtfAvatar extends StatelessWidget {
  const WtfAvatar({
    super.key,
    this.url,
    this.radius = 24,
    this.fallbackIcon = Icons.person_rounded,
  });

  final String? url;
  final double radius;
  final IconData fallbackIcon;

  @override
  Widget build(BuildContext context) {
    final trimmed = url?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.neutral100,
        child: Icon(fallbackIcon, size: radius, color: AppColors.neutral500),
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.neutral100,
      child: ClipOval(
        child: Image.network(
          trimmed,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          gaplessPlayback: true,
          filterQuality: FilterQuality.low,
          errorBuilder: (_, __, ___) => Icon(
            fallbackIcon,
            size: radius,
            color: AppColors.neutral500,
          ),
        ),
      ),
    );
  }
}
