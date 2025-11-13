import 'dart:convert';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../models/chat_item.dart';
import '../models/message_response.dart';
import '../models/create_group_request.dart';
import '../models/edit_group_request.dart';
import '../models/send_message_request.dart';

abstract class ChatRemoteDataSource {
  Future<List<ChatItem>> getUserGroups(String userId);
  Future<ChatItem> createGroup(CreateGroupRequest request);
  Future<ChatItem> getGroupById(String groupId);
  Future<List<ChatItem>> getAllGroups();
  Future<ChatItem> updateGroup(String groupId, EditGroupRequest request);
  Future<void> deleteGroup(String groupId);
  Future<MessageResponse> sendMessage(String groupId, SendMessageRequest request);
  Future<List<MessageResponse>> getGroupMessages(String groupId);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final ApiClient _apiClient;

  ChatRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<List<ChatItem>> getUserGroups(String userId) async {
    final endpoint = '${ApiConstants.chatGroupsByUser}?userId=$userId';
    print('📱 ChatRemoteDataSource: GET $endpoint');
    
    final response = await _apiClient.get(
      endpoint,
      requireAuth: true,
    );

    print('📱 ChatRemoteDataSource: Response status: ${response.statusCode}');
    print('📱 ChatRemoteDataSource: Response body: ${response.body}');

    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => ChatItem.fromJson(json)).toList();
  }

  @override
  Future<ChatItem> createGroup(CreateGroupRequest request) async {
    final response = await _apiClient.post(
      ApiConstants.chatGroups,
      body: request.toJson(),
      requireAuth: true,
    );

    final data = jsonDecode(response.body);
    return ChatItem.fromJson(data);
  }

  @override
  Future<ChatItem> getGroupById(String groupId) async {
    final endpoint = ApiConstants.chatGroupById.replaceAll('{groupId}', groupId);
    final response = await _apiClient.get(
      endpoint,
      requireAuth: true,
    );

    final data = jsonDecode(response.body);
    return ChatItem.fromJson(data);
  }

  @override
  Future<List<ChatItem>> getAllGroups() async {
    final response = await _apiClient.get(
      ApiConstants.chatGroups,
      requireAuth: true,
    );

    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => ChatItem.fromJson(json)).toList();
  }

  @override
  Future<ChatItem> updateGroup(String groupId, EditGroupRequest request) async {
    print('🔄 ChatRemoteDataSource: Updating group $groupId');
    print('🔄 Request data: ${request.toJson()}');
    
    final endpoint = ApiConstants.chatGroupById.replaceAll('{groupId}', groupId);
    print('🔄 PUT endpoint: $endpoint');
    
    try {
      final response = await _apiClient.put(
        endpoint,
        body: request.toJson(),
        requireAuth: true,
      );

      print('🔄 Update response status: ${response.statusCode}');
      print('🔄 Update response body: ${response.body}');
      
      final data = jsonDecode(response.body);
      final updatedGroup = ChatItem.fromJson(data);
      print('✅ Group updated successfully: ${updatedGroup.id}');
      
      return updatedGroup;
    } catch (e) {
      print('❌ Error updating group: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteGroup(String groupId) async {
    print('🗑️ ChatRemoteDataSource: Deleting group $groupId');
    
    final endpoint = ApiConstants.chatGroupById.replaceAll('{groupId}', groupId);
    print('🗑️ DELETE endpoint: $endpoint');
    
    try {
      final response = await _apiClient.delete(
        endpoint,
        requireAuth: true,
      );

      print('🗑️ Delete response status: ${response.statusCode}');
      print('✅ Group deleted successfully');
    } catch (e) {
      print('❌ Error deleting group: $e');
      rethrow;
    }
  }

  @override
  Future<MessageResponse> sendMessage(String groupId, SendMessageRequest request) async {
    print('📤 ChatRemoteDataSource: Sending message to group $groupId');
    print('📤 Message data: ${request.toJson()}');
    
    final endpoint = ApiConstants.chatGroupMessages.replaceAll('{groupId}', groupId);
    print('📤 POST endpoint: $endpoint');
    
    try {
      final response = await _apiClient.post(
        endpoint,
        body: request.toJson(),
        requireAuth: true,
      );

      print('📤 Send message response status: ${response.statusCode}');
      print('📤 Send message response body: ${response.body}');
      
      final data = jsonDecode(response.body);
      final message = MessageResponse.fromJson(data);
      print('✅ Message sent successfully: ${message.messageId}');
      
      return message;
    } catch (e) {
      print('❌ Error sending message: $e');
      rethrow;
    }
  }

  @override
  Future<List<MessageResponse>> getGroupMessages(String groupId) async {
    print('📥 ChatRemoteDataSource: Getting messages for group $groupId');
    
    final endpoint = ApiConstants.chatGroupMessages.replaceAll('{groupId}', groupId);
    print('📥 GET endpoint: $endpoint');
    
    try {
      final response = await _apiClient.get(
        endpoint,
        requireAuth: true,
      );

      print('📥 Get messages response status: ${response.statusCode}');
      
      final List<dynamic> data = jsonDecode(response.body);
      final messages = data.map((json) => MessageResponse.fromJson(json)).toList();
      print('✅ Retrieved ${messages.length} messages for group $groupId');
      
      return messages;
    } catch (e) {
      print('❌ Error getting messages: $e');
      rethrow;
    }
  }
}