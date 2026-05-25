import 'package:equatable/equatable.dart';

class RoomMeta extends Equatable {
  const RoomMeta({
    required this.id,
    required this.callRequestId,
    required this.hmsRoomId,
    required this.hmsRoleMember,
    required this.hmsRoleTrainer,
  });

  final String id;
  final String callRequestId;
  final String hmsRoomId;
  final String hmsRoleMember;
  final String hmsRoleTrainer;

  factory RoomMeta.fromJson(Map<String, dynamic> json) {
    return RoomMeta(
      id: json['id'] as String,
      callRequestId: json['callRequestId'] as String,
      hmsRoomId: json['hmsRoomId'] as String,
      hmsRoleMember: json['hmsRoleMember'] as String,
      hmsRoleTrainer: json['hmsRoleTrainer'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'callRequestId': callRequestId,
        'hmsRoomId': hmsRoomId,
        'hmsRoleMember': hmsRoleMember,
        'hmsRoleTrainer': hmsRoleTrainer,
      };

  @override
  List<Object?> get props =>
      [id, callRequestId, hmsRoomId, hmsRoleMember, hmsRoleTrainer];
}
