import 'dart:convert';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../models/event_model.dart';
import '../models/create_event_request.dart';
import '../models/update_event_request.dart';

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

  EventRemoteDataSourceImpl({required ApiClient client}) : _client = client;

  @override
  Future<List<EventModel>> getEvents({String? userId, String? filterType}) async {
    String endpoint = ApiConstants.events;

    final params = <String, String>{};
    if (userId != null && userId.isNotEmpty) params['userId'] = userId;
    if (filterType != null && filterType.isNotEmpty) params['filter'] = filterType;

    if (params.isNotEmpty) {
      final qs = params.entries
          .map((e) => '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}')
          .join('&');
      endpoint = '$endpoint?$qs';
    }

    final response = await _client.get(endpoint, requireAuth: true);
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((e) => EventModel.fromJson(e)).toList();
  }

  @override
  Future<EventModel> getEventById(String eventId) async {
    final endpoint = ApiConstants.eventById.replaceAll('{eventId}', eventId);
    final response = await _client.get(endpoint, requireAuth: true);
    final data = jsonDecode(response.body);
    return EventModel.fromJson(data);
  }

  @override
  Future<List<EventModel>> getEventsCalendar({String? userId}) async {
    String endpoint = ApiConstants.eventsCalendar;

    if (userId != null && userId.isNotEmpty) {
      final qs = 'userId=${Uri.encodeQueryComponent(userId)}';
      endpoint = '$endpoint?$qs';
    }

    final response = await _client.get(endpoint, requireAuth: true);
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((e) => EventModel.fromJson(e)).toList();
  }

  @override
  Future<EventModel> createEvent(CreateEventRequest request) async {
    final response = await _client.post(
      ApiConstants.events,
      body: request.toJson(),
      requireAuth: true,
    );
    final data = jsonDecode(response.body);
    return EventModel.fromJson(data);
  }

  @override
  Future<EventModel> updateEvent(String eventId, UpdateEventRequest request) async {
    final endpoint = ApiConstants.eventById.replaceAll('{eventId}', eventId);
    final response = await _client.put(
      endpoint,
      body: request.toJson(),
      requireAuth: true,
    );
    final data = jsonDecode(response.body);
    return EventModel.fromJson(data);
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    final endpoint = ApiConstants.eventById.replaceAll('{eventId}', eventId);
    final response = await _client.delete(endpoint, requireAuth: true);

    if (response.statusCode == 204) return;
    if (response.statusCode == 404) throw Exception('Evento no encontrado');
    throw Exception('Error eliminando evento: ${response.statusCode}');
  }
}