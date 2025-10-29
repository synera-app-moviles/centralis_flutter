import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/profile_repository.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository _profileRepository;

  ProfileBloc({required ProfileRepository profileRepository})
      : _profileRepository = profileRepository,
        super(ProfileInitial()) {
    on<ProfileCreateRequested>(_onCreateRequested);
    on<ProfileLoadRequested>(_onLoadRequested);
    on<ProfileLoadByUserRequested>(_onLoadByUserRequested);
    on<ProfileUpdateRequested>(_onUpdateRequested);
    on<AllProfilesLoadRequested>(_onAllProfilesLoadRequested);
  }

  Future<void> _onCreateRequested(
    ProfileCreateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      final profile = await _profileRepository.createProfile(
        userId: event.userId,
        firstName: event.firstName,
        lastName: event.lastName,
        email: event.email,
        avatarUrl: event.avatarUrl,
        position: event.position,
        department: event.department,
      );
      
      emit(ProfileCreated(profile));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onLoadRequested(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      final profile = await _profileRepository.getProfileById(event.profileId);
      emit(ProfileLoaded(profile));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onLoadByUserRequested(
    ProfileLoadByUserRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      final profile = await _profileRepository.getProfileByUserId(event.userId);
      emit(ProfileLoaded(profile));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onUpdateRequested(
    ProfileUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      final profile = await _profileRepository.updateProfile(
        profileId: event.profileId,
        firstName: event.firstName,
        lastName: event.lastName,
        email: event.email,
        avatarUrl: event.avatarUrl,
        position: event.position,
        department: event.department,
      );
      
      // Emit both ProfileUpdated (for UI feedback) and ProfileLoaded (to maintain state)
      emit(ProfileUpdated(profile));
      emit(ProfileLoaded(profile));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onAllProfilesLoadRequested(
    AllProfilesLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      final profiles = await _profileRepository.getAllProfiles();
      emit(ProfilesLoaded(profiles));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
}
