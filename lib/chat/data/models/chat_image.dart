/// Model for chat group image
class ChatImage {
  final String imageId;
  final String groupId;
  final String senderId;
  final String imageUrl;
  final DateTime sentAt;
  final bool isVisible;

  const ChatImage({
    required this.imageId,
    required this.groupId,
    required this.senderId,
    required this.imageUrl,
    required this.sentAt,
    required this.isVisible,
  });

  factory ChatImage.fromJson(Map<String, dynamic> json) {
    return ChatImage(
      imageId: json['imageId'] as String,
      groupId: json['groupId'] as String,
      senderId: json['senderId'] as String,
      imageUrl: json['imageUrl'] as String,
      sentAt: DateTime.parse(json['sentAt'] as String),
      isVisible: json['isVisible'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'imageId': imageId,
    'groupId': groupId,
    'senderId': senderId,
    'imageUrl': imageUrl,
    'sentAt': sentAt.toIso8601String(),
    'isVisible': isVisible,
  };

  ChatImage copyWith({
    String? imageId,
    String? groupId,
    String? senderId,
    String? imageUrl,
    DateTime? sentAt,
    bool? isVisible,
  }) {
    return ChatImage(
      imageId: imageId ?? this.imageId,
      groupId: groupId ?? this.groupId,
      senderId: senderId ?? this.senderId,
      imageUrl: imageUrl ?? this.imageUrl,
      sentAt: sentAt ?? this.sentAt,
      isVisible: isVisible ?? this.isVisible,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatImage &&
          runtimeType == other.runtimeType &&
          imageId == other.imageId;

  @override
  int get hashCode => imageId.hashCode;
}