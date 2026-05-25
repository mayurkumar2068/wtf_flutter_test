import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/auth_service.dart';
import '../services/call_service.dart';
import '../services/chat_service.dart';
import '../services/sync_client.dart';
import '../utils/api_config.dart';
import 'sync_host_provider.dart';

final apiConfigProvider = Provider<ApiConfig>((ref) => ApiConfig());

final syncClientProvider = Provider<SyncClient>((ref) {
  final client = SyncClient();
  ref.onDispose(client.dispose);
  return client;
});

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final chatServiceProvider = Provider<ChatService>((ref) {
  final chat = ChatService(
    ref.watch(syncClientProvider),
    ref.watch(authServiceProvider),
  );
  ref.onDispose(chat.dispose);
  return chat;
});

final callServiceProvider = Provider<CallService>((ref) {
  final call = CallService(ref.watch(syncClientProvider));
  ref.onDispose(call.dispose);
  return call;
});

/// @deprecated Use [syncHostProvider] from sync_host_provider.dart
final serverOnlineProvider = Provider<AsyncValue<bool>>(
  (ref) => ref.watch(syncHostProvider),
);
