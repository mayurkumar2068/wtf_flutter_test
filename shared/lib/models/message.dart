import 'package:equatable/equatable.dart';

enum MessageStatus { sending, sent, read }

class Message extends Equatable {
  const Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.createdAt,
    this.status = MessageStatus.sent,
    this.isSystem = false,
    this.imageUrl,
  });

  final String id;
  final String chatId;
  final String senderId;
  final String receiverId;
  final String text;
  final DateTime createdAt;
  final MessageStatus status;
  final bool isSystem;
  final String? imageUrl;

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      chatId: json['chatId'] as String,
      senderId: json['senderId'] as String,
      receiverId: json['receiverId'] as String,
      text: json['text'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: _statusFrom(json['status'] as String?),
      isSystem: json['isSystem'] as bool? ?? false,
      imageUrl: json['imageUrl'] as String?,
    );
  }

  static MessageStatus _statusFrom(String? s) {
    switch (s) {
      case 'sending':
        return MessageStatus.sending;
      case 'read':
        return MessageStatus.read;
      default:
        return MessageStatus.sent;
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'chatId': chatId,
        'senderId': senderId,
        'receiverId': receiverId,
        'text': text,
        'createdAt': createdAt.toIso8601String(),
        'status': status.name,
        'isSystem': isSystem,
        'imageUrl': imageUrl,
      };

  Message copyWith({MessageStatus? status}) => Message(
        id: id,
        chatId: chatId,
        senderId: senderId,
        receiverId: receiverId,
        text: text,
        createdAt: createdAt,
        status: status ?? this.status,
        isSystem: isSystem,
        imageUrl: imageUrl,
      );

  @override
  List<Object?> get props =>
      [id, chatId, senderId, receiverId, text, createdAt, status, isSystem];
}
