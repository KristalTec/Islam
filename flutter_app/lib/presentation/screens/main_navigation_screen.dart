import 'package:flutter/material.dart';

import 'home/home_screen.dart';
import 'library/library_screen.dart';
import 'prayer_times/prayer_times_screen.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  static const List<Widget> _screens = [
    HomeScreen(),
    LibraryScreen(),
    PrayerTimesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (i) => setState(() => _currentIndex = i),
            selectedItemColor: AppColors.gold,
            unselectedItemColor: Colors.grey,
            backgroundColor: Colors.white,
            elevation: 0,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            items: const [
              BottomNavigationBarItem(
                icon: Text('🏠', style: TextStyle(fontSize: 24)),
                label: AppStrings.navHome,
              ),
              BottomNavigationBarItem(
                icon: Text('📚', style: TextStyle(fontSize: 24)),
                label: AppStrings.navLibrary,
              ),
              BottomNavigationBarItem(
                icon: Text('🕌', style: TextStyle(fontSize: 24)),
                label: AppStrings.navPrayer,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
