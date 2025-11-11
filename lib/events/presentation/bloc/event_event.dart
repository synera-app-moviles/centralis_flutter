import 'package:equatable/equatable.dart';
import '../../data/models/create_event_request.dart';
import '../../data/models/update_event_request.dart';

abstract class EventEvent extends Equatable {
  const EventEvent();

  @override
  List<Object?> get props => [];
}

class LoadEvents extends EventEvent {
  final String? userId;
  final String? filterType;

  const LoadEvents({this.userId, this.filterType});

  @override
  List<Object?> get props => [userId, filterType];
}

class LoadEventById extends EventEvent {
  final String eventId;

  const LoadEventById(this.eventId);

  @override
  List<Object?> get props => [eventId];
}

class LoadEventsCalendar extends EventEvent {
  final String? userId;

  const LoadEventsCalendar({this.userId});

  @override
  List<Object?> get props => [userId];
}

class CreateEvent extends EventEvent {
  final CreateEventRequest request;

  const CreateEvent(this.request);

  @override
  List<Object?> get props => [request];
}

class UpdateEvent extends EventEvent {
  final String eventId;
  final UpdateEventRequest request;

  const UpdateEvent(this.eventId, this.request);

  @override
  List<Object?> get props => [eventId, request];
}

class DeleteEvent extends EventEvent {
  final String eventId;

  const DeleteEvent(this.eventId);

  @override
  List<Object?> get props => [eventId];
}

class ResetEventState extends EventEvent {}

