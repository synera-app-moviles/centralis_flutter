import 'package:equatable/equatable.dart';

/// Request para crear un nuevo mensaje
class CreateMessageRequest extends Equatable {
  final String senderId;
  final String body;

  const CreateMessageRequest({
    required this.senderId,
    required this.body,
  });

  factory CreateMessageRequest.fromJson(Map<String, dynamic> json) {
    return CreateMessageRequest(
      senderId: json['senderId'] as String,
      body: json['body'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'senderId': senderId,
      'body': body,
    };
  }

  @override
  List<Object?> get props => [senderId, body];
}