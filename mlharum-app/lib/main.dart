import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'services/auth_service.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
  ));
  final loggedIn = await AuthService.isLoggedIn();
  runApp(AiHarumApp(loggedIn: loggedIn));
}

class AiHarumApp extends StatelessWidget {
  final bool loggedIn;
  const AiHarumApp({super.key, required this.loggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ai-Harumanis',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: loggedIn ? const HomeScreen() : const LoginScreen(),
    );
  }
}
