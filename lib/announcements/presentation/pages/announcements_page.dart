import 'package:flutter/material.dart';
import 'announcement_list_page.dart';

/// Main announcements page that handles the tab navigation
/// This is the page that is called from the bottom navigation
class AnnouncementsPage extends StatelessWidget {
  const AnnouncementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // For now, this just shows the announcement list
    // In the future, this could have additional filtering, search, etc.
    return const AnnouncementListPage();
  }
}
