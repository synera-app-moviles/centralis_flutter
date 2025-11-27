// dart
  // File: `lib/events/presentation/bloc/event_bloc.dart`
  // Cambios: normalización de recipientIds, logs y uso en filtros.

  import 'dart:convert';
  import 'package:flutter/foundation.dart';
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

    bool _idEquals(String? a, String? b) {
      if (a == null || b == null) return false;
      return a.toString().trim() == b.toString().trim();
    }

    List<String> _toIdList(dynamic raw) {
      try {
        if (raw == null) return [];
        if (raw is List) {
          final out = <String>{};
          for (var r in raw) {
            if (r == null) continue;
            if (r is String) {
              final t = r.trim();
              if (t.isNotEmpty) out.add(t);
            } else if (r is Map) {
              final id = (r['profileId'] ?? r['id'] ?? r['userId'] ?? r['profile_id'] ?? r['user_id'])?.toString().trim();
              if (id != null && id.isNotEmpty) out.add(id);
            } else {
              final t = r.toString().trim();
              if (t.isNotEmpty) out.add(t);
            }
          }
          return out.toList();
        }
        if (raw is String) {
          // Try parse JSON array
          try {
            final parsed = jsonDecode(raw);
            if (parsed is List) return _toIdList(parsed);
          } catch (_) {}
          // CSV fallback
          return raw.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toSet().toList();
        }
        // Fallback single value
        final s = raw.toString().trim();
        return s.isEmpty ? [] : [s];
      } catch (_) {
        return [];
      }
    }

    bool _matchesUser(dynamic e, String currentUserId) {
      try {
        final createdBy = (e.createdBy ?? e.creatorId ?? e.ownerId ?? (e['createdBy'] ?? '') ).toString().trim();
        if (createdBy.isNotEmpty && _idEquals(createdBy, currentUserId)) return true;

        final rawRecipients = e.recipientIds ?? e['recipientIds'] ?? [];
        final recipients = _toIdList(rawRecipients);
        for (final rid in recipients) {
          if (_idEquals(rid, currentUserId)) return true;
        }
      } catch (_) {
        // ignore
      }
      return false;
    }

    Future<void> _onLoadEvents(LoadEvents event, Emitter<EventState> emit) async {
      emit(EventLoading());
      try {
        final storage = sl<SecureStorageService>();
        final currentUserId = await storage.getUserId();

        if (currentUserId == null) {
          emit(const EventsLoaded([]));
          return;
        }

        final events = await repository.getEvents(filterType: event.filterType);

        final filtered = events.where((e) => _matchesUser(e, currentUserId)).toList();

        if (kDebugMode) {
          print('EventBloc: fetched=${events.length} filtered=${filtered.length} user=$currentUserId');
        }

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

        if (currentUserId == null || !_matchesUser(ev, currentUserId)) {
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

        final events = await repository.getEventsCalendar();

        final filtered = events.where((e) => _matchesUser(e, currentUserId)).toList();

        if (kDebugMode) {
          print('EventBloc(calendar): fetched=${events.length} filtered=${filtered.length} user=$currentUserId');
        }

        emit(EventsLoaded(filtered));
      } catch (e) {
        emit(EventError(e.toString()));
      }
    }

    Future<void> _onCreateEvent(CreateEvent event, Emitter<EventState> emit) async {
      emit(EventLoading());
      try {
        if (kDebugMode) print('CreateEvent: payload=${jsonEncode(event.request.toJson())}');
        final created = await repository.createEvent(event.request);
        emit(EventCreatedSuccess(created));
      } catch (e) {
        emit(EventError(e.toString()));
      }
    }

    Future<void> _onUpdateEvent(UpdateEvent event, Emitter<EventState> emit) async {
      emit(EventLoading());
      try {
        if (kDebugMode) print('UpdateEvent: id=${event.eventId} payload=${jsonEncode(event.request.toJson())}');
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