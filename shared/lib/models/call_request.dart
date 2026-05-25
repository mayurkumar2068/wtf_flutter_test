import 'package:equatable/equatable.dart';

enum CallRequestStatus { pending, approved, declined, cancelled }

class CallRequest extends Equatable {
  const CallRequest({
    required this.id,
    required this.memberId,
    required this.trainerId,
    required this.requestedAt,
    required this.scheduledFor,
    this.note,
    this.status = CallRequestStatus.pending,
    this.declineReason,
  });

  final String id;
  final String memberId;
  final String trainerId;
  final DateTime requestedAt;
  final DateTime scheduledFor;
  final String? note;
  final CallRequestStatus status;
  final String? declineReason;

  factory CallRequest.fromJson(Map<String, dynamic> json) {
    return CallRequest(
      id: json['id'] as String,
      memberId: json['memberId'] as String,
      trainerId: json['trainerId'] as String,
      requestedAt: DateTime.parse(json['requestedAt'] as String),
      scheduledFor: DateTime.parse(json['scheduledFor'] as String),
      note: json['note'] as String?,
      status: _statusFrom(json['status'] as String),
      declineReason: json['declineReason'] as String?,
    );
  }

  static CallRequestStatus _statusFrom(String s) {
    switch (s) {
      case 'approved':
        return CallRequestStatus.approved;
      case 'declined':
        return CallRequestStatus.declined;
      case 'cancelled':
        return CallRequestStatus.cancelled;
      default:
        return CallRequestStatus.pending;
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'memberId': memberId,
        'trainerId': trainerId,
        'requestedAt': requestedAt.toIso8601String(),
        'scheduledFor': scheduledFor.toIso8601String(),
        'note': note,
        'status': status.name,
        'declineReason': declineReason,
      };

  CallRequest copyWith({
    CallRequestStatus? status,
    String? declineReason,
  }) =>
      CallRequest(
        id: id,
        memberId: memberId,
        trainerId: trainerId,
        requestedAt: requestedAt,
        scheduledFor: scheduledFor,
        note: note,
        status: status ?? this.status,
        declineReason: declineReason ?? this.declineReason,
      );

  @override
  List<Object?> get props =>
      [id, memberId, trainerId, requestedAt, scheduledFor, note, status];
}
