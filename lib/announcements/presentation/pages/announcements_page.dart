import 'package:flutter/material.dart';
import '../../../shared/widgets/placeholder_page.dart';

/// Announcements page - placeholder until BLoC implementation
class AnnouncementsPage extends StatelessWidget {
  const AnnouncementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderPage(
      title: 'Announcements',
      icon: Icons.campaign,
      showFab: true,
    );
  }
}

// TODO: When implementing AnnouncementsBloc:
