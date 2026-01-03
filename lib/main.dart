import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/settings_provider.dart';
import 'game/game_provider.dart';
import 'theme/app_theme.dart';
import 'theme/theme_provider.dart';
import 'ui/screens/game_screen.dart';
import 'ui/screens/menu_screen.dart';
import 'ui/screens/stats_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const OpenSweeperApp());
}

class OpenSweeperApp extends StatelessWidget {
  const OpenSweeperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => GameProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'OpenSweeper',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme(),
            darkTheme: AppTheme.darkTheme(),
            themeMode: themeProvider.themeMode,
            home: const MainScreen(),
          );
        },
      ),
    );
  }
}

/// Main screen with menu, game, and stats navigation.
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  void _startGame() {
    // Get settings and start a new game with the selected config
    final settings = context.read<SettingsProvider>();
    final gameProvider = context.read<GameProvider>();
    gameProvider.newGame(config: settings.currentGameConfig);
    
    // Navigate to game tab
    setState(() => _currentIndex = 1);
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      MenuScreen(onStartGame: _startGame),
      const GameScreen(),
      const StatsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Menu',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_view),
            selectedIcon: Icon(Icons.grid_view_rounded),
            label: 'Game',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Stats',
          ),
        ],
      ),
    );
  }
}
