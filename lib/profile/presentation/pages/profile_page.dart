import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../shared/theme/colors.dart';
import '../../../app/routes/route_names.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_info_section.dart';
import '../widgets/profile_action_buttons.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../../data/models/enums.dart';
import '../../data/models/profile_model.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/di/service_locator.dart';

/// Profile page with read-only view and edit mode
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  
  @override
  void initState() {
    super.initState();
    // Load all profiles on page load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfilesWithAuthCheck();
    });
  }

  Future<void> _loadProfilesWithAuthCheck() async {
    print('🔍 ProfilePage: Verificando autenticación antes de cargar perfil del usuario...');
    
    // Verificar si hay token primero
    final storage = sl<SecureStorageService>();
    final token = await storage.getToken();
    final userId = await storage.getUserId();
    
    if (token != null && userId != null) {
      print('✅ ProfilePage: Token y userId encontrados, cargando perfil del usuario: $userId');
      if (mounted) {
        context.read<ProfileBloc>().add(ProfileLoadByUserRequested(userId));
      }
    } else {
      print('❌ ProfilePage: No hay token de autenticación o userId');
      print('   Token: ${token != null ? "✅" : "❌"}');
      print('   UserId: ${userId != null ? "✅" : "❌"}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Debes iniciar sesión para ver tu perfil'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  void _navigateToEditProfile() async {
    final result = await Navigator.pushNamed(context, RouteNames.editProfile);
    
    // If profile was updated successfully, reload the profile data
    if (result != null) {
      print('📱 ProfilePage: Profile updated, reloading data...');
      _loadProfilesWithAuthCheck();
    }
  }

  void _handleSignOut() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: CentralisColors.secondary,
        title: const Text(
          'Sign Out',
          style: TextStyle(color: CentralisColors.onBackground),
        ),
        content: const Text(
          'Are you sure you want to sign out?',
          style: TextStyle(color: CentralisColors.onBackground),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(
                context,
                RouteNames.signIn,
                (route) => false,
              );
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CentralisColors.background,
      body: BlocListener<ProfileBloc, ProfileState>(
        listener: (context, state) {
          print('🎯 ProfilePage: Estado recibido: ${state.runtimeType}');
          
          if (state is ProfileError) {
            print('❌ ProfilePage: Error: ${state.message}');
            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error al cargar perfil: ${state.message}'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 5),
              ),
            );
          } else if (state is ProfileLoaded) {
            print('✅ ProfilePage: Perfil del usuario cargado: ${state.profile.fullName}');
          } else if (state is ProfileUpdated) {
            print('✅ ProfilePage: Perfil actualizado: ${state.profile.fullName}');
          } else if (state is ProfilesLoaded) {
            print('✅ ProfilePage: Perfiles cargados: ${state.profiles.length} perfiles');
          } else if (state is ProfileLoading) {
            print('⏳ ProfilePage: Cargando perfil...');
          }
        },
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            print('🏗️ ProfilePage: Construyendo UI con estado: ${state.runtimeType}');
            
            // Handle different states
            if (state is ProfileLoading) {
              return const Center(
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
              );
            }
            
            // Get the profile data from the current state
            ProfileModel? profileData;
            
            if (state is ProfileLoaded) {
              // Perfil individual del usuario logueado
              profileData = state.profile;
              print('📊 ProfilePage: Datos del perfil individual: ${profileData.toJson()}');
            } else if (state is ProfileUpdated) {
              // Perfil recién actualizado
              profileData = state.profile;
              print('📊 ProfilePage: Datos del perfil actualizado: ${profileData.toJson()}');
            } else if (state is ProfilesLoaded && state.profiles.isNotEmpty) {
              // Fallback: primer perfil de la lista (por compatibilidad)
              profileData = state.profiles.first;
              print('📊 ProfilePage: Datos del primer perfil de la lista: ${profileData.toJson()}');
            }
            
            print('📊 ProfilePage: ProfileData final: ${profileData?.toJson() ?? "null"}');
            
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
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            // Header
                            const ProfileHeader(),
                            
                            // Profile info section
                            if (profileData != null)
                              ProfileInfoSection(
                                userProfile: {
                                  'name': profileData.firstName,
                                  'lastName': profileData.lastName,
                                  'email': profileData.email,
                                  'username': profileData.email, // Using email as username for now
                                  'position': profileData.position.displayName,
                                  'department': profileData.department.displayName,
                                  'avatarUrl': profileData.avatarUrl ?? '',
                                },
                              )
                            else
                              Padding(
                                padding: const EdgeInsets.all(32.0),
                                child: Column(
                                  children: [
                                    const Icon(
                                      Icons.person_off,
                                      size: 64,
                                      color: CentralisColors.onBackground,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No hay datos de perfil disponibles',
                                      style: TextStyle(
                                        color: CentralisColors.onBackground,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Estado actual: ${state.runtimeType}',
                                      style: TextStyle(
                                        color: CentralisColors.onBackground.withOpacity(0.7),
                                        fontSize: 12,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton(
                                      onPressed: () {
                                        print('🔄 ProfilePage: Recargando perfiles...');
                                        _loadProfilesWithAuthCheck();
                                      },
                                      child: const Text('Reintentar'),
                                    ),
                                  ],
                                ),
                              ),
                            
                            // Action buttons
                            ProfileActionButtons(
                              onEditProfile: _navigateToEditProfile,
                              onSignOut: _handleSignOut,
                              isLoading: state is ProfileLoading,
                            ),
                            
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
}
