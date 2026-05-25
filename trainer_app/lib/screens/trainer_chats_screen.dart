import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wtf_shared/wtf_shared.dart';

class TrainerChatsScreen extends ConsumerStatefulWidget {
  const TrainerChatsScreen({super.key, required this.trainer});

  final User trainer;

  @override
  ConsumerState<TrainerChatsScreen> createState() => _TrainerChatsScreenState();
}

class _TrainerChatsScreenState extends ConsumerState<TrainerChatsScreen>
    with ListRefreshMixin {
  User? _dk;
  String? _chatId;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final users = await ref.read(usersProvider.future);
    final dk = users.firstWhere((u) => u.id == 'member_dk');
    final chatId =
        ref.read(authServiceProvider).chatIdFor(widget.trainer, dk);
    if (!mounted) return;
    setState(() {
      _dk = dk;
      _chatId = chatId;
    });
    registerAutoRefresh(() {
      if (_chatId != null) refreshChatMessages(ref, _chatId!);
    });
  }

  Future<void> _openChat(User peer) async {
    await AppRouter.openConversation(
      context,
      me: widget.trainer,
      peer: peer,
    );
    if (_chatId != null) {
      refreshChatMessages(ref, _chatId!);
      refreshChatUnread(
        ref,
        ChatUnreadParams(userId: widget.trainer.id, chatId: _chatId!),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dk = _dk;
    final chatId = _chatId;

    if (dk == null || chatId == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final messagesAsync = ref.watch(chatMessagesProvider(chatId));

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(title: const Text(AppStrings.chats)),
      body: messagesAsync.when(
        skipLoadingOnReload: true,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text(AppStrings.syncOffline)),
        data: (msgs) {
          final last = msgs.isNotEmpty ? msgs.last : null;
          final unread = msgs
              .where((m) =>
                  m.receiverId == widget.trainer.id &&
                  m.status != MessageStatus.read)
              .length;

          return RefreshIndicator(
            onRefresh: () => refreshChatMessages(ref, chatId),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ChatListTile(
                  peer: dk,
                  lastMessage: last,
                  unread: unread,
                  onTap: () => _openChat(dk),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
