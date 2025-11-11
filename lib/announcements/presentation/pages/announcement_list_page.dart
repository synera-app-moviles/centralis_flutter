import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../shared/theme/colors.dart';
import '../../../core/di/service_locator.dart';
import '../bloc/announcement_bloc.dart';
import '../bloc/announcement_event.dart';
import '../bloc/announcement_state.dart';
import '../widgets/announcement_card.dart';
import '../widgets/empty_announcements_widget.dart';
import 'announcement_detail_page.dart';
import 'create_announcement_page.dart';

class AnnouncementListPage extends StatelessWidget {
  const AnnouncementListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<AnnouncementBloc>()..add(AnnouncementLoadRequested()),
      child: const _AnnouncementListView(),
    );
  }
}

class _AnnouncementListView extends StatelessWidget {
  const _AnnouncementListView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AnnouncementColors.background,
      appBar: AppBar(
        title: const Text(
          "Announcements",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: AnnouncementColors.background,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.download, color: Colors.white),
            onPressed: () => _saveAnnouncementsLocally(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCreateAnnouncement(context),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: BlocBuilder<AnnouncementBloc, AnnouncementState>(
        builder: (context, state) {
          if (state is AnnouncementLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AnnouncementColors.primary,
              ),
            );
          }

          if (state is AnnouncementError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: AnnouncementColors.error,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${state.message}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<AnnouncementBloc>().add(AnnouncementLoadRequested());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AnnouncementColors.primary,
                    ),
                    child: const Text(
                      'Retry',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is AnnouncementLoaded) {
            if (state.announcements.isEmpty) {
              return const EmptyAnnouncementsWidget();
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<AnnouncementBloc>().add(AnnouncementLoadRequested());
              },
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 80), // Space for FAB
                itemCount: state.announcements.length,
                itemBuilder: (context, index) {
                  final announcement = state.announcements[index];
                  return AnnouncementCard(
                    announcement: announcement,
                    onTap: () => _navigateToAnnouncementDetail(context, announcement.id),
                  );
                },
              ),
            );
          }

          return const EmptyAnnouncementsWidget();
        },
      ),
    );
  }

  void _saveAnnouncementsLocally(BuildContext context) {
    // TODO: Implement save announcements locally
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Announcements saved locally'),
        backgroundColor: AnnouncementColors.success,
      ),
    );
  }

  void _navigateToCreateAnnouncement(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CreateAnnouncementPage(),
      ),
    );
  }

  void _navigateToAnnouncementDetail(BuildContext context, String announcementId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AnnouncementDetailPage(announcementId: announcementId),
      ),
    );
  }
}