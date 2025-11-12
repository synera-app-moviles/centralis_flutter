import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import '../theme/chat_colors.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/bloc/profile_event.dart';
import '../../../profile/presentation/bloc/profile_state.dart';
import '../../../profile/data/models/profile_model.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/di/service_locator.dart';
import '../../../app/config/cloudinary_config.dart';
import '../../../shared/widgets/image_picker_widget.dart';

/// Vista para crear un nuevo grupo de chat
class CreateGroupView extends StatefulWidget {
  const CreateGroupView({super.key});

  @override
  State<CreateGroupView> createState() => _CreateGroupViewState();
}

class _CreateGroupViewState extends State<CreateGroupView> {
  late final ChatBloc _chatBloc;
  late final ProfileBloc _profileBloc;
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  String _selectedVisibility = 'PUBLIC';
  List<String> _selectedParticipants = [];
  String? _selectedImageUrl;
  List<ProfileModel> _availableProfiles = [];
  List<ProfileModel> _filteredProfiles = [];
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _chatBloc = context.read<ChatBloc>();
    _profileBloc = context.read<ProfileBloc>();
    
    // Cargar userId del usuario autenticado
    _loadCurrentUserId();
    
    // Cargar perfiles disponibles
    _profileBloc.add(AllProfilesLoadRequested());
    
    // Listener para búsqueda
    _searchController.addListener(_filterProfiles);
  }

  Future<void> _loadCurrentUserId() async {
    try {
      final storage = sl<SecureStorageService>();
      final userId = await storage.getUserId();
      if (mounted) {
        setState(() {
          _currentUserId = userId;
        });
      }
    } catch (e) {
      print('❌ Error loading current userId: $e');
    }
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    _descriptionController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _filterProfiles() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredProfiles = List.from(_availableProfiles);
      } else {
        _filteredProfiles = _availableProfiles.where((profile) {
          return profile.fullName.toLowerCase().contains(query) ||
                 profile.email.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  bool get _isFormValid {
    return _groupNameController.text.trim().isNotEmpty &&
           _selectedParticipants.isNotEmpty &&
           _currentUserId != null;
  }

  void _createGroup() {
    if (_isFormValid && _currentUserId != null) {
      _chatBloc.add(GroupCreateRequested(
        name: _groupNameController.text.trim(),
        description: _descriptionController.text.trim().isNotEmpty 
            ? _descriptionController.text.trim() 
            : null,
        imageUrl: _selectedImageUrl,
        visibility: _selectedVisibility,
        memberIds: [..._selectedParticipants, _currentUserId!],
        createdBy: _currentUserId!,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ProfileBloc, ProfileState>(
          listener: (context, state) {
            if (state is ProfilesLoaded) {
              setState(() {
                _availableProfiles = state.profiles;
                _filteredProfiles = List.from(_availableProfiles);
              });
            } else if (state is ProfileError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error loading employees: ${state.message}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),
        BlocListener<ChatBloc, ChatState>(
          listener: (context, state) async {
            if (state is GroupCreated) {
              // Recargar la lista de grupos y navegar de vuelta
              if (_currentUserId != null) {
                _chatBloc.add(ChatListRefreshRequested(userId: _currentUserId!));
              }
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
        ),
      ],
      child: Scaffold(
        backgroundColor: ChatColors.background,
        body: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
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
              'New group',
              style: TextStyle(
                color: ChatColors.titleColor,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
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
                  const SizedBox(height: 24),
                  _buildParticipantsSection(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
        _buildCreateButton(),
      ],
    );
  }

  Widget _buildCreateButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          final isLoading = state is GroupActionLoading;
          
          return ElevatedButton(
            onPressed: (_isFormValid && !isLoading) ? _createGroup : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: ChatColors.accent,
              foregroundColor: ChatColors.textPrimary,
              disabledBackgroundColor: ChatColors.cardBackground,
              disabledForegroundColor: ChatColors.textSecondary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: ChatColors.textPrimary,
                    ),
                  )
                : const Text(
                    'Create group',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      children: [
        // Previsualización de la imagen seleccionada
        if (_selectedImageUrl != null) ...[
          Container(
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
            child: CircleAvatar(
              radius: 58,
              backgroundImage: NetworkImage(_selectedImageUrl!),
            ),
          ),
          const SizedBox(height: 16),
        ],
        // Widget de selección de imagen
        ImagePickerWidget(
          imageType: ImageType.chat,
          currentImageUrl: _selectedImageUrl,
          onImageUploaded: (newImageUrl) {
            setState(() {
              _selectedImageUrl = newImageUrl;
            });
          },
          onImageRemoved: () {
            setState(() {
              _selectedImageUrl = null;
            });
          },
          buttonText: _selectedImageUrl != null ? 'Change Avatar' : 'Select Avatar',
        ),
      ],
    );
  }

  Widget _buildGroupNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Group name',
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
            hintText: 'Ex: Development Team',
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
          'Description',
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
            hintText: 'Describe what this group is about...',
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

  Widget _buildParticipantsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select participants',
          style: const TextStyle(
            color: ChatColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        // Campo de búsqueda
        TextField(
          controller: _searchController,
          style: const TextStyle(color: ChatColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Search for employees',
            hintStyle: const TextStyle(color: ChatColors.textSecondary),
            filled: true,
            fillColor: ChatColors.fieldBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(16),
            suffixIcon: const Icon(
              Icons.search,
              color: ChatColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: 16),
        BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const Center(
                child: CircularProgressIndicator(color: ChatColors.accent),
              );
            }
            
            if (state is ProfileError) {
              return Center(
                child: Text(
                  'Error: ${state.message}',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            if (_filteredProfiles.isEmpty) {
              return Center(
                child: Text(
                  'No se encontraron empleados',
                  style: const TextStyle(
                    color: ChatColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              );
            }

            return Container(
              constraints: const BoxConstraints(maxHeight: 300),
              decoration: BoxDecoration(
                color: ChatColors.fieldBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _filteredProfiles.length,
                itemBuilder: (context, index) {
                  final profile = _filteredProfiles[index];
                  final isSelected = _selectedParticipants.contains(profile.profileId);
                  
                  return ListTile(
                    leading: CircleAvatar(
                      radius: 20,
                      backgroundColor: ChatColors.cardBackground,
                      backgroundImage: profile.avatarUrl != null 
                          ? NetworkImage(profile.avatarUrl!) 
                          : null,
                      child: profile.avatarUrl == null
                          ? Text(
                              profile.fullName.isNotEmpty
                                  ? profile.fullName[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                color: ChatColors.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    title: Text(
                      profile.fullName.isNotEmpty ? profile.fullName : 'No name',
                      style: const TextStyle(
                        color: ChatColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      'EMPLOYEE',
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
                            _selectedParticipants.add(profile.profileId);
                          } else {
                            _selectedParticipants.remove(profile.profileId);
                          }
                        });
                      },
                      activeColor: ChatColors.accent,
                      checkColor: ChatColors.textPrimary,
                    ),
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedParticipants.remove(profile.profileId);
                        } else {
                          _selectedParticipants.add(profile.profileId);
                        }
                      });
                    },
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}