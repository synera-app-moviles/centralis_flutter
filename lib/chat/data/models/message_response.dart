import 'package:equatable/equatable.dart';

/// Modelo para representar un mensaje en una conversación
class MessageResponse extends Equatable {
  final String messageId;
  final String groupId;
  final String senderId;
  final String senderUsername;
  final String body;
  final DateTime sentAt;
  final DateTime? editedAt;
  final String status; // SENT, EDITED, DELETED
  final bool isVisible;

  const MessageResponse({
    required this.messageId,
    required this.groupId,
    required this.senderId,
    required this.senderUsername,
    required this.body,
    required this.sentAt,
    this.editedAt,
    this.status = 'SENT',
    this.isVisible = true,
  });

  factory MessageResponse.fromJson(Map<String, dynamic> json) {
    return MessageResponse(
      messageId: json['messageId'] as String,
      groupId: json['groupId'] as String,
      senderId: json['senderId'] as String,
      senderUsername: json['senderUsername'] as String,
      body: json['body'] as String,
      sentAt: DateTime.parse(json['sentAt'] as String),
      editedAt: json['editedAt'] != null 
          ? DateTime.parse(json['editedAt'] as String)
          : null,
      status: json['status'] as String? ?? 'SENT',
      isVisible: json['isVisible'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'groupId': groupId,
      'senderId': senderId,
      'senderUsername': senderUsername,
      'body': body,
      'sentAt': sentAt.toIso8601String(),
      'editedAt': editedAt?.toIso8601String(),
      'status': status,
      'isVisible': isVisible,
    };
  }

  MessageResponse copyWith({
    String? messageId,
    String? groupId,
    String? senderId,
    String? senderUsername,
    String? body,
    DateTime? sentAt,
    DateTime? editedAt,
    String? status,
    bool? isVisible,
  }) {
    return MessageResponse(
      messageId: messageId ?? this.messageId,
      groupId: groupId ?? this.groupId,
      senderId: senderId ?? this.senderId,
      senderUsername: senderUsername ?? this.senderUsername,
      body: body ?? this.body,
      sentAt: sentAt ?? this.sentAt,
      editedAt: editedAt ?? this.editedAt,
      status: status ?? this.status,
      isVisible: isVisible ?? this.isVisible,
    );
  }

  @override
  List<Object?> get props => [
    messageId, groupId, senderId, senderUsername, body,
    sentAt, editedAt, status, isVisible,
  ];
}