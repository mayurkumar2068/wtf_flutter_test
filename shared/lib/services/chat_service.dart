import 'dart:async';

import 'package:uuid/uuid.dart';

import '../models/message.dart';
import '../models/user.dart';
import 'auth_service.dart';
import 'polling_sync.dart';
import 'sync_client.dart';

class ChatService {
  ChatService(this._sync, this._auth);

  final SyncClient _sync;
  final AuthService _auth;
  final _uuid = const Uuid();
  PollingSync? _polling;
  final _typingController = StreamController<bool>.broadcast();
  bool _peerTyping = false;

  Stream<bool> get peerTyping => _typingController.stream;
  Stream<Map<String, dynamic>> get events => _sync.events;

  void startSync(String chatId, String userId) {
    _polling?.stop();
    _polling = PollingSync(_sync);
    _polling!.addListener((type, data) {
      if (type == 'messages') {
        _sync.emitLocalEvent('messages_updated', data);
      }
    });
    _polling!.start(chatId: chatId, userId: userId);
  }

  void stopSync() => _polling?.stop();

  Future<List<Message>> loadMessages(String chatId) =>
      _sync.fetchMessages(chatId);

  Future<Message> sendText({
    required User sender,
    required User receiver,
    required String text,
    String? imageUrl,
  }) async {
    final chatId = _auth.chatIdFor(sender, receiver);
    final msg = Message(
      id: _uuid.v4(),
      chatId: chatId,
      senderId: sender.id,
      receiverId: receiver.id,
      text: text,
      createdAt: DateTime.now(),
      status: MessageStatus.sending,
      imageUrl: imageUrl,
    );

    final sent = await _sync.sendMessage(msg);
    _simulatePeerTyping(receiver.id, sender.id);
    return sent;
  }

  Future<void> markRead(String chatId, String readerId) async {
    await _sync.markMessagesRead(chatId, readerId);
  }

  void _simulatePeerTyping(String peerId, String myId) {
    if (_peerTyping) return;
    _peerTyping = true;
    _typingController.add(true);
    final delay = 400 + (peerId.hashCode % 400);
    Future.delayed(Duration(milliseconds: delay), () {
      _peerTyping = false;
      _typingController.add(false);
      _sync.emitLocalEvent('typing_end', {'peerId': peerId});
    });
  }

  void dispose() {
    _polling?.stop();
    _typingController.close();
  }
}
