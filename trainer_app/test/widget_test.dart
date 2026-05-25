import 'package:flutter_test/flutter_test.dart';
import 'package:wtf_shared/wtf_shared.dart';

void main() {
  test('Message model round-trip', () {
    final m = Message(
      id: '1',
      chatId: 'c',
      senderId: 'a',
      receiverId: 'b',
      text: 'test',
      createdAt: DateTime.now(),
    );
    expect(Message.fromJson(m.toJson()).text, 'test');
  });
}
