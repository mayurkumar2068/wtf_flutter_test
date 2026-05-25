import 'package:flutter_test/flutter_test.dart';
import 'package:wtf_shared/wtf_shared.dart';

/// B6, B8, C3 — assessment §11 copy present.
void main() {
  group('Assessment copy (§11)', () {
    test('B6 quick reply chips defined', () {
      expect(AppStrings.quickGotIt, isNotEmpty);
      expect(AppStrings.quickTalkAt6, contains('6'));
      expect(AppStrings.quickSharePlan, isNotEmpty);
    });

    test('B8 empty chat strings', () {
      expect(AppStrings.emptyChatTitle, isNotEmpty);
      expect(AppStrings.sayHi, isNotEmpty);
    });

    test('C3 request sent toast', () {
      expect(AppStrings.requestSent, contains('trainer'));
    });

    test('auth strings for both apps', () {
      expect(AppStrings.getStarted, isNotEmpty);
      expect(AppStrings.continueAsAarav, isNotEmpty);
      expect(AppStrings.signOut, isNotEmpty);
    });
  });
}
