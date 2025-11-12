import 'package:equatable/equatable.dart';

/// Modelo para representar un chat en la lista de chats
class ChatItem extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final String? lastSenderId;
  final String? lastSenderName;
  final int unreadCount;
  final bool isGroup;
  final List<String> memberIds;
  final String visibility; // PUBLIC, PRIVATE
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ChatItem({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.lastMessage,
    this.lastMessageTime,
    this.lastSenderId,
    this.lastSenderName,
    this.unreadCount = 0,
    this.isGroup = true,
    this.memberIds = const [],
    this.visibility = 'PRIVATE',
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChatItem.fromJson(Map<String, dynamic> json) {
    return ChatItem(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      lastMessage: json['lastMessage'] as String?,
      lastMessageTime: json['lastMessageTime'] != null 
          ? DateTime.parse(json['lastMessageTime'] as String)
          : null,
      lastSenderId: json['lastSenderId'] as String?,
      lastSenderName: json['lastSenderName'] as String?,
      unreadCount: json['unreadCount'] as int? ?? 0,
      isGroup: json['isGroup'] as bool? ?? true,
      memberIds: (json['memberIds'] as List<dynamic>?)?.cast<String>() ?? [],
      visibility: json['visibility'] as String? ?? 'PRIVATE',
      createdBy: json['createdBy'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime?.toIso8601String(),
      'lastSenderId': lastSenderId,
      'lastSenderName': lastSenderName,
      'unreadCount': unreadCount,
      'isGroup': isGroup,
      'memberIds': memberIds,
      'visibility': visibility,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  ChatItem copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    String? lastMessage,
    DateTime? lastMessageTime,
    String? lastSenderId,
    String? lastSenderName,
    int? unreadCount,
    bool? isGroup,
    List<String>? memberIds,
    String? visibility,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChatItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      lastSenderId: lastSenderId ?? this.lastSenderId,
      lastSenderName: lastSenderName ?? this.lastSenderName,
      unreadCount: unreadCount ?? this.unreadCount,
      isGroup: isGroup ?? this.isGroup,
      memberIds: memberIds ?? this.memberIds,
      visibility: visibility ?? this.visibility,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id, name, description, imageUrl, lastMessage, lastMessageTime,
    lastSenderId, lastSenderName, unreadCount, isGroup, memberIds,
    visibility, createdBy, createdAt, updatedAt,
  ];
}