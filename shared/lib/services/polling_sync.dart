import 'dart:async';

import '../utils/app_logger.dart';
import 'sync_client.dart';

/// Polls server when data may change. Only notifies listeners when payload hash changes.
class PollingSync {
  PollingSync(this._client, {this.interval = const Duration(seconds: 2)});

  final SyncClient _client;
  final Duration interval;
  Timer? _timer;
  String? _lastMessageHash;
  String? _lastRequestHash;
  String? _chatId;
  String? _userId;

  final _handlers = <void Function(String type, Map<String, dynamic> data)>[];

  void addListener(void Function(String type, Map<String, dynamic> data) fn) {
    _handlers.add(fn);
  }

  void start({required String chatId, String? userId}) {
    _chatId = chatId;
    _userId = userId;
    _timer?.cancel();
    _timer = Timer.periodic(interval, (_) => _poll());
    _poll();
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _chatId = null;
    _userId = null;
    _lastMessageHash = null;
    _lastRequestHash = null;
  }

  Future<void> _poll() async {
    final chatId = _chatId;
    if (chatId == null) return;
    try {
      final messages = await _client.fetchMessages(chatId);
      final hash = messages.map((m) => '${m.id}:${m.status.name}').join('|');
      if (hash != _lastMessageHash) {
        _lastMessageHash = hash;
        _notify('messages', {'messages': messages});
      }

      final userId = _userId;
      if (userId != null) {
        final requests = await _client.fetchCallRequests(userId: userId);
        final rHash = requests.map((r) => '${r.id}:${r.status.name}').join('|');
        if (rHash != _lastRequestHash) {
          _lastRequestHash = rHash;
          _notify('call_requests', {'requests': requests});
        }
      }
    } catch (e) {
      AppLogger.instance.log(LogTag.general, 'Poll error: $e');
    }
  }

  void _notify(String type, Map<String, dynamic> data) {
    for (final h in _handlers) {
      h(type, data);
    }
    _client.emitLocalEvent(type, data);
  }
}
