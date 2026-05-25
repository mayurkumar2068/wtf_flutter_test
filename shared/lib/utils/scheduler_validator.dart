import '../models/call_request.dart';
import 'time_utils.dart' show isPastSlot;

class SchedulerValidationResult {
  const SchedulerValidationResult({required this.valid, this.error});

  final bool valid;
  final String? error;
}

class SchedulerValidator {
  static SchedulerValidationResult validateNewRequest({
    required DateTime scheduledFor,
    required List<CallRequest> existing,
    String? memberId,
    String? trainerId,
  }) {
    if (isPastSlot(scheduledFor)) {
      return const SchedulerValidationResult(
        valid: false,
        error: 'Cannot schedule a call in the past.',
      );
    }

    final conflict = existing.any((r) {
      if (r.status != CallRequestStatus.approved) return false;
      if (memberId != null && r.memberId != memberId) return false;
      if (trainerId != null && r.trainerId != trainerId) return false;
      return _sameSlot(r.scheduledFor, scheduledFor);
    });

    if (conflict) {
      return const SchedulerValidationResult(
        valid: false,
        error: 'This time slot is already booked. Pick another slot.',
      );
    }

    return const SchedulerValidationResult(valid: true);
  }

  static bool _sameSlot(DateTime a, DateTime b) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day &&
        a.hour == b.hour &&
        a.minute == b.minute;
  }
}
