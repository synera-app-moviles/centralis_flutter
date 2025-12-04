import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../data/models/models.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import '../theme/chat_colors.dart';
import '../widgets/widgets.dart';

/// Vista de detalle del chat - Conversación individual
class ChatDetailView extends StatefulWidget {
  final String groupId;
  final String groupName;

  const ChatDetailView({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  State<ChatDetailView> createState() => _ChatDetailViewState();
}

class _ChatDetailViewState extends State<ChatDetailView> {
  late final ChatBloc _chatBloc;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final SecureStorageService _storage = SecureStorageService();

  String? _currentUserId;
  
  // Variables dinámicas para la información del grupo
  late String _currentGroupName;
  String? _currentGroupImage;

  @override
  void initState() {
    super.initState();
    _chatBloc = context.read<ChatBloc>();
    _currentGroupName = widget.groupName; // Inicializar con el valor pasado
    _loadCurrentUserId();
    _loadGroupInfo(); // Cargar información completa del grupo
    _loadMessages();
  }

  Future<void> _loadGroupInfo() async {
    print('📋 ChatDetailView: Loading group info for ${widget.groupId}');
    _chatBloc.add(GroupInfoLoadRequested(groupId: widget.groupId));
  }

  Future<void> _loadCurrentUserId() async {
    try {
      final userId = await _storage.getUserId();
      setState(() {
        _currentUserId = userId;
      });
    } catch (error) {
      print('❌ Error loading current userId: $error');
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadMessages() {
    _chatBloc.add(ChatMessagesLoadRequested(groupId: widget.groupId));
  }

  void _refreshMessages() {
    _chatBloc.add(ChatMessagesRefreshRequested(groupId: widget.groupId));
  }

  void _sendMessage() {
    final messageText = _messageController.text.trim();
    if (messageText.isNotEmpty && _currentUserId != null) {
      _chatBloc.add(MessageSendRequested(
        groupId: widget.groupId,
        senderId: _currentUserId!,
        body: messageText,
      ));
      _messageController.clear();
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChatBloc, ChatState>(
      listener: (context, state) {
        // Manejar estados de imagen
        if (state is ChatImageUploaded) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Imagen enviada correctamente'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          // Añadir un pequeño delay y luego recargar mensajes para mostrar la nueva imagen
          Future.delayed(const Duration(milliseconds: 1000), () {
            _loadMessages();
          });
        } else if (state is ChatError && state.message.contains('image')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Error al enviar imagen: ${state.message}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: ChatColors.background,
        body: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _buildContent(),
            ),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return ChatHeaderWidget(
      title: _currentGroupName, // Usar nombre dinámico
      subtitle: null, 
      avatarUrl: _currentGroupImage, // Pasar la imagen del grupo
      onBackPressed: () {
        // Limpiar estado y volver a cargar la lista de chats
        print('🔙 ChatDetailView: Back pressed, clearing state');
        _chatBloc.add(ChatStateClearRequested());
        Navigator.of(context).pop();
      },
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(
            Icons.more_vert,
            color: ChatColors.textPrimary,
          ),
          color: ChatColors.cardBackground,
          onSelected: _onMenuSelected,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'info',
              child: Row(
                children: [
                  Icon(Icons.info, color: ChatColors.textPrimary),
                  SizedBox(width: 12),
                  Text(
                    'Info del grupo',
                    style: TextStyle(color: ChatColors.textPrimary),
                  ),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, color: ChatColors.textPrimary),
                  SizedBox(width: 12),
                  Text(
                    'Edit group',
                    style: TextStyle(color: ChatColors.textPrimary),
                  ),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 12),
                  Text(
                    'Delete group',
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContent() {
    return BlocConsumer<ChatBloc, ChatState>(
      listener: (context, state) {
        if (state is ChatMessagesLoaded) {
          // Messages loaded successfully - scroll to bottom to show the newest message
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToBottom();
          });
        } else if (state is MessageSent) {
          // Message sent successfully - reload messages and scroll to bottom 
          print('💬 ChatDetailView: Message sent successfully');
          _loadMessages(); // Recargar mensajes para mostrar el nuevo mensaje
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToBottom();
          });
        } else if (state is GroupInfoLoaded) {
          // Información del grupo cargada - actualizar nombre e imagen
          setState(() {
            _currentGroupName = state.group.name;
            _currentGroupImage = state.group.imageUrl;
          });
        } else if (state is GroupUpdated) {
          // El grupo fue actualizado - actualizar información local y recargar mensajes
          setState(() {
            _currentGroupName = state.group.name;
            _currentGroupImage = state.group.imageUrl;
          });
          
          // Recargar mensajes para asegurar que se muestren correctamente
          _loadMessages();
        } else if (state is GroupDeleted) {
          // Grupo eliminado - redirigir a la vista de chats y recargar lista
          if (_currentUserId != null) {
            _chatBloc.add(ChatListRefreshRequested(userId: _currentUserId!));
          }
          Navigator.of(context).pop();
        } else if (state is MessageSendError) {
          // Solo mostrar errores, no éxitos
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is ChatMessagesLoading) {
          return _buildLoading();
        } else if (state is ChatMessagesLoaded) {
          return _buildMessagesList(state.messages, state.images);
        } else if (state is ChatMessagesEmpty) {
          return _buildEmptyMessages();
        } else if (state is ChatMessagesError) {
          return _buildErrorState(state.message);
        }
        
        return _buildEmptyMessages();
      },
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(
        color: ChatColors.accent,
      ),
    );
  }

  Widget _buildMessagesList(List<dynamic> messages, List<dynamic> images) {
    // Combinar mensajes e imágenes ordenados por fecha
    final combinedContent = _combineMessagesAndImages(messages, images);
    
    return RefreshIndicator(
      onRefresh: () async {
        _refreshMessages();
        await Future.delayed(const Duration(milliseconds: 500));
      },
      color: ChatColors.accent,
      backgroundColor: ChatColors.cardBackground,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: combinedContent.length,
        itemBuilder: (context, index) {
          final item = combinedContent[index];
          final isMyContent = _currentUserId != null && item.senderId == _currentUserId;
          
          // Si es un mensaje de texto
          if (item is MessageResponse) {
            return MessageBubbleWidget(
              message: item,
              isMyMessage: isMyContent,
            );
          }
          // Si es una imagen
          else {
            return ChatImageBubbleWidget(
              chatImage: item,
              isMyImage: isMyContent,
            );
          }
        },
      ),
    );
  }

  /// Combina mensajes e imágenes ordenándolos por fecha de envío
  List<dynamic> _combineMessagesAndImages(List<dynamic> messages, List<dynamic> images) {
    final combined = <dynamic>[];
    combined.addAll(messages);
    combined.addAll(images);
    
    // Ordenar por fecha de envío (más antiguos primero para mostrar cronológicamente)
    combined.sort((a, b) {
      final dateA = a is MessageResponse ? a.sentAt : (a as ChatImage).sentAt;
      final dateB = b is MessageResponse ? b.sentAt : (b as ChatImage).sentAt;
      return dateA.compareTo(dateB);
    });
    
    return combined;
  }

  Widget _buildEmptyMessages() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: ChatColors.cardBackground,
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(
              Icons.chat_bubble_outline,
              size: 40,
              color: ChatColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No messages',
            style: TextStyle(
              color: ChatColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Be the first to write\na message in this group',
            style: TextStyle(
              color: ChatColors.textSecondary,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: ChatColors.cardBackground,
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(
              Icons.error_outline,
              size: 40,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Error loading messages',
            style: TextStyle(
              color: ChatColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(
              color: ChatColors.textSecondary,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadMessages,
            style: ElevatedButton.styleFrom(
              backgroundColor: ChatColors.accent,
              foregroundColor: ChatColors.textPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        final isLoading = state is GroupActionLoading;
        
        return MessageInputWidget(
          controller: _messageController,
          onSend: _sendMessage,
          isEnabled: !isLoading,
          hintText: isLoading ? 'Sending...' : 'Type a message...',
          // Pasar el widget de imagen como trailing widget
          trailingWidget: _currentUserId != null
              ? ChatImageAttachmentWidget(
                  groupId: widget.groupId,
                  currentUserId: _currentUserId!,
                )
              : null,
        );
      },
    );
  }

  void _onMenuSelected(String value) {
    switch (value) {
      case 'info':
        _onInfoPressed();
        break;
      case 'edit':
        _onEditPressed();
        break;
      case 'delete':
        _onDeletePressed();
        break;
    }
  }

  void _onInfoPressed() {
    // TODO: Mostrar información del grupo
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Próximamente: Información del grupo'),
        backgroundColor: ChatColors.accent,
      ),
    );
  }

  void _onEditPressed() {
    // Navegar a EditGroupView
    Navigator.pushNamed(context, '/chat/edit-group', arguments: {
      'groupId': widget.groupId,
    });
  }

  void _onDeletePressed() {
    _showDeleteDialog();
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ChatColors.cardBackground,
        title: const Text(
          'Delete group',
          style: TextStyle(color: ChatColors.textPrimary),
        ),
        content: const Text(
          'Are you sure you want to delete this group? This action cannot be undone.',
          style: TextStyle(color: ChatColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: ChatColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteGroup();
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteGroup() {
    _chatBloc.add(GroupDeleteRequested(groupId: widget.groupId));
  }
}