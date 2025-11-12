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
  final String message;
  const EventCreatedSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class EventUpdatedSuccess extends EventState {
  final String message;
  const EventUpdatedSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class EventDeletedSuccess extends EventState {
  final String message;
  const EventDeletedSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class EventError extends EventState {
  final String error;

  const EventError(this.error);

  @override
  List<Object?> get props => [error];
}