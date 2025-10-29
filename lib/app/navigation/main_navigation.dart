import 'package:flutter/material.dart';
import '../../../shared/theme/colors.dart';
import '../../announcements/presentation/pages/announcements_page.dart';
import '../../events/presentation/pages/events_page.dart';
import '../../chat/presentation/pages/chat_page.dart';
import '../../profile/presentation/pages/profile_page.dart';

/// Main navigation with bottom navigation bar
class MainNavigation extends StatefulWidget {
  final int initialTab;
  
  const MainNavigation({
    super.key,
    this.initialTab = 0,
  });

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          AnnouncementsPage(),
          EventsPage(),
          ChatPage(),
          ProfilePage(),
        ],
      ),
      bottomNavigationBar: Container(
        //height: 70,
        decoration: const BoxDecoration(
          color: CentralisColors.secondary,
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: CentralisColors.primary,
          unselectedItemColor: CentralisColors.placeholder,

          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.campaign),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.date_range),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.question_answer),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: '',
            ),
          ],
        ),
      ),
    );
  }
}
