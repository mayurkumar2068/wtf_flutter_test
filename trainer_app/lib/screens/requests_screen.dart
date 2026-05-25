import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wtf_shared/wtf_shared.dart';

class RequestsScreen extends ConsumerStatefulWidget {
  const RequestsScreen({super.key, required this.trainer});

  final User trainer;

  @override
  ConsumerState<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends ConsumerState<RequestsScreen>
    with ListRefreshMixin {
  @override
  void initState() {
    super.initState();
    registerAutoRefresh(() => refreshCallRequests(ref, widget.trainer.id));
  }

  Future<void> _approve(CallRequest r) async {
    await ref
        .read(syncClientProvider)
        .updateCallRequest(r.id, status: 'approved');
    await refreshCallRequests(ref, widget.trainer.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Call approved for ${formatDateTime(r.scheduledFor)}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _decline(CallRequest r) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final c = TextEditingController();
        return AlertDialog(
          title: const Text(AppStrings.declineReason),
          content: TextField(
            controller: c,
            decoration: const InputDecoration(hintText: 'Reason'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(AppStrings.back),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, c.text),
              child: const Text(AppStrings.declined),
            ),
          ],
        );
      },
    );
    if (reason == null) return;
    await ref.read(syncClientProvider).updateCallRequest(
          r.id,
          status: 'declined',
          declineReason: reason.isEmpty ? 'Not available' : reason,
        );
    await refreshCallRequests(ref, widget.trainer.id);
  }

  @override
  Widget build(BuildContext context) {
    final requestsAsync = ref.watch(callRequestsProvider(widget.trainer.id));

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(title: const Text(AppStrings.requests)),
      body: requestsAsync.when(
        skipLoadingOnReload: true,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text(AppStrings.syncOffline)),
        data: (all) {
          final pending =
              all.where((r) => r.status == CallRequestStatus.pending).toList();

          return RefreshIndicator(
            onRefresh: () => refreshCallRequests(ref, widget.trainer.id),
            child: pending.isEmpty
                ? ListView(
                    children: const [
                      SizedBox(height: 80),
                      Center(child: Text(AppStrings.noPendingRequests)),
                    ],
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: pending.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => _PendingRequestCard(
                      request: pending[i],
                      onApprove: () => _approve(pending[i]),
                      onDecline: () => _decline(pending[i]),
                    ),
                  ),
          );
        },
      ),
    );
  }
}

class _PendingRequestCard extends StatelessWidget {
  const _PendingRequestCard({
    required this.request,
    required this.onApprove,
    required this.onDecline,
  });

  final CallRequest request;
  final VoidCallback onApprove;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: AppDecorations.surfaceCard(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'DK — ${formatDateTime(request.scheduledFor)}',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            if (request.note != null) ...[
              const SizedBox(height: 6),
              Text(request.note!),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onDecline,
                    child: const Text(AppStrings.declined),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: onApprove,
                    style: FilledButton.styleFrom(backgroundColor: primary),
                    child: const Text(AppStrings.approve),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
