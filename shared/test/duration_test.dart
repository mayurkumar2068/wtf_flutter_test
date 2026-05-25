import 'package:flutter_test/flutter_test.dart';
import 'package:wtf_shared/wtf_shared.dart';

void main() {
  test('Log duration calculation', () {
    final start = DateTime(2026, 5, 22, 18, 0, 0);
    final end = DateTime(2026, 5, 22, 18, 25, 30);
    expect(calculateDurationSec(start, end), 1530);
  });
}
