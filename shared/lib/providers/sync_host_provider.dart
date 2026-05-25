import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/sync_host_resolver.dart';

final syncHostProvider =
    AsyncNotifierProvider<SyncHostNotifier, bool>(SyncHostNotifier.new);

class SyncHostNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() => SyncHostResolver.resolve();

  Future<bool> retry() async {
    SyncHostResolver.reset();
    state = const AsyncLoading();
    final ok = await SyncHostResolver.resolve();
    state = AsyncData(ok);
    return ok;
  }
}
