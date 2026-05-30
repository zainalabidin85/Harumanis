import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../theme.dart';
import '../widgets/page_route.dart';
import 'marketplace_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  late AnimationController _ctrl;
  late Animation<double> _logoFade, _logoScale, _cardFade;
  late Animation<Offset> _cardSlide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _logoFade  = CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.5, curve: Curves.easeOut));
    _logoScale = Tween<double>(begin: 0.75, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.55, curve: Curves.easeOutBack)));
    _cardSlide = Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero).animate(
        CurvedAnimation(parent: _ctrl, curve: const Interval(0.35, 1.0, curve: Curves.easeOutCubic)));
    _cardFade  = CurvedAnimation(parent: _ctrl, curve: const Interval(0.35, 0.75));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    HapticFeedback.mediumImpact();
    setState(() { _loading = true; _error = null; });
    try {
      final token = await ApiService.login(_emailCtrl.text.trim(), _passwordCtrl.text);
      await AuthService.saveToken(token);
      final me = await ApiService.getMe();
      final role = me['role'] as String?;
      if (role != 'buyer') {
        await AuthService.logout();
        setState(() => _error = 'This account is registered as a farmer. Please use the Ai-Harumanis app.');
        return;
      }
      if (mounted) {
        Navigator.pushReplacement(context, FadeSlideRoute(page: const MarketplaceScreen()));
      }
    } on DioException catch (e) {
      HapticFeedback.vibrate();
      final status = e.response?.statusCode;
      setState(() {
        if (status == 401) {
          _error = 'Invalid email or password';
        } else if (e.type == DioExceptionType.connectionError ||
                   e.type == DioExceptionType.unknown) {
          _error = 'Cannot reach server. Check your connection.';
        } else {
          _error = 'Login failed. Please try again.';
        }
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF78350F), Color(0xFFB45309)],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                Expanded(
                  flex: 4,
                  child: FadeTransition(
                    opacity: _logoFade,
                    child: ScaleTransition(
                      scale: _logoScale,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.15),
                              border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.3), width: 1.5),
                            ),
                            child: const Center(child: Text('🥭', style: TextStyle(fontSize: 46))),
                          ),
                          const SizedBox(height: 20),
                          Text('Beli Harumanis',
                              style: GoogleFonts.poppins(
                                  fontSize: 34, fontWeight: FontWeight.bold, color: Colors.white)),
                          const SizedBox(height: 6),
                          Text('Fresh from the farm, direct to you',
                              style: GoogleFonts.poppins(
                                  fontSize: 13, color: Colors.white.withValues(alpha: 0.75))),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 6,
                  child: FadeTransition(
                    opacity: _cardFade,
                    child: SlideTransition(
                      position: _cardSlide,
                      child: Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFAFAFA),
                          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                        ),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(28, 36, 28, 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text('Welcome back',
                                  style: GoogleFonts.poppins(
                                      fontSize: 24, fontWeight: FontWeight.bold, color: kText1)),
                              const SizedBox(height: 4),
                              Text('Sign in to your buyer account',
                                  style: GoogleFonts.poppins(fontSize: 14, color: kText2)),
                              const SizedBox(height: 28),
                              TextField(
                                controller: _emailCtrl,
                                decoration: const InputDecoration(
                                    labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                              ),
                              const SizedBox(height: 14),
                              TextField(
                                controller: _passwordCtrl,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    icon: Icon(_obscure
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                        color: kText3),
                                    onPressed: () => setState(() => _obscure = !_obscure),
                                  ),
                                ),
                                obscureText: _obscure,
                                textInputAction: TextInputAction.done,
                                onSubmitted: (_) => _login(),
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: _loading ? null : _showForgotPassword,
                                  style: TextButton.styleFrom(foregroundColor: kAmberPrimary),
                                  child: Text('Forgot Password?',
                                      style: GoogleFonts.poppins(fontSize: 13)),
                                ),
                              ),
                              AnimatedSize(
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeOut,
                                child: _error != null
                                    ? Padding(
                                        padding: const EdgeInsets.only(bottom: 14),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 10),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFEF2F2),
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(color: const Color(0xFFFECACA)),
                                          ),
                                          child: Row(children: [
                                            const Icon(Icons.error_outline, color: kRed, size: 18),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(_error!,
                                                  style: GoogleFonts.poppins(
                                                      color: kRed, fontSize: 13)),
                                            ),
                                          ]),
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                              ),
                              ElevatedButton(
                                onPressed: _loading ? null : _login,
                                child: _loading
                                    ? const SizedBox(
                                        height: 20, width: 20,
                                        child: CircularProgressIndicator(
                                            color: Colors.white, strokeWidth: 2.5))
                                    : const Text('Sign In'),
                              ),
                              const SizedBox(height: 16),
                              GestureDetector(
                                onTap: _loading ? null : _showRegister,
                                child: Center(
                                  child: RichText(
                                    text: TextSpan(
                                      style: GoogleFonts.poppins(fontSize: 14, color: kText2),
                                      children: [
                                        const TextSpan(text: "Don't have an account? "),
                                        TextSpan(
                                          text: 'Register',
                                          style: GoogleFonts.poppins(
                                              color: kAmberPrimary, fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showForgotPassword() {
    final emailCtrl   = TextEditingController();
    final otpCtrl     = TextEditingController();
    final newPassCtrl = TextEditingController();
    bool step2 = false;
    String? dialogError;
    bool dialogLoading = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) {
          Future<void> sendCode() async {
            if (emailCtrl.text.trim().isEmpty) {
              setSt(() => dialogError = 'Please enter your email.');
              return;
            }
            setSt(() { dialogLoading = true; dialogError = null; });
            try {
              await ApiService.forgotPassword(emailCtrl.text.trim());
              setSt(() { dialogLoading = false; step2 = true; });
            } catch (_) {
              setSt(() { dialogLoading = false; dialogError = 'Failed to send code.'; });
            }
          }

          Future<void> submitReset() async {
            setSt(() { dialogLoading = true; dialogError = null; });
            final messenger = ScaffoldMessenger.of(context);
            try {
              await ApiService.resetPassword(
                  emailCtrl.text.trim(), otpCtrl.text.trim(), newPassCtrl.text);
              if (ctx.mounted) {
                Navigator.pop(ctx);
                messenger.showSnackBar(
                    const SnackBar(content: Text('Password reset! Please log in.')));
              }
            } catch (_) {
              setSt(() { dialogLoading = false; dialogError = 'Invalid or expired code.'; });
            }
          }

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(step2 ? 'Enter Reset Code' : 'Forgot Password',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            content: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                if (!step2) ...[
                  Text('Enter your email to receive a reset code.',
                      style: GoogleFonts.poppins(color: kText2, fontSize: 13)),
                  const SizedBox(height: 16),
                  TextField(controller: emailCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
                      keyboardType: TextInputType.emailAddress),
                ] else ...[
                  Text('Code sent to ${emailCtrl.text.trim()}.',
                      style: GoogleFonts.poppins(color: kText2, fontSize: 13)),
                  const SizedBox(height: 16),
                  TextField(controller: otpCtrl,
                      decoration: const InputDecoration(
                          labelText: '6-digit Code', prefixIcon: Icon(Icons.pin_outlined)),
                      keyboardType: TextInputType.number, maxLength: 6),
                  const SizedBox(height: 8),
                  TextField(controller: newPassCtrl,
                      decoration: const InputDecoration(
                          labelText: 'New Password', prefixIcon: Icon(Icons.lock_outline)),
                      obscureText: true),
                ],
                if (dialogError != null) ...[
                  const SizedBox(height: 10),
                  Text(dialogError!, style: GoogleFonts.poppins(color: kRed, fontSize: 13)),
                ],
              ]),
            ),
            actions: [
              TextButton(
                  onPressed: dialogLoading ? null : () => Navigator.pop(ctx),
                  child: Text('Cancel', style: GoogleFonts.poppins(color: kText2))),
              ElevatedButton(
                onPressed: dialogLoading ? null : (step2 ? submitReset : sendCode),
                child: dialogLoading
                    ? const SizedBox(width: 18, height: 18,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(step2 ? 'Reset Password' : 'Send Code',
                        style: GoogleFonts.poppins()),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showRegister() {
    final nameCtrl      = TextEditingController();
    final emailCtrl     = TextEditingController();
    final addressCtrl   = TextEditingController();
    final phoneCtrl     = TextEditingController();
    final waCtrl        = TextEditingController();
    final passCtrl      = TextEditingController();
    String? dialogError;
    bool dialogLoading = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Create Buyer Account',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(controller: nameCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Full Name', prefixIcon: Icon(Icons.person_outline)),
                  textCapitalization: TextCapitalization.words),
              const SizedBox(height: 12),
              TextField(controller: emailCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
                  keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 12),
              TextField(controller: addressCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Delivery Address *',
                      prefixIcon: Icon(Icons.location_on_outlined),
                      hintText: 'Full address for mango delivery'),
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 2,
                  minLines: 1),
              const SizedBox(height: 12),
              TextField(controller: phoneCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Phone (optional)', prefixIcon: Icon(Icons.phone_outlined)),
                  keyboardType: TextInputType.phone),
              const SizedBox(height: 12),
              TextField(controller: waCtrl,
                  decoration: const InputDecoration(
                      labelText: 'WhatsApp number (optional)',
                      prefixIcon: Icon(Icons.chat_outlined)),
                  keyboardType: TextInputType.phone),
              const SizedBox(height: 12),
              TextField(controller: passCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Password', prefixIcon: Icon(Icons.lock_outline)),
                  obscureText: true),
              if (dialogError != null) ...[
                const SizedBox(height: 10),
                Text(dialogError!, style: GoogleFonts.poppins(color: kRed, fontSize: 13)),
              ],
            ]),
          ),
          actions: [
            TextButton(
                onPressed: dialogLoading ? null : () => Navigator.pop(ctx),
                child: Text('Cancel', style: GoogleFonts.poppins(color: kText2))),
            ElevatedButton(
              onPressed: dialogLoading
                  ? null
                  : () async {
                      if (nameCtrl.text.trim().isEmpty ||
                          emailCtrl.text.trim().isEmpty ||
                          addressCtrl.text.trim().isEmpty ||
                          passCtrl.text.isEmpty) {
                        setSt(() => dialogError = 'Name, email, address and password are required.');
                        return;
                      }
                      setSt(() { dialogLoading = true; dialogError = null; });
                      final messenger = ScaffoldMessenger.of(context);
                      final emailText = emailCtrl.text.trim();
                      try {
                        await ApiService.register(
                          nameCtrl.text.trim(),
                          emailText,
                          passCtrl.text,
                          addressCtrl.text.trim(),
                          phone: phoneCtrl.text.trim().isEmpty ? null : phoneCtrl.text.trim(),
                          whatsapp: waCtrl.text.trim().isEmpty ? null : waCtrl.text.trim(),
                        );
                        if (ctx.mounted) {
                          Navigator.pop(ctx);
                          messenger.showSnackBar(
                              const SnackBar(content: Text('Account created! Please log in.')));
                          _emailCtrl.text = emailText;
                        }
                      } catch (e) {
                        setSt(() { dialogLoading = false; dialogError = 'Registration failed: $e'; });
                      }
                    },
              child: dialogLoading
                  ? const SizedBox(width: 18, height: 18,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text('Register', style: GoogleFonts.poppins()),
            ),
          ],
        ),
      ),
    );
  }
}
