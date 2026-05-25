import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wtf_shared/wtf_shared.dart';

import 'login_screen.dart';
import 'members_screen.dart';
import 'requests_screen.dart';
import 'trainer_chats_screen.dart';

class TrainerHomeScreen extends ConsumerStatefulWidget {
  const TrainerHomeScreen({
    super.key,
    required this.user,
    required this.auth,
  });

  final User user;
  final AuthService auth;

  @override
  ConsumerState<TrainerHomeScreen> createState() => _TrainerHomeScreenState();
}

class _TrainerHomeScreenState extends ConsumerState<TrainerHomeScreen>
    with ListRefreshMixin {
  late final ChatUnreadParams _unreadParams;

  @override
  void initState() {
    super.initState();
    final chatId = widget.auth.chatIdFor(widget.user, SeedData.memberDk);
    _unreadParams = ChatUnreadParams(userId: widget.user.id, chatId: chatId);
    registerAutoRefresh(() => refreshChatUnread(ref, _unreadParams));
  }

  Future<void> _openChats() async {
    await AppRouter.push(
      context,
      TrainerChatsScreen(trainer: widget.user),
    );
    refreshChatUnread(ref, _unreadParams);
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final sync = ref.watch(syncHostProvider);
    final unread = ref.watch(chatUnreadProvider(_unreadParams)).valueOrNull ?? 0;

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _TrainerHeader(
                  primary: primary,
                  sync: sync,
                  unread: unread,
                  onRetry: () => ref.read(syncHostProvider.notifier).retry(),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 88),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.05,
                  ),
                  delegate: SliverChildListDelegate([
                    QuickActionTile(
                      icon: Icons.people_alt_rounded,
                      title: AppStrings.members,
                      subtitle: 'Assigned members',
                      accent: primary,
                      onTap: () => AppRouter.push(
                        context,
                        MembersScreen(trainer: widget.user),
                      ),
                    ),
                    QuickActionTile(
                      icon: Icons.forum_rounded,
                      title: AppStrings.chats,
                      subtitle: unread > 0
                          ? '$unread ${AppStrings.newMessages}'
                          : 'Message DK',
                      accent: primary,
                      badge: unread > 0 ? (unread > 9 ? '9+' : '$unread') : null,
                      onTap: _openChats,
                    ),
                    QuickActionTile(
                      icon: Icons.event_available_rounded,
                      title: AppStrings.requests,
                      subtitle: 'Approve calls',
                      accent: const Color(0xFFF59E0B),
                      onTap: () => AppRouter.push(
                        context,
                        RequestsScreen(trainer: widget.user),
                      ),
                    ),
                    QuickActionTile(
                      icon: Icons.analytics_rounded,
                      title: AppStrings.sessions,
                      subtitle: 'Logs & ratings',
                      accent: const Color(0xFF7C3AED),
                      onTap: () => AppRouter.openSessions(
                        context,
                        user: widget.user,
                        isTrainer: true,
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
          DevPanelFab(
            appName: AppStrings.appNameTrainer,
            buildInfo: 'v1.0.0+1',
            onReconnect: () => ref.read(syncHostProvider.notifier).retry(),
            onSignOut: () async {
              await widget.auth.clearSession();
              if (!context.mounted) return;
              AppRouter.replace(context, LoginScreen(auth: widget.auth));
            },
          ),
        ],
      ),
    );
  }
}

class _TrainerHeader extends StatelessWidget {
  const _TrainerHeader({
    required this.primary,
    required this.sync,
    required this.unread,
    required this.onRetry,
  });

  final Color primary;
  final AsyncValue<bool> sync;
  final int unread;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
      decoration: BoxDecoration(
        gradient: AppDecorations.headerGradient(primary),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  AppStrings.coachDashboard,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (unread > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$unread ${AppStrings.newMessages}',
                    style: TextStyle(
                      color: primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            AppStrings.trainerBadge,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          sync.when(
            data: (ok) => _ServerPill(ok: ok, onRetry: onRetry),
            loading: () => const SizedBox(
              height: 3,
              child: LinearProgressIndicator(
                backgroundColor: Colors.white24,
                color: Colors.white,
              ),
            ),
            error: (_, __) => _ServerPill(ok: false, onRetry: onRetry),
          ),
        ],
      ),
    );
  }
}

class _ServerPill extends StatelessWidget {
  const _ServerPill({required this.ok, required this.onRetry});

  final bool ok;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: ok ? null : onRetry,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Icon(
                ok ? Icons.cloud_done_rounded : Icons.cloud_off_rounded,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  ok ? AppStrings.connected : AppStrings.tapRetryServer,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
              if (!ok)
                const Icon(Icons.refresh_rounded, color: Colors.white, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
