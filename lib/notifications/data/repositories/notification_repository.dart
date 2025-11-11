import '../models/notification_model.dart';
import '../datasources/notification_local_datasource.dart';
import '../datasources/notification_remote_datasource.dart';

/// Repository for managing notifications
/// Combines local (SQLite) and remote (API) data sources
class NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;
  final NotificationDatabase localDataSource;

  NotificationRepository({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  /// Sync notifications from server and save to local database
  Future<List<NotificationModel>> syncNotifications(String userId) async {
    try {
      print('🔄 NotificationRepository: Sincronizando notificaciones...');
      
      // Fetch from server
      final notifications = await remoteDataSource.getNotificationsByUser(userId);
      
      // Save to local database
      if (notifications.isNotEmpty) {
        await localDataSource.insertNotifications(notifications);
        print('✅ NotificationRepository: ${notifications.length} notificaciones guardadas localmente');
      }
      
      return notifications;
    } catch (e) {
      print('❌ NotificationRepository: Error sincronizando: $e');
      // If sync fails, return local data
      return await localDataSource.getNotificationsByUser(userId);
    }
  }

  /// Get notifications from local database
  Future<List<NotificationModel>> getLocalNotifications(String userId) async {
    try {
      return await localDataSource.getNotificationsByUser(userId);
    } catch (e) {
      print('❌ NotificationRepository: Error obteniendo notificaciones locales: $e');
      return [];
    }
  }

  /// Get unread notifications count
  Future<int> getUnreadCount(String userId) async {
    try {
      return await localDataSource.getUnreadCount(userId);
    } catch (e) {
      print('❌ NotificationRepository: Error obteniendo contador: $e');
      return 0;
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(int notificationId) async {
    try {
      await localDataSource.markAsRead(notificationId);
    } catch (e) {
      print('❌ NotificationRepository: Error marcando como leído: $e');
      rethrow;
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead(String userId) async {
    try {
      await localDataSource.markAllAsRead(userId);
    } catch (e) {
      print('❌ NotificationRepository: Error marcando todas como leídas: $e');
      rethrow;
    }
  }

  /// Delete a notification
  Future<void> deleteNotification(int notificationId) async {
    try {
      await localDataSource.deleteNotification(notificationId);
    } catch (e) {
      print('❌ NotificationRepository: Error eliminando notificación: $e');
      rethrow;
    }
  }

  /// Delete all notifications
  Future<void> deleteAllNotifications(String userId) async {
    try {
      await localDataSource.deleteAllNotifications(userId);
    } catch (e) {
      print('❌ NotificationRepository: Error eliminando todas las notificaciones: $e');
      rethrow;
    }
  }
}
