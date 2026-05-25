import 'package:equatable/equatable.dart';

enum UserRole { trainer, member }

class User extends Equatable {
  const User({
    required this.id,
    required this.role,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.assignedTrainerId,
  });

  final String id;
  final UserRole role;
  final String name;
  final String email;
  final String? avatarUrl;
  final String? assignedTrainerId;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      role: json['role'] == 'trainer' ? UserRole.trainer : UserRole.member,
      name: json['name'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      assignedTrainerId: json['assignedTrainerId'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'role': role == UserRole.trainer ? 'trainer' : 'member',
        'name': name,
        'email': email,
        'avatarUrl': avatarUrl,
        'assignedTrainerId': assignedTrainerId,
      };

  @override
  List<Object?> get props =>
      [id, role, name, email, avatarUrl, assignedTrainerId];
}
