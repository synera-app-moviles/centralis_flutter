import '../datasources/dashboard_remote_datasource.dart';
import '../models/dashboard_summary.dart';
import '../models/dashboard_user.dart';
import '../models/user_viewed_announcement.dart';
import '../models/user_viewed_event.dart';

abstract class DashboardRepository {
  Future<DashboardSummary> getViewsSummary();
  Future<List<DashboardUser>> getAllUsers();
  Future<List<UserViewedAnnouncement>> getUserViewedAnnouncements(String userId);
  Future<List<UserViewedEvent>> getUserViewedEvents(String userId);
  Future<List<DashboardUser>> getAnnouncementViewers(String announcementId);
  Future<List<DashboardUser>> getEventViewers(String eventId);
  Future<Map<String, dynamic>> registerAnnouncementView(String announcementId, String userId);
  Future<Map<String, dynamic>> registerEventView(String eventId, String userId);
}

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource remoteDataSource;

  DashboardRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<DashboardSummary> getViewsSummary() async {
    return await remoteDataSource.getViewsSummary();
  }

  @override
  Future<List<DashboardUser>> getAllUsers() async {
    return await remoteDataSource.getAllUsers();
  }

  @override
  Future<List<UserViewedAnnouncement>> getUserViewedAnnouncements(String userId) async {
    return await remoteDataSource.getUserViewedAnnouncements(userId);
  }

  @override
  Future<List<UserViewedEvent>> getUserViewedEvents(String userId) async {
    return await remoteDataSource.getUserViewedEvents(userId);
  }

  @override
  Future<List<DashboardUser>> getAnnouncementViewers(String announcementId) async {
    return await remoteDataSource.getAnnouncementViewers(announcementId);
  }

  @override
  Future<List<DashboardUser>> getEventViewers(String eventId) async {
    return await remoteDataSource.getEventViewers(eventId);
  }

  @override
  Future<Map<String, dynamic>> registerAnnouncementView(String announcementId, String userId) async {
    return await remoteDataSource.registerAnnouncementView(announcementId, userId);
  }

  @override
  Future<Map<String, dynamic>> registerEventView(String eventId, String userId) async {
    return await remoteDataSource.registerEventView(eventId, userId);
  }
}