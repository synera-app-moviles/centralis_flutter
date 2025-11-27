import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/event_repository.dart';
import 'event_event.dart';
import 'event_state.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/storage/secure_storage_service.dart';

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
      // Obtener userId actual desde almacenamiento seguro
      final storage = sl<SecureStorageService>();
      final currentUserId = await storage.getUserId();

      // Si no hay userId, devolver lista vacía (sin acceso)
      if (currentUserId == null) {
        emit(const EventsLoaded([]));
        return;
      }

      final events = await repository.getEvents(
        userId: event.userId,
        filterType: event.filterType,
      );

      // Filtrar eventos: solo los creados por el usuario o donde es asistente
      final filtered = events.where((e) {
        final createdByMatch = (e.createdBy ?? '') == currentUserId;
        final attendeesMatch = e.recipientIds.contains(currentUserId);
        return createdByMatch || attendeesMatch;
      }).toList();

      emit(EventsLoaded(filtered));
    } catch (e) {
      emit(EventError(e.toString()));
    }
  }

  Future<void> _onLoadEventById(LoadEventById event, Emitter<EventState> emit) async {
    emit(EventLoading());
    try {
      final ev = await repository.getEventById(event.eventId);

      final storage = sl<SecureStorageService>();
      final currentUserId = await storage.getUserId();

      // Si no hay userId o el usuario no es creador ni asistente, negar acceso
      if (currentUserId == null ||
          ((ev.createdBy ?? '') != currentUserId && !ev.recipientIds.contains(currentUserId))) {
        emit(const EventError('No tienes permiso para ver este evento'));
        return;
      }

      emit(EventLoaded(ev));
    } catch (e) {
      emit(EventError(e.toString()));
    }
  }

  Future<void> _onLoadEventsCalendar(LoadEventsCalendar event, Emitter<EventState> emit) async {
    emit(EventLoading());
    try {
      final storage = sl<SecureStorageService>();
      final currentUserId = await storage.getUserId();

      if (currentUserId == null) {
        emit(const EventsLoaded([]));
        return;
      }

      final events = await repository.getEventsCalendar(userId: event.userId);

      final filtered = events.where((e) {
        final createdByMatch = (e.createdBy ?? '') == currentUserId;
        final attendeesMatch = e.recipientIds.contains(currentUserId);
        return createdByMatch || attendeesMatch;
      }).toList();

      emit(EventsLoaded(filtered));
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