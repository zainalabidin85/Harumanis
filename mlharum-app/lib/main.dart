import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final loggedIn = await AuthService.isLoggedIn();
  runApp(MLharumApp(loggedIn: loggedIn));
}

class MLharumApp extends StatelessWidget {
  final bool loggedIn;
  const MLharumApp({super.key, required this.loggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MLharum',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green.shade700),
        useMaterial3: true,
      ),
      home: loggedIn ? const HomeScreen() : const LoginScreen(),
    );
  }
}
