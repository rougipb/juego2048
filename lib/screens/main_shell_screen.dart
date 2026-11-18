import 'package:flutter/material.dart';
import '../services/preferencias_service.dart';
import 'history_screen.dart';
import 'home_screen.dart';
import 'ranking_screen.dart';
import 'settings_screen.dart';

class MainShellScreen extends StatefulWidget {
  final PreferenciasService prefs;

  const MainShellScreen({super.key, required this.prefs});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(prefs: widget.prefs),
      const HistoryScreen(),
      const RankingScreen(),
      SettingsScreen(prefs: widget.prefs),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (idx) => setState(() => _selectedIndex = idx),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Inicio'),
          NavigationDestination(icon: Icon(Icons.history), label: 'Historial'),
          NavigationDestination(icon: Icon(Icons.leaderboard), label: 'Ranking'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Ajustes'),
        ],
      ),
    );
  }
}