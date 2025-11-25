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
    on<AnnouncementStatsRequested>(_onAnnouncementStatsRequested);
    on<EventStatsRequested>(_onEventStatsRequested);
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
    // Check if we already have combined analytics state
    if (state is ContentAnalyticsLoaded) {
      final currentState = state as ContentAnalyticsLoaded;
      if (currentState.isAnnouncement) {
        emit(currentState.copyWith(isViewersRefreshing: true));
      } else {
        emit(DashboardLoading());
      }
    } else if (state is AnnouncementViewersLoaded) {
      final currentState = state as AnnouncementViewersLoaded;
      if (currentState.announcementId == event.announcementId) {
        emit(currentState.copyWith(isRefreshing: true));
      } else {
        emit(DashboardLoading());
      }
    } else {
      emit(DashboardLoading());
    }

    try {
      final viewers = await _dashboardRepository.getAnnouncementViewers(event.announcementId);
      
      // Check if we have stats to combine with
      if (state is ContentAnalyticsLoaded) {
        final currentState = state as ContentAnalyticsLoaded;
        emit(currentState.copyWith(
          viewers: viewers,
          isViewersRefreshing: false,
        ));
      } else {
        emit(ContentAnalyticsLoaded(
          viewers: viewers,
          isAnnouncement: true,
          isViewersRefreshing: false,
        ));
      }
    } catch (e) {
      print('🚨 Dashboard: Error loading announcement viewers: ${e.toString()}');
      emit(DashboardError('Failed to load announcement viewers: ${e.toString()}'));
    }
  }

  Future<void> _onEventViewersRequested(
    EventViewersRequested event,
    Emitter<DashboardState> emit,
  ) async {
    // Check if we already have combined analytics state
    if (state is ContentAnalyticsLoaded) {
      final currentState = state as ContentAnalyticsLoaded;
      if (!currentState.isAnnouncement) {
        emit(currentState.copyWith(isViewersRefreshing: true));
      } else {
        emit(DashboardLoading());
      }
    } else if (state is EventViewersLoaded) {
      final currentState = state as EventViewersLoaded;
      if (currentState.eventId == event.eventId) {
        emit(currentState.copyWith(isRefreshing: true));
      } else {
        emit(DashboardLoading());
      }
    } else {
      emit(DashboardLoading());
    }

    try {
      final viewers = await _dashboardRepository.getEventViewers(event.eventId);
      
      // Check if we have stats to combine with
      if (state is ContentAnalyticsLoaded) {
        final currentState = state as ContentAnalyticsLoaded;
        emit(currentState.copyWith(
          viewers: viewers,
          isViewersRefreshing: false,
        ));
      } else {
        emit(ContentAnalyticsLoaded(
          viewers: viewers,
          isAnnouncement: false,
          isViewersRefreshing: false,
        ));
      }
    } catch (e) {
      print('🚨 Dashboard: Error loading event viewers: ${e.toString()}');
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

  Future<void> _onAnnouncementStatsRequested(
    AnnouncementStatsRequested event,
    Emitter<DashboardState> emit,
  ) async {
    // Check if we already have combined analytics state
    if (state is ContentAnalyticsLoaded) {
      final currentState = state as ContentAnalyticsLoaded;
      if (currentState.isAnnouncement) {
        emit(currentState.copyWith(isStatsRefreshing: true));
      } else {
        emit(DashboardLoading());
      }
    } else if (state is ContentStatsLoaded) {
      final currentState = state as ContentStatsLoaded;
      if (currentState.isAnnouncement) {
        emit(currentState.copyWith(isRefreshing: true));
      } else {
        emit(DashboardLoading());
      }
    } else {
      emit(DashboardLoading());
    }

    try {
      final stats = await _dashboardRepository.getAnnouncementStats(event.announcementId);
      print('📊 Dashboard: Announcement stats loaded successfully');
      
      // Check if we have viewers to combine with
      if (state is ContentAnalyticsLoaded) {
        final currentState = state as ContentAnalyticsLoaded;
        emit(currentState.copyWith(
          stats: stats,
          isStatsRefreshing: false,
        ));
      } else {
        emit(ContentAnalyticsLoaded(
          stats: stats,
          isAnnouncement: true,
          isStatsRefreshing: false,
        ));
      }
    } catch (e) {
      print('🚨 Dashboard: Error loading announcement stats: ${e.toString()}');
      emit(DashboardError('Failed to load announcement stats: ${e.toString()}'));
    }
  }

  Future<void> _onEventStatsRequested(
    EventStatsRequested event,
    Emitter<DashboardState> emit,
  ) async {
    // Check if we already have combined analytics state
    if (state is ContentAnalyticsLoaded) {
      final currentState = state as ContentAnalyticsLoaded;
      if (!currentState.isAnnouncement) {
        emit(currentState.copyWith(isStatsRefreshing: true));
      } else {
        emit(DashboardLoading());
      }
    } else if (state is ContentStatsLoaded) {
      final currentState = state as ContentStatsLoaded;
      if (!currentState.isAnnouncement) {
        emit(currentState.copyWith(isRefreshing: true));
      } else {
        emit(DashboardLoading());
      }
    } else {
      emit(DashboardLoading());
    }

    try {
      final stats = await _dashboardRepository.getEventStats(event.eventId);
      print('📊 Dashboard: Event stats loaded successfully');
      
      // Check if we have viewers to combine with
      if (state is ContentAnalyticsLoaded) {
        final currentState = state as ContentAnalyticsLoaded;
        emit(currentState.copyWith(
          stats: stats,
          isStatsRefreshing: false,
        ));
      } else {
        emit(ContentAnalyticsLoaded(
          stats: stats,
          isAnnouncement: false,
          isStatsRefreshing: false,
        ));
      }
    } catch (e) {
      print('🚨 Dashboard: Error loading event stats: ${e.toString()}');
      emit(DashboardError('Failed to load event stats: ${e.toString()}'));
    }
  }
}