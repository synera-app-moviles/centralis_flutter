import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import '../theme/chat_colors.dart';
import '../widgets/widgets.dart';

/// Página principal de chats - Lista de conversaciones
class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late final ChatBloc _chatBloc;
  final SecureStorageService _storage = SecureStorageService();

  @override
  void initState() {
    super.initState();
    _chatBloc = context.read<ChatBloc>();
    _loadChats();
  }

  Future<void> _loadChats() async {
    try {
      final userId = await _storage.getUserId();
      print('📱 ChatPage: Loading chats for userId: $userId');
      
      if (userId != null) {
        _chatBloc.add(ChatListLoadRequested(userId: userId));
      } else {
        print('❌ ChatPage: No userId found in storage');
        // Mostrar error o navegar al login
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: Usuario no autenticado'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      print('❌ ChatPage: Error getting userId: $error');
    }
  }

  Future<void> _refreshChats() async {
    try {
      final userId = await _storage.getUserId();
      print('🔄 ChatPage: Refreshing chats for userId: $userId');
      
      if (userId != null) {
        _chatBloc.add(ChatListRefreshRequested(userId: userId));
      }
    } catch (error) {
      print('❌ ChatPage: Error refreshing chats: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ChatColors.darkBackground,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: SafeArea(
        child: Stack(
          children: [

            Center(
              child: const Text(
                'Chats',
                style: TextStyle(
                  color: ChatColors.titleColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            Positioned(
              right: 0,
              child: IconButton(
                onPressed: _onCreateGroupPressed,
                icon: const Icon(
                  Icons.add,
                  color: ChatColors.textPrimary,
                  size: 28,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        // Estados específicos de lista de chats
        if (state is ChatListLoading) {
          return _buildLoading();
        } else if (state is ChatListLoaded) {
          return _buildChatsList(state.chats);
        } else if (state is ChatListEmpty) {
          return _buildEmptyState();
        } else if (state is ChatListError) {
          return _buildErrorState(state.message);
        }
        
        // Solo auto-cargar cuando se limpia el estado (regreso desde detail)
        if (state is ChatInitial) {
          print('🔄 ChatPage: Detected ChatInitial state, auto-loading chats');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _loadChats();
          });
          return _buildLoading();
        }
        
        // Para otros estados no relacionados con lista, mostrar empty
        print('🔄 ChatPage: Unhandled state: ${state.runtimeType}');
        return _buildEmptyState();
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

  Widget _buildChatsList(List<dynamic> chats) {
    return RefreshIndicator(
      onRefresh: () async {
        _refreshChats();
        await Future.delayed(const Duration(milliseconds: 500));
      },
      color: ChatColors.accent,
      backgroundColor: ChatColors.cardBackground,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: chats.length,
        separatorBuilder: (context, index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          height: 1,
          color: ChatColors.cardBackground,
        ),
        itemBuilder: (context, index) {
          final chat = chats[index];
          return ChatItemWidget(
            chat: chat,
            onTap: () => _onChatTap(chat),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
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
            'No tienes conversaciones',
            style: TextStyle(
              color: ChatColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Inicia una nueva conversación\ncreando un grupo',
            style: TextStyle(
              color: ChatColors.textSecondary,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _onCreateGroupPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: ChatColors.accent,
              foregroundColor: ChatColors.textPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            icon: const Icon(Icons.add),
            label: const Text('Crear grupo'),
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
            'Error al cargar chats',
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
            onPressed: _loadChats,
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

  void _onChatTap(dynamic chat) {
    // Disparar evento de selección para navegación
    _chatBloc.add(ChatSelectedEvent(
      groupId: chat.id,
      groupName: chat.name,
    ));
    
    // Navegar a ChatDetailView
    Navigator.pushNamed(context, '/chat/detail', arguments: {
      'groupId': chat.id,
      'groupName': chat.name,
    });
  }

  void _onCreateGroupPressed() {
    // Navegar a CreateGroupView
    Navigator.pushNamed(context, '/chat/create-group');
  }
}