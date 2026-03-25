import 'package:flutter/material.dart';

import '../../design_system/tokens/app_colors.dart';
import '../../features/chat/chat.dart';
import '../../features/home/presentation/pages/home_placeholder_page.dart';
import '../../features/medical_records/presentation/pages/medical_records_pages.dart';
import '../../features/pets/pets.dart';
import '../../features/settings/presentation/pages/settings_page.dart';

class HomeShellPage extends StatefulWidget {
  const HomeShellPage({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<HomeShellPage> createState() => _HomeShellPageState();
}

class _HomeShellPageState extends State<HomeShellPage> {
  late int _currentIndex = widget.initialIndex;

  late final List<Widget> _pages = const [
    HomePlaceholderPage(),
    PetsListPage(),
    ChatConversationsPage(),
    MedicalRecordsListPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        height: 76,
        backgroundColor: Colors.white,
        indicatorColor: AppColors.accentSoft,
        selectedIndex: _currentIndex,
        onDestinationSelected: (value) {
          setState(() {
            _currentIndex = value;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.pets_outlined),
            selectedIcon: Icon(Icons.pets_rounded),
            label: 'Pets',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline_rounded),
            selectedIcon: Icon(Icons.chat_bubble_rounded),
            label: 'Chat',
          ),
          NavigationDestination(
            icon: Icon(Icons.description_outlined),
            selectedIcon: Icon(Icons.description_rounded),
            label: 'Records',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
