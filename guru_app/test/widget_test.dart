import 'package:flutter_test/flutter_test.dart';
import 'package:wtf_shared/wtf_shared.dart';

void main() {
  test('SchedulerValidator rejects past slots', () {
    final result = SchedulerValidator.validateNewRequest(
      scheduledFor: DateTime.now().subtract(const Duration(hours: 2)),
      existing: [],
    );
    expect(result.valid, false);
  });
}
