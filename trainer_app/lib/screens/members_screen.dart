import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wtf_shared/wtf_shared.dart';

class MembersScreen extends ConsumerWidget {
  const MembersScreen({super.key, required this.trainer});

  final User trainer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(usersProvider);

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(title: const Text(AppStrings.members)),
      body: usersAsync.when(
        skipLoadingOnReload: true,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text(AppStrings.syncOffline)),
        data: (users) {
          final members = users
              .where((u) =>
                  u.role == UserRole.member &&
                  u.assignedTrainerId == trainer.id)
              .toList();

          return RefreshIndicator(
            onRefresh: () => ref.read(usersProvider.notifier).refresh(),
            child: members.isEmpty
                ? ListView(
                    children: const [
                      SizedBox(height: 120),
                      Center(child: Text(AppStrings.noMembersAssigned)),
                    ],
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: members.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final m = members[i];
                      return ListTile(
                        leading: WtfAvatar(url: m.avatarUrl, radius: 22),
                        title: Text(m.name),
                        subtitle: Text(m.email),
                      );
                    },
                  ),
          );
        },
      ),
    );
  }
}
