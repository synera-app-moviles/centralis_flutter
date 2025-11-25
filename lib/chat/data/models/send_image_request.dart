/// Request model for sharing a new image in a group
class SendImageRequest {
  final String senderId;
  final String imageUrl;

  const SendImageRequest({
    required this.senderId,
    required this.imageUrl,
  });

  Map<String, dynamic> toJson() => {
    'senderId': senderId,
    'imageUrl': imageUrl,
  };

  factory SendImageRequest.fromJson(Map<String, dynamic> json) {
    return SendImageRequest(
      senderId: json['senderId'] as String,
      imageUrl: json['imageUrl'] as String,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SendImageRequest &&
          runtimeType == other.runtimeType &&
          senderId == other.senderId &&
          imageUrl == other.imageUrl;

  @override
  int get hashCode => senderId.hashCode ^ imageUrl.hashCode;
}