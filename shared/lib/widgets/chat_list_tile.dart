import 'package:flutter/material.dart';

import '../core/strings/app_strings.dart';
import '../models/message.dart';
import '../models/user.dart';
import '../utils/app_decorations.dart';
import '../utils/app_theme.dart';
import '../utils/time_utils.dart';
import 'wtf_avatar.dart';

/// Single chat row — shared by Guru + Trainer list screens.
class ChatListTile extends StatelessWidget {
  const ChatListTile({
    super.key,
    required this.peer,
    required this.lastMessage,
    required this.unread,
    required this.onTap,
  });

  final User peer;
  final Message? lastMessage;
  final int unread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: AppDecorations.surfaceCard(),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    WtfAvatar(url: peer.avatarUrl, radius: 26),
                    if (unread > 0)
                      Positioned(
                        right: -2,
                        top: -2,
                        child: _UnreadBadge(count: unread),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        peer.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        lastMessage?.text ?? AppStrings.emptyChatSubtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                if (lastMessage != null)
                  Text(
                    formatRelativeTime(lastMessage!.createdAt),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.neutral500,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _UnreadBadge extends StatelessWidget {
  const _UnreadBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
      decoration: const BoxDecoration(
        color: AppColors.error,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        count > 9 ? '9+' : '$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
