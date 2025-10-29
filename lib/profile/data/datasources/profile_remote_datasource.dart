import 'dart:convert';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../models/profile_model.dart';
import '../models/create_profile_request.dart';
import '../models/update_profile_request.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileModel> createProfile(CreateProfileRequest request);
  Future<ProfileModel> getProfileById(String profileId);
  Future<ProfileModel> getProfileByUserId(String userId);
  Future<List<ProfileModel>> getAllProfiles();
  Future<ProfileModel> updateProfile(String profileId, UpdateProfileRequest request);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiClient _apiClient;

  ProfileRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<ProfileModel> createProfile(CreateProfileRequest request) async {
    final response = await _apiClient.post(
      ApiConstants.profiles,
      body: request.toJson(),
      requireAuth: true,
    );

    final data = jsonDecode(response.body);
    return ProfileModel.fromJson(data);
  }

  @override
  Future<ProfileModel> getProfileById(String profileId) async {
    final endpoint = ApiConstants.profileById.replaceAll('{id}', profileId);
    final response = await _apiClient.get(
      endpoint,
      requireAuth: true,
    );

    final data = jsonDecode(response.body);
    return ProfileModel.fromJson(data);
  }

  @override
  Future<ProfileModel> getProfileByUserId(String userId) async {
    final endpoint = ApiConstants.profileByUser.replaceAll('{userId}', userId);
    final response = await _apiClient.get(
      endpoint,
      requireAuth: true,
    );

    final data = jsonDecode(response.body);
    return ProfileModel.fromJson(data);
  }

  @override
  Future<List<ProfileModel>> getAllProfiles() async {
    final response = await _apiClient.get(
      ApiConstants.profiles,
      requireAuth: true,
    );

    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => ProfileModel.fromJson(json)).toList();
  }

  @override
  Future<ProfileModel> updateProfile(
    String profileId,
    UpdateProfileRequest request,
  ) async {
    print('🔄 ProfileRemoteDataSource: Updating profile $profileId');
    print('🔄 Request data: ${request.toJson()}');
    
    final endpoint = ApiConstants.profileById.replaceAll('{id}', profileId);
    print('🔄 PUT endpoint: $endpoint');
    
    try {
      final response = await _apiClient.put(
        endpoint,
        body: request.toJson(),
        requireAuth: true,
      );

      print('🔄 Update response status: ${response.statusCode}');
      print('🔄 Update response body: ${response.body}');
      
      final data = jsonDecode(response.body);
      final updatedProfile = ProfileModel.fromJson(data);
      print('✅ Profile updated successfully: ${updatedProfile.profileId}');
      
      return updatedProfile;
    } catch (e) {
      print('❌ Error updating profile: $e');
      rethrow;
    }
  }
}