import 'package:intl/intl.dart';

String formatRelativeTime(DateTime time) {
  final diff = DateTime.now().difference(time);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return DateFormat('MMM d').format(time);
}

String formatDateTime(DateTime dt) {
  return DateFormat('MMM d, h:mm a').format(dt);
}

String formatDuration(int seconds) {
  final m = seconds ~/ 60;
  final s = seconds % 60;
  if (m == 0) return '${s}s';
  return '${m}m ${s}s';
}

int calculateDurationSec(DateTime start, DateTime end) {
  return end.difference(start).inSeconds.clamp(0, 86400);
}

bool isPastSlot(DateTime scheduled) => scheduled.isBefore(DateTime.now());

bool canJoinCall(DateTime scheduled, {Duration window = const Duration(minutes: 10)}) {
  final now = DateTime.now();
  final start = scheduled.subtract(window);
  final end = scheduled.add(const Duration(hours: 2));
  return !now.isBefore(start) && now.isBefore(end);
}
