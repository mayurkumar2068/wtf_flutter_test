import 'package:flutter/material.dart';

import '../utils/app_decorations.dart';
import '../utils/app_theme.dart';

class RoleAppBar extends StatelessWidget implements PreferredSizeWidget {
  const RoleAppBar({
    super.key,
    required this.title,
    required this.roleLabel,
    this.actions,
    this.leading,
  });

  final String title;
  final String roleLabel;
  final List<Widget>? actions;
  final Widget? leading;

  @override
  Size get preferredSize => const Size.fromHeight(88);

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return AppBar(
      leading: leading,
      toolbarHeight: 88,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              AppColors.neutral50,
            ],
          ),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              gradient: AppDecorations.headerGradient(primary),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              roleLabel,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
      actions: actions,
    );
  }
}
