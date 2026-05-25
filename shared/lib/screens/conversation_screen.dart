import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wtf_shared/wtf_shared.dart';

class ConversationScreen extends ConsumerStatefulWidget {
  const ConversationScreen({
    super.key,
    required this.me,
    required this.peer,
    this.upcomingCall,
  });

  final User me;
  final User peer;
  final CallRequest? upcomingCall;

  @override
  ConsumerState<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends ConsumerState<ConversationScreen> {
  final _scrollController = ScrollController();
  late final ConversationParams _params;

  @override
  void initState() {
    super.initState();
    _params = ConversationParams(
      chatId: ref.read(authServiceProvider).chatIdFor(widget.me, widget.peer),
      me: widget.me,
      peer: widget.peer,
      upcomingCall: widget.upcomingCall,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(conversationControllerProvider(_params));
    final ctrl = ref.read(conversationControllerProvider(_params).notifier);
    final isMember = widget.me.role == UserRole.member;
    final colors = isMember ? AppColors.guru : AppColors.trainer;
    final primary = Theme.of(context).colorScheme.primary;

    ref.listen(conversationControllerProvider(_params), (prev, next) {
      if (prev?.messages.length != next.messages.length) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
          }
        });
      }
    });

    final unread = state.messages
        .where((m) =>
            m.receiverId == widget.me.id && m.status != MessageStatus.read)
        .length;

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: primary.withValues(alpha: 0.3), width: 2),
              ),
              child: CircleAvatar(
                radius: 22,
                backgroundImage: NetworkImage(widget.peer.avatarUrl ?? ''),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.peer.name,
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w700)),
                  Text(
                    state.peerTyping
                        ? AppStrings.typing
                        : unread > 0
                            ? '$unread ${AppStrings.newMessages}'
                            : AppStrings.online,
                    style: TextStyle(
                      fontSize: 12,
                      color: state.peerTyping
                          ? primary
                          : unread > 0
                              ? AppColors.warning
                              : AppColors.success,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          if (state.joinableCall != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Material(
                color: AppColors.success,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _joinCall(state.joinableCall!),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        Icon(Icons.videocam_rounded, color: Colors.white, size: 20),
                        SizedBox(width: 6),
                        Text(AppStrings.joinCall,
                            style: TextStyle(
                                color: Colors.white, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: state.loading && state.messages.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : state.messages.isEmpty
                    ? EmptyState(
                        title: AppStrings.emptyChatTitle,
                        subtitle: AppStrings.emptyChatSubtitle,
                        actionLabel: AppStrings.sayHi,
                        onAction: () => ctrl.sendText('Hi Coach 👋'),
                      )
                    : RefreshIndicator(
                        onRefresh: () => ctrl.reload(markRead: true),
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          itemCount:
                              state.messages.length + (state.peerTyping ? 1 : 0),
                          itemBuilder: (context, i) {
                            if (state.peerTyping && i == state.messages.length) {
                              return const Padding(
                                padding: EdgeInsets.only(left: 16, bottom: 8),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: _TypingBubble(),
                                ),
                              );
                            }
                            final m = state.messages[i];
                            return MessageBubble(
                              message: m,
                              isMine: m.senderId == widget.me.id,
                              memberColor: colors.memberBubble,
                              trainerColor: colors.trainerBubble,
                              senderRole: m.senderId == widget.me.id
                                  ? widget.me.role
                                  : widget.peer.role,
                            );
                          },
                        ),
                      ),
          ),
          ChatInputBar(
            quickReplies: const [
              AppStrings.quickGotIt,
              AppStrings.quickTalkAt6,
              AppStrings.quickSharePlan,
            ],
            onSend: ctrl.sendText,
            onAttach: _attachImage,
          ),
        ],
      ),
    );
  }

  Future<void> _attachImage() async {
    final file = await ImagePicker()
        .pickImage(source: ImageSource.gallery, maxWidth: 1200, imageQuality: 85);
    if (file == null) return;
    try {
      await ref
          .read(conversationControllerProvider(_params).notifier)
          .sendImageFromFile(file.path);
    } catch (e) {
      if (mounted) {
        showErrorSnack(context, AppStrings.downloadFailed, detail: e.toString());
      }
    }
  }

  Future<void> _joinCall(CallRequest call) async {
    HapticFeedback.mediumImpact();
    final room = await ref.read(syncClientProvider).getRoomForCall(call.id);
    if (room == null) {
      if (mounted) showErrorSnack(context, AppStrings.roomNotReady);
      return;
    }
    if (!mounted) return;
    await AppRouter.openPrejoin(
      context,
      me: widget.me,
      peer: widget.peer,
      room: room,
      callRequest: call,
      isTrainer: widget.me.role == UserRole.trainer,
    );
  }
}

class _TypingBubble extends StatefulWidget {
  const _TypingBubble();

  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) => Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final opacity = ((_controller.value + i * 0.33) % 1.0);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.neutral500.withValues(alpha: 0.3 + opacity * 0.5),
                shape: BoxShape.circle,
              ),
            );
          }),
        ),
      ),
    );
  }
}
