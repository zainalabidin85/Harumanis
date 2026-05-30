import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../theme.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() { _loading = true; _error = null; });
    try {
      final token = await ApiService.login(_emailCtrl.text.trim(), _passwordCtrl.text);
      await AuthService.saveToken(token);
      final me = await ApiService.getMe();
      if (me['role'] != 'admin') {
        await AuthService.deleteToken();
        setState(() { _error = 'This account does not have admin access.'; _loading = false; });
        return;
      }
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final detail = e.response?.data is Map ? e.response!.data['detail'] : null;
      setState(() {
        _error = status == 403
            ? (detail ?? 'Account suspended.')
            : status == 401
                ? 'Invalid email or password.'
                : 'Login failed (error $status).';
        _loading = false;
      });
    } catch (e) {
      setState(() { _error = 'Error: $e'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72, height: 72,
                  decoration: BoxDecoration(color: kIndigo700, borderRadius: BorderRadius.circular(20)),
                  child: const Center(child: Text('🛡️', style: TextStyle(fontSize: 32))),
                ),
                const SizedBox(height: 20),
                Text('Harumanis Admin', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700, color: kText1)),
                const SizedBox(height: 6),
                Text('Platform management console', style: GoogleFonts.poppins(fontSize: 13, color: kText3)),
                const SizedBox(height: 36),
                TextField(
                  controller: _emailCtrl,
                  decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _passwordCtrl,
                  decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock_outline)),
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _login(),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFFECACA)),
                    ),
                    child: Row(children: [
                      const Icon(Icons.error_outline, color: kRed, size: 16),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_error!, style: GoogleFonts.poppins(fontSize: 13, color: kRed))),
                    ]),
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _login,
                    child: _loading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                        : const Text('Sign In'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
