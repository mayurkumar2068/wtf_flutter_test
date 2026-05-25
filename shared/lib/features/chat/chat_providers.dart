import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/message.dart';
import '../../models/user.dart';
import '../../providers/app_providers.dart';
import '../../services/auth_service.dart';

final chatMessagesProvider =
    AsyncNotifierProvider.family<ChatMessagesNotifier, List<Message>, String>(
  ChatMessagesNotifier.new,
);

class ChatMessagesNotifier extends FamilyAsyncNotifier<List<Message>, String> {
  @override
  Future<List<Message>> build(String chatId) => _fetch(chatId);

  Future<List<Message>> _fetch(String chatId) =>
      ref.read(syncClientProvider).fetchMessages(chatId);

  Future<void> silentRefresh() async {
    final previous = state;
    try {
      state = AsyncData(await _fetch(arg));
    } catch (e, st) {
      if (!previous.hasValue) {
        state = AsyncError<List<Message>>(e, st);
      }
    }
  }
}

Future<void> refreshChatMessages(WidgetRef ref, String chatId) =>
    ref.read(chatMessagesProvider(chatId).notifier).silentRefresh();

Future<void> markChatReadIfNeeded(
  WidgetRef ref, {
  required String chatId,
  required String readerId,
}) async {
  final msgs = await ref.read(syncClientProvider).fetchMessages(chatId);
  final hasUnread = msgs.any(
    (m) => m.receiverId == readerId && m.status != MessageStatus.read,
  );
  if (!hasUnread) return;
  await ref.read(chatServiceProvider).markRead(chatId, readerId);
  await ref.read(chatMessagesProvider(chatId).notifier).silentRefresh();
}

String chatIdForUsers(AuthService auth, User a, User b) => auth.chatIdFor(a, b);

class ChatUnreadParams {
  const ChatUnreadParams({required this.userId, required this.chatId});

  final String userId;
  final String chatId;

  @override
  bool operator ==(Object other) =>
      other is ChatUnreadParams &&
      other.userId == userId &&
      other.chatId == chatId;

  @override
  int get hashCode => Object.hash(userId, chatId);
}

final chatUnreadProvider =
    FutureProvider.family<int, ChatUnreadParams>((ref, params) async {
  final msgs =
      await ref.watch(syncClientProvider).fetchMessages(params.chatId);
  return msgs
      .where((m) =>
          m.receiverId == params.userId && m.status != MessageStatus.read)
      .length;
});

void refreshChatUnread(WidgetRef ref, ChatUnreadParams params) {
  ref.invalidate(chatUnreadProvider(params));
}
