import 'package:equatable/equatable.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

/// Eventos para cargar chats
class ChatListLoadRequested extends ChatEvent {
  final String userId;

  const ChatListLoadRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Eventos para cargar mensajes de un chat específico
class ChatMessagesLoadRequested extends ChatEvent {
  final String groupId;

  const ChatMessagesLoadRequested({required this.groupId});

  @override
  List<Object?> get props => [groupId];
}

/// Eventos para enviar mensajes
class MessageSendRequested extends ChatEvent {
  final String groupId;
  final String senderId;
  final String body;
  final String? senderName;

  const MessageSendRequested({
    required this.groupId,
    required this.senderId,
    required this.body,
    this.senderName,
  });

  @override
  List<Object?> get props => [groupId, senderId, body, senderName];
}

/// Eventos para crear grupos
class GroupCreateRequested extends ChatEvent {
  final String name;
  final String? description;
  final String? imageUrl;
  final String visibility;
  final List<String> memberIds;
  final String createdBy;

  const GroupCreateRequested({
    required this.name,
    this.description,
    this.imageUrl,
    this.visibility = 'PRIVATE',
    this.memberIds = const [],
    required this.createdBy,
  });

  @override
  List<Object?> get props => [
    name, description, imageUrl, visibility, memberIds, createdBy,
  ];
}

/// Eventos para actualizar grupos
class GroupUpdateRequested extends ChatEvent {
  final String groupId;
  final String? name;
  final String? description;
  final String? imageUrl;
  final String? visibility;

  const GroupUpdateRequested({
    required this.groupId,
    this.name,
    this.description,
    this.imageUrl,
    this.visibility,
  });

  @override
  List<Object?> get props => [groupId, name, description, imageUrl, visibility];
}

/// Evento para eliminar grupos
class GroupDeleteRequested extends ChatEvent {
  final String groupId;

  const GroupDeleteRequested({required this.groupId});

  @override
  List<Object?> get props => [groupId];
}

/// Evento para cargar información específica de un grupo
class GroupInfoLoadRequested extends ChatEvent {
  final String groupId;

  const GroupInfoLoadRequested({required this.groupId});

  @override
  List<Object?> get props => [groupId];
}

/// Evento para refrescar la lista de chats
class ChatListRefreshRequested extends ChatEvent {
  final String userId;

  const ChatListRefreshRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Evento para refrescar mensajes de un chat
class ChatMessagesRefreshRequested extends ChatEvent {
  final String groupId;

  const ChatMessagesRefreshRequested({required this.groupId});

  @override
  List<Object?> get props => [groupId];
}

/// Evento para limpiar el estado actual
class ChatStateClearRequested extends ChatEvent {}

/// Evento para seleccionar un chat (navegación)
class ChatSelectedEvent extends ChatEvent {
  final String groupId;
  final String groupName;

  const ChatSelectedEvent({
    required this.groupId,
    required this.groupName,
  });

  @override
  List<Object?> get props => [groupId, groupName];
}

/// Eventos para enviar imágenes
class ChatImageUploadRequested extends ChatEvent {
  final String groupId;
  final String senderId;
  final String imagePath;

  const ChatImageUploadRequested({
    required this.groupId,
    required this.senderId,
    required this.imagePath,
  });

  @override
  List<Object?> get props => [groupId, senderId, imagePath];
}

/// Evento para enviar una imagen ya subida a Cloudinary
class ChatImageSendRequested extends ChatEvent {
  final String groupId;
  final String senderId;
  final String imageUrl;

  const ChatImageSendRequested({
    required this.groupId,
    required this.senderId,
    required this.imageUrl,
  });

  @override
  List<Object?> get props => [groupId, senderId, imageUrl];
}

/// Eventos para cargar imágenes de un grupo
class ChatImagesLoadRequested extends ChatEvent {
  final String groupId;

  const ChatImagesLoadRequested({required this.groupId});

  @override
  List<Object?> get props => [groupId];
}

/// Eventos para eliminar una imagen
class ChatImageDeleteRequested extends ChatEvent {
  final String groupId;
  final String imageId;

  const ChatImageDeleteRequested({
    required this.groupId,
    required this.imageId,
  });

  @override
  List<Object?> get props => [groupId, imageId];
}