import '../datasources/profile_remote_datasource.dart';
import '../models/profile_model.dart';
import '../models/create_profile_request.dart';
import '../models/update_profile_request.dart';
import '../models/enums.dart';

abstract class ProfileRepository {
  Future<ProfileModel> createProfile({
    required String userId,
    required String firstName,
    required String lastName,
    required String email,
    String? avatarUrl,
    required Position position,
    required Department department,
  });
  Future<ProfileModel> getProfileById(String profileId);
  Future<ProfileModel> getProfileByUserId(String userId);
  Future<List<ProfileModel>> getAllProfiles();
  Future<ProfileModel> updateProfile({
    required String profileId,
    required String firstName,
    required String lastName,
    required String email,
    String? avatarUrl,
    required Position position,
    required Department department,
  });
}

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<ProfileModel> createProfile({
    required String userId,
    required String firstName,
    required String lastName,
    required String email,
    String? avatarUrl,
    required Position position,
    required Department department,
  }) async {
    final request = CreateProfileRequest(
      userId: userId,
      firstName: firstName,
      lastName: lastName,
      email: email,
      avatarUrl: avatarUrl,
      position: position,
      department: department,
    );
    
    return await remoteDataSource.createProfile(request);
  }

  @override
  Future<ProfileModel> getProfileById(String profileId) async {
    return await remoteDataSource.getProfileById(profileId);
  }

  @override
  Future<ProfileModel> getProfileByUserId(String userId) async {
    return await remoteDataSource.getProfileByUserId(userId);
  }

  @override
  Future<List<ProfileModel>> getAllProfiles() async {
    return await remoteDataSource.getAllProfiles();
  }

  @override
  Future<ProfileModel> updateProfile({
    required String profileId,
    required String firstName,
    required String lastName,
    required String email,
    String? avatarUrl,
    required Position position,
    required Department department,
  }) async {
    final request = UpdateProfileRequest(
      firstName: firstName,
      lastName: lastName,
      email: email,
      avatarUrl: avatarUrl,
      position: position,
      department: department,
    );
    
    return await remoteDataSource.updateProfile(profileId, request);
  }
}