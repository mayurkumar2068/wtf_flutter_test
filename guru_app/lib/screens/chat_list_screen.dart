import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wtf_shared/wtf_shared.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key, required this.currentUser});

  final User currentUser;

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen>
    with ListRefreshMixin {
  User? _trainer;
  String? _chatId;

  @override
  void initState() {
    super.initState();
    _loadTrainer();
  }

  Future<void> _loadTrainer() async {
    final users = await ref.read(usersProvider.future);
    final trainer = users.firstWhere(
      (u) => u.id == widget.currentUser.assignedTrainerId,
      orElse: () => users.firstWhere((u) => u.role == UserRole.trainer),
    );
    final chatId =
        ref.read(authServiceProvider).chatIdFor(widget.currentUser, trainer);
    if (!mounted) return;
    setState(() {
      _trainer = trainer;
      _chatId = chatId;
    });
    registerAutoRefresh(() {
      if (_chatId != null) refreshChatMessages(ref, _chatId!);
    });
  }

  Future<void> _openChat(User trainer) async {
    await AppRouter.openConversation(
      context,
      me: widget.currentUser,
      peer: trainer,
    );
    if (_chatId != null) {
      refreshChatMessages(ref, _chatId!);
      refreshChatUnread(
        ref,
        ChatUnreadParams(
          userId: widget.currentUser.id,
          chatId: _chatId!,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final trainer = _trainer;
    final chatId = _chatId;
    final primary = Theme.of(context).colorScheme.primary;

    if (trainer == null || chatId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final messagesAsync = ref.watch(chatMessagesProvider(chatId));

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: const Text(AppStrings.messages),
        actions: [
          IconButton(
            icon: Icon(Icons.edit_rounded, color: primary),
            onPressed: () => _openChat(trainer),
          ),
        ],
      ),
      body: messagesAsync.when(
        skipLoadingOnReload: true,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text(AppStrings.syncOffline)),
        data: (msgs) {
          final last = msgs.isNotEmpty ? msgs.last : null;
          final unread = msgs
              .where((m) =>
                  m.receiverId == widget.currentUser.id &&
                  m.status != MessageStatus.read)
              .length;

          return RefreshIndicator(
            onRefresh: () => refreshChatMessages(ref, chatId),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ChatListTile(
                  peer: trainer,
                  lastMessage: last,
                  unread: unread,
                  onTap: () => _openChat(trainer),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
