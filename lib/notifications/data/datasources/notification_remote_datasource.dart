import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/notification_model.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/error/exceptions.dart';

/// Remote data source for fetching notifications from the web service
class NotificationRemoteDataSource {
  final http.Client client;
  final SecureStorageService storage;

  NotificationRemoteDataSource({
    required this.client,
    required this.storage,
  });

  /// Get all notifications for a user from the server
  Future<List<NotificationModel>> getNotificationsByUser(String userId) async {
    try {
      print('📡 NotificationRemoteDataSource: Obteniendo notificaciones del usuario $userId');

      final token = await storage.getToken();
      if (token == null) {
        print('❌ NotificationRemoteDataSource: No se encontró token');
        throw UnauthorizedException('No authentication token found');
      }

      final url = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.notificationsByUser.replaceAll('{userId}', userId.toString())}'
      );

      print('📡 Request URL: $url');

      final response = await client.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        final notifications = jsonList
            .map((json) => NotificationModel.fromJson(json as Map<String, dynamic>))
            .toList();

        print('✅ NotificationRemoteDataSource: ${notifications.length} notificaciones obtenidas');
        return notifications;
      } else if (response.statusCode == 401) {
        throw UnauthorizedException('Unauthorized');
      } else if (response.statusCode == 404) {
        print('⚠️ NotificationRemoteDataSource: No se encontraron notificaciones');
        return []; // Return empty list if not found
      } else {
        throw ServerException('Failed to load notifications: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ NotificationRemoteDataSource: Error: $e');
      if (e is UnauthorizedException || e is ServerException) {
        rethrow;
      }
      throw ServerException('Failed to load notifications: $e');
    }
  }

  /// Get a specific notification by ID
  Future<NotificationModel> getNotificationById(int notificationId) async {
    try {
      print('📡 NotificationRemoteDataSource: Obteniendo notificación $notificationId');

      final token = await storage.getToken();
      if (token == null) {
        throw UnauthorizedException('No authentication token found');
      }

      final url = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.notificationById.replaceAll('{notificationId}', notificationId.toString())}'
      );

      final response = await client.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final notification = NotificationModel.fromJson(
          json.decode(response.body) as Map<String, dynamic>
        );
        print('✅ NotificationRemoteDataSource: Notificación obtenida');
        return notification;
      } else if (response.statusCode == 401) {
        throw UnauthorizedException('Unauthorized');
      } else if (response.statusCode == 404) {
        throw NotFoundException('Notification not found');
      } else {
        throw ServerException('Failed to load notification: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ NotificationRemoteDataSource: Error: $e');
      if (e is UnauthorizedException || e is ServerException || e is NotFoundException) {
        rethrow;
      }
      throw ServerException('Failed to load notification: $e');
    }
  }
}
