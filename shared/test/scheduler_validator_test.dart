import 'package:flutter_test/flutter_test.dart';
import 'package:wtf_shared/wtf_shared.dart';

void main() {
  group('C. Schedule validation', () {
    test('C1/C2 rejects past time', () {
      final result = SchedulerValidator.validateNewRequest(
        scheduledFor: DateTime.now().subtract(const Duration(hours: 1)),
        existing: [],
      );
      expect(result.valid, isFalse);
      expect(result.error, contains('past'));
    });

    test('C2 rejects conflicting approved slot', () {
      final slot = DateTime(2026, 6, 1, 18, 0);
      final existing = [
        CallRequest(
          id: '1',
          memberId: 'member_dk',
          trainerId: 'trainer_aarav',
          requestedAt: DateTime.now(),
          scheduledFor: slot,
          status: CallRequestStatus.approved,
        ),
      ];
      final result = SchedulerValidator.validateNewRequest(
        scheduledFor: slot,
        existing: existing,
        memberId: 'member_dk',
      );
      expect(result.valid, isFalse);
      expect(result.error, contains('booked'));
    });

    test('pending request does not block same slot', () {
      final slot = DateTime.now().add(const Duration(days: 2));
      final existing = [
        CallRequest(
          id: '1',
          memberId: 'member_dk',
          trainerId: 'trainer_aarav',
          requestedAt: DateTime.now(),
          scheduledFor: slot,
          status: CallRequestStatus.pending,
        ),
      ];
      final result = SchedulerValidator.validateNewRequest(
        scheduledFor: slot,
        existing: existing,
        memberId: 'member_dk',
      );
      expect(result.valid, isTrue);
    });

    test('valid future slot passes', () {
      final result = SchedulerValidator.validateNewRequest(
        scheduledFor: DateTime.now().add(const Duration(days: 3)),
        existing: [],
        memberId: 'member_dk',
        trainerId: 'trainer_aarav',
      );
      expect(result.valid, isTrue);
      expect(result.error, isNull);
    });
  });
}
