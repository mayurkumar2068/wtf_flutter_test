import 'dart:collection';

enum LogTag { auth, chat, rtc, schedule, general }

class AppLogEntry {
  AppLogEntry({
    required this.tag,
    required this.message,
    required this.at,
  });

  final LogTag tag;
  final String message;
  final DateTime at;

  String get tagLabel => switch (tag) {
        LogTag.auth => 'AUTH',
        LogTag.chat => 'CHAT',
        LogTag.rtc => 'RTC',
        LogTag.schedule => 'SCHEDULE',
        LogTag.general => 'APP',
      };
}

class AppLogger {
  AppLogger._();
  static final AppLogger instance = AppLogger._();

  final _entries = ListQueue<AppLogEntry>();

  void log(LogTag tag, String message) {
    final entry = AppLogEntry(
      tag: tag,
      message: message,
      at: DateTime.now(),
    );
    _entries.addLast(entry);
    while (_entries.length > 20) {
      _entries.removeFirst();
    }
    // ignore: avoid_print
    print('[${entry.tagLabel}] $message');
  }

  List<AppLogEntry> get recent => List.unmodifiable(_entries);
}
