import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/models.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  // TODO: Agregar repositorio cuando se implemente el networking
  // final ChatRepository _chatRepository;

  ChatBloc() : super(ChatInitial()) {
    on<ChatListLoadRequested>(_onChatListLoadRequested);
    on<ChatListRefreshRequested>(_onChatListRefreshRequested);
    on<ChatMessagesLoadRequested>(_onChatMessagesLoadRequested);
    on<ChatMessagesRefreshRequested>(_onChatMessagesRefreshRequested);
    on<MessageSendRequested>(_onMessageSendRequested);
    on<GroupCreateRequested>(_onGroupCreateRequested);
    on<GroupUpdateRequested>(_onGroupUpdateRequested);
    on<GroupDeleteRequested>(_onGroupDeleteRequested);
    on<GroupInfoLoadRequested>(_onGroupInfoLoadRequested);
    on<ChatSelectedEvent>(_onChatSelectedEvent);
    on<ChatStateClearRequested>(_onChatStateClearRequested);
  }

  /// Cargar lista de chats del usuario
  Future<void> _onChatListLoadRequested(
    ChatListLoadRequested event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatListLoading());
    
    try {
      // TODO: Implementar llamada al repositorio
      // final chats = await _chatRepository.getChatsByUser(event.userId);
      
      // Mock data por ahora
      await Future.delayed(const Duration(seconds: 1));
      final mockChats = _generateMockChats();
      
      if (mockChats.isEmpty) {
        emit(ChatListEmpty());
      } else {
        emit(ChatListLoaded(chats: mockChats));
      }
    } catch (error) {
      emit(ChatListError(
        message: 'Error al cargar chats: ${error.toString()}',
        errorCode: 'CHAT_LIST_LOAD_ERROR',
      ));
    }
  }

  /// Refrescar lista de chats
  Future<void> _onChatListRefreshRequested(
    ChatListRefreshRequested event,
    Emitter<ChatState> emit,
  ) async {
    // Para refresh, no mostramos loading, solo actualizamos
    try {
      // TODO: Implementar llamada al repositorio
      // final chats = await _chatRepository.getChatsByUser(event.userId);
      
      await Future.delayed(const Duration(milliseconds: 500));
      final mockChats = _generateMockChats();
      
      if (mockChats.isEmpty) {
        emit(ChatListEmpty());
      } else {
        emit(ChatListLoaded(chats: mockChats));
      }
    } catch (error) {
      emit(ChatListError(
        message: 'Error al refrescar chats: ${error.toString()}',
        errorCode: 'CHAT_LIST_REFRESH_ERROR',
      ));
    }
  }

  /// Cargar mensajes de un chat específico
  Future<void> _onChatMessagesLoadRequested(
    ChatMessagesLoadRequested event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatMessagesLoading());
    
    try {
      // TODO: Implementar llamada al repositorio
      // final messages = await _chatRepository.getMessagesByGroup(event.groupId);
      
      await Future.delayed(const Duration(seconds: 1));
      final mockMessages = _generateMockMessages(event.groupId);
      final groupName = 'Grupo Demo'; // TODO: Obtener del repositorio
      
      if (mockMessages.isEmpty) {
        emit(ChatMessagesEmpty(
          groupId: event.groupId,
          groupName: groupName,
        ));
      } else {
        emit(ChatMessagesLoaded(
          messages: mockMessages,
          groupId: event.groupId,
          groupName: groupName,
        ));
      }
    } catch (error) {
      emit(ChatMessagesError(
        message: 'Error al cargar mensajes: ${error.toString()}',
        groupId: event.groupId,
        errorCode: 'CHAT_MESSAGES_LOAD_ERROR',
      ));
    }
  }

  /// Refrescar mensajes de un chat
  Future<void> _onChatMessagesRefreshRequested(
    ChatMessagesRefreshRequested event,
    Emitter<ChatState> emit,
  ) async {
    try {
      // TODO: Implementar llamada al repositorio
      // final messages = await _chatRepository.getMessagesByGroup(event.groupId);
      
      await Future.delayed(const Duration(milliseconds: 500));
      final mockMessages = _generateMockMessages(event.groupId);
      final groupName = 'Grupo Demo'; // TODO: Obtener del repositorio
      
      if (mockMessages.isEmpty) {
        emit(ChatMessagesEmpty(
          groupId: event.groupId,
          groupName: groupName,
        ));
      } else {
        emit(ChatMessagesLoaded(
          messages: mockMessages,
          groupId: event.groupId,
          groupName: groupName,
        ));
      }
    } catch (error) {
      emit(ChatMessagesError(
        message: 'Error al refrescar mensajes: ${error.toString()}',
        groupId: event.groupId,
        errorCode: 'CHAT_MESSAGES_REFRESH_ERROR',
      ));
    }
  }

  /// Enviar mensaje
  Future<void> _onMessageSendRequested(
    MessageSendRequested event,
    Emitter<ChatState> emit,
  ) async {
    try {
      // TODO: Implementar llamada al repositorio
      // final message = await _chatRepository.sendMessage(
      //   groupId: event.groupId,
      //   senderId: event.senderId,
      //   body: event.body,
      // );
      
      await Future.delayed(const Duration(milliseconds: 800));
      final newMessage = MessageResponse(
        messageId: DateTime.now().millisecondsSinceEpoch.toString(),
        groupId: event.groupId,
        senderId: event.senderId,
        senderUsername: 'Usuario Actual',
        body: event.body,
        sentAt: DateTime.now(),
        status: 'SENT',
      );
      
      emit(MessageSent(message: newMessage));
      
      // Después de enviar, refrescar mensajes
      add(ChatMessagesRefreshRequested(groupId: event.groupId));
    } catch (error) {
      emit(MessageSendError(
        message: 'Error al enviar mensaje: ${error.toString()}',
        groupId: event.groupId,
        errorCode: 'MESSAGE_SEND_ERROR',
      ));
    }
  }

  /// Crear grupo
  Future<void> _onGroupCreateRequested(
    GroupCreateRequested event,
    Emitter<ChatState> emit,
  ) async {
    emit(GroupActionLoading());
    
    try {
      // TODO: Implementar llamada al repositorio
      // final group = await _chatRepository.createGroup(
      //   name: event.name,
      //   description: event.description,
      //   ...
      // );
      
      await Future.delayed(const Duration(seconds: 1));
      final newGroup = ChatItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: event.name,
        description: event.description,
        imageUrl: event.imageUrl,
        memberIds: event.memberIds,
        visibility: event.visibility,
        createdBy: event.createdBy,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      emit(GroupCreated(group: newGroup));
    } catch (error) {
      emit(GroupActionError(
        message: 'Error al crear grupo: ${error.toString()}',
        errorCode: 'GROUP_CREATE_ERROR',
      ));
    }
  }

  /// Actualizar grupo
  Future<void> _onGroupUpdateRequested(
    GroupUpdateRequested event,
    Emitter<ChatState> emit,
  ) async {
    emit(GroupActionLoading());
    
    try {
      // TODO: Implementar llamada al repositorio
      // final group = await _chatRepository.updateGroup(
      //   groupId: event.groupId,
      //   name: event.name,
      //   ...
      // );
      
      await Future.delayed(const Duration(seconds: 1));
      final updatedGroup = ChatItem(
        id: event.groupId,
        name: event.name ?? 'Grupo Actualizado',
        description: event.description,
        imageUrl: event.imageUrl,
        createdBy: 'user1',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now(),
      );
      
      emit(GroupUpdated(group: updatedGroup));
    } catch (error) {
      emit(GroupActionError(
        message: 'Error al actualizar grupo: ${error.toString()}',
        groupId: event.groupId,
        errorCode: 'GROUP_UPDATE_ERROR',
      ));
    }
  }

  /// Eliminar grupo
  Future<void> _onGroupDeleteRequested(
    GroupDeleteRequested event,
    Emitter<ChatState> emit,
  ) async {
    emit(GroupActionLoading());
    
    try {
      // TODO: Implementar llamada al repositorio
      // await _chatRepository.deleteGroup(event.groupId);
      
      await Future.delayed(const Duration(seconds: 1));
      emit(GroupDeleted(groupId: event.groupId));
    } catch (error) {
      emit(GroupActionError(
        message: 'Error al eliminar grupo: ${error.toString()}',
        groupId: event.groupId,
        errorCode: 'GROUP_DELETE_ERROR',
      ));
    }
  }

  /// Cargar información específica del grupo
  Future<void> _onGroupInfoLoadRequested(
    GroupInfoLoadRequested event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading());
    
    try {
      // TODO: Implementar llamada al repositorio
      // final group = await _chatRepository.getGroupById(event.groupId);
      
      await Future.delayed(const Duration(milliseconds: 500));
      final groupInfo = ChatItem(
        id: event.groupId,
        name: 'Información del Grupo',
        description: 'Descripción del grupo de ejemplo',
        createdBy: 'user1',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now(),
      );
      
      emit(GroupInfoLoaded(group: groupInfo));
    } catch (error) {
      emit(ChatError(
        message: 'Error al cargar información del grupo: ${error.toString()}',
        errorCode: 'GROUP_INFO_LOAD_ERROR',
      ));
    }
  }

  /// Seleccionar chat para navegación
  Future<void> _onChatSelectedEvent(
    ChatSelectedEvent event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatSelected(
      groupId: event.groupId,
      groupName: event.groupName,
    ));
  }

  /// Limpiar estado
  Future<void> _onChatStateClearRequested(
    ChatStateClearRequested event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatInitial());
  }

  /// Mock data para desarrollo - será removido cuando se implemente el networking
  List<ChatItem> _generateMockChats() {
    return [
      ChatItem(
        id: '1',
        name: 'Equipo de Desarrollo',
        description: 'Chat del equipo de desarrollo',
        lastMessage: '¿Cómo van con el nuevo feature?',
        lastMessageTime: DateTime.now().subtract(const Duration(minutes: 15)),
        lastSenderId: 'user2',
        lastSenderName: 'Juan Pérez',
        unreadCount: 3,
        memberIds: ['user1', 'user2', 'user3'],
        createdBy: 'user1',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(minutes: 15)),
      ),
      ChatItem(
        id: '2',
        name: 'Proyecto Mobile',
        description: 'Discusiones sobre el proyecto móvil',
        lastMessage: 'Revisar los nuevos diseños',
        lastMessageTime: DateTime.now().subtract(const Duration(hours: 2)),
        lastSenderId: 'user3',
        lastSenderName: 'María García',
        unreadCount: 0,
        memberIds: ['user1', 'user3', 'user4'],
        createdBy: 'user3',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      ChatItem(
        id: '3',
        name: 'Reuniones Semanales',
        description: 'Chat para coordinar reuniones',
        lastMessage: 'La reunión será a las 3pm',
        lastMessageTime: DateTime.now().subtract(const Duration(days: 1)),
        lastSenderId: 'user1',
        lastSenderName: 'Tú',
        unreadCount: 1,
        memberIds: ['user1', 'user2', 'user3', 'user4', 'user5'],
        createdBy: 'user1',
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }

  List<MessageResponse> _generateMockMessages(String groupId) {
    final baseTime = DateTime.now();
    return [
      MessageResponse(
        messageId: '1',
        groupId: groupId,
        senderId: 'user2',
        senderUsername: 'Juan Pérez',
        body: 'Hola equipo! ¿Cómo van las cosas?',
        sentAt: baseTime.subtract(const Duration(hours: 2)),
      ),
      MessageResponse(
        messageId: '2',
        groupId: groupId,
        senderId: 'user1',
        senderUsername: 'Tú',
        body: 'Todo bien! Estoy trabajando en la nueva feature',
        sentAt: baseTime.subtract(const Duration(hours: 1, minutes: 45)),
      ),
      MessageResponse(
        messageId: '3',
        groupId: groupId,
        senderId: 'user3',
        senderUsername: 'María García',
        body: 'Perfecto! ¿Necesitan ayuda con algo específico?',
        sentAt: baseTime.subtract(const Duration(hours: 1, minutes: 30)),
      ),
      MessageResponse(
        messageId: '4',
        groupId: groupId,
        senderId: 'user1',
        senderUsername: 'Tú',
        body: 'Por ahora todo bien, gracias! 👍',
        sentAt: baseTime.subtract(const Duration(minutes: 15)),
      ),
    ];
  }
}