import 'package:equatable/equatable.dart';
import '../../data/models/notification_model.dart';

/// States for notification bloc
abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class NotificationInitial extends NotificationState {}

/// Loading state
class NotificationLoading extends NotificationState {}

/// Notifications loaded state
class NotificationLoaded extends NotificationState {
  final List<NotificationModel> notifications;
  final int unreadCount;

  const NotificationLoaded({
    required this.notifications,
    this.unreadCount = 0,
  });

  @override
  List<Object?> get props => [notifications, unreadCount];
}

/// Syncing state (loading in background)
class NotificationSyncing extends NotificationState {
  final List<NotificationModel> notifications;
  final int unreadCount;

  const NotificationSyncing({
    required this.notifications,
    this.unreadCount = 0,
  });

  @override
  List<Object?> get props => [notifications, unreadCount];
}

/// Error state
class NotificationError extends NotificationState {
  final String message;

  const NotificationError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Notification marked as read state
class NotificationMarkedAsRead extends NotificationState {
  final int notificationId;

  const NotificationMarkedAsRead(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

/// Notification deleted state
class NotificationDeleted extends NotificationState {
  final int notificationId;

  const NotificationDeleted(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

/// All notifications deleted state
class NotificationAllDeleted extends NotificationState {}

