import '../datasources/announcement_remote_datasource.dart';
import '../models/announcement.dart';
import '../models/comment.dart';
import '../models/priority.dart';
import '../models/create_announcement_request.dart';
import '../models/update_announcement_request.dart';
import '../models/create_comment_request.dart';

abstract class AnnouncementRepository {
  Future<Announcement> createAnnouncement({
    required String title,
    required String description,
    String? image,
    required Priority priority,
    required String createdBy,
  });
  
  Future<Announcement> getAnnouncementById(String announcementId);
  Future<List<Announcement>> getAllAnnouncements();
  Future<List<Announcement>> getAnnouncementsByPriority(Priority priority);
  Future<List<Announcement>> getAnnouncementsByCreator(String createdBy);
  
  Future<Announcement> updateAnnouncement({
    required String announcementId,
    required String title,
    required String description,
    String? image,
    required Priority priority,
  });
  
  Future<void> deleteAnnouncement(String announcementId);
  
  Future<Comment> createComment({
    required String announcementId,
    required String employeeId,
    required String content,
  });
  
  Future<List<Comment>> getCommentsByAnnouncement(String announcementId);
  Future<Comment> getCommentById(String commentId);
  Future<void> deleteComment(String commentId);
}

class AnnouncementRepositoryImpl implements AnnouncementRepository {
  final AnnouncementRemoteDataSource remoteDataSource;

  AnnouncementRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Announcement> createAnnouncement({
    required String title,
    required String description,
    String? image,
    required Priority priority,
    required String createdBy,
  }) async {
    print('🏛️ AnnouncementRepository: Creating announcement');
    
    final request = CreateAnnouncementRequest(
      title: title,
      description: description,
      image: image,
      priority: priority,
      createdBy: createdBy,
    );
    
    try {
      final announcement = await remoteDataSource.createAnnouncement(request);
      print('🏛️ AnnouncementRepository: Successfully created announcement: ${announcement.title}');
      return announcement;
    } catch (e) {
      print('🏛️ AnnouncementRepository: Error creating announcement: $e');
      rethrow;
    }
  }

  @override
  Future<Announcement> getAnnouncementById(String announcementId) async {
    print('🏛️ AnnouncementRepository: Getting announcement $announcementId');
    
    try {
      final announcement = await remoteDataSource.getAnnouncementById(announcementId);
      print('🏛️ AnnouncementRepository: Successfully got announcement: ${announcement.title}');
      return announcement;
    } catch (e) {
      print('🏛️ AnnouncementRepository: Error getting announcement: $e');
      rethrow;
    }
  }

  @override
  Future<List<Announcement>> getAllAnnouncements() async {
    print('🏛️ AnnouncementRepository: Getting all announcements');
    
    try {
      final announcements = await remoteDataSource.getAllAnnouncements();
      print('🏛️ AnnouncementRepository: Successfully got ${announcements.length} announcements');
      return announcements;
    } catch (e) {
      print('🏛️ AnnouncementRepository: Error getting announcements: $e');
      rethrow;
    }
  }

  @override
  Future<List<Announcement>> getAnnouncementsByPriority(Priority priority) async {
    print('🏛️ AnnouncementRepository: Getting announcements by priority ${priority.value}');
    
    try {
      final announcements = await remoteDataSource.getAnnouncementsByPriority(priority);
      print('🏛️ AnnouncementRepository: Successfully got ${announcements.length} announcements with priority ${priority.value}');
      return announcements;
    } catch (e) {
      print('🏛️ AnnouncementRepository: Error getting announcements by priority: $e');
      rethrow;
    }
  }

  @override
  Future<List<Announcement>> getAnnouncementsByCreator(String createdBy) async {
    print('🏛️ AnnouncementRepository: Getting announcements by creator $createdBy');
    
    try {
      final announcements = await remoteDataSource.getAnnouncementsByCreator(createdBy);
      print('🏛️ AnnouncementRepository: Successfully got ${announcements.length} announcements by creator $createdBy');
      return announcements;
    } catch (e) {
      print('🏛️ AnnouncementRepository: Error getting announcements by creator: $e');
      rethrow;
    }
  }

  @override
  Future<Announcement> updateAnnouncement({
    required String announcementId,
    required String title,
    required String description,
    String? image,
    required Priority priority,
  }) async {
    print('🏛️ AnnouncementRepository: Updating announcement $announcementId');
    
    final request = UpdateAnnouncementRequest(
      title: title,
      description: description,
      image: image,
      priority: priority,
    );
    
    try {
      final announcement = await remoteDataSource.updateAnnouncement(announcementId, request);
      print('🏛️ AnnouncementRepository: Successfully updated announcement: ${announcement.title}');
      return announcement;
    } catch (e) {
      print('🏛️ AnnouncementRepository: Error updating announcement: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteAnnouncement(String announcementId) async {
    print('🏛️ AnnouncementRepository: Deleting announcement $announcementId');
    
    try {
      await remoteDataSource.deleteAnnouncement(announcementId);
      print('🏛️ AnnouncementRepository: Successfully deleted announcement $announcementId');
    } catch (e) {
      print('🏛️ AnnouncementRepository: Error deleting announcement: $e');
      rethrow;
    }
  }

  @override
  Future<Comment> createComment({
    required String announcementId,
    required String employeeId,
    required String content,
  }) async {
    print('🏛️ AnnouncementRepository: Creating comment for announcement $announcementId');
    
    final request = CreateCommentRequest(
      employeeId: employeeId,
      content: content,
    );
    
    try {
      final comment = await remoteDataSource.createComment(announcementId, request);
      print('🏛️ AnnouncementRepository: Successfully created comment: ${comment.content}');
      return comment;
    } catch (e) {
      print('🏛️ AnnouncementRepository: Error creating comment: $e');
      rethrow;
    }
  }

  @override
  Future<List<Comment>> getCommentsByAnnouncement(String announcementId) async {
    print('🏛️ AnnouncementRepository: Getting comments for announcement $announcementId');
    
    try {
      final comments = await remoteDataSource.getCommentsByAnnouncement(announcementId);
      print('🏛️ AnnouncementRepository: Successfully got ${comments.length} comments');
      return comments;
    } catch (e) {
      print('🏛️ AnnouncementRepository: Error getting comments: $e');
      rethrow;
    }
  }

  @override
  Future<Comment> getCommentById(String commentId) async {
    print('🏛️ AnnouncementRepository: Getting comment $commentId');
    
    try {
      final comment = await remoteDataSource.getCommentById(commentId);
      print('🏛️ AnnouncementRepository: Successfully got comment: ${comment.content}');
      return comment;
    } catch (e) {
      print('🏛️ AnnouncementRepository: Error getting comment: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteComment(String commentId) async {
    print('🏛️ AnnouncementRepository: Deleting comment $commentId');
    
    try {
      await remoteDataSource.deleteComment(commentId);
      print('🏛️ AnnouncementRepository: Successfully deleted comment $commentId');
    } catch (e) {
      print('🏛️ AnnouncementRepository: Error deleting comment: $e');
      rethrow;
    }
  }
}