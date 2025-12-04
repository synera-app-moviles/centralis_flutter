import 'package:equatable/equatable.dart';
import '../../data/models/dashboard_summary.dart';
import '../../data/models/dashboard_user.dart';
import '../../data/models/user_viewed_announcement.dart';
import '../../data/models/user_viewed_event.dart';
import '../../data/models/content_stats.dart';
import '../../data/models/viewer_info.dart';

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
  final List<ViewerInfo> viewers;
  final bool isRefreshing;

  const AnnouncementViewersLoaded({
    required this.announcementId,
    required this.viewers,
    this.isRefreshing = false,
  });

  AnnouncementViewersLoaded copyWith({
    String? announcementId,
    List<ViewerInfo>? viewers,
    bool? isRefreshing,
  }) {
    return AnnouncementViewersLoaded(
      announcementId: announcementId ?? this.announcementId,
      viewers: viewers ?? this.viewers,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  List<Object?> get props => [announcementId, viewers, isRefreshing];
}

/// State when event viewers are loaded
class EventViewersLoaded extends DashboardState {
  final String eventId;
  final List<ViewerInfo> viewers;
  final bool isRefreshing;

  const EventViewersLoaded({
    required this.eventId,
    required this.viewers,
    this.isRefreshing = false,
  });

  EventViewersLoaded copyWith({
    String? eventId,
    List<ViewerInfo>? viewers,
    bool? isRefreshing,
  }) {
    return EventViewersLoaded(
      eventId: eventId ?? this.eventId,
      viewers: viewers ?? this.viewers,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  List<Object?> get props => [eventId, viewers, isRefreshing];
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

/// State when content stats are loaded
class ContentStatsLoaded extends DashboardState {
  final ContentStats stats;
  final bool isAnnouncement;
  final bool isRefreshing;

  const ContentStatsLoaded({
    required this.stats,
    required this.isAnnouncement,
    this.isRefreshing = false,
  });

  ContentStatsLoaded copyWith({
    ContentStats? stats,
    bool? isAnnouncement,
    bool? isRefreshing,
  }) {
    return ContentStatsLoaded(
      stats: stats ?? this.stats,
      isAnnouncement: isAnnouncement ?? this.isAnnouncement,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  List<Object?> get props => [stats, isAnnouncement, isRefreshing];
}

/// Combined state when both stats and viewers are available
class ContentAnalyticsLoaded extends DashboardState {
  final ContentStats? stats;
  final List<ViewerInfo>? viewers;
  final bool isAnnouncement;
  final bool isStatsRefreshing;
  final bool isViewersRefreshing;

  const ContentAnalyticsLoaded({
    this.stats,
    this.viewers,
    required this.isAnnouncement,
    this.isStatsRefreshing = false,
    this.isViewersRefreshing = false,
  });

  ContentAnalyticsLoaded copyWith({
    ContentStats? stats,
    List<ViewerInfo>? viewers,
    bool? isAnnouncement,
    bool? isStatsRefreshing,
    bool? isViewersRefreshing,
    bool? clearStats,
    bool? clearViewers,
  }) {
    return ContentAnalyticsLoaded(
      stats: clearStats == true ? null : (stats ?? this.stats),
      viewers: clearViewers == true ? null : (viewers ?? this.viewers),
      isAnnouncement: isAnnouncement ?? this.isAnnouncement,
      isStatsRefreshing: isStatsRefreshing ?? this.isStatsRefreshing,
      isViewersRefreshing: isViewersRefreshing ?? this.isViewersRefreshing,
    );
  }

  @override
  List<Object?> get props => [stats, viewers, isAnnouncement, isStatsRefreshing, isViewersRefreshing];
}