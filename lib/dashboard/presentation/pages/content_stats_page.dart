import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../shared/theme/colors.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../../data/models/content_stats.dart';
import '../../data/models/viewer_info.dart';

/// Page showing statistics and viewers for an announcement or event
class ContentStatsPage extends StatefulWidget {
  final String contentId;
  final String contentTitle;
  final String contentType; // 'announcement' or 'event'

  const ContentStatsPage({
    super.key,
    required this.contentId,
    required this.contentTitle,
    required this.contentType,
  });

  @override
  State<ContentStatsPage> createState() => _ContentStatsPageState();
}

class _ContentStatsPageState extends State<ContentStatsPage>
    with SingleTickerProviderStateMixin {
  
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Load initial data
    _loadContentStats();
    _loadContentViewers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadContentStats() {
    print('📊 ContentStatsPage: Loading stats for ${widget.contentType} ${widget.contentId}');
    if (widget.contentType == 'announcement') {
      context.read<DashboardBloc>().add(AnnouncementStatsRequested(widget.contentId));
    } else {
      context.read<DashboardBloc>().add(EventStatsRequested(widget.contentId));
    }
  }

  void _loadContentViewers() {
    print('👥 ContentStatsPage: Loading viewers for ${widget.contentType} ${widget.contentId}');
    if (widget.contentType == 'announcement') {
      context.read<DashboardBloc>().add(AnnouncementViewersRequested(widget.contentId));
    } else {
      context.read<DashboardBloc>().add(EventViewersRequested(widget.contentId));
    }
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
            Text(
              '${widget.contentType == 'announcement' ? 'Announcement' : 'Event'} Analytics',
              style: const TextStyle(
                color: CentralisColors.onBackground,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              widget.contentTitle,
              style: TextStyle(
                color: CentralisColors.onBackground.withOpacity(0.7),
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: CentralisColors.onBackground),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: CentralisColors.primary,
          unselectedLabelColor: CentralisColors.onBackground.withOpacity(0.6),
          indicatorColor: CentralisColors.primary,
          tabs: const [
            Tab(
              icon: Icon(Icons.bar_chart),
              text: 'Statistics',
            ),
            Tab(
              icon: Icon(Icons.people),
              text: 'Viewers',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Statistics Tab
          RefreshIndicator(
            onRefresh: () async {
              _loadContentStats();
            },
            backgroundColor: CentralisColors.secondary,
            color: CentralisColors.primary,
            child: BlocBuilder<DashboardBloc, DashboardState>(
              builder: (context, state) {
                if (state is ContentAnalyticsLoaded && state.stats != null) {
                  return Stack(
                    children: [
                      _buildStatsTab(state.stats!),
                      if (state.isStatsRefreshing)
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 2,
                            child: const LinearProgressIndicator(
                              color: CentralisColors.primary,
                              backgroundColor: Colors.transparent,
                            ),
                          ),
                        ),
                    ],
                  );
                }
                
                if (state is ContentStatsLoaded) {
                  return Stack(
                    children: [
                      _buildStatsTab(state.stats),
                      if (state.isRefreshing)
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 2,
                            child: const LinearProgressIndicator(
                              color: CentralisColors.primary,
                              backgroundColor: Colors.transparent,
                            ),
                          ),
                        ),
                    ],
                  );
                }
                
                if (state is DashboardLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: CentralisColors.primary),
                  );
                }
                
                if (state is DashboardError) {
                  return _buildErrorState(state.message);
                }
                
                return _buildEmptyState('No statistics available');
              },
            ),
          ),
          
          // Viewers Tab
          RefreshIndicator(
            onRefresh: () async {
              _loadContentViewers();
            },
            backgroundColor: CentralisColors.secondary,
            color: CentralisColors.primary,
            child: BlocBuilder<DashboardBloc, DashboardState>(
              builder: (context, state) {
                // Handle combined analytics state
                if (state is ContentAnalyticsLoaded && state.viewers != null) {
                  return Stack(
                    children: [
                      _buildViewersTab(state.viewers!),
                      if (state.isViewersRefreshing)
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 2,
                            child: const LinearProgressIndicator(
                              color: CentralisColors.primary,
                              backgroundColor: Colors.transparent,
                            ),
                          ),
                        ),
                    ],
                  );
                }
                
                // Handle individual viewers states
                if (state is AnnouncementViewersLoaded && widget.contentType == 'announcement') {
                  return Stack(
                    children: [
                      _buildViewersTab(state.viewers),
                      if (state.isRefreshing)
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 2,
                            child: const LinearProgressIndicator(
                              color: CentralisColors.primary,
                              backgroundColor: Colors.transparent,
                            ),
                          ),
                        ),
                    ],
                  );
                }
                
                if (state is EventViewersLoaded && widget.contentType == 'event') {
                  return Stack(
                    children: [
                      _buildViewersTab(state.viewers),
                      if (state.isRefreshing)
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 2,
                            child: const LinearProgressIndicator(
                              color: CentralisColors.primary,
                              backgroundColor: Colors.transparent,
                            ),
                          ),
                        ),
                    ],
                  );
                }
                
                if (state is DashboardLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: CentralisColors.primary),
                  );
                }
                
                if (state is DashboardError) {
                  return _buildErrorState(state.message);
                }
                
                return _buildEmptyState('No viewers data available');
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsTab(ContentStats stats) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Engagement Chart
          if (stats.viewsData.viewStats != null) 
            _buildEngagementChart(stats.viewsData.viewStats!),
          const SizedBox(height: 24),
          
          // Stats Summary
          _buildStatsSummary(stats),
          const SizedBox(height: 24),
          
          // Department Breakdown
          if (stats.departmentBreakdown.byDepartment.isNotEmpty)
            _buildDepartmentBreakdown(stats),
        ],
      ),
    );
  }

  Widget _buildEngagementChart(ViewStats viewStats) {
    return Card(
      color: CentralisColors.secondary,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Engagement Overview',
              style: TextStyle(
                color: CentralisColors.onBackground,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            SizedBox(
              height: 200,
              child: Row(
                children: [
                  // Pie Chart
                  Expanded(
                    flex: 2,
                    child: PieChart(
                      PieChartData(
                        sections: [
                          PieChartSectionData(
                            value: viewStats.viewed.percentage,
                            title: '${viewStats.viewed.percentage.toInt()}%',
                            color: _parseColor(viewStats.viewed.color),
                            radius: 80,
                            titleStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          PieChartSectionData(
                            value: viewStats.notViewed.percentage,
                            title: '${viewStats.notViewed.percentage.toInt()}%',
                            color: _parseColor(viewStats.notViewed.color),
                            radius: 80,
                            titleStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                        sectionsSpace: 2,
                        centerSpaceRadius: 0,
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Legend
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLegendItem(
                          'Viewed',
                          viewStats.viewed.count.toString(),
                          _parseColor(viewStats.viewed.color),
                        ),
                        const SizedBox(height: 8),
                        _buildLegendItem(
                          'Not Viewed',
                          viewStats.notViewed.count.toString(),
                          _parseColor(viewStats.notViewed.color),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, String count, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: CentralisColors.onBackground,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '$count users',
                style: TextStyle(
                  color: CentralisColors.onBackground.withOpacity(0.7),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSummary(ContentStats stats) {
    return Card(
      color: CentralisColors.secondary,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Summary Statistics',
              style: TextStyle(
                color: CentralisColors.onBackground,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildStatItem('Total Views', stats.totalViews.toString()),
                ),
                Expanded(
                  child: _buildStatItem('Total Users', stats.uniqueViewers.toString()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: CentralisColors.primary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: CentralisColors.onBackground.withOpacity(0.7),
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDepartmentBreakdown(ContentStats stats) {
    return Card(
      color: CentralisColors.secondary,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Views by Department',
              style: TextStyle(
                color: CentralisColors.onBackground,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            ...stats.departmentBreakdown.byDepartment.map(
              (dept) => _buildDepartmentItem(dept),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDepartmentItem(DepartmentViews dept) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              dept.department,
              style: const TextStyle(
                color: CentralisColors.onBackground,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            '${dept.views} views',
            style: const TextStyle(
              color: CentralisColors.primary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${dept.percentage.toInt()}%',
            style: TextStyle(
              color: CentralisColors.onBackground.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewersTab(List<ViewerInfo> viewers) {
    if (viewers.isEmpty) {
      return _buildEmptyState('No viewers yet');
    }

    return Column(
      children: [
        // Header
        Container(
          width: double.infinity,
          color: CentralisColors.secondary,
          padding: const EdgeInsets.all(16),
          child: Text(
            '${viewers.length} viewers',
            style: TextStyle(
              color: CentralisColors.onBackground.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ),

        // Viewers list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: viewers.length,
            itemBuilder: (context, index) {
              final viewer = viewers[index];
              return _buildViewerCard(viewer);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildViewerCard(ViewerInfo viewer) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: CentralisColors.secondary,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: CentralisColors.primary,
          backgroundImage: viewer.avatarUrl != null ? NetworkImage(viewer.avatarUrl!) : null,
          child: viewer.avatarUrl == null ? Text(
            _getInitials(viewer.userFullName),
            style: const TextStyle(
              color: CentralisColors.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ) : null,
        ),
        title: Text(
          viewer.userFullName,
          style: const TextStyle(
            color: CentralisColors.onBackground,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (viewer.userEmail.isNotEmpty) Text(
              viewer.userEmail,
              style: TextStyle(
                color: CentralisColors.onBackground.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
            Text(
              '${viewer.userDepartment} • Viewed ${_formatViewedDate(viewer.viewedAt)}',
              style: TextStyle(
                color: CentralisColors.onBackground.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 64,
            color: CentralisColors.onBackground.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: CentralisColors.onBackground.withOpacity(0.7),
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red.withOpacity(0.7),
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading data',
            style: TextStyle(
              color: CentralisColors.onBackground,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              message,
              style: TextStyle(
                color: CentralisColors.onBackground.withOpacity(0.7),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              _loadContentStats();
              _loadContentViewers();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: CentralisColors.primary,
            ),
            child: const Text(
              'Retry',
              style: TextStyle(color: CentralisColors.onPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Color _parseColor(String hexColor) {
    try {
      return Color(int.parse(hexColor.replaceAll('#', '0xFF')));
    } catch (e) {
      return CentralisColors.primary;
    }
  }

  String _getInitials(String name) {
    List<String> nameParts = name.trim().split(' ');
    if (nameParts.length == 1) {
      return nameParts[0].isNotEmpty ? nameParts[0][0].toUpperCase() : '';
    }
    return '${nameParts.first[0]}${nameParts.last[0]}'.toUpperCase();
  }

  String _formatViewedDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}