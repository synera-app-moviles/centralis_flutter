import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import '../theme/chat_colors.dart';

/// Vista para crear un nuevo grupo de chat
class CreateGroupView extends StatefulWidget {
  const CreateGroupView({super.key});

  @override
  State<CreateGroupView> createState() => _CreateGroupViewState();
}

class _CreateGroupViewState extends State<CreateGroupView> {
  late final ChatBloc _chatBloc;
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String _selectedVisibility = 'PRIVATE';
  List<String> _selectedParticipants = [];
  String? _selectedImageUrl;

  // TODO: Obtener del usuario logueado
  static const String _currentUserId = 'user1';

  // Mock data de usuarios disponibles
  final List<Map<String, String>> _availableUsers = [
    {'id': 'user2', 'name': 'Juan Pérez', 'email': 'juan@example.com'},
    {'id': 'user3', 'name': 'María García', 'email': 'maria@example.com'},
    {'id': 'user4', 'name': 'Carlos López', 'email': 'carlos@example.com'},
    {'id': 'user5', 'name': 'Ana Martínez', 'email': 'ana@example.com'},
    {'id': 'user6', 'name': 'Luis Rodríguez', 'email': 'luis@example.com'},
  ];

  @override
  void initState() {
    super.initState();
    _chatBloc = context.read<ChatBloc>();
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    return _groupNameController.text.trim().isNotEmpty &&
           _selectedParticipants.isNotEmpty;
  }

  void _createGroup() {
    if (_isFormValid) {
      _chatBloc.add(GroupCreateRequested(
        name: _groupNameController.text.trim(),
        description: _descriptionController.text.trim().isNotEmpty 
            ? _descriptionController.text.trim() 
            : null,
        imageUrl: _selectedImageUrl,
        visibility: _selectedVisibility,
        memberIds: [..._selectedParticipants, _currentUserId],
        createdBy: _currentUserId,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ChatColors.background,
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
      padding: const EdgeInsets.all(16),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(
                Icons.close,
                color: ChatColors.textPrimary,
                size: 24,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Crear grupo',
              style: TextStyle(
                color: ChatColors.titleColor,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            BlocConsumer<ChatBloc, ChatState>(
              listener: (context, state) {
                if (state is GroupCreated) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Grupo creado exitosamente'),
                      backgroundColor: ChatColors.accent,
                    ),
                  );
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
                final isLoading = state is GroupActionLoading;
                
                return ElevatedButton(
                  onPressed: (_isFormValid && !isLoading) ? _createGroup : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ChatColors.accent,
                    foregroundColor: ChatColors.textPrimary,
                    disabledBackgroundColor: ChatColors.cardBackground,
                    disabledForegroundColor: ChatColors.textSecondary,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: ChatColors.textPrimary,
                          ),
                        )
                      : const Text('Crear'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImagePicker(),
            const SizedBox(height: 20),
            _buildGroupNameField(),
            const SizedBox(height: 16),
            _buildDescriptionField(),
            const SizedBox(height: 16),
            _buildVisibilitySelector(),
            const SizedBox(height: 24),
            _buildParticipantsSection(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Center(
      child: GestureDetector(
        onTap: _pickImage,
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: ChatColors.cardBackground,
            shape: BoxShape.circle,
            border: Border.all(
              color: ChatColors.accent.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: _selectedImageUrl != null
              ? CircleAvatar(
                  radius: 58,
                  backgroundImage: NetworkImage(_selectedImageUrl!),
                )
              : const Icon(
                  Icons.add_a_photo,
                  size: 40,
                  color: ChatColors.textSecondary,
                ),
        ),
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
            hintText: 'Ej: Equipo de desarrollo',
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
          'Descripción (opcional)',
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
            hintText: 'Describe de qué trata este grupo...',
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
        ),
      ],
    );
  }

  Widget _buildVisibilitySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Visibilidad',
          style: TextStyle(
            color: ChatColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildVisibilityOption(
                'PRIVATE',
                'Privado',
                'Solo miembros invitados',
                Icons.lock,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildVisibilityOption(
                'PUBLIC',
                'Público',
                'Cualquiera puede unirse',
                Icons.public,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVisibilityOption(
    String value,
    String title,
    String subtitle,
    IconData icon,
  ) {
    final isSelected = _selectedVisibility == value;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedVisibility = value),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? ChatColors.accent.withOpacity(0.2) : ChatColors.fieldBackground,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? ChatColors.accent : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? ChatColors.accent : ChatColors.textSecondary,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? ChatColors.accent : ChatColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                color: ChatColors.textSecondary,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParticipantsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Participantes (${_selectedParticipants.length} seleccionados)',
          style: const TextStyle(
            color: ChatColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          constraints: const BoxConstraints(maxHeight: 300),
          decoration: BoxDecoration(
            color: ChatColors.fieldBackground,
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _availableUsers.length,
            itemBuilder: (context, index) {
              final user = _availableUsers[index];
              final isSelected = _selectedParticipants.contains(user['id']);
              
              return ListTile(
                leading: CircleAvatar(
                  radius: 20,
                  backgroundColor: ChatColors.cardBackground,
                  child: Text(
                    user['name']![0].toUpperCase(),
                    style: const TextStyle(
                      color: ChatColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  user['name']!,
                  style: const TextStyle(
                    color: ChatColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  user['email']!,
                  style: const TextStyle(
                    color: ChatColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                trailing: Checkbox(
                  value: isSelected,
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        _selectedParticipants.add(user['id']!);
                      } else {
                        _selectedParticipants.remove(user['id']!);
                      }
                    });
                  },
                  activeColor: ChatColors.accent,
                  checkColor: ChatColors.textPrimary,
                ),
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedParticipants.remove(user['id']!);
                    } else {
                      _selectedParticipants.add(user['id']!);
                    }
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _pickImage() {
    // TODO: Implementar selector de imagen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Próximamente: Selector de imagen'),
        backgroundColor: ChatColors.accent,
      ),
    );
  }
}