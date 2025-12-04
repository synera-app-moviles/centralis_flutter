import 'dart:convert';
import '../../../core/di/service_locator.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../data/models/event_model.dart';
import '../../data/models/create_event_request.dart';
import '../../data/models/update_event_request.dart';

abstract class EventRemoteDataSource {
  Future<List<EventModel>> getEvents({String? userId, String? filterType});
  Future<EventModel> getEventById(String eventId);
  Future<List<EventModel>> getEventsCalendar({String? userId});
  Future<EventModel> createEvent(CreateEventRequest request);
  Future<EventModel> updateEvent(String eventId, UpdateEventRequest request);
  Future<void> deleteEvent(String eventId);
}

class EventRemoteDataSourceImpl implements EventRemoteDataSource {
  final ApiClient _client;

  EventRemoteDataSourceImpl({ApiClient? client}) : _client = client ?? sl<ApiClient>();

  List<EventModel> _parseList(String? body) {
    try {
      if (body == null || body.trim().isEmpty) return [];
      final decoded = jsonDecode(body);
      List<dynamic> list;
      if (decoded is List) {
        list = decoded;
      } else if (decoded is Map && decoded['data'] is List) {
        list = decoded['data'] as List<dynamic>;
      } else {
        return [];
      }
      return list.map((e) {
        if (e is Map<String, dynamic>) return EventModel.fromJson(e);
        if (e is Map) return EventModel.fromJson(Map<String, dynamic>.from(e));
        return EventModel.fromJson((e as dynamic).toJson() as Map<String, dynamic>);
      }).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<EventModel>> _getWithAuthFallback(String endpoint) async {
    try {
      final resp = await _client.get(endpoint, requireAuth: true);
      return _parseList(resp.body);
    } catch (e) {

      try {
        final respNoAuth = await _client.get(endpoint, requireAuth: false);
        return _parseList(respNoAuth.body);
      } catch (_) {
        rethrow;
      }
    }
  }

  List<EventModel> _filterEventsForUser(List<EventModel> events, String userId, String? profileId) {
    return events.where((e) {
      if (e.createdBy != null && e.createdBy == userId) return true;
      if (e.recipientIds.contains(userId)) return true;
      if (profileId != null && e.recipientIds.contains(profileId)) return true;
      return false;
    }).toList();
  }

  @override
  Future<List<EventModel>> getEvents({String? userId, String? filterType}) async {
    var endpoint = ApiConstants.events;
    final params = <String>[];

    if (filterType != null && filterType.isNotEmpty) {
      params.add('filter=${Uri.encodeQueryComponent(filterType)}');
    }
    if (params.isNotEmpty) endpoint = '$endpoint?${params.join('&')}';

    final all = await _getWithAuthFallback(endpoint);

    if (userId == null || userId.isEmpty) return all;

    String? profileId;
    try {

      final profileEndpoint = '${ApiConstants.profiles}/user/${Uri.encodeComponent(userId)}';
      final resp = await _client.get(profileEndpoint, requireAuth: true);
      if (resp.body.isNotEmpty) {
        final map = jsonDecode(resp.body);
        if (map is Map<String, dynamic>) {
          profileId = (map['profileId'] ?? map['profile_id'] ?? map['id'])?.toString();
        }
      }
    } catch (_) {

    }

    return _filterEventsForUser(all, userId, profileId);
  }

  @override
  Future<EventModel> getEventById(String eventId) async {
    final endpoint = '${ApiConstants.events}/$eventId';
    final resp = await _client.get(endpoint, requireAuth: true);
    final map = (resp.body.isNotEmpty) ? jsonDecode(resp.body) as Map<String, dynamic> : <String, dynamic>{};
    return EventModel.fromJson(map);
  }

  @override
  Future<List<EventModel>> getEventsCalendar({String? userId}) async {
    var endpoint = ApiConstants.eventsCalendar;
    if (userId != null && userId.isNotEmpty) {
      endpoint = '$endpoint?user_id=${Uri.encodeQueryComponent(userId)}';
    }
    return await _getWithAuthFallback(endpoint);
  }

  @override
  Future<EventModel> createEvent(CreateEventRequest request) async {

    final resp = await _client.post(ApiConstants.events, body: request.toJson(), requireAuth: true);
    final map = (resp.body.isNotEmpty) ? jsonDecode(resp.body) as Map<String, dynamic> : <String, dynamic>{};
    return EventModel.fromJson(map);
  }

  @override
  Future<EventModel> updateEvent(String eventId, UpdateEventRequest request) async {
    final endpoint = '${ApiConstants.events}/$eventId';
    final resp = await _client.put(endpoint, body: request.toJson(), requireAuth: true);
    final map = (resp.body.isNotEmpty) ? jsonDecode(resp.body) as Map<String, dynamic> : <String, dynamic>{};
    return EventModel.fromJson(map);
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    final endpoint = '${ApiConstants.events}/$eventId';
    await _client.delete(endpoint, requireAuth: true);
  }
}