import 'package:equatable/equatable.dart';
import '../../data/models/event_model.dart';

abstract class EventState extends Equatable {
  const EventState();

  @override
  List<Object?> get props => [];
}

class EventInitial extends EventState {}

class EventLoading extends EventState {}

class EventsLoaded extends EventState {
  final List<EventModel> events;

  const EventsLoaded(this.events);

  @override
  List<Object?> get props => [events];
}

class EventLoaded extends EventState {
  final EventModel event;

  const EventLoaded(this.event);

  @override
  List<Object?> get props => [event];
}

class EventOperationSuccess extends EventState {
  final String message;

  const EventOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class EventCreatedSuccess extends EventState {
  final EventModel createdEvent;
  final String message;

  EventCreatedSuccess(this.createdEvent, {this.message = 'Event created successfully'});

  @override
  List<Object?> get props => [createdEvent, message];
}

class EventUpdatedSuccess extends EventState {
  final EventModel updatedEvent;
  final String message;

  EventUpdatedSuccess(this.updatedEvent, {this.message = 'Event updated successfully'});

  @override
  List<Object?> get props => [updatedEvent, message];
}

class EventDeletedSuccess extends EventState {
  final String eventId;
  const EventDeletedSuccess(this.eventId);

  @override
  List<Object?> get props => [eventId];
}

class EventError extends EventState {
  final String error;

  const EventError(this.error);

  @override
  List<Object?> get props => [error];
}