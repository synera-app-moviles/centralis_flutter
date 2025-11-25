import 'package:equatable/equatable.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

/// Load dashboard summary statistics
class DashboardSummaryRequested extends DashboardEvent {
  const DashboardSummaryRequested();
}

/// Load all users for the dashboard
class DashboardUsersRequested extends DashboardEvent {
  const DashboardUsersRequested();
}

/// Load announcements viewed by a specific user
class UserViewedAnnouncementsRequested extends DashboardEvent {
  final String userId;

  const UserViewedAnnouncementsRequested(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Load events viewed by a specific user
class UserViewedEventsRequested extends DashboardEvent {
  final String userId;

  const UserViewedEventsRequested(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Load users who viewed a specific announcement
class AnnouncementViewersRequested extends DashboardEvent {
  final String announcementId;

  const AnnouncementViewersRequested(this.announcementId);

  @override
  List<Object?> get props => [announcementId];
}

/// Load users who viewed a specific event
class EventViewersRequested extends DashboardEvent {
  final String eventId;

  const EventViewersRequested(this.eventId);

  @override
  List<Object?> get props => [eventId];
}

/// Register that a user viewed an announcement
class AnnouncementViewRegistered extends DashboardEvent {
  final String announcementId;
  final String userId;

  const AnnouncementViewRegistered({
    required this.announcementId,
    required this.userId,
  });

  @override
  List<Object?> get props => [announcementId, userId];
}

/// Register that a user viewed an event
class EventViewRegistered extends DashboardEvent {
  final String eventId;
  final String userId;

  const EventViewRegistered({
    required this.eventId,
    required this.userId,
  });

  @override
  List<Object?> get props => [eventId, userId];
}

/// Clear dashboard data
class DashboardCleared extends DashboardEvent {
  const DashboardCleared();
}