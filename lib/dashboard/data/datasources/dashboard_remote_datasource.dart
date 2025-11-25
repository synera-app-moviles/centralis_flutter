import 'dart:convert';
import '../../../core/network/api_client.dart';
import '../../../profile/data/models/enums.dart';
import '../../../profile/data/repositories/profile_repository.dart';
import '../models/dashboard_summary.dart';
import '../models/dashboard_user.dart';
import '../models/user_viewed_announcement.dart';
import '../models/user_viewed_event.dart';
import '../models/content_stats.dart';
import '../models/viewer_info.dart';

abstract class DashboardRemoteDataSource {
  /// Get general summary of views
  Future<DashboardSummary> getViewsSummary();

  /// Get all users in dashboard format (for user list)
  Future<List<DashboardUser>> getAllUsers();

  /// Get announcements viewed by specific user
  Future<List<UserViewedAnnouncement>> getUserViewedAnnouncements(String userId);

  /// Get events viewed by specific user
  Future<List<UserViewedEvent>> getUserViewedEvents(String userId);

  /// Get users who viewed specific announcement
  Future<List<ViewerInfo>> getAnnouncementViewers(String announcementId);

  /// Get users who viewed specific event
  Future<List<ViewerInfo>> getEventViewers(String eventId);

  /// Register announcement view
  Future<Map<String, dynamic>> registerAnnouncementView(String announcementId, String userId);

  /// Register event view
  Future<Map<String, dynamic>> registerEventView(String eventId, String userId);

  /// Get announcement statistics
  Future<ContentStats> getAnnouncementStats(String announcementId);

  /// Get event statistics  
  Future<ContentStats> getEventStats(String eventId);
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final ApiClient _apiClient;
  final ProfileRepository _profileRepository;

  DashboardRemoteDataSourceImpl({
    required ApiClient apiClient,
    required ProfileRepository profileRepository,
  }) : _apiClient = apiClient,
       _profileRepository = profileRepository;

  @override
  Future<DashboardSummary> getViewsSummary() async {
    const endpoint = '/dashboard/views/summary';
    final response = await _apiClient.get(
      endpoint,
      requireAuth: true,
    );

    final data = jsonDecode(response.body);
    return DashboardSummary.fromJson(data);
  }

  @override
  Future<List<DashboardUser>> getAllUsers() async {
    // Note: This endpoint doesn't exist in the API documentation,
    // We'll use the profiles endpoint and transform the data
    const endpoint = '/profiles';
    final response = await _apiClient.get(
      endpoint,
      requireAuth: true,
    );

    final data = jsonDecode(response.body) as List<dynamic>;
    return data.map((json) => _profileToDashboardUser(json)).toList();
  }

  /// Helper method to convert profile data to dashboard user format
  DashboardUser _profileToDashboardUser(Map<String, dynamic> profileJson) {
    return DashboardUser(
      userId: profileJson['userId'] as String,
      userFullName: profileJson['fullName'] as String? ?? 
                   '${profileJson['firstName']} ${profileJson['lastName']}'.trim(),
      userEmail: profileJson['email'] as String,
      userDepartment: _parseDepartment(profileJson['department']),
      userPosition: _parsePosition(profileJson['position']),
      avatarUrl: profileJson['avatarUrl'] as String?,
      totalViews: 0, // Default since profiles don't include view count
    );
  }

  @override
  Future<List<UserViewedAnnouncement>> getUserViewedAnnouncements(String userId) async {
    final endpoint = '/dashboard/users/$userId/announcements/views';
    try {
      final response = await _apiClient.get(
        endpoint,
        requireAuth: true,
      );

      final data = jsonDecode(response.body) as List<dynamic>;
      print('📊 Dashboard: Raw announcements data: $data');
      
      return data.map((json) {
        try {
          return UserViewedAnnouncement.fromJson(json as Map<String, dynamic>);
        } catch (e) {
          print('❌ Dashboard: Error parsing announcement: $e');
          print('📋 Dashboard: Raw announcement data: $json');
          rethrow;
        }
      }).toList();
    } catch (e) {
      print('❌ Dashboard: Error fetching user announcements: $e');
      rethrow;
    }
  }

  @override
  Future<List<UserViewedEvent>> getUserViewedEvents(String userId) async {
    final endpoint = '/dashboard/users/$userId/events/views';
    try {
      final response = await _apiClient.get(
        endpoint,
        requireAuth: true,
      );

      final data = jsonDecode(response.body) as List<dynamic>;
      print('📊 Dashboard: Raw events data: $data');
      
      return data.map((json) {
        try {
          return UserViewedEvent.fromJson(json as Map<String, dynamic>);
        } catch (e) {
          print('❌ Dashboard: Error parsing event: $e');
          print('📋 Dashboard: Raw event data: $json');
          rethrow;
        }
      }).toList();
    } catch (e) {
      print('❌ Dashboard: Error fetching user events: $e');
      rethrow;
    }
  }

  @override
  Future<List<ViewerInfo>> getAnnouncementViewers(String announcementId) async {
    final endpoint = '/dashboard/announcements/$announcementId/users/views';
    print('📡 Dashboard: Fetching announcement viewers from $endpoint');
    
    final response = await _apiClient.get(
      endpoint,
      requireAuth: true,
    );

    print('📡 Dashboard: Announcement viewers response status: ${response.statusCode}');
    print('📡 Dashboard: Announcement viewers response body: ${response.body}');

    final data = jsonDecode(response.body) as List<dynamic>;
    final viewers = data.map((json) => ViewerInfo.fromJson(json as Map<String, dynamic>)).toList();
    print('📊 Dashboard: Parsed ${viewers.length} announcement viewers');
    
    // Enrich viewers with profile data (avatar URLs)
    final enrichedViewers = await _enrichViewersWithProfileData(viewers);
    return enrichedViewers;
  }

  @override
  Future<List<ViewerInfo>> getEventViewers(String eventId) async {
    final endpoint = '/dashboard/events/$eventId/users/views';
    print('📡 Dashboard: Fetching event viewers from $endpoint');
    
    final response = await _apiClient.get(
      endpoint,
      requireAuth: true,
    );

    print('📡 Dashboard: Event viewers response status: ${response.statusCode}');
    print('📡 Dashboard: Event viewers response body: ${response.body}');

    final data = jsonDecode(response.body) as List<dynamic>;
    final viewers = data.map((json) => ViewerInfo.fromJson(json as Map<String, dynamic>)).toList();
    print('📊 Dashboard: Parsed ${viewers.length} event viewers');
    
    // Enrich viewers with profile data (avatar URLs)
    final enrichedViewers = await _enrichViewersWithProfileData(viewers);
    return enrichedViewers;
  }

  /// Helper method to enrich viewers with profile data (especially avatar URLs)
  Future<List<ViewerInfo>> _enrichViewersWithProfileData(List<ViewerInfo> viewers) async {
    if (viewers.isEmpty) return viewers;

    try {
      // Get all profiles to create a userId -> avatarUrl mapping
      final profiles = await _profileRepository.getAllProfiles();
      final Map<String, String?> userIdToAvatarUrl = {};
      
      for (final profile in profiles) {
        userIdToAvatarUrl[profile.userId] = profile.avatarUrl;
      }
      
      // Enrich each viewer with avatar URL from profile
      final enrichedViewers = viewers.map((viewer) {
        final avatarUrl = userIdToAvatarUrl[viewer.userId];
        return viewer.copyWith(avatarUrl: avatarUrl);
      }).toList();
      
      print('📊 Dashboard: Enriched ${enrichedViewers.length} viewers with profile data');
      return enrichedViewers;
    } catch (e) {
      print('⚠️ Dashboard: Failed to enrich viewers with profile data: $e');
      // Return original viewers if profile enrichment fails
      return viewers;
    }
  }

  @override
  Future<Map<String, dynamic>> registerAnnouncementView(String announcementId, String userId) async {
    final endpoint = '/analytics/announcements/$announcementId/views';
    final response = await _apiClient.post(
      endpoint,
      body: {'userId': userId},
      requireAuth: true,
    );

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> registerEventView(String eventId, String userId) async {
    final endpoint = '/analytics/events/$eventId/views';
    final response = await _apiClient.post(
      endpoint,
      body: {'userId': userId},
      requireAuth: true,
    );

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  @override
  Future<ContentStats> getAnnouncementStats(String announcementId) async {
    final endpoint = '/dashboard/announcements/$announcementId/stats';
    try {
      final response = await _apiClient.get(
        endpoint,
        requireAuth: true,
      );

      final data = jsonDecode(response.body);
      print('📊 Dashboard: Raw announcement stats: $data');
      
      return ContentStats.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      print('❌ Dashboard: Error fetching announcement stats: $e');
      rethrow;
    }
  }

  @override
  Future<ContentStats> getEventStats(String eventId) async {
    final endpoint = '/dashboard/events/$eventId/stats';
    try {
      final response = await _apiClient.get(
        endpoint,
        requireAuth: true,
      );

      final data = jsonDecode(response.body);
      print('📊 Dashboard: Raw event stats: $data');
      
      return ContentStats.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      print('❌ Dashboard: Error fetching event stats: $e');
      rethrow;
    }
  }

  /// Helper method to parse department from API response
  Department _parseDepartment(dynamic departmentValue) {
    if (departmentValue == null) return Department.other;
    
    final departmentStr = departmentValue.toString().toUpperCase();
    return Department.values.firstWhere(
      (e) => e.value == departmentStr,
      orElse: () => Department.other,
    );
  }

  /// Helper method to parse position from API response
  Position _parsePosition(dynamic positionValue) {
    if (positionValue == null) return Position.employee;
    
    final positionStr = positionValue.toString().toUpperCase();
    return Position.values.firstWhere(
      (e) => e.value == positionStr,
      orElse: () => Position.employee,
    );
  }
}