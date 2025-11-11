import 'package:flutter_bloc/flutter_bloc.dart';
import 'notification_event.dart';
import 'notification_state.dart';
import '../../data/repositories/notification_repository.dart';

/// BLoC for managing notification state
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository repository;

  NotificationBloc({required this.repository}) : super(NotificationInitial()) {
    on<NotificationLoadRequested>(_onLoadRequested);
    on<NotificationSyncRequested>(_onSyncRequested);
    on<NotificationMarkAsRead>(_onMarkAsRead);
    on<NotificationMarkAllAsRead>(_onMarkAllAsRead);
    on<NotificationDeleteRequested>(_onDeleteRequested);
    on<NotificationDeleteAllRequested>(_onDeleteAllRequested);
  }

  /// Load notifications from local database first, then sync
  Future<void> _onLoadRequested(
    NotificationLoadRequested event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      emit(NotificationLoading());

      // Load from local database first
      final localNotifications = await repository.getLocalNotifications(event.userId);
      final unreadCount = await repository.getUnreadCount(event.userId);

      if (localNotifications.isNotEmpty) {
        emit(NotificationLoaded(
          notifications: localNotifications,
          unreadCount: unreadCount,
        ));
      }

      // Then sync from server in background
      final notifications = await repository.syncNotifications(event.userId);
      final newUnreadCount = await repository.getUnreadCount(event.userId);

      emit(NotificationLoaded(
        notifications: notifications,
        unreadCount: newUnreadCount,
      ));
    } catch (e) {
      print('❌ NotificationBloc: Error loading notifications: $e');
      emit(NotificationError(e.toString()));
    }
  }

  /// Sync notifications from server
  Future<void> _onSyncRequested(
    NotificationSyncRequested event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      // Show syncing state if we have current notifications
      if (state is NotificationLoaded) {
        final currentState = state as NotificationLoaded;
        emit(NotificationSyncing(
          notifications: currentState.notifications,
          unreadCount: currentState.unreadCount,
        ));
      }

      final notifications = await repository.syncNotifications(event.userId);
      final unreadCount = await repository.getUnreadCount(event.userId);

      emit(NotificationLoaded(
        notifications: notifications,
        unreadCount: unreadCount,
      ));
    } catch (e) {
      print('❌ NotificationBloc: Error syncing notifications: $e');

      // If sync fails, load from local
      final localNotifications = await repository.getLocalNotifications(event.userId);
      final unreadCount = await repository.getUnreadCount(event.userId);

      emit(NotificationLoaded(
        notifications: localNotifications,
        unreadCount: unreadCount,
      ));
    }
  }

  /// Mark a notification as read
  Future<void> _onMarkAsRead(
    NotificationMarkAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await repository.markAsRead(event.notificationId);

      // Reload notifications if we have a userId in current state
      if (state is NotificationLoaded) {
        final currentState = state as NotificationLoaded;
        final userId = currentState.notifications.isNotEmpty
            ? currentState.notifications.first.userId
            : null;

        if (userId != null) {
          final notifications = await repository.getLocalNotifications(userId);
          final unreadCount = await repository.getUnreadCount(userId);

          emit(NotificationLoaded(
            notifications: notifications,
            unreadCount: unreadCount,
          ));
        }
      }
    } catch (e) {
      print('❌ NotificationBloc: Error marking as read: $e');
      emit(NotificationError(e.toString()));
    }
  }

  /// Mark all notifications as read
  Future<void> _onMarkAllAsRead(
    NotificationMarkAllAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await repository.markAllAsRead(event.userId);

      final notifications = await repository.getLocalNotifications(event.userId);
      final unreadCount = await repository.getUnreadCount(event.userId);

      emit(NotificationLoaded(
        notifications: notifications,
        unreadCount: unreadCount,
      ));
    } catch (e) {
      print('❌ NotificationBloc: Error marking all as read: $e');
      emit(NotificationError(e.toString()));
    }
  }

  /// Delete a notification
  Future<void> _onDeleteRequested(
    NotificationDeleteRequested event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await repository.deleteNotification(event.notificationId);

      // Reload notifications if we have a userId in current state
      if (state is NotificationLoaded) {
        final currentState = state as NotificationLoaded;
        final userId = currentState.notifications.isNotEmpty
            ? currentState.notifications.first.userId
            : null;

        if (userId != null) {
          final notifications = await repository.getLocalNotifications(userId);
          final unreadCount = await repository.getUnreadCount(userId);

          emit(NotificationLoaded(
            notifications: notifications,
            unreadCount: unreadCount,
          ));
        }
      }
    } catch (e) {
      print('❌ NotificationBloc: Error deleting notification: $e');
      emit(NotificationError(e.toString()));
    }
  }

  /// Delete all notifications
  Future<void> _onDeleteAllRequested(
    NotificationDeleteAllRequested event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await repository.deleteAllNotifications(event.userId);

      emit(const NotificationLoaded(
        notifications: [],
        unreadCount: 0,
      ));
    } catch (e) {
      print('❌ NotificationBloc: Error deleting all notifications: $e');
      emit(NotificationError(e.toString()));
    }
  }
}

