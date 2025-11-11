import 'dart:convert';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../models/announcement.dart';
import '../models/comment.dart';
import '../models/priority.dart';
import '../models/create_announcement_request.dart';
import '../models/update_announcement_request.dart';
import '../models/create_comment_request.dart';

abstract class AnnouncementRemoteDataSource {
  Future<Announcement> createAnnouncement(CreateAnnouncementRequest request);
  Future<Announcement> getAnnouncementById(String announcementId);
  Future<List<Announcement>> getAllAnnouncements();
  Future<List<Announcement>> getAnnouncementsByPriority(Priority priority);
  Future<List<Announcement>> getAnnouncementsByCreator(String createdBy);
  Future<Announcement> updateAnnouncement(String announcementId, UpdateAnnouncementRequest request);
  Future<void> deleteAnnouncement(String announcementId);
  
  Future<Comment> createComment(String announcementId, CreateCommentRequest request);
  Future<List<Comment>> getCommentsByAnnouncement(String announcementId);
  Future<Comment> getCommentById(String commentId);
  Future<void> deleteComment(String commentId);
}

class AnnouncementRemoteDataSourceImpl implements AnnouncementRemoteDataSource {
  final ApiClient _apiClient;

  AnnouncementRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<Announcement> createAnnouncement(CreateAnnouncementRequest request) async {
    print('📢 AnnouncementRemoteDataSource: Creating announcement');
    print('📢 Request data: ${request.toJson()}');
    
    final response = await _apiClient.post(
      ApiConstants.announcements,
      body: request.toJson(),
      requireAuth: true,
    );

    final data = jsonDecode(response.body);
    print('📢 Created announcement response: $data');
    return Announcement.fromJson(data);
  }

  @override
  Future<Announcement> getAnnouncementById(String announcementId) async {
    print('📢 AnnouncementRemoteDataSource: Getting announcement $announcementId');
    
    final endpoint = ApiConstants.announcementById.replaceAll('{announcementId}', announcementId);
    final response = await _apiClient.get(
      endpoint,
      requireAuth: true,
    );

    final data = jsonDecode(response.body);
    print('📢 Got announcement: ${data['title']}');
    return Announcement.fromJson(data);
  }

  @override
  Future<List<Announcement>> getAllAnnouncements() async {
    print('📢 AnnouncementRemoteDataSource: Getting all announcements');
    
    final response = await _apiClient.get(
      ApiConstants.announcements,
      requireAuth: true,
    );

    final List<dynamic> data = jsonDecode(response.body);
    print('📢 Got ${data.length} announcements');
    return data.map((json) => Announcement.fromJson(json)).toList();
  }

  @override
  Future<List<Announcement>> getAnnouncementsByPriority(Priority priority) async {
    print('📢 AnnouncementRemoteDataSource: Getting announcements by priority ${priority.value}');
    
    final endpoint = ApiConstants.announcementsByPriority.replaceAll('{priority}', priority.value);
    final response = await _apiClient.get(
      endpoint,
      requireAuth: true,
    );

    final List<dynamic> data = jsonDecode(response.body);
    print('📢 Got ${data.length} announcements with priority ${priority.value}');
    return data.map((json) => Announcement.fromJson(json)).toList();
  }

  @override
  Future<List<Announcement>> getAnnouncementsByCreator(String createdBy) async {
    print('📢 AnnouncementRemoteDataSource: Getting announcements by creator $createdBy');
    
    final endpoint = ApiConstants.announcementsByCreator.replaceAll('{createdBy}', createdBy);
    final response = await _apiClient.get(
      endpoint,
      requireAuth: true,
    );

    final List<dynamic> data = jsonDecode(response.body);
    print('📢 Got ${data.length} announcements by creator $createdBy');
    return data.map((json) => Announcement.fromJson(json)).toList();
  }

  @override
  Future<Announcement> updateAnnouncement(String announcementId, UpdateAnnouncementRequest request) async {
    print('📢 AnnouncementRemoteDataSource: Updating announcement $announcementId');
    print('📢 Request data: ${request.toJson()}');
    
    final endpoint = ApiConstants.announcementById.replaceAll('{announcementId}', announcementId);
    final response = await _apiClient.put(
      endpoint,
      body: request.toJson(),
      requireAuth: true,
    );

    final data = jsonDecode(response.body);
    print('📢 Updated announcement: ${data['title']}');
    return Announcement.fromJson(data);
  }

  @override
  Future<void> deleteAnnouncement(String announcementId) async {
    print('📢 AnnouncementRemoteDataSource: Deleting announcement $announcementId');
    
    final endpoint = ApiConstants.announcementById.replaceAll('{announcementId}', announcementId);
    await _apiClient.delete(
      endpoint,
      requireAuth: true,
    );
    
    print('📢 Deleted announcement $announcementId');
  }

  @override
  Future<Comment> createComment(String announcementId, CreateCommentRequest request) async {
    print('💬 AnnouncementRemoteDataSource: Creating comment for announcement $announcementId');
    print('💬 Request data: ${request.toJson()}');
    
    final endpoint = ApiConstants.announcementComments.replaceAll('{announcementId}', announcementId);
    final response = await _apiClient.post(
      endpoint,
      body: request.toJson(),
      requireAuth: true,
    );

    final data = jsonDecode(response.body);
    print('💬 Created comment: ${data['content']}');
    return Comment.fromJson(data);
  }

  @override
  Future<List<Comment>> getCommentsByAnnouncement(String announcementId) async {
    print('💬 AnnouncementRemoteDataSource: Getting comments for announcement $announcementId');
    
    final endpoint = ApiConstants.announcementComments.replaceAll('{announcementId}', announcementId);
    final response = await _apiClient.get(
      endpoint,
      requireAuth: true,
    );

    final List<dynamic> data = jsonDecode(response.body);
    print('💬 Got ${data.length} comments for announcement $announcementId');
    return data.map((json) => Comment.fromJson(json)).toList();
  }

  @override
  Future<Comment> getCommentById(String commentId) async {
    print('💬 AnnouncementRemoteDataSource: Getting comment $commentId');
    
    final endpoint = ApiConstants.commentById.replaceAll('{commentId}', commentId);
    final response = await _apiClient.get(
      endpoint,
      requireAuth: true,
    );

    final data = jsonDecode(response.body);
    print('💬 Got comment: ${data['content']}');
    return Comment.fromJson(data);
  }

  @override
  Future<void> deleteComment(String commentId) async {
    print('💬 AnnouncementRemoteDataSource: Deleting comment $commentId');
    
    final endpoint = ApiConstants.commentById.replaceAll('{commentId}', commentId);
    await _apiClient.delete(
      endpoint,
      requireAuth: true,
    );
    
    print('💬 Deleted comment $commentId');
  }
}