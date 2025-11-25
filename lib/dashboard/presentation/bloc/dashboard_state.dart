import 'package:equatable/equatable.dart';
import '../../data/models/dashboard_summary.dart';
import '../../data/models/dashboard_user.dart';
import '../../data/models/user_viewed_announcement.dart';
import '../../data/models/user_viewed_event.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

/// State when dashboard summary is loaded
class DashboardSummaryLoaded extends DashboardState {
  final DashboardSummary summary;

  const DashboardSummaryLoaded(this.summary);

  @override
  List<Object?> get props => [summary];
}

/// State when users list is loaded
class DashboardUsersLoaded extends DashboardState {
  final List<DashboardUser> users;

  const DashboardUsersLoaded(this.users);

  @override
  List<Object?> get props => [users];
}

/// State when user viewed content is loaded
class UserViewedContentLoaded extends DashboardState {
  final String userId;
  final List<UserViewedAnnouncement> announcements;
  final List<UserViewedEvent> events;

  const UserViewedContentLoaded({
    required this.userId,
    required this.announcements,
    required this.events,
  });

  @override
  List<Object?> get props => [userId, announcements, events];
}

/// State when announcement viewers are loaded
class AnnouncementViewersLoaded extends DashboardState {
  final String announcementId;
  final List<DashboardUser> viewers;

  const AnnouncementViewersLoaded({
    required this.announcementId,
    required this.viewers,
  });

  @override
  List<Object?> get props => [announcementId, viewers];
}

/// State when event viewers are loaded
class EventViewersLoaded extends DashboardState {
  final String eventId;
  final List<DashboardUser> viewers;

  const EventViewersLoaded({
    required this.eventId,
    required this.viewers,
  });

  @override
  List<Object?> get props => [eventId, viewers];
}

/// State when a view is successfully registered
class ViewRegistered extends DashboardState {
  final String message;
  final bool isNewView;

  const ViewRegistered({
    required this.message,
    required this.isNewView,
  });

  @override
  List<Object?> get props => [message, isNewView];
}

/// State when an error occurs
class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}