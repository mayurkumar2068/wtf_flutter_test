import 'package:flutter_test/flutter_test.dart';
import 'package:wtf_shared/wtf_shared.dart';

void main() {
  group('B. Chat models', () {
    test('B1 message round-trip preserves text and status', () {
      final original = Message(
        id: 'm1',
        chatId: 'chat_member_dk_trainer_aarav',
        senderId: 'member_dk',
        receiverId: 'trainer_aarav',
        text: 'Hi Coach 👋',
        createdAt: DateTime(2026, 5, 22, 18, 0),
        status: MessageStatus.sent,
      );
      final restored = Message.fromJson(original.toJson());
      expect(restored.text, 'Hi Coach 👋');
      expect(restored.senderId, 'member_dk');
    });

    test('B4 read status serializes', () {
      final m = Message(
        id: 'm2',
        chatId: 'c',
        senderId: 'a',
        receiverId: 'b',
        text: 'ok',
        createdAt: DateTime.now(),
        status: MessageStatus.read,
      );
      expect(Message.fromJson(m.toJson()).status, MessageStatus.read);
    });
  });

  group('C. Schedule models', () {
    test('C4/C5 call request status round-trip', () {
      final pending = CallRequest(
        id: 'r1',
        memberId: 'member_dk',
        trainerId: 'trainer_aarav',
        requestedAt: DateTime.now(),
        scheduledFor: DateTime.now().add(const Duration(days: 1)),
        status: CallRequestStatus.pending,
      );
      expect(
        CallRequest.fromJson(pending.toJson()).status,
        CallRequestStatus.pending,
      );

      final approved = CallRequest(
        id: 'r2',
        memberId: 'member_dk',
        trainerId: 'trainer_aarav',
        requestedAt: DateTime.now(),
        scheduledFor: DateTime.now().add(const Duration(days: 1)),
        status: CallRequestStatus.approved,
      );
      expect(
        CallRequest.fromJson(approved.toJson()).status,
        CallRequestStatus.approved,
      );
    });

    test('C6 decline reason preserved', () {
      final declined = CallRequest(
        id: 'r3',
        memberId: 'member_dk',
        trainerId: 'trainer_aarav',
        requestedAt: DateTime.now(),
        scheduledFor: DateTime.now().add(const Duration(days: 1)),
        status: CallRequestStatus.declined,
        declineReason: 'Not available',
      );
      expect(
        CallRequest.fromJson(declined.toJson()).declineReason,
        'Not available',
      );
    });
  });

  group('D. Session models', () {
    test('D1/D3 session log round-trip with rating', () {
      final log = SessionLog(
        id: 's1',
        memberId: 'member_dk',
        trainerId: 'trainer_aarav',
        startedAt: DateTime(2026, 5, 22, 18, 0),
        endedAt: DateTime(2026, 5, 22, 18, 30),
        durationSec: 1800,
        rating: 5,
        memberNotes: 'Great session',
        trainerNotes: 'Macros reviewed',
      );
      final json = log.toJson();
      final restored = SessionLog.fromJson(json);
      expect(restored.rating, 5);
      expect(restored.durationSec, 1800);
      expect(restored.memberNotes, 'Great session');
    });
  });

  group('A2 seed data', () {
    test('member DK assigned to Aarav', () {
      expect(SeedData.memberDk.assignedTrainerId, 'trainer_aarav');
      expect(SeedData.trainers.first.id, 'trainer_aarav');
    });
  });
}
