import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guru_app/screens/guru_home_screen.dart';
import 'package:wtf_shared/wtf_shared.dart';

class _OnlineSync extends SyncHostNotifier {
  @override
  Future<bool> build() async => true;
}

void main() {
  testWidgets('A5 Guru home shows workspace after login state', (tester) async {
    final auth = AuthService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [syncHostProvider.overrideWith(_OnlineSync.new)],
        child: MaterialApp(
          theme: buildAppTheme(AppColors.guru),
          home: GuruHomeScreen(user: SeedData.memberDk, auth: auth),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.workspace), findsOneWidget);
    expect(find.text(AppStrings.chatWithTrainer), findsWidgets);
    expect(find.text(AppStrings.scheduleCall), findsOneWidget);
  });
}
