import 'package:flutter_test/flutter_test.dart';
import 'package:wtf_shared/wtf_shared.dart';

void main() {
  group('C7 join window', () {
    test('can join 5 minutes before scheduled time', () {
      final scheduled = DateTime.now().add(const Duration(minutes: 5));
      expect(canJoinCall(scheduled), isTrue);
    });

    test('cannot join more than 10 minutes before', () {
      final scheduled = DateTime.now().add(const Duration(minutes: 15));
      expect(canJoinCall(scheduled), isFalse);
    });

    test('cannot join after window ends', () {
      final scheduled = DateTime.now().subtract(const Duration(hours: 3));
      expect(canJoinCall(scheduled), isFalse);
    });
  });

  group('C1 past slots', () {
    test('isPastSlot true for yesterday', () {
      expect(
        isPastSlot(DateTime.now().subtract(const Duration(days: 1))),
        isTrue,
      );
    });

    test('isPastSlot false for tomorrow', () {
      expect(
        isPastSlot(DateTime.now().add(const Duration(days: 1))),
        isFalse,
      );
    });
  });

  group('D session duration', () {
    test('calculateDurationSec clamps negative', () {
      final start = DateTime(2026, 1, 1, 10, 0);
      final end = DateTime(2026, 1, 1, 9, 0);
      expect(calculateDurationSec(start, end), 0);
    });

    test('formatDuration shows minutes and seconds', () {
      expect(formatDuration(125), '2m 5s');
      expect(formatDuration(45), '45s');
    });
  });
}
