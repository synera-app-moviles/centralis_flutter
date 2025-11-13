import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/event_repository.dart';
import 'event_event.dart';
import 'event_state.dart';

class EventBloc extends Bloc<EventEvent, EventState> {
  final EventRepository repository;

  EventBloc({required this.repository}) : super(EventInitial()) {
    on<LoadEvents>(_onLoadEvents);
    on<LoadEventById>(_onLoadEventById);
    on<LoadEventsCalendar>(_onLoadEventsCalendar);
    on<CreateEvent>(_onCreateEvent);
    on<UpdateEvent>(_onUpdateEvent);
    on<DeleteEvent>(_onDeleteEvent);
    on<ResetEventState>(_onResetEventState);
  }

  Future<void> _onLoadEvents(LoadEvents event, Emitter<EventState> emit) async {
    emit(EventLoading());
    try {
      final events = await repository.getEvents(
        userId: event.userId,
        filterType: event.filterType,
      );
      emit(EventsLoaded(events));
    } catch (e) {
      emit(EventError(e.toString()));
    }
  }

  Future<void> _onLoadEventById(LoadEventById event, Emitter<EventState> emit) async {
    emit(EventLoading());
    try {
      final eventData = await repository.getEventById(event.eventId);
      emit(EventLoaded(eventData));
    } catch (e) {
      emit(EventError(e.toString()));
    }
  }

  Future<void> _onLoadEventsCalendar(LoadEventsCalendar event, Emitter<EventState> emit) async {
    emit(EventLoading());
    try {
      final events = await repository.getEventsCalendar(userId: event.userId);
      emit(EventsLoaded(events));
    } catch (e) {
      emit(EventError(e.toString()));
    }
  }

  Future<void> _onCreateEvent(CreateEvent event, Emitter<EventState> emit) async {
    emit(EventLoading());
    try {
      final created = await repository.createEvent(event.request);
      emit(EventCreatedSuccess(created));
    } catch (e) {
      emit(EventError(e.toString()));
    }
  }

  Future<void> _onUpdateEvent(UpdateEvent event, Emitter<EventState> emit) async {
    emit(EventLoading());
    try {
      final updated = await repository.updateEvent(event.eventId, event.request);
      emit(EventUpdatedSuccess(updated));
    } catch (e) {
      emit(EventError(e.toString()));
    }
  }

  Future<void> _onDeleteEvent(DeleteEvent event, Emitter<EventState> emit) async {
    emit(EventLoading());
    try {
      await repository.deleteEvent(event.eventId);
      emit(EventDeletedSuccess(event.eventId));
    } catch (e) {
      emit(EventError(e.toString()));
    }
  }

  void _onResetEventState(ResetEventState event, Emitter<EventState> emit) {
    emit(EventInitial());
  }
}