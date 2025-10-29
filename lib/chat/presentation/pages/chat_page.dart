import 'package:flutter/material.dart';
import '../../../shared/widgets/placeholder_page.dart';

/// Chat page - placeholder until BLoC implementation
class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderPage(
      title: 'Chat',
      icon: Icons.question_answer,
    );
  }
}