import 'package:equatable/equatable.dart';

/// Modelo para representar un mensaje en una conversación
class MessageResponse extends Equatable {
  final String messageId;
  final String groupId;
  final String senderId;
  final String body;
  final DateTime sentAt;
  final DateTime? editedAt;
  final String status; // SENT, EDITED, DELETED
  final bool isEdited;
  final bool isVisible;

  const MessageResponse({
    required this.messageId,
    required this.groupId,
    required this.senderId,
    required this.body,
    required this.sentAt,
    this.editedAt,
    this.status = 'SENT',
    this.isEdited = false,
    this.isVisible = true,
  });

  factory MessageResponse.fromJson(Map<String, dynamic> json) {
    try {
      print('🔍 MessageResponse.fromJson: Parsing message ${json['messageId']}');
      
      return MessageResponse(
        messageId: json['messageId'] as String,
        groupId: json['groupId'] as String,
        senderId: json['senderId'] as String,
        body: json['body'] as String,
        sentAt: DateTime.parse(json['sentAt'] as String),
        editedAt: json['editedAt'] != null 
            ? DateTime.parse(json['editedAt'] as String)
            : null,
        status: json['status'] as String? ?? 'SENT',
        isEdited: json['isEdited'] as bool? ?? false,
        isVisible: json['isVisible'] as bool? ?? true,
      );
    } catch (error) {
      print('❌ MessageResponse.fromJson: Error parsing message: $error');
      print('❌ JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'groupId': groupId,
      'senderId': senderId,
      'body': body,
      'sentAt': sentAt.toIso8601String(),
      'editedAt': editedAt?.toIso8601String(),
      'status': status,
      'isEdited': isEdited,
      'isVisible': isVisible,
    };
  }

  MessageResponse copyWith({
    String? messageId,
    String? groupId,
    String? senderId,
    String? body,
    DateTime? sentAt,
    DateTime? editedAt,
    String? status,
    bool? isEdited,
    bool? isVisible,
  }) {
    return MessageResponse(
      messageId: messageId ?? this.messageId,
      groupId: groupId ?? this.groupId,
      senderId: senderId ?? this.senderId,
      body: body ?? this.body,
      sentAt: sentAt ?? this.sentAt,
      editedAt: editedAt ?? this.editedAt,
      status: status ?? this.status,
      isEdited: isEdited ?? this.isEdited,
      isVisible: isVisible ?? this.isVisible,
    );
  }

  @override
  List<Object?> get props => [
    messageId, groupId, senderId, body,
    sentAt, editedAt, status, isEdited, isVisible,
  ];
}