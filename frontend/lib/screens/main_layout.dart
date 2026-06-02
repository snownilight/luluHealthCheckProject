import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'timeline_screen.dart';
import 'trends_screen.dart';
import 'settings_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    TrendsScreen(),
    TimelineScreen(),
    SettingsScreen(),
  ];



  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isWideScreen = screenWidth > 600;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Row(
        children: [
          // If screen is wide, display a vertical Navigation Rail on the side
          if (isWideScreen)
            NavigationRail(
              selectedIndex: _selectedIndex,
              backgroundColor: isDark ? const Color(0xFF1F1816) : const Color(0xFFFFFDFB),
              selectedIconTheme: const IconThemeData(color: Color(0xFFE8875C)),
              unselectedIconTheme: IconThemeData(color: isDark ? const Color(0xFF8C7364) : const Color(0xFFB19F95)),
              selectedLabelTextStyle: const TextStyle(color: Color(0xFFE8875C), fontWeight: FontWeight.bold),
              unselectedLabelTextStyle: TextStyle(color: isDark ? const Color(0xFF8C7364) : const Color(0xFFB19F95)),
              onDestinationSelected: (int index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              labelType: NavigationRailLabelType.all,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard),
                  label: Text('首頁'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.show_chart_outlined),
                  selectedIcon: Icon(Icons.show_chart),
                  label: Text('健康'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.book_outlined),
                  selectedIcon: Icon(Icons.book),
                  label: Text('聯絡簿'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings),
                  label: Text('設定'),
                ),
              ],
            ),
          
          // Divider between Nav Rail and Main Screen
          if (isWideScreen) const VerticalDivider(thickness: 1, width: 1),

          // Main Screen Content
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: _screens[_selectedIndex],
            ),
          ),
        ],
      ),
      // If screen is mobile/narrow, display a Bottom Navigation Bar
      bottomNavigationBar: isWideScreen
          ? null
          : Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF261D1A) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: isDark ? Colors.black.withOpacity(0.3) : const Color(0xFF35261D).withOpacity(0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BottomNavigationBar(
                  currentIndex: _selectedIndex,
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  selectedItemColor: const Color(0xFFE8875C),
                  unselectedItemColor: isDark ? const Color(0xFF8C7364) : const Color(0xFFB19F95),
                  selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  unselectedLabelStyle: const TextStyle(fontSize: 11),
                  onTap: (int index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.dashboard_outlined),
                      activeIcon: Icon(Icons.dashboard),
                      label: '首頁',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.show_chart_outlined),
                      activeIcon: Icon(Icons.show_chart),
                      label: '健康',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.book_outlined),
                      activeIcon: Icon(Icons.book),
                      label: '聯絡簿',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.settings_outlined),
                      activeIcon: Icon(Icons.settings),
                      label: '設定',
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
