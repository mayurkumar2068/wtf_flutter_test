import 'package:flutter/material.dart';

import '../models/message.dart';
import '../models/user.dart';
import '../utils/app_theme.dart';
import '../utils/chat_image_utils.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.isMine,
    required this.memberColor,
    required this.trainerColor,
    this.senderRole,
  });

  final Message message;
  final bool isMine;
  final Color memberColor;
  final Color trainerColor;
  final UserRole? senderRole;

  @override
  Widget build(BuildContext context) {
    if (message.isSystem) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.neutral100,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.neutral200),
            ),
            child: Text(
              message.text,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.neutral500,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ),
      );
    }

    final bubbleColor = isMine
        ? (senderRole == UserRole.trainer ? trainerColor : memberColor)
        : Colors.white;
    final textColor = isMine ? Colors.white : AppColors.neutral900;
    final hasImage = message.imageUrl != null && message.imageUrl!.isNotEmpty;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset((isMine ? 1 : -1) * (1 - t) * 12, 0),
          child: child,
        ),
      ),
      child: Align(
        alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.76,
          ),
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
          padding: EdgeInsets.fromLTRB(
            hasImage ? 8 : 16,
            hasImage ? 8 : 12,
            hasImage ? 8 : 16,
            hasImage ? 8 : 12,
          ),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20),
              topRight: const Radius.circular(20),
              bottomLeft: Radius.circular(isMine ? 20 : 6),
              bottomRight: Radius.circular(isMine ? 6 : 20),
            ),
            border: isMine ? null : Border.all(color: AppColors.neutral200),
            boxShadow: [
              BoxShadow(
                color: AppColors.neutral900.withValues(
                  alpha: isMine ? 0.12 : 0.05,
                ),
                blurRadius: isMine ? 12 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (hasImage)
                GestureDetector(
                  onTap: () => openChatImagePreview(context, message.imageUrl),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        buildChatImage(message.imageUrl, height: 160, width: 220),
                        Container(
                          margin: const EdgeInsets.all(6),
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.45),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.zoom_in_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (message.text.isNotEmpty && message.text != '📷 Photo')
                Padding(
                  padding: EdgeInsets.only(
                    top: hasImage ? 8 : 0,
                    left: hasImage ? 8 : 0,
                    right: hasImage ? 8 : 0,
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 15,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              if (message.text == '📷 Photo' && hasImage)
                const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(top: 4, right: 4),
                child: _StatusTicks(status: message.status, color: textColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusTicks extends StatelessWidget {
  const _StatusTicks({required this.status, required this.color});

  final MessageStatus status;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final iconColor = color.withValues(alpha: 0.85);
    if (status == MessageStatus.read) {
      return Icon(Icons.done_all_rounded, size: 16, color: iconColor);
    }
    if (status == MessageStatus.sent) {
      return Icon(Icons.done_rounded, size: 16, color: iconColor);
    }
    return SizedBox(
      width: 14,
      height: 14,
      child: CircularProgressIndicator(strokeWidth: 1.5, color: iconColor),
    );
  }
}
