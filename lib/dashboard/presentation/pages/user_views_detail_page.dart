import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../shared/theme/colors.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../widgets/viewed_content_item.dart';
import '../../data/models/user_viewed_announcement.dart';
import '../../data/models/user_viewed_event.dart';

/// Page showing announcements and events viewed by a specific user
class UserViewsDetailPage extends StatefulWidget {
  final String userId;
  final String userFullName;

  const UserViewsDetailPage({
    super.key,
    required this.userId,
    required this.userFullName,
  });

  @override
  State<UserViewsDetailPage> createState() => _UserViewsDetailPageState();
}

class _UserViewsDetailPageState extends State<UserViewsDetailPage>
    with SingleTickerProviderStateMixin {
  
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Load user viewed content when page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserContent();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadUserContent() {
    context.read<DashboardBloc>().add(
      UserViewedAnnouncementsRequested(widget.userId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CentralisColors.background,
      appBar: AppBar(
        backgroundColor: CentralisColors.secondary,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'User Activity',
              style: TextStyle(
                color: CentralisColors.onBackground,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              widget.userFullName,
              style: TextStyle(
                color: CentralisColors.onBackground.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: CentralisColors.onBackground,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh,
              color: CentralisColors.onBackground,
            ),
            onPressed: _loadUserContent,
          ),
        ],
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: CentralisColors.primary,
          unselectedLabelColor: CentralisColors.onBackground.withOpacity(0.6),
          indicatorColor: CentralisColors.primary,
          tabs: const [
            Tab(
              icon: Icon(Icons.campaign),
              text: 'Announcements',
            ),
            Tab(
              icon: Icon(Icons.event),
              text: 'Events',
            ),
          ],
        ),
      ),
      body: BlocListener<DashboardBloc, DashboardState>(
        listener: (context, state) {
          if (state is DashboardError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 5),
              ),
            );
          }
        },
        child: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            if (state is DashboardLoading) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: CentralisColors.primary,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Loading user activity...',
                      style: TextStyle(
                        color: CentralisColors.onBackground,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            }

            if (state is UserViewedContentLoaded) {
              return TabBarView(
                controller: _tabController,
                children: [
                  // Announcements tab
                  _buildAnnouncementsTab(state.announcements),
                  
                  // Events tab
                  _buildEventsTab(state.events),
                ],
              );
            }

            // Initial state or error fallback
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_search,
                    size: 64,
                    color: CentralisColors.onBackground.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No activity data loaded',
                    style: TextStyle(
                      color: CentralisColors.onBackground.withOpacity(0.7),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap refresh to load user activity',
                    style: TextStyle(
                      color: CentralisColors.onBackground.withOpacity(0.5),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _loadUserContent,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CentralisColors.primary,
                      foregroundColor: CentralisColors.onPrimary,
                    ),
                    child: const Text('Load Activity'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAnnouncementsTab(List<UserViewedAnnouncement> announcements) {
    if (announcements.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.campaign_outlined,
              size: 64,
              color: CentralisColors.onBackground.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No announcements viewed',
              style: TextStyle(
                color: CentralisColors.onBackground.withOpacity(0.7),
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This user hasn\'t viewed any announcements yet',
              style: TextStyle(
                color: CentralisColors.onBackground.withOpacity(0.5),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        _loadUserContent();
      },
      backgroundColor: CentralisColors.secondary,
      color: CentralisColors.primary,
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            color: CentralisColors.secondary,
            padding: const EdgeInsets.all(16),
            child: Text(
              '${announcements.length} announcements viewed',
              style: TextStyle(
                color: CentralisColors.onBackground.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ),

          // Announcements list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: announcements.length,
              itemBuilder: (context, index) {
                final announcement = announcements[index];
                return ViewedContentItem.announcement(
                  announcement: announcement,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsTab(List<UserViewedEvent> events) {
    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_outlined,
              size: 64,
              color: CentralisColors.onBackground.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No events viewed',
              style: TextStyle(
                color: CentralisColors.onBackground.withOpacity(0.7),
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This user hasn\'t viewed any events yet',
              style: TextStyle(
                color: CentralisColors.onBackground.withOpacity(0.5),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        _loadUserContent();
      },
      backgroundColor: CentralisColors.secondary,
      color: CentralisColors.primary,
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            color: CentralisColors.secondary,
            padding: const EdgeInsets.all(16),
            child: Text(
              '${events.length} events viewed',
              style: TextStyle(
                color: CentralisColors.onBackground.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ),

          // Events list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return ViewedContentItem.event(
                  event: event,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}