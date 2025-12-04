import '../datasources/chat_remote_datasource.dart';
import '../models/chat_item.dart';
import '../models/message_response.dart';
import '../models/create_group_request.dart';
import '../models/edit_group_request.dart';
import '../models/send_message_request.dart';
import '../models/chat_image.dart';
import '../models/send_image_request.dart';

abstract class ChatRepository {
  Future<List<ChatItem>> getUserGroups(String userId);
  Future<ChatItem> createGroup({
    required String name,
    required String description,
    required String visibility,
    required String createdBy,
    required List<String> memberIds,
    String? imageUrl,
  });
  Future<ChatItem> getGroupById(String groupId);
  Future<List<ChatItem>> getAllGroups();
  Future<ChatItem> updateGroup({
    required String groupId,
    required String name,
    required String description,
    required String visibility,
    String? imageUrl,
  });
  Future<void> deleteGroup(String groupId);
  Future<MessageResponse> sendMessage({
    required String groupId,
    required String content,
    required String senderId,
    required String senderName,
    String? messageType,
  });
  Future<List<MessageResponse>> getGroupMessages(String groupId);
  
  // Image methods
  Future<ChatImage> sendImage({
    required String groupId,
    required String senderId,
    required String imageUrl,
  });
  Future<List<ChatImage>> getGroupImages(String groupId);
  Future<ChatImage> getImageById(String groupId, String imageId);
  Future<ChatImage> deleteImage(String groupId, String imageId);
}

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<List<ChatItem>> getUserGroups(String userId) async {
    return await remoteDataSource.getUserGroups(userId);
  }

  @override
  Future<ChatItem> createGroup({
    required String name,
    required String description,
    required String visibility,
    required String createdBy,
    required List<String> memberIds,
    String? imageUrl,
  }) async {
    final request = CreateGroupRequest(
      name: name,
      description: description,
      visibility: visibility,
      createdBy: createdBy,
      memberIds: memberIds,
      imageUrl: imageUrl,
    );
    
    return await remoteDataSource.createGroup(request);
  }

  @override
  Future<ChatItem> getGroupById(String groupId) async {
    return await remoteDataSource.getGroupById(groupId);
  }

  @override
  Future<List<ChatItem>> getAllGroups() async {
    return await remoteDataSource.getAllGroups();
  }

  @override
  Future<ChatItem> updateGroup({
    required String groupId,
    required String name,
    required String description,
    required String visibility,
    String? imageUrl,
  }) async {
    final request = EditGroupRequest(
      name: name,
      description: description,
      visibility: visibility,
      imageUrl: imageUrl,
    );
    
    return await remoteDataSource.updateGroup(groupId, request);
  }

  @override
  Future<void> deleteGroup(String groupId) async {
    return await remoteDataSource.deleteGroup(groupId);
  }

  @override
  Future<MessageResponse> sendMessage({
    required String groupId,
    required String content,
    required String senderId,
    required String senderName,
    String? messageType,
  }) async {
    final request = SendMessageRequest(
      body: content, // Cambiado de 'content' a 'body'
      senderId: senderId,
    );
    
    return await remoteDataSource.sendMessage(groupId, request);
  }

  @override
  Future<List<MessageResponse>> getGroupMessages(String groupId) async {
    return await remoteDataSource.getGroupMessages(groupId);
  }

  // Image methods implementation
  @override
  Future<ChatImage> sendImage({
    required String groupId,
    required String senderId,
    required String imageUrl,
  }) async {
    final request = SendImageRequest(
      senderId: senderId,
      imageUrl: imageUrl,
    );
    
    return await remoteDataSource.sendImage(groupId, request);
  }

  @override
  Future<List<ChatImage>> getGroupImages(String groupId) async {
    return await remoteDataSource.getGroupImages(groupId);
  }

  @override
  Future<ChatImage> getImageById(String groupId, String imageId) async {
    return await remoteDataSource.getImageById(groupId, imageId);
  }

  @override
  Future<ChatImage> deleteImage(String groupId, String imageId) async {
    return await remoteDataSource.deleteImage(groupId, imageId);
  }
}