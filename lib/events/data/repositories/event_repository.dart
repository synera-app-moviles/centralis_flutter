import '../datasources/event_remote_datasource.dart';
import '../models/create_event_request.dart';
import '../models/event_model.dart';
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
  final EventRemoteDataSource remoteDataSource;

  EventRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<EventModel>> getEvents({String? userId, String? filterType}) async {
    return await remoteDataSource.getEvents(
      userId: userId,
      filterType: filterType,
    );
  }

  @override
  Future<EventModel> getEventById(String eventId) async {
    return await remoteDataSource.getEventById(eventId);
  }

  @override
  Future<List<EventModel>> getEventsCalendar({String? userId}) async {
    return await remoteDataSource.getEventsCalendar(userId: userId);
  }

  @override
  Future<EventModel> createEvent(CreateEventRequest request) async {
    return await remoteDataSource.createEvent(request);
  }

  @override
  Future<EventModel> updateEvent(String eventId, UpdateEventRequest request) async {
    return await remoteDataSource.updateEvent(eventId, request);
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    await remoteDataSource.deleteEvent(eventId);
  }
}