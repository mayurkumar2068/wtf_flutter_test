import 'package:flutter_test/flutter_test.dart';
import 'package:wtf_shared/wtf_shared.dart';

void main() {
  test('Message serialization round-trip', () {
    final original = Message(
      id: 'm1',
      chatId: 'chat_a_b',
      senderId: 'member_dk',
      receiverId: 'trainer_aarav',
      text: 'Hi Coach 👋',
      createdAt: DateTime(2026, 5, 22, 18, 0),
      status: MessageStatus.sent,
    );

    final json = original.toJson();
    final restored = Message.fromJson(json);

    expect(restored.id, original.id);
    expect(restored.text, original.text);
    expect(restored.status, MessageStatus.sent);
    expect(restored.createdAt, original.createdAt);
  });
}
