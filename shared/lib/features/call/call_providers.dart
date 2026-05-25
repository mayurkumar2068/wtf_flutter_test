import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/call_request.dart';
import '../../providers/app_providers.dart';

final callRequestsProvider = AsyncNotifierProvider.family<
    CallRequestsNotifier, List<CallRequest>, String?>(
  CallRequestsNotifier.new,
);

class CallRequestsNotifier
    extends FamilyAsyncNotifier<List<CallRequest>, String?> {
  @override
  Future<List<CallRequest>> build(String? userId) => _fetch(userId);

  Future<List<CallRequest>> _fetch(String? userId) =>
      ref.read(syncClientProvider).fetchCallRequests(userId: userId);

  /// Refresh without flashing a full-screen loader.
  Future<void> silentRefresh() async {
    final previous = state;
    try {
      state = AsyncData(await _fetch(arg));
    } catch (e, st) {
      if (!previous.hasValue) {
        state = AsyncError<List<CallRequest>>(e, st);
      }
    }
  }
}

Future<void> refreshCallRequests(WidgetRef ref, String? userId) =>
    ref.read(callRequestsProvider(userId).notifier).silentRefresh();
