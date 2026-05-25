import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trainer_app/screens/trainer_home_screen.dart';
import 'package:wtf_shared/wtf_shared.dart';

class _OnlineSync extends SyncHostNotifier {
  @override
  Future<bool> build() async => true;
}

void main() {
  testWidgets('A3 Trainer dashboard shows four actions', (tester) async {
    final auth = AuthService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [syncHostProvider.overrideWith(_OnlineSync.new)],
        child: MaterialApp(
          theme: buildAppTheme(AppColors.trainer),
          home: TrainerHomeScreen(
            user: SeedData.trainers.first,
            auth: auth,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.coachDashboard), findsOneWidget);
    expect(find.text(AppStrings.members), findsOneWidget);
    expect(find.text(AppStrings.chats), findsOneWidget);
    expect(find.text(AppStrings.requests), findsOneWidget);
    expect(find.text(AppStrings.sessions), findsOneWidget);
  });
}
