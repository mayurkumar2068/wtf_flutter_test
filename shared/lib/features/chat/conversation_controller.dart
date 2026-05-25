import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/call_request.dart';
import '../../models/message.dart';
import '../../models/user.dart';
import '../../providers/app_providers.dart';
import '../../utils/time_utils.dart';

/// Live conversation state: messages + typing + joinable call (single source).
class ConversationState {
  const ConversationState({
    this.messages = const [],
    this.peerTyping = false,
    this.joinableCall,
    this.loading = true,
  });

  final List<Message> messages;
  final bool peerTyping;
  final CallRequest? joinableCall;
  final bool loading;

  ConversationState copyWith({
    List<Message>? messages,
    bool? peerTyping,
    CallRequest? joinableCall,
    bool? loading,
    bool clearJoinable = false,
  }) =>
      ConversationState(
        messages: messages ?? this.messages,
        peerTyping: peerTyping ?? this.peerTyping,
        joinableCall: clearJoinable ? null : (joinableCall ?? this.joinableCall),
        loading: loading ?? this.loading,
      );
}

class ConversationParams {
  const ConversationParams({
    required this.chatId,
    required this.me,
    required this.peer,
    this.upcomingCall,
  });

  final String chatId;
  final User me;
  final User peer;
  final CallRequest? upcomingCall;

  @override
  bool operator ==(Object other) =>
      other is ConversationParams &&
      other.chatId == chatId &&
      other.me.id == me.id &&
      other.peer.id == peer.id;

  @override
  int get hashCode => Object.hash(chatId, me.id, peer.id);
}

final conversationControllerProvider = StateNotifierProvider.autoDispose
    .family<ConversationController, ConversationState, ConversationParams>(
  (ref, params) => ConversationController(ref, params),
);

class ConversationController extends StateNotifier<ConversationState> {
  ConversationController(this.ref, this.params)
      : super(const ConversationState()) {
    _init();
  }

  final Ref ref;
  final ConversationParams params;
  StreamSubscription? _typingSub;
  StreamSubscription? _pollSub;
  Timer? _reloadDebounce;
  String? _lastReadHash;

  Future<void> _init() async {
    final chat = ref.read(chatServiceProvider);
    chat.startSync(params.chatId, params.me.id);
    _typingSub = chat.peerTyping.listen((v) {
      if (mounted) state = state.copyWith(peerTyping: v);
    });
    _pollSub = ref.read(syncClientProvider).events.listen((_) {
      _scheduleReload();
    });
    await reload(markRead: true);
    await _resolveJoinable();
  }

  void _scheduleReload() {
    _reloadDebounce?.cancel();
    _reloadDebounce = Timer(const Duration(milliseconds: 350), () {
      reload();
    });
  }

  Future<void> reload({bool markRead = false}) async {
    if (!mounted) return;
    state = state.copyWith(loading: state.messages.isEmpty);
    try {
      final list =
          await ref.read(syncClientProvider).fetchMessages(params.chatId);
      if (!mounted) return;
      state = state.copyWith(messages: list, loading: false);
      if (markRead) await _markUnreadIfNeeded(list);
      await _resolveJoinable();
    } catch (_) {
      if (mounted) state = state.copyWith(loading: false);
    }
  }

  Future<void> _markUnreadIfNeeded(List<Message> msgs) async {
    final unread = msgs.where(
      (m) =>
          m.receiverId == params.me.id && m.status != MessageStatus.read,
    );
    if (unread.isEmpty) return;
    final hash = unread.map((m) => m.id).join(',');
    if (hash == _lastReadHash) return;
    _lastReadHash = hash;
    await ref.read(chatServiceProvider).markRead(params.chatId, params.me.id);
  }

  Future<void> _resolveJoinable() async {
    final requests = await ref
        .read(syncClientProvider)
        .fetchCallRequests(userId: params.me.id);
    CallRequest? joinable;
    for (final r in requests) {
      if (r.status == CallRequestStatus.approved && canJoinCall(r.scheduledFor)) {
        joinable = r;
        break;
      }
    }
    joinable ??= params.upcomingCall != null &&
            canJoinCall(params.upcomingCall!.scheduledFor)
        ? params.upcomingCall
        : null;
    if (mounted) state = state.copyWith(joinableCall: joinable);
  }

  Future<void> sendText(String text, {String? imageUrl}) async {
    await ref.read(chatServiceProvider).sendText(
          sender: params.me,
          receiver: params.peer,
          text: text,
          imageUrl: imageUrl,
        );
    await reload();
  }

  Future<void> sendImageFromFile(String localPath) async {
    final url = await ref.read(syncClientProvider).uploadChatImage(localPath);
    await sendText('📷 Photo', imageUrl: url);
  }

  @override
  void dispose() {
    _reloadDebounce?.cancel();
    _typingSub?.cancel();
    _pollSub?.cancel();
    ref.read(chatServiceProvider).stopSync();
    super.dispose();
  }
}
