import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../shared/theme/colors.dart';
import '../../../shared/widgets/avatar_widget.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../../data/models/enums.dart';
import '../../data/models/profile_model.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/di/service_locator.dart';

/// Edit profile page with form for updating user information
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  
  Position? _selectedPosition;
  Department? _selectedDepartment;
  String? _avatarUrl; // Nueva variable para la URL del avatar
  bool _isLoading = false;
  ProfileModel? _currentProfile;
  String? _profileId;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    print('🔍 EditProfile: Cargando perfil del usuario logueado...');
    
    // Obtener userId del usuario logueado
    final storage = sl<SecureStorageService>();
    final userId = await storage.getUserId();
    
    if (userId != null && mounted) {
      print('✅ EditProfile: UserId encontrado: $userId');
      context.read<ProfileBloc>().add(ProfileLoadByUserRequested(userId));
    } else {
      print('❌ EditProfile: No se encontró userId');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: Usuario no autenticado'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  void _populateFormWithProfile(ProfileModel profile) {
    print('📝 EditProfile: Poblando formulario con datos del perfil');
    _currentProfile = profile;
    _profileId = profile.profileId;
    
    _firstNameController.text = profile.firstName;
    _lastNameController.text = profile.lastName;
    _emailController.text = profile.email;
    _selectedPosition = profile.position;
    _selectedDepartment = profile.department;
    _avatarUrl = profile.avatarUrl; // Cargar URL del avatar
    
    print('📝 Position from profile: ${profile.position.value}');
    print('📝 Department from profile: ${profile.department.value}');
    print('📝 Avatar URL: ${profile.avatarUrl}');
    
    setState(() {});
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _handleSaveProfile() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_profileId == null || _selectedPosition == null || _selectedDepartment == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: Datos del perfil incompletos'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      print('💾 EditProfile: Guardando cambios del perfil...');
      
      // Set loading state with timeout
      setState(() {
        _isLoading = true;
      });
      
      // Add a timeout to prevent infinite loading
      Timer(const Duration(seconds: 30), () {
        if (_isLoading && mounted) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error: La operación tomó mucho tiempo. Inténtalo de nuevo.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      });
      
      context.read<ProfileBloc>().add(ProfileUpdateRequested(
        profileId: _profileId!,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        avatarUrl: _avatarUrl, // Usar la URL del avatar actualizada
        position: _selectedPosition!,
        department: _selectedDepartment!,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CentralisColors.background,
      body: BlocListener<ProfileBloc, ProfileState>(
        listener: (context, state) {
          print('🎯 EditProfile: Estado recibido: ${state.runtimeType}');
          
          if (state is ProfileLoaded && _currentProfile == null) {
            // Cargar datos del perfil en el formulario
            print('✅ EditProfile: Perfil cargado, poblando formulario');
            _populateFormWithProfile(state.profile);
          } else if (state is ProfileUpdated) {
            print('✅ EditProfile: Perfil actualizado exitosamente');
            
            // Update local profile data with the updated profile
            _populateFormWithProfile(state.profile);
            
            setState(() {
              _isLoading = false;
            });
            
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Perfil actualizado exitosamente!'),
                backgroundColor: CentralisColors.success,
                duration: Duration(seconds: 2),
              ),
            );
            
            // Optional: Return after a short delay to allow user to see the updated data
            Future.delayed(const Duration(seconds: 1), () {
              if (mounted) {
                Navigator.pop(context, state.profile);
              }
            });
          } else if (state is ProfileError) {
            print('❌ EditProfile: Error: ${state.message}');
            setState(() {
              _isLoading = false;
            });
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is ProfileLoading) {
            print('⏳ EditProfile: Cargando...');
            // Don't set loading state here since we're already setting it in _handleSaveProfile
          }
        },
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            return SafeArea(
              child: Column(
                children: [
                  // Extra spacing for devices with notch/camera cutout
                  const SizedBox(height: 16),
                  
                  // Main content
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      color: CentralisColors.secondary,
                      child: _currentProfile == null
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    color: CentralisColors.primary,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Cargando perfil...',
                                    style: TextStyle(
                                      color: CentralisColors.onBackground,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : SingleChildScrollView(
                              child: Column(
                                children: [
                                  // Header
                                  _buildHeader(),
                                  
                                  // Profile form
                                  _buildProfileForm(),
                                  
                                  const SizedBox(height: 32),
                                ],
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back,
              color: CentralisColors.onBackground,
            ),
          ),
          Expanded(
            child: Text(
              'Edit Profile',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 48), // Balance the back button
        ],
      ),
    );
  }

  Widget _buildProfileForm() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Avatar section with Cloudinary integration
            AvatarWidget(
              imageUrl: _avatarUrl,
              onImageChanged: (newImageUrl) {
                setState(() {
                  _avatarUrl = newImageUrl;
                });
                print('🖼️ Avatar actualizado: $newImageUrl');
              },
              onImageRemoved: () {
                setState(() {
                  _avatarUrl = null;
                });
                print('🗑️ Avatar eliminado');
              },
              size: 120,
            ),
            const SizedBox(height: 32),
            
            // Form fields
            _buildInputField(
              label: 'First Name',
              controller: _firstNameController,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'First name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            _buildInputField(
              label: 'Last Name',
              controller: _lastNameController,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Last name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            _buildInputField(
              label: 'Email',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Email is required';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                    .hasMatch(value!)) {
                  return 'Enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Position dropdown
            _buildPositionDropdown(),
            const SizedBox(height: 16),
            
            // Department dropdown
            _buildDepartmentDropdown(),
            const SizedBox(height: 32),
            
            // Save button
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: CentralisColors.onBackground,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(
            color: CentralisColors.inputText,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: label,
            hintStyle: const TextStyle(
              color: CentralisColors.placeholder,
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSaveProfile,
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    CentralisColors.onPrimary,
                  ),
                ),
              )
            : const Text('Save Profile'),
      ),
    );
  }

  Widget _buildPositionDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Position',
          style: TextStyle(
            color: CentralisColors.onBackground,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: CentralisColors.background,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: CentralisColors.placeholder,
              width: 1,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<Position>(
              value: _selectedPosition,
              hint: Text(
                'Select Position',
                style: TextStyle(
                  color: CentralisColors.placeholder,
                  fontSize: 16,
                ),
              ),
              dropdownColor: CentralisColors.background,
              style: TextStyle(
                color: CentralisColors.onBackground,
                fontSize: 16,
              ),
              items: Position.values.map((position) {
                return DropdownMenuItem<Position>(
                  value: position,
                  child: Text(position.displayName),
                );
              }).toList(),
              onChanged: (Position? value) {
                setState(() {
                  _selectedPosition = value;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDepartmentDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Department',
          style: TextStyle(
            color: CentralisColors.onBackground,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: CentralisColors.background,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: CentralisColors.placeholder,
              width: 1,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<Department>(
              value: _selectedDepartment,
              hint: Text(
                'Select Department',
                style: TextStyle(
                  color: CentralisColors.placeholder,
                  fontSize: 16,
                ),
              ),
              dropdownColor: CentralisColors.background,
              style: TextStyle(
                color: CentralisColors.onBackground,
                fontSize: 16,
              ),
              items: Department.values.map((department) {
                return DropdownMenuItem<Department>(
                  value: department,
                  child: Text(department.displayName),
                );
              }).toList(),
              onChanged: (Department? value) {
                setState(() {
                  _selectedDepartment = value;
                });
              },
            ),
          ),
        ),
      ],
    );
  }
}
