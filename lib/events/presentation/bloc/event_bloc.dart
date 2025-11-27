import 'package:bloc/bloc.dart';
import '../../data/repositories/event_repository.dart';
import 'event_event.dart';
import 'event_state.dart';
import '../../data/models/create_event_request.dart';
import '../../data/models/update_event_request.dart';
import '../../../core/di/service_locator.dart';

class EventBloc extends Bloc<EventEvent, EventState> {
  final EventRepository _repo;

  EventBloc({EventRepository? repository})
      : _repo = repository ?? sl<EventRepository>(),
        super(EventInitial()) {
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
      final events = await _repo.getEvents(userId: event.userId, filterType: event.filterType);
      emit(EventsLoaded(events));
    } catch (e) {
      emit(EventError(e.toString()));
    }
  }

  Future<void> _onLoadEventById(LoadEventById event, Emitter<EventState> emit) async {
    emit(EventLoading());
    try {
      final ev = await _repo.getEventById(event.eventId);
      emit(EventLoaded(ev));
    } catch (e) {
      emit(EventError(e.toString()));
    }
  }

  Future<void> _onLoadEventsCalendar(LoadEventsCalendar event, Emitter<EventState> emit) async {
    emit(EventLoading());
    try {
      final events = await _repo.getEventsCalendar(userId: event.userId);
      emit(EventsLoaded(events));
    } catch (e) {
      emit(EventError(e.toString()));
    }
  }

  Future<void> _onCreateEvent(CreateEvent event, Emitter<EventState> emit) async {
    emit(EventLoading());
    try {
      final created = await _repo.createEvent(event.request as CreateEventRequest);
      emit(EventCreatedSuccess(created));
    } catch (e) {
      emit(EventError(e.toString()));
    }
  }

  Future<void> _onUpdateEvent(UpdateEvent event, Emitter<EventState> emit) async {
    emit(EventLoading());
    try {
      final updated = await _repo.updateEvent(event.eventId, event.request as UpdateEventRequest);
      emit(EventUpdatedSuccess(updated));
    } catch (e) {
      emit(EventError(e.toString()));
    }
  }

  Future<void> _onDeleteEvent(DeleteEvent event, Emitter<EventState> emit) async {
    emit(EventLoading());
    try {
      await _repo.deleteEvent(event.eventId);
      emit(EventDeletedSuccess(event.eventId));
    } catch (e) {
      emit(EventError(e.toString()));
    }
  }

  void _onResetEventState(ResetEventState event, Emitter<EventState> emit) {
    emit(EventInitial());
  }
}