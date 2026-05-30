import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/settings_screen.dart';
import 'screens/camera_screen.dart';
import 'screens/stats_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final hasUrl = (prefs.getString('server_url') ?? '').isNotEmpty;
  runApp(MLharumCollectorApp(startAtCamera: hasUrl));
}

class MLharumCollectorApp extends StatelessWidget {
  final bool startAtCamera;
  const MLharumCollectorApp({super.key, required this.startAtCamera});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Harumanis Collector',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      initialRoute: startAtCamera ? '/camera' : '/settings',
      routes: {
        '/settings': (_) => const SettingsScreen(),
        '/camera': (_) => const CollectorHome(),
        '/stats': (_) => const StatsScreen(),
      },
    );
  }
}

class CollectorHome extends StatefulWidget {
  const CollectorHome({super.key});

  @override
  State<CollectorHome> createState() => _CollectorHomeState();
}

class _CollectorHomeState extends State<CollectorHome> {
  int _tab = 0;

  static const _screens = [
    CameraScreen(),
    StatsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_tab],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() { _tab = i; }),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.camera_alt), label: 'Camera'),
          NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Stats'),
        ],
      ),
    );
  }
}
