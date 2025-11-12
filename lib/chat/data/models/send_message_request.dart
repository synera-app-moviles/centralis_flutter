import 'package:equatable/equatable.dart';

/// Request model para enviar un mensaje
class SendMessageRequest extends Equatable {
  final String body; // Cambiado de 'content' a 'body' para coincidir con la API
  final String senderId;

  const SendMessageRequest({
    required this.body,
    required this.senderId,
  });

  Map<String, dynamic> toJson() {
    return {
      'body': body,
      'senderId': senderId,
    };
  }

  @override
  List<Object?> get props => [body, senderId];
}