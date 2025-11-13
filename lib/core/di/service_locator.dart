import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Core
import '../storage/secure_storage_service.dart';
import '../network/api_client.dart';
import '../constants/api_constants.dart';
import '../services/cloudinary_service.dart';

// IAM
import '../../iam/data/datasources/auth_remote_datasource.dart';
import '../../iam/data/datasources/auth_local_datasource.dart';
import '../../iam/data/repositories/auth_repository.dart';
import '../../iam/presentation/bloc/auth_bloc.dart';

// Profile
import '../../profile/data/datasources/profile_remote_datasource.dart';
import '../../profile/data/repositories/profile_repository.dart';
import '../../profile/presentation/bloc/profile_bloc.dart';

// Importa los archivos de eventos
import '../../events/data/datasources/event_remote_datasource.dart';
import '../../events/data/repositories/event_repository.dart';
import '../../events/presentation/bloc/event_bloc.dart';
// Announcements
import '../../announcements/data/datasources/announcement_remote_datasource.dart';
import '../../announcements/data/repositories/announcement_repository.dart';
import '../../announcements/presentation/bloc/announcement_bloc.dart';

// Chat
import '../../chat/data/datasources/chat_remote_datasource.dart';
import '../../chat/data/repositories/chat_repository.dart';
import '../../chat/presentation/bloc/chat_bloc.dart';
// Notifications
import '../../notifications/data/datasources/notification_local_datasource.dart';
import '../../notifications/data/datasources/notification_remote_datasource.dart';
import '../../notifications/data/repositories/notification_repository.dart';
import '../../notifications/presentation/bloc/notification_bloc.dart';
import 'package:http/http.dart' as http;

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

  // Cloudinary service
  sl.registerLazySingleton<CloudinaryService>(
    () => CloudinaryService(),
  );

  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);


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

// ==================== Events ====================

// Data sources
  sl.registerLazySingleton<EventRemoteDataSource>(
        () => EventRemoteDataSourceImpl(client: sl<ApiClient>()),
  );

// Repositories
  sl.registerLazySingleton<EventRepository>(
        () => EventRepositoryImpl(remoteDataSource: sl<EventRemoteDataSource>()),
  );

// BLoC
  sl.registerFactory<EventBloc>(
        () => EventBloc(repository: sl<EventRepository>()),
  // Announcements feature
  sl.registerLazySingleton<AnnouncementRemoteDataSource>(
    () => AnnouncementRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );
  
  sl.registerLazySingleton<AnnouncementRepository>(
    () => AnnouncementRepositoryImpl(
      remoteDataSource: sl<AnnouncementRemoteDataSource>(),
    ),
  );
  
  sl.registerFactory<AnnouncementBloc>(
    () => AnnouncementBloc(announcementRepository: sl<AnnouncementRepository>()),
  );

  // Chat feature
  sl.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );
  
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(
      remoteDataSource: sl<ChatRemoteDataSource>(),
    ),
  );
  
  sl.registerFactory<ChatBloc>(
    () => ChatBloc(chatRepository: sl<ChatRepository>()),
  // Notifications feature
  sl.registerLazySingleton<http.Client>(
    () => http.Client(),
  );

  sl.registerLazySingleton<NotificationDatabase>(
    () => NotificationDatabase(),
  );

  sl.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSource(
      client: sl<http.Client>(),
      storage: sl<SecureStorageService>(),
    ),
  );

  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepository(
      remoteDataSource: sl<NotificationRemoteDataSource>(),
      localDataSource: sl<NotificationDatabase>(),
    ),
  );

  sl.registerFactory<NotificationBloc>(
    () => NotificationBloc(repository: sl<NotificationRepository>()),
  );
}