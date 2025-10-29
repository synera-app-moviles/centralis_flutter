import 'package:flutter/material.dart';
import '../theme/colors.dart';

/// Widget reutilizable para páginas placeholder
class PlaceholderPage extends StatelessWidget {
  final String title;
  final IconData icon;
  final String subtitle;
  final bool showFab;

  const PlaceholderPage({
    super.key,
    required this.title,
    required this.icon,
    this.subtitle = 'Feature coming soon...',
    this.showFab = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CentralisColors.background,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: CentralisColors.secondary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: CentralisColors.placeholder,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                color: CentralisColors.onBackground,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                color: CentralisColors.placeholder,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: showFab
          ? FloatingActionButton(
              onPressed: () {},
              backgroundColor: CentralisColors.primary,
              child: const Icon(
                Icons.add,
                color: CentralisColors.onPrimary,
              ),
            )
          : null,
    );
  }
}