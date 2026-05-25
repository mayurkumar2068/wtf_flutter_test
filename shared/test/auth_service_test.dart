import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:wtf_shared/wtf_shared.dart';

void main() {
  late Directory tempDir;
  late AuthService auth;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('wtf_auth_test');
    auth = AuthService();
    await auth.initForTest(tempDir.path);
  });

  tearDown(() async {
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('A. Auth scenarios', () {
    test('A4/A5 clearSession resets onboarding flag', () async {
      await auth.completeOnboarding(SeedData.memberDk);
      expect(auth.isOnboardingDone, isTrue);
      expect(auth.currentUser?.id, 'member_dk');

      await auth.clearSession();
      expect(auth.isOnboardingDone, isFalse);
      expect(auth.currentUser, isNull);
    });

    test('A3 trainer login persists user', () async {
      await auth.login(SeedData.trainers.first);
      expect(auth.currentUser?.role, UserRole.trainer);
      expect(auth.isOnboardingDone, isTrue);
    });

    test('chatIdFor is order-independent', () {
      final id1 = auth.chatIdFor(SeedData.memberDk, SeedData.trainers.first);
      final id2 = auth.chatIdFor(SeedData.trainers.first, SeedData.memberDk);
      expect(id1, id2);
      expect(id1, 'chat_member_dk_trainer_aarav');
    });
  });
}
