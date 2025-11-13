// dart
import '../datasources/event_remote_datasource.dart';
import '../models/event_model.dart';
import '../models/create_event_request.dart';
import '../models/update_event_request.dart';

abstract class EventRepository {
  Future<List<EventModel>> getEvents({String? userId, String? filterType});
  Future<EventModel> getEventById(String eventId);
  Future<List<EventModel>> getEventsCalendar({String? userId});
  Future<EventModel> createEvent(CreateEventRequest request);
  Future<EventModel> updateEvent(String eventId, UpdateEventRequest request);
  Future<void> deleteEvent(String eventId);
}

class EventRepositoryImpl implements EventRepository {
  final EventRemoteDataSource _remote;

  EventRepositoryImpl({required EventRemoteDataSource remoteDataSource})
      : _remote = remoteDataSource;

  @override
  Future<List<EventModel>> getEvents({String? userId, String? filterType}) {
    return _remote.getEvents(userId: userId, filterType: filterType);
  }

  @override
  Future<EventModel> getEventById(String eventId) {
    return _remote.getEventById(eventId);
  }

  @override
  Future<List<EventModel>> getEventsCalendar({String? userId}) {
    return _remote.getEventsCalendar(userId: userId);
  }

  @override
  Future<EventModel> createEvent(CreateEventRequest request) async {
    return await _remote.createEvent(request);
  }

  @override
  Future<EventModel> updateEvent(String eventId, UpdateEventRequest request) async {
    return await _remote.updateEvent(eventId, request);
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    await _remote.deleteEvent(eventId);
  }
}