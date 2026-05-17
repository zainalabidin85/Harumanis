import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'tree_list_screen.dart';
import 'dashboard_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    await AuthService.logout();
    if (context.mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MLharum'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('🥭', textAlign: TextAlign.center, style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            const Text(
              'What would you like to do?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 40),
            _HomeButton(
              icon: Icons.forest,
              label: 'My Trees',
              subtitle: 'Scan fruit and manage trees',
              color: Colors.green.shade700,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TreeListScreen()),
              ),
            ),
            const SizedBox(height: 16),
            _HomeButton(
              icon: Icons.map,
              label: 'Farm Dashboard',
              subtitle: 'View satellite map of your farm',
              color: Colors.blue.shade700,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DashboardScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _HomeButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
