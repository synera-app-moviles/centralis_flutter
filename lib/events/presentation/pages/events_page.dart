import 'package:flutter/material.dart';
import '../../../shared/widgets/placeholder_page.dart';

/// Events page - placeholder until BLoC implementation
class EventsPage extends StatelessWidget {
  const EventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderPage(
      title: 'Events',
      icon: Icons.date_range,
    );
  }
}