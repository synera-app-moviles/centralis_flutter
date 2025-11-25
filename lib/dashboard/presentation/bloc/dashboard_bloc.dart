import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/dashboard_repository.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardRepository _dashboardRepository;

  DashboardBloc({required DashboardRepository dashboardRepository})
      : _dashboardRepository = dashboardRepository,
        super(DashboardInitial()) {
    
    on<DashboardSummaryRequested>(_onSummaryRequested);
    on<DashboardUsersRequested>(_onUsersRequested);
    on<UserViewedAnnouncementsRequested>(_onUserViewedAnnouncementsRequested);
    on<UserViewedEventsRequested>(_onUserViewedEventsRequested);
    on<AnnouncementViewersRequested>(_onAnnouncementViewersRequested);
    on<EventViewersRequested>(_onEventViewersRequested);
    on<AnnouncementViewRegistered>(_onAnnouncementViewRegistered);
    on<EventViewRegistered>(_onEventViewRegistered);
    on<DashboardCleared>(_onDashboardCleared);
  }

  Future<void> _onSummaryRequested(
    DashboardSummaryRequested event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());
    try {
      final summary = await _dashboardRepository.getViewsSummary();
      emit(DashboardSummaryLoaded(summary));
    } catch (e) {
      emit(DashboardError('Failed to load dashboard summary: ${e.toString()}'));
    }
  }

  Future<void> _onUsersRequested(
    DashboardUsersRequested event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());
    try {
      final users = await _dashboardRepository.getAllUsers();
      emit(DashboardUsersLoaded(users));
    } catch (e) {
      emit(DashboardError('Failed to load users: ${e.toString()}'));
    }
  }

  Future<void> _onUserViewedAnnouncementsRequested(
    UserViewedAnnouncementsRequested event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());
    try {
      final announcements = await _dashboardRepository.getUserViewedAnnouncements(event.userId);
      final events = await _dashboardRepository.getUserViewedEvents(event.userId);
      
      emit(UserViewedContentLoaded(
        userId: event.userId,
        announcements: announcements,
        events: events,
      ));
    } catch (e) {
      emit(DashboardError('Failed to load user viewed announcements: ${e.toString()}'));
    }
  }

  Future<void> _onUserViewedEventsRequested(
    UserViewedEventsRequested event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());
    try {
      final events = await _dashboardRepository.getUserViewedEvents(event.userId);
      
      // If we already have announcements data, preserve it
      if (state is UserViewedContentLoaded) {
        final currentState = state as UserViewedContentLoaded;
        emit(UserViewedContentLoaded(
          userId: event.userId,
          announcements: currentState.announcements,
          events: events,
        ));
      } else {
        // Load both announcements and events
        final announcements = await _dashboardRepository.getUserViewedAnnouncements(event.userId);
        emit(UserViewedContentLoaded(
          userId: event.userId,
          announcements: announcements,
          events: events,
        ));
      }
    } catch (e) {
      emit(DashboardError('Failed to load user viewed events: ${e.toString()}'));
    }
  }

  Future<void> _onAnnouncementViewersRequested(
    AnnouncementViewersRequested event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());
    try {
      final viewers = await _dashboardRepository.getAnnouncementViewers(event.announcementId);
      emit(AnnouncementViewersLoaded(
        announcementId: event.announcementId,
        viewers: viewers,
      ));
    } catch (e) {
      emit(DashboardError('Failed to load announcement viewers: ${e.toString()}'));
    }
  }

  Future<void> _onEventViewersRequested(
    EventViewersRequested event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());
    try {
      final viewers = await _dashboardRepository.getEventViewers(event.eventId);
      emit(EventViewersLoaded(
        eventId: event.eventId,
        viewers: viewers,
      ));
    } catch (e) {
      emit(DashboardError('Failed to load event viewers: ${e.toString()}'));
    }
  }

  Future<void> _onAnnouncementViewRegistered(
    AnnouncementViewRegistered event,
    Emitter<DashboardState> emit,
  ) async {
    try {
      final result = await _dashboardRepository.registerAnnouncementView(
        event.announcementId,
        event.userId,
      );
      
      emit(ViewRegistered(
        message: result['message'] as String? ?? 'View registered successfully',
        isNewView: result['isNewView'] as bool? ?? true,
      ));
    } catch (e) {
      emit(DashboardError('Failed to register announcement view: ${e.toString()}'));
    }
  }

  Future<void> _onEventViewRegistered(
    EventViewRegistered event,
    Emitter<DashboardState> emit,
  ) async {
    try {
      final result = await _dashboardRepository.registerEventView(
        event.eventId,
        event.userId,
      );
      
      emit(ViewRegistered(
        message: result['message'] as String? ?? 'View registered successfully',
        isNewView: result['isNewView'] as bool? ?? true,
      ));
    } catch (e) {
      emit(DashboardError('Failed to register event view: ${e.toString()}'));
    }
  }

  Future<void> _onDashboardCleared(
    DashboardCleared event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardInitial());
  }
}