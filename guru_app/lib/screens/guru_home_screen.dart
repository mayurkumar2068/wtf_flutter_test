import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wtf_shared/wtf_shared.dart';

import 'chat_list_screen.dart';
import 'onboarding_screen.dart';
import 'schedule_call_screen.dart';

class GuruHomeScreen extends ConsumerStatefulWidget {
  const GuruHomeScreen({
    super.key,
    required this.user,
    required this.auth,
  });

  final User user;
  final AuthService auth;

  @override
  ConsumerState<GuruHomeScreen> createState() => _GuruHomeScreenState();
}

class _GuruHomeScreenState extends ConsumerState<GuruHomeScreen>
    with ListRefreshMixin {
  ChatUnreadParams? _unreadParams;

  @override
  void initState() {
    super.initState();
    _setupUnreadRefresh();
  }

  void _setupUnreadRefresh() {
    ref.read(usersProvider.future).then((users) {
      if (!mounted) return;
      final trainer = users.firstWhere(
        (u) => u.id == widget.user.assignedTrainerId,
        orElse: () => users.firstWhere((u) => u.role == UserRole.trainer),
      );
      final chatId = widget.auth.chatIdFor(widget.user, trainer);
      final params = ChatUnreadParams(
        userId: widget.user.id,
        chatId: chatId,
      );
      setState(() => _unreadParams = params);
      registerAutoRefresh(() => refreshChatUnread(ref, params));
    });
  }

  Future<void> _openChat() async {
    final params = _unreadParams;
    await AppRouter.push(
      context,
      ChatListScreen(currentUser: widget.user),
    );
    if (params != null) refreshChatUnread(ref, params);
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final sync = ref.watch(syncHostProvider);
    final unreadParams = _unreadParams;
    final unread = unreadParams == null
        ? 0
        : ref.watch(chatUnreadProvider(unreadParams)).valueOrNull ?? 0;

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 0,
                backgroundColor: AppColors.neutral50,
                surfaceTintColor: Colors.transparent,
                title: Row(
                  children: [
                    WtfAvatar(url: widget.user.avatarUrl, radius: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.user.name,
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          Text(
                            AppStrings.appNameGuru,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontSize: 11,
                                ),
                          ),
                        ],
                      ),
                    ),
                    if (unread > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(minWidth: 22, minHeight: 22),
                        alignment: Alignment.center,
                        child: Text(
                          unread > 9 ? '9+' : '$unread',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              SliverToBoxAdapter(
                child: sync.when(
                  data: (ok) => ok
                      ? const SizedBox.shrink()
                      : _OfflineBanner(
                          onRetry: () =>
                              ref.read(syncHostProvider.notifier).retry(),
                        ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => _OfflineBanner(
                    onRetry: () => ref.read(syncHostProvider.notifier).retry(),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    QuickActionBanner(
                      icon: Icons.chat_bubble_rounded,
                      title: AppStrings.chatWithTrainer,
                      subtitle: unread > 0
                          ? '$unread ${AppStrings.newMessages}'
                          : AppStrings.chatWithTrainerSub,
                      accent: primary,
                      unreadCount: unread,
                      onTap: _openChat,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      AppStrings.workspace,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppStrings.quickActionsSubtitle,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.05,
                      children: [
                        QuickActionTile(
                          icon: Icons.calendar_month_rounded,
                          title: AppStrings.scheduleCall,
                          subtitle: AppStrings.scheduleCallSub,
                          accent: primary,
                          onTap: () => AppRouter.push(
                            context,
                            ScheduleCallScreen(user: widget.user),
                          ),
                        ),
                        QuickActionTile(
                          icon: Icons.insights_rounded,
                          title: AppStrings.mySessions,
                          subtitle: AppStrings.mySessionsSub,
                          accent: const Color(0xFF7C3AED),
                          onTap: () => AppRouter.openSessions(
                            context,
                            user: widget.user,
                            isTrainer: false,
                          ),
                        ),
                        QuickActionTile(
                          icon: Icons.groups_rounded,
                          title: 'My Coach',
                          subtitle: 'Aarav • Lead Trainer',
                          accent: const Color(0xFF0D9488),
                          badge: unread > 0 ? '$unread' : null,
                          onTap: _openChat,
                        ),
                        QuickActionTile(
                          icon: Icons.help_outline_rounded,
                          title: 'Support',
                          subtitle: 'Setup & sync help',
                          accent: AppColors.neutral700,
                          onTap: () =>
                              ref.read(syncHostProvider.notifier).retry(),
                        ),
                      ],
                    ),
                  ]),
                ),
              ),
            ],
          ),
          DevPanelFab(
            appName: AppStrings.appNameGuru,
            buildInfo: 'v1.0.0+1',
            onReconnect: () => ref.read(syncHostProvider.notifier).retry(),
            onSignOut: () => _signOut(context),
          ),
        ],
      ),
    );
  }

  Future<void> _signOut(BuildContext context) async {
    await widget.auth.clearSession();
    if (!context.mounted) return;
    AppRouter.replace(context, OnboardingScreen(auth: widget.auth));
  }
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Material(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onRetry,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.wifi_off_rounded, color: AppColors.warning, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    AppStrings.serverOfflineBanner,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.neutral900,
                          fontSize: 12,
                        ),
                  ),
                ),
                const Icon(Icons.refresh_rounded, size: 18, color: AppColors.warning),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
