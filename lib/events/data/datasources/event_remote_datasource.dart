import 'dart:convert';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../models/event_model.dart';
import '../models/create_event_request.dart';
import '../models/update_event_request.dart';

abstract class EventRemoteDataSource {
  Future<EventModel> createEvent(CreateEventRequest request);
  Future<EventModel> getEventById(String eventId);
  Future<List<EventModel>> getEvents({String? userId, String? filterType});
  Future<List<EventModel>> getEventsCalendar({String? userId});
  Future<EventModel> updateEvent(String eventId, UpdateEventRequest request);
  Future<void> deleteEvent(String eventId);
}

class EventRemoteDataSourceImpl implements EventRemoteDataSource {
  final ApiClient _apiClient;
  final SecureStorageService _storage;

  EventRemoteDataSourceImpl({
    required ApiClient apiClient,
    required SecureStorageService storage,
  })  : _apiClient = apiClient,
        _storage = storage;

  @override
  Future<EventModel> createEvent(CreateEventRequest request) async {
    try {
      print('📤 EventRemoteDataSource: Creating event...');

      // Limpia el JSON eliminando valores null opcionales
      final jsonData = request.toJson();
      jsonData.removeWhere((key, value) => value == null);

      print('📤 Request body (cleaned): $jsonData');

      final response = await _apiClient.post(
        ApiConstants.events,
        body: jsonData,
        requireAuth: true,
      );

      final data = jsonDecode(response.body);
      return EventModel.fromJson(data);
    } catch (e) {
      print('❌ Error creating event: $e');
      rethrow;
    }
  }

  @override
  Future<EventModel> getEventById(String eventId) async {
    try {
      final endpoint = ApiConstants.eventById.replaceAll('{eventId}', eventId);
      final response = await _apiClient.get(endpoint, requireAuth: true);

      final data = jsonDecode(response.body);
      return EventModel.fromJson(data);
    } catch (e) {
      print('❌ Error getting event by id: $e');
      rethrow;
    }
  }

  @override
  Future<List<EventModel>> getEvents({String? userId, String? filterType}) async {
    try {
      final currentUserId = userId ?? await _storage.getUserId();

      final queryParams = <String, String>{};
      if (currentUserId != null) queryParams['userId'] = currentUserId;
      if (filterType != null) queryParams['filterType'] = filterType;

      final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.events}')
          .replace(queryParameters: queryParams);

      final response = await _apiClient.get(uri.toString(), requireAuth: true);

      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => EventModel.fromJson(json)).toList();
    } catch (e) {
      print('❌ Error getting events: $e');
      rethrow;
    }
  }

  @override
  Future<List<EventModel>> getEventsCalendar({String? userId}) async {
    try {
      final currentUserId = userId ?? await _storage.getUserId();

      final queryParams = <String, String>{};
      if (currentUserId != null) queryParams['userId'] = currentUserId;

      final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.eventsCalendar}')
          .replace(queryParameters: queryParams);

      final response = await _apiClient.get(uri.toString(), requireAuth: true);

      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => EventModel.fromJson(json)).toList();
    } catch (e) {
      print('❌ Error getting events calendar: $e');
      rethrow;
    }
  }

  @override
  Future<EventModel> updateEvent(
    String eventId,
    UpdateEventRequest request,
  ) async {
    try {
      print('🔄 EventRemoteDataSource: Updating event $eventId');

      // Limpia el JSON eliminando valores null opcionales
      final jsonData = request.toJson();
      jsonData.removeWhere((key, value) => value == null);

      print('🔄 Request body (cleaned): $jsonData');

      final endpoint = ApiConstants.eventById.replaceAll('{eventId}', eventId);

      final response = await _apiClient.put(
        endpoint,
        body: jsonData,
        requireAuth: true,
      );

      final data = jsonDecode(response.body);
      return EventModel.fromJson(data);
    } catch (e) {
      print('❌ Error updating event: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    try {
      print('🗑️ EventRemoteDataSource: Deleting event $eventId');

      final endpoint = ApiConstants.eventById.replaceAll('{eventId}', eventId);

      await _apiClient.put(
        endpoint,
        requireAuth: true,
      );

      print('✅ Event deleted successfully');
    } catch (e) {
      print('❌ Error deleting event: $e');
      rethrow;
    }
  }
}