import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wtf_shared/wtf_shared.dart';

class SessionsScreen extends ConsumerStatefulWidget {
  const SessionsScreen({
    super.key,
    required this.user,
    required this.isTrainer,
  });

  final User user;
  final bool isTrainer;

  @override
  ConsumerState<SessionsScreen> createState() => _SessionsScreenState();
}

class _SessionsScreenState extends ConsumerState<SessionsScreen>
    with ListRefreshMixin {
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    registerAutoRefresh(() => refreshSessions(ref, widget.user.id));
  }

  List<SessionLog> _filtered(List<SessionLog> sessions) {
    final now = DateTime.now();
    switch (_filter) {
      case '7d':
        return sessions
            .where((s) => now.difference(s.startedAt).inDays <= 7)
            .toList();
      case 'month':
        return sessions
            .where((s) =>
                s.startedAt.month == now.month && s.startedAt.year == now.year)
            .toList();
      default:
        return sessions;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionsAsync = ref.watch(sessionsListProvider(widget.user.id));

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(title: const Text(AppStrings.sessions)),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _chip(AppStrings.filterAll, 'all'),
                _chip(AppStrings.filter7d, '7d'),
                _chip(AppStrings.filterMonth, 'month'),
              ],
            ),
          ),
          Expanded(
            child: sessionsAsync.when(
              skipLoadingOnReload: true,
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Center(child: Text(AppStrings.syncOffline)),
              data: (sessions) {
                final filtered = _filtered(sessions);
                if (filtered.isEmpty) {
                  return EmptyState(
                    title: AppStrings.noSessionsTitle,
                    subtitle: AppStrings.noSessionsSubtitle,
                    icon: Icons.event_note_outlined,
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async => refreshSessions(ref, widget.user.id),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final s = filtered[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: AppDecorations.surfaceCard(),
                        child: ListTile(
                          title: Text(formatDateTime(s.startedAt)),
                          subtitle: Text(formatDuration(s.durationSec)),
                          trailing: s.rating != null
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.star_rounded,
                                        color: AppColors.warning, size: 18),
                                    Text('${s.rating}'),
                                  ],
                                )
                              : null,
                          onTap: () => _showDetail(s),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: sessionsAsync.maybeWhen(
        data: (sessions) {
          if (sessions.isEmpty) return null;
          return FloatingActionButton.small(
            onPressed: () {
              final summary = _filtered(sessions)
                  .map((s) =>
                      '${formatDateTime(s.startedAt)} — ${formatDuration(s.durationSec)}')
                  .join('\n');
              Share.share('WTF Session Summary\n$summary');
            },
            child: const Icon(Icons.share_outlined),
          );
        },
        orElse: () => null,
      ),
    );
  }

  Widget _chip(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: WtfChip(
        label: label,
        selected: _filter == value,
        onTap: () => setState(() => _filter = value),
      ),
    );
  }

  void _showDetail(SessionLog s) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(formatDateTime(s.startedAt)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Duration: ${formatDuration(s.durationSec)}'),
            if (s.rating != null) Text('Rating: ${s.rating}/5'),
            if (s.memberNotes != null) Text('Member: ${s.memberNotes}'),
            if (s.trainerNotes != null) Text('Trainer: ${s.trainerNotes}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(AppStrings.close),
          ),
        ],
      ),
    );
  }
}
