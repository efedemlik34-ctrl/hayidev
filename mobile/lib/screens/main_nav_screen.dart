import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'games_screen.dart';
import 'rooms_screen.dart';
import 'leaderboard_screen.dart';
import 'profile_screen.dart';

class MainNavScreen extends StatefulWidget {
  const MainNavScreen({super.key});
  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int _index = 0;

  final _pages = const [
    HomeScreen(),
    GamesScreen(),
    RoomsScreen(),
    LeaderboardScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1A0F3E), Color(0xFF0F0A2E)]),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFFFC107).withOpacity(0.3)),
          boxShadow: [
            BoxShadow(color: const Color(0xFFFFC107).withOpacity(0.15),
              blurRadius: 20, offset: const Offset(0, 6)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BottomNavigationBar(
            currentIndex: _index,
            onTap: (i) => setState(() => _index = i),
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: const Color(0xFFFFC107),
            unselectedItemColor: Colors.white38,
            selectedFontSize: 11,
            unselectedFontSize: 10,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Ana'),
              BottomNavigationBarItem(icon: Icon(Icons.casino), label: 'Oyun'),
              BottomNavigationBarItem(icon: Icon(Icons.mic), label: 'Oda'),
              BottomNavigationBarItem(icon: Icon(Icons.emoji_events), label: 'Lider'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Ben'),
            ],
          ),
        ),
      ),
    );
  }
}
