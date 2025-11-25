import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../shared/theme/colors.dart';
import '../../../app/routes/route_names.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../widgets/user_list_item.dart';

/// Main dashboard page displaying list of all users
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  
  @override
  void initState() {
    super.initState();
    // Load users when page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUsers();
    });
  }

  void _loadUsers() {
    context.read<DashboardBloc>().add(const DashboardUsersRequested());
  }

  void _navigateToUserDetails(String userId, String userFullName) {
    Navigator.pushNamed(
      context,
      RouteNames.userViewsDetail,
      arguments: {
        'userId': userId,
        'userFullName': userFullName,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CentralisColors.background,
      appBar: AppBar(
        backgroundColor: CentralisColors.secondary,
        title: const Text(
          'Analytics Dashboard',
          style: TextStyle(
            color: CentralisColors.onBackground,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
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
            onPressed: _loadUsers,
          ),
        ],
        elevation: 0,
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
                      'Loading users...',
                      style: TextStyle(
                        color: CentralisColors.onBackground,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            }

            if (state is DashboardUsersLoaded) {
              final users = state.users;

              if (users.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 64,
                        color: CentralisColors.onBackground.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No users found',
                        style: TextStyle(
                          color: CentralisColors.onBackground.withOpacity(0.7),
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Check your connection and try again',
                        style: TextStyle(
                          color: CentralisColors.onBackground.withOpacity(0.5),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _loadUsers,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CentralisColors.primary,
                          foregroundColor: CentralisColors.onPrimary,
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  _loadUsers();
                },
                backgroundColor: CentralisColors.secondary,
                color: CentralisColors.primary,
                child: Column(
                  children: [
                    // Header with user count
                    Container(
                      width: double.infinity,
                      color: CentralisColors.secondary,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Users Overview',
                            style: const TextStyle(
                              color: CentralisColors.onBackground,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${users.length} users found',
                            style: TextStyle(
                              color: CentralisColors.onBackground.withOpacity(0.7),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Users list
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          final user = users[index];
                          return UserListItem(
                            user: user,
                            onTap: () => _navigateToUserDetails(
                              user.userId,
                              user.userFullName,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            }

            // Initial state or error fallback
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.dashboard,
                    size: 64,
                    color: CentralisColors.onBackground.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Welcome to Analytics Dashboard',
                    style: TextStyle(
                      color: CentralisColors.onBackground.withOpacity(0.7),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap refresh to load users data',
                    style: TextStyle(
                      color: CentralisColors.onBackground.withOpacity(0.5),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _loadUsers,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CentralisColors.primary,
                      foregroundColor: CentralisColors.onPrimary,
                    ),
                    child: const Text('Load Users'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}