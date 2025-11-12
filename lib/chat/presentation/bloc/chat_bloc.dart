import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/chat_repository.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository _chatRepository;

  ChatBloc({required ChatRepository chatRepository}) 
    : _chatRepository = chatRepository,
      super(ChatInitial()) {
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
      print('📱 ChatBloc: Loading chats for user ${event.userId}');
      final chats = await _chatRepository.getUserGroups(event.userId);
      
      if (chats.isEmpty) {
        print('📱 ChatBloc: No chats found for user');
        emit(ChatListEmpty());
      } else {
        print('📱 ChatBloc: Loaded ${chats.length} chats for user');
        emit(ChatListLoaded(chats: chats));
      }
    } catch (error) {
      print('❌ ChatBloc: Error loading chats: $error');
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
      print('🔄 ChatBloc: Refreshing chats for user ${event.userId}');
      final chats = await _chatRepository.getUserGroups(event.userId);
      
      if (chats.isEmpty) {
        print('🔄 ChatBloc: No chats found after refresh');
        emit(ChatListEmpty());
      } else {
        print('🔄 ChatBloc: Refreshed ${chats.length} chats for user');
        emit(ChatListLoaded(chats: chats));
      }
    } catch (error) {
      print('❌ ChatBloc: Error refreshing chats: $error');
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
      print('📨 ChatBloc: Loading messages for group ${event.groupId}');
      
      // Obtener información del grupo y mensajes
      final group = await _chatRepository.getGroupById(event.groupId);
      final messages = await _chatRepository.getGroupMessages(event.groupId);
      
      if (messages.isEmpty) {
        print('📨 ChatBloc: No messages found for group');
        emit(ChatMessagesEmpty(
          groupId: event.groupId,
          groupName: group.name,
        ));
      } else {
        print('📨 ChatBloc: Loaded ${messages.length} messages for group');
        emit(ChatMessagesLoaded(
          messages: messages,
          groupId: event.groupId,
          groupName: group.name,
        ));
      }
    } catch (error) {
      print('❌ ChatBloc: Error loading messages: $error');
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
      print('🔄 ChatBloc: Refreshing messages for group ${event.groupId}');
      
      // Obtener información del grupo y mensajes
      final group = await _chatRepository.getGroupById(event.groupId);
      final messages = await _chatRepository.getGroupMessages(event.groupId);
      
      if (messages.isEmpty) {
        print('🔄 ChatBloc: No messages found after refresh');
        emit(ChatMessagesEmpty(
          groupId: event.groupId,
          groupName: group.name,
        ));
      } else {
        print('🔄 ChatBloc: Refreshed ${messages.length} messages for group');
        emit(ChatMessagesLoaded(
          messages: messages,
          groupId: event.groupId,
          groupName: group.name,
        ));
      }
    } catch (error) {
      print('❌ ChatBloc: Error refreshing messages: $error');
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
      print('📤 ChatBloc: Sending message to group ${event.groupId}');
      
      final message = await _chatRepository.sendMessage(
        groupId: event.groupId,
        content: event.body,
        senderId: event.senderId,
        senderName: event.senderName ?? 'Usuario',
        messageType: 'TEXT',
      );
      
      print('📤 ChatBloc: Message sent successfully');
      
      // Actualización optimista: agregar el mensaje a la lista actual
      final currentState = state;
      if (currentState is ChatMessagesLoaded) {
        // Si ya hay mensajes cargados, agregar el nuevo mensaje a la lista
        final updatedMessages = [...currentState.messages, message];
        print('📤 ChatBloc: Adding message optimistically to existing list (${updatedMessages.length} messages)');
        emit(ChatMessagesLoaded(
          messages: updatedMessages,
          groupId: currentState.groupId,
          groupName: currentState.groupName,
        ));
      } else {
        // Si no hay estado previo, emitir MessageSent 
        emit(MessageSent(message: message));
      }
      
    } catch (error) {
      print('❌ ChatBloc: Error sending message: $error');
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
      print('👥 ChatBloc: Creating new group "${event.name}"');
      
      final group = await _chatRepository.createGroup(
        name: event.name,
        description: event.description ?? '',
        visibility: event.visibility,
        createdBy: event.createdBy,
        memberIds: event.memberIds,
        imageUrl: event.imageUrl,
      );
      
      print('👥 ChatBloc: Group created successfully: ${group.id}');
      emit(GroupCreated(group: group));
    } catch (error) {
      print('❌ ChatBloc: Error creating group: $error');
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
      print('🔄 ChatBloc: Updating group ${event.groupId}');
      
      final group = await _chatRepository.updateGroup(
        groupId: event.groupId,
        name: event.name ?? '',
        description: event.description ?? '',
        visibility: event.visibility ?? 'PUBLIC',
        imageUrl: event.imageUrl,
      );
      
      print('🔄 ChatBloc: Group updated successfully: ${group.id}');
      emit(GroupUpdated(group: group));
    } catch (error) {
      print('❌ ChatBloc: Error updating group: $error');
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
      print('🗑️ ChatBloc: Deleting group ${event.groupId}');
      
      await _chatRepository.deleteGroup(event.groupId);
      
      print('🗑️ ChatBloc: Group deleted successfully');
      emit(GroupDeleted(groupId: event.groupId));
    } catch (error) {
      print('❌ ChatBloc: Error deleting group: $error');
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
      print('ℹ️ ChatBloc: Loading group info for ${event.groupId}');
      
      final group = await _chatRepository.getGroupById(event.groupId);
      
      print('ℹ️ ChatBloc: Group info loaded successfully');
      emit(GroupInfoLoaded(group: group));
    } catch (error) {
      print('❌ ChatBloc: Error loading group info: $error');
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
    print('🔄 ChatBloc: State cleared, emitting ChatInitial');
    emit(ChatInitial());
  }

  /// Mock data para desarrollo - será removido cuando se implemente el networking
}