import 'package:equatable/equatable.dart';

/// Events for notification bloc
abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load notifications from server and local database
class NotificationLoadRequested extends NotificationEvent {
  final String userId;

  const NotificationLoadRequested(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Event to sync notifications from server
class NotificationSyncRequested extends NotificationEvent {
  final String userId;

  const NotificationSyncRequested(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Event to mark notification as read
class NotificationMarkAsRead extends NotificationEvent {
  final String notificationId;

  const NotificationMarkAsRead(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

/// Event to mark all notifications as read
class NotificationMarkAllAsRead extends NotificationEvent {
  final String userId;

  const NotificationMarkAllAsRead(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Event to delete a notification
class NotificationDeleteRequested extends NotificationEvent {
  final String notificationId;

  const NotificationDeleteRequested(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

/// Event to delete all notifications
class NotificationDeleteAllRequested extends NotificationEvent {
  final String userId;

  const NotificationDeleteAllRequested(this.userId);

  @override
  List<Object?> get props => [userId];
}
