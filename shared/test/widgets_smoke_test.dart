import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wtf_shared/wtf_shared.dart';

void main() {
  group('E. UI widgets smoke', () {
    testWidgets('QuickActionTile renders title', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 180,
              height: 160,
              child: QuickActionTile(
                icon: Icons.chat,
                title: AppStrings.chatWithTrainer,
                subtitle: AppStrings.chatWithTrainerSub,
                accent: AppColors.guru.primary,
                onTap: () {},
              ),
            ),
          ),
        ),
      );
      expect(find.text(AppStrings.chatWithTrainer), findsOneWidget);
    });

    testWidgets('QuickActionBanner tap', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuickActionBanner(
              icon: Icons.chat,
              title: 'Chat',
              subtitle: 'Open',
              accent: AppColors.guru.primary,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );
      await tester.tap(find.text('Chat'));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('ChatListTile shows peer name', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatListTile(
              peer: SeedData.trainers.first,
              lastMessage: null,
              unread: 2,
              onTap: () {},
            ),
          ),
        ),
      );
      expect(find.text('Aarav (Lead Trainer)'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });
  });
}
