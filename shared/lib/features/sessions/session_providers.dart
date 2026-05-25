import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/session_log.dart';
import '../../providers/app_providers.dart';

final sessionsListProvider = AsyncNotifierProvider.family<
    SessionsListNotifier, List<SessionLog>, String?>(
  SessionsListNotifier.new,
);

class SessionsListNotifier
    extends FamilyAsyncNotifier<List<SessionLog>, String?> {
  @override
  Future<List<SessionLog>> build(String? userId) => _fetch(userId);

  Future<List<SessionLog>> _fetch(String? userId) =>
      ref.read(syncClientProvider).fetchSessions(userId: userId);

  Future<void> silentRefresh() async {
    final previous = state;
    try {
      state = AsyncData(await _fetch(arg));
    } catch (e, st) {
      if (!previous.hasValue) {
        state = AsyncError<List<SessionLog>>(e, st);
      }
    }
  }
}

Future<void> refreshSessions(WidgetRef ref, String? userId) =>
    ref.read(sessionsListProvider(userId).notifier).silentRefresh();
