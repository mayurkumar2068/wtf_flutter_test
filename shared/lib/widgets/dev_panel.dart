import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/strings/app_strings.dart';
import '../utils/app_logger.dart';
import '../utils/app_theme.dart';
import '../utils/sync_host_resolver.dart';
import 'wtf_bottom_sheet.dart';

class DevPanelFab extends StatelessWidget {
  const DevPanelFab({
    super.key,
    required this.appName,
    required this.buildInfo,
    this.onReconnect,
    this.onSignOut,
  });

  final String appName;
  final String buildInfo;
  final Future<void> Function()? onReconnect;
  final VoidCallback? onSignOut;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 16,
      bottom: 24,
      child: FloatingActionButton(
        heroTag: 'dev_menu',
        elevation: 2,
        backgroundColor: AppColors.neutral900,
        onPressed: () => _openMenu(context),
        child: const Icon(Icons.more_horiz_rounded, color: Colors.white),
      ),
    );
  }

  void _openMenu(BuildContext context) {
    showWtfBottomSheet(
      context: context,
      title: AppStrings.account,
      subtitle: appName,
      children: [
        if (onReconnect != null)
          WtfSheetAction(
            icon: Icons.cloud_sync_rounded,
            label: AppStrings.reconnectServer,
            subtitle: SyncHostResolver.isResolved
                ? SyncHostResolver.baseUrl
                : AppStrings.syncOffline,
            onTap: () async {
              Navigator.pop(context);
              await onReconnect!();
            },
          ),
        if (onSignOut != null)
          WtfSheetAction(
            icon: Icons.logout_rounded,
            label: AppStrings.signOut,
            subtitle: AppStrings.signOutSubtitle,
            destructive: true,
            onTap: () {
              Navigator.pop(context);
              onSignOut!();
            },
          ),
        WtfSheetAction(
          icon: Icons.code_rounded,
          label: AppStrings.devTools,
          subtitle: 'Logs, API, build info',
          onTap: () {
            Navigator.pop(context);
            _openDevTools(context);
          },
        ),
      ],
    );
  }

  void _openDevTools(BuildContext context) {
    showWtfBottomSheet(
      context: context,
      title: AppStrings.devTools,
      subtitle: '$appName • $buildInfo',
      children: [
        _InfoRow(label: 'API', value: SyncHostResolver.baseUrl),
        _InfoRow(
          label: 'Status',
          value: SyncHostResolver.isResolved ? 'Online' : 'Offline',
          valueColor:
              SyncHostResolver.isResolved ? AppColors.success : AppColors.error,
        ),
        const SizedBox(height: 8),
        Text(
          SyncHostResolver.setupHint,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
        ),
        const SizedBox(height: 16),
        Text('Recent logs', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        ...AppLogger.instance.recent.reversed.take(12).map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  '[${e.tagLabel}] ${e.message}',
                  style: const TextStyle(fontSize: 11, color: AppColors.neutral700),
                ),
              ),
            ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: valueColor ?? AppColors.neutral900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void showErrorSnack(BuildContext context, String message, {String? detail}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      action: detail != null
          ? SnackBarAction(
              label: 'Copy',
              onPressed: () {
                Clipboard.setData(ClipboardData(text: detail));
              },
            )
          : null,
      backgroundColor: AppColors.error,
    ),
  );
}
