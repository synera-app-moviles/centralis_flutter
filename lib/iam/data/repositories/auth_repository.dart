import '../datasources/auth_remote_datasource.dart';
import '../datasources/auth_local_datasource.dart';
import '../models/sign_in_request.dart';
import '../models/sign_up_request.dart';
import '../models/sign_up_response.dart';
import '../models/authenticated_user.dart';
import '../models/user_model.dart';

abstract class AuthRepository {
  Future<AuthenticatedUser> signIn(String username, String password);
  Future<SignUpResponse> signUp({
    required String username,
    required String password,
    required String name,
    required String lastname,
    required String email,
  });
  Future<void> signOut();
  Future<bool> isLoggedIn();
  Future<String?> getCurrentUserId();
  Future<String?> getCurrentUsername();
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<AuthenticatedUser> signIn(String username, String password) async {
    final request = SignInRequest(username: username, password: password);
    final authenticatedUser = await remoteDataSource.signIn(request);
    
    // Save tokens and user data locally
    await localDataSource.saveToken(authenticatedUser.token);
    await localDataSource.saveUserId(authenticatedUser.id);
    await localDataSource.saveUsername(authenticatedUser.username);
    
    return authenticatedUser;
  }

  @override
  Future<SignUpResponse> signUp({
    required String username,
    required String password,
    required String name,
    required String lastname,
    required String email,
  }) async {
    final request = SignUpRequest(
      username: username,
      password: password,
      name: name,
      lastname: lastname,
      email: email,
      roles: ['ROLE_MANAGER'],
    );
    
    return await remoteDataSource.signUp(request);
  }

  @override
  Future<void> signOut() async {
    await localDataSource.clearAllData();
  }

  @override
  Future<bool> isLoggedIn() async {
    return await localDataSource.isLoggedIn();
  }

  @override
  Future<String?> getCurrentUserId() async {
    return await localDataSource.getUserId();
  }

  @override
  Future<String?> getCurrentUsername() async {
    return await localDataSource.getUsername();
  }
}