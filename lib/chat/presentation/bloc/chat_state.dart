import 'package:equatable/equatable.dart';
import '../../data/models/models.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class ChatInitial extends ChatState {}

/// Estados de carga
class ChatLoading extends ChatState {}

class ChatListLoading extends ChatState {}

class ChatMessagesLoading extends ChatState {}

class GroupActionLoading extends ChatState {}

/// Estados de éxito para lista de chats
class ChatListLoaded extends ChatState {
  final List<ChatItem> chats;

  const ChatListLoaded({required this.chats});

  @override
  List<Object?> get props => [chats];
}

/// Estados de éxito para mensajes
class ChatMessagesLoaded extends ChatState {
  final List<MessageResponse> messages;
  final String groupId;
  final String groupName;

  const ChatMessagesLoaded({
    required this.messages,
    required this.groupId,
    required this.groupName,
  });

  @override
  List<Object?> get props => [messages, groupId, groupName];
}

/// Estado cuando se carga información específica del grupo
class GroupInfoLoaded extends ChatState {
  final ChatItem group;

  const GroupInfoLoaded({required this.group});

  @override
  List<Object?> get props => [group];
}

/// Estados de éxito para acciones
class MessageSent extends ChatState {
  final MessageResponse message;

  const MessageSent({required this.message});

  @override
  List<Object?> get props => [message];
}

class GroupCreated extends ChatState {
  final ChatItem group;

  const GroupCreated({required this.group});

  @override
  List<Object?> get props => [group];
}

class GroupUpdated extends ChatState {
  final ChatItem group;

  const GroupUpdated({required this.group});

  @override
  List<Object?> get props => [group];
}

class GroupDeleted extends ChatState {
  final String groupId;

  const GroupDeleted({required this.groupId});

  @override
  List<Object?> get props => [groupId];
}

/// Estado cuando un chat es seleccionado (para navegación)
class ChatSelected extends ChatState {
  final String groupId;
  final String groupName;

  const ChatSelected({
    required this.groupId,
    required this.groupName,
  });

  @override
  List<Object?> get props => [groupId, groupName];
}

/// Estados de error
class ChatError extends ChatState {
  final String message;
  final String? errorCode;

  const ChatError({
    required this.message,
    this.errorCode,
  });

  @override
  List<Object?> get props => [message, errorCode];
}

class ChatListError extends ChatState {
  final String message;
  final String? errorCode;

  const ChatListError({
    required this.message,
    this.errorCode,
  });

  @override
  List<Object?> get props => [message, errorCode];
}

class ChatMessagesError extends ChatState {
  final String message;
  final String groupId;
  final String? errorCode;

  const ChatMessagesError({
    required this.message,
    required this.groupId,
    this.errorCode,
  });

  @override
  List<Object?> get props => [message, groupId, errorCode];
}

class MessageSendError extends ChatState {
  final String message;
  final String groupId;
  final String? errorCode;

  const MessageSendError({
    required this.message,
    required this.groupId,
    this.errorCode,
  });

  @override
  List<Object?> get props => [message, groupId, errorCode];
}

class GroupActionError extends ChatState {
  final String message;
  final String? groupId;
  final String? errorCode;

  const GroupActionError({
    required this.message,
    this.groupId,
    this.errorCode,
  });

  @override
  List<Object?> get props => [message, groupId, errorCode];
}

/// Estados de datos vacíos
class ChatListEmpty extends ChatState {}

class ChatMessagesEmpty extends ChatState {
  final String groupId;
  final String groupName;

  const ChatMessagesEmpty({
    required this.groupId,
    required this.groupName,
  });

  @override
  List<Object?> get props => [groupId, groupName];
}