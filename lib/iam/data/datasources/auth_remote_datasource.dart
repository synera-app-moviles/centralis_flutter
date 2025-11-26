import 'dart:convert';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../models/sign_in_request.dart';
import '../models/sign_up_request.dart';
import '../models/sign_up_response.dart';
import '../models/authenticated_user.dart';

abstract class AuthRemoteDataSource {
  Future<AuthenticatedUser> signIn(SignInRequest request);
  Future<SignUpResponse> signUp(SignUpRequest request);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<AuthenticatedUser> signIn(SignInRequest request) async {
    final response = await _apiClient.post(
      ApiConstants.signIn,
      body: request.toJson(),
      requireAuth: false,
    );

    final data = jsonDecode(response.body);
    return AuthenticatedUser.fromJson(data);
  }

  @override
  Future<SignUpResponse> signUp(SignUpRequest request) async {
    final response = await _apiClient.post(
      ApiConstants.signUp,
      body: request.toJson(),
      requireAuth: false,
    );

    final data = jsonDecode(response.body);
    return SignUpResponse.fromJson(data);
  }
}