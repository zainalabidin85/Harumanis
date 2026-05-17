import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _login() async {
    setState(() { _loading = true; _error = null; });
    try {
      final token = await ApiService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );
      await AuthService.saveToken(token);
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      }
    } catch (e) {
      setState(() { _error = 'Invalid email or password'; });
    } finally {
      setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('🥭', textAlign: TextAlign.center, style: TextStyle(fontSize: 56)),
              const SizedBox(height: 8),
              const Text(
                'MLharum',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Harumanis Farm Manager',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
                obscureText: true,
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loading ? null : _login,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.green.shade700,
                ),
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Login', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
