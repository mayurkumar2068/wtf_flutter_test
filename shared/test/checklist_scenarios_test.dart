import 'package:flutter_test/flutter_test.dart';
import 'package:wtf_shared/wtf_shared.dart';

/// Master map: CHECKLIST.md scenario → automated test coverage.
/// Manual-only: C8–C10 (100ms UI), B2/B3 live sync, full E2E on device.
void main() {
  group('CHECKLIST coverage index', () {
    test('documents automated vs manual scenarios', () {
      const automated = {
        'A2': 'models_roundtrip_test / seed',
        'A3': 'auth_service_test login',
        'A4': 'auth_service_test clearSession',
        'A5': 'auth_service_test persistence',
        'B1': 'message_test / models',
        'B4': 'models read status',
        'B6': 'app_strings_test',
        'B8': 'app_strings_test',
        'C1': 'scheduler + time_utils past',
        'C2': 'scheduler conflict',
        'C3': 'app_strings_test',
        'C4-C6': 'models call status',
        'C7': 'time_utils_test join window',
        'D1-D3': 'models session + duration_test',
        'E1': 'app_strings_test',
        'E6-E7': 'flutter test all packages',
      };
      const manual = {
        'A1': 'onboarding UI — device',
        'B2-B3': 'cross-app chat sync — server + 2 apps',
        'B5': 'typing indicator — device',
        'B7': 'system message on approve — server',
        'C8-C10': '100ms prejoin/incall — device + HMS',
        'C11-C12': 'post-call sheets — device',
        'D4': 'share export — device',
      };
      expect(automated.length, greaterThan(10));
      expect(manual.length, greaterThan(5));
    });
  });

  group('ConversationParams', () {
    test('equality for Riverpod family key', () {
      final a = ConversationParams(
        chatId: 'chat_member_dk_trainer_aarav',
        me: SeedData.memberDk,
        peer: SeedData.trainers.first,
      );
      final b = ConversationParams(
        chatId: 'chat_member_dk_trainer_aarav',
        me: SeedData.memberDk,
        peer: SeedData.trainers.first,
      );
      expect(a, equals(b));
    });
  });
}
