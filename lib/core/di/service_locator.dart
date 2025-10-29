import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Core
import '../storage/secure_storage_service.dart';
import '../network/api_client.dart';
import '../constants/api_constants.dart';

// IAM
import '../../iam/data/datasources/auth_remote_datasource.dart';
import '../../iam/data/datasources/auth_local_datasource.dart';
import '../../iam/data/repositories/auth_repository.dart';
import '../../iam/presentation/bloc/auth_bloc.dart';

// Profile
import '../../profile/data/datasources/profile_remote_datasource.dart';
import '../../profile/data/repositories/profile_repository.dart';
import '../../profile/presentation/bloc/profile_bloc.dart';

final GetIt sl = GetIt.instance;

Future<void> initializeDependencies() async {
  // Core services
  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );

  sl.registerLazySingleton<SecureStorageService>(
    () => SecureStorageService(),
  );
  
  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(
      baseUrl: ApiConstants.baseUrl,
      storage: sl<SecureStorageService>(),
    ),
  );

  // IAM feature
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );
  
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(storage: sl<SecureStorageService>()),
  );
  
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl<AuthRemoteDataSource>(),
      localDataSource: sl<AuthLocalDataSource>(),
    ),
  );
  
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(authRepository: sl<AuthRepository>()),
  );

  // Profile feature
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );
  
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(
      remoteDataSource: sl<ProfileRemoteDataSource>(),
    ),
  );
  
  sl.registerFactory<ProfileBloc>(
    () => ProfileBloc(profileRepository: sl<ProfileRepository>()),
  );
}