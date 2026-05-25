import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/seed_data.dart';
import '../../models/user.dart';
import '../../providers/app_providers.dart';
final usersProvider = AsyncNotifierProvider<UsersNotifier, List<User>>(
  UsersNotifier.new,
);

class UsersNotifier extends AsyncNotifier<List<User>> {
  @override
  Future<List<User>> build() async {
    try {
      return await ref.read(syncClientProvider).fetchUsers();
    } catch (_) {
      return [...SeedData.trainers, SeedData.memberDk];
    }
  }

  Future<void> refresh() async {
    final previous = state;
    try {
      state = AsyncData(await build());
    } catch (e, st) {
      if (!previous.hasValue) {
        state = AsyncError<List<User>>(e, st);
      }
    }
  }
}

final trainerListProvider = Provider<List<User>>((ref) {
  final users = ref.watch(usersProvider).valueOrNull ?? SeedData.trainers;
  return users.where((u) => u.role == UserRole.trainer).toList();
});

final memberListProvider = Provider<List<User>>((ref) {
  final users = ref.watch(usersProvider).valueOrNull ?? [SeedData.memberDk];
  return users.where((u) => u.role == UserRole.member).toList();
});
