import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import '../theme/chat_colors.dart';
import '../../../shared/widgets/avatar_widget.dart';

/// Vista para editar información de un grupo existente
class EditGroupView extends StatefulWidget {
  final String groupId;

  const EditGroupView({
    super.key,
    required this.groupId,
  });

  @override
  State<EditGroupView> createState() => _EditGroupViewState();
}

class _EditGroupViewState extends State<EditGroupView> {
  late final ChatBloc _chatBloc;
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String? _currentImageUrl;
  String? _newImageUrl;

  @override
  void initState() {
    super.initState();
    _chatBloc = context.read<ChatBloc>();
    _loadGroupInfo();
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _loadGroupInfo() {
    _chatBloc.add(GroupInfoLoadRequested(groupId: widget.groupId));
  }

  bool get _hasChanges {
    // TODO: Comparar con datos originales
    return _groupNameController.text.trim().isNotEmpty || 
           _descriptionController.text.trim().isNotEmpty ||
           _newImageUrl != _currentImageUrl;
  }

  void _updateGroup() {
    if (_hasChanges) {
      _chatBloc.add(GroupUpdateRequested(
        groupId: widget.groupId,
        name: _groupNameController.text.trim().isNotEmpty 
            ? _groupNameController.text.trim() 
            : null,
        description: _descriptionController.text.trim().isNotEmpty 
            ? _descriptionController.text.trim() 
            : null,
        imageUrl: _newImageUrl,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ChatColors.background,
      appBar: _buildAppBar(),
      body: BlocConsumer<ChatBloc, ChatState>(
        listener: (context, state) {
          if (state is GroupInfoLoaded) {
            _populateFields(state.group);
          } else if (state is GroupUpdated) {
            // Solo navegar de vuelta, sin SnackBar
            Navigator.of(context).pop();
          } else if (state is GroupActionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ChatLoading) {
            return _buildLoading();
          } else if (state is ChatError) {
            return _buildErrorState(state.message);
          }
          
          return _buildContent(state);
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: ChatColors.background,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(
          Icons.close,
          color: ChatColors.textPrimary,
        ),
      ),
      title: const Text(
        'Editar grupo',
        style: TextStyle(
          color: ChatColors.titleColor,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        BlocBuilder<ChatBloc, ChatState>(
          builder: (context, state) {
            final isLoading = state is GroupActionLoading;
            
            return TextButton(
              onPressed: (_hasChanges && !isLoading) ? _updateGroup : null,
              child: isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: ChatColors.accent,
                      ),
                    )
                  : Text(
                      'Guardar',
                      style: TextStyle(
                        color: (_hasChanges && !isLoading) 
                            ? ChatColors.accent 
                            : ChatColors.textSecondary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            );
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildContent(ChatState state) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGroupImageEditor(),
            const SizedBox(height: 24),
            _buildGroupNameField(),
            const SizedBox(height: 16),
            _buildDescriptionField(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(
        color: ChatColors.accent,
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
            'Error al cargar grupo',
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
            onPressed: _loadGroupInfo,
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

  Widget _buildGroupImageEditor() {
    return Center(
      child: Column(
        children: [
          const Text(
            'Imagen del grupo',
            style: TextStyle(
              color: ChatColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          AvatarWidget(
            imageUrl: _newImageUrl ?? _currentImageUrl,
            size: 120,
            isEditable: true,
            showEditHint: true,
            onImageChanged: (String newImageUrl) {
              setState(() {
                _newImageUrl = newImageUrl;
              });
              print('🖼️ Group image updated: $newImageUrl');
            },
            onImageRemoved: () {
              setState(() {
                _newImageUrl = null;
              });
              print('🗑️ Group image removed');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGroupNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nombre del grupo',
          style: TextStyle(
            color: ChatColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _groupNameController,
          style: const TextStyle(color: ChatColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Ingresa un nuevo nombre...',
            hintStyle: const TextStyle(color: ChatColors.textSecondary),
            filled: true,
            fillColor: ChatColors.fieldBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          maxLength: 50,
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Descripción',
          style: TextStyle(
            color: ChatColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _descriptionController,
          style: const TextStyle(color: ChatColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Actualiza la descripción...',
            hintStyle: const TextStyle(color: ChatColors.textSecondary),
            filled: true,
            fillColor: ChatColors.fieldBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          maxLines: 3,
          maxLength: 200,
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  void _populateFields(dynamic group) {
    setState(() {
      _groupNameController.text = group.name;
      _descriptionController.text = group.description ?? '';
      _currentImageUrl = group.imageUrl;
    });
  }
}