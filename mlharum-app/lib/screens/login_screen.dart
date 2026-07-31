import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../theme.dart';
import '../widgets/page_route.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading  = false;
  bool _obscure  = true;
  String? _error;

  late AnimationController _ctrl;
  late Animation<double>  _logoFade;
  late Animation<double>  _logoScale;
  late Animation<Offset>  _cardSlide;
  late Animation<double>  _cardFade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1000));
    _logoFade = CurvedAnimation(
      parent: _ctrl, curve: const Interval(0.0, 0.5, curve: Curves.easeOut));
    _logoScale = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOutBack)));
    _cardSlide = Tween<Offset>(
            begin: const Offset(0, 0.25), end: Offset.zero)
        .animate(CurvedAnimation(
          parent: _ctrl,
          curve: const Interval(0.35, 1.0, curve: Curves.easeOutCubic)));
    _cardFade = CurvedAnimation(
      parent: _ctrl, curve: const Interval(0.35, 0.75));
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
      final token = await ApiService.login(
          _emailCtrl.text.trim(), _passwordCtrl.text);
      await AuthService.saveToken(token);
      final me = await ApiService.getMe();
      final role = me['role'] as String?;
      if (role != 'farmer' && role != 'admin' && role != 'doa') {
        await AuthService.logout();
        setState(() => _error = 'This account is registered as a buyer. Please use the Beli Harumanis app.');
        return;
      }
      await AuthService.saveRole(role!);
      final farmId = me['farm_id'] as int?;
      if (farmId != null) await AuthService.saveFarmId(farmId);
      if (mounted) {
        Navigator.pushReplacement(
            context, FadeSlideRoute(page: const HomeScreen()));
      }
    } on DioException catch (e) {
      HapticFeedback.vibrate();
      print('[LOGIN] DioException type=${e.type} status=${e.response?.statusCode} msg=${e.message}');
      print('[LOGIN] response body=${e.response?.data}');
      final status = e.response?.statusCode;
      if (status == 401) {
        setState(() => _error = 'Invalid email or password');
      } else if (e.type == DioExceptionType.connectionError ||
                 e.type == DioExceptionType.unknown) {
        setState(() => _error = 'Cannot reach server. Check your connection.');
      } else {
        setState(() => _error = 'Login failed (${e.message})');
      }
    } catch (e, st) {
      HapticFeedback.vibrate();
      print('[LOGIN] Unexpected error: $e\n$st');
      setState(() => _error = 'Error: $e');
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
              colors: [Color(0xFF0A2E17), Color(0xFF166534)],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                // ── Hero / logo ──────────────────────────────────────────
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
                                  color: Colors.white.withValues(alpha: 0.3),
                                  width: 1.5),
                            ),
                            child: const Center(
                              child:
                                  Text('🥭', style: TextStyle(fontSize: 46)),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Ai-Harumanis',
                            style: GoogleFonts.poppins(
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Harumanis Farm Manager',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Form card ────────────────────────────────────────────
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
                          borderRadius: BorderRadius.vertical(
                              top: Radius.circular(32)),
                        ),
                        child: SingleChildScrollView(
                          padding:
                              const EdgeInsets.fromLTRB(28, 36, 28, 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Welcome back',
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: kText1,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Sign in to your farm account',
                                style: GoogleFonts.poppins(
                                    fontSize: 14, color: kText2),
                              ),
                              const SizedBox(height: 28),
                              TextField(
                                controller: _emailCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Email',
                                  prefixIcon: Icon(Icons.email_outlined),
                                ),
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                              ),
                              const SizedBox(height: 14),
                              TextField(
                                controller: _passwordCtrl,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon:
                                      const Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscure
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: kText3,
                                    ),
                                    onPressed: () =>
                                        setState(() => _obscure = !_obscure),
                                  ),
                                ),
                                obscureText: _obscure,
                                textInputAction: TextInputAction.done,
                                onSubmitted: (_) => _login(),
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: _loading
                                      ? null
                                      : _showForgotPasswordDialog,
                                  style: TextButton.styleFrom(
                                      foregroundColor: kGreenPrimary),
                                  child: Text(
                                    'Forgot Password?',
                                    style: GoogleFonts.poppins(fontSize: 13),
                                  ),
                                ),
                              ),
                              AnimatedSize(
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeOut,
                                child: _error != null
                                    ? Padding(
                                        padding: const EdgeInsets.only(
                                            bottom: 14),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 10),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFEF2F2),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                                color:
                                                    const Color(0xFFFECACA)),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(
                                                  Icons.error_outline,
                                                  color: kRed,
                                                  size: 18),
                                              const SizedBox(width: 8),
                                              Text(
                                                _error!,
                                                style: GoogleFonts.poppins(
                                                    color: kRed,
                                                    fontSize: 13),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                              ),
                              ElevatedButton(
                                onPressed: _loading ? null : _login,
                                child: _loading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.5),
                                      )
                                    : const Text('Sign In'),
                              ),
                              const SizedBox(height: 16),
                              GestureDetector(
                                onTap: _loading ? null : _showRegisterDialog,
                                child: Center(
                                  child: RichText(
                                    text: TextSpan(
                                      style: GoogleFonts.poppins(
                                          fontSize: 14, color: kText2),
                                      children: [
                                        const TextSpan(
                                            text: "Don't have an account? "),
                                        TextSpan(
                                          text: 'Register',
                                          style: GoogleFonts.poppins(
                                            color: kGreenPrimary,
                                            fontWeight: FontWeight.w600,
                                          ),
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

  // ── Forgot-password dialog ──────────────────────────────────────────────
  void _showForgotPasswordDialog() {
    final emailCtrl   = TextEditingController();
    final otpCtrl     = TextEditingController();
    final newPassCtrl = TextEditingController();
    bool step2          = false;
    String? dialogError;
    bool dialogLoading  = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          Future<void> sendCode() async {
            if (emailCtrl.text.trim().isEmpty) {
              setDialogState(
                  () => dialogError = 'Please enter your email.');
              return;
            }
            setDialogState(
                () { dialogLoading = true; dialogError = null; });
            try {
              await ApiService.forgotPassword(emailCtrl.text.trim());
              setDialogState(
                  () { dialogLoading = false; step2 = true; });
            } catch (_) {
              setDialogState(() {
                dialogLoading = false;
                dialogError = 'Failed to send code. Try again.';
              });
            }
          }

          Future<void> submitReset() async {
            if (otpCtrl.text.trim().isEmpty ||
                newPassCtrl.text.isEmpty) {
              setDialogState(
                  () => dialogError = 'Please fill in all fields.');
              return;
            }
            setDialogState(
                () { dialogLoading = true; dialogError = null; });
            try {
              await ApiService.resetPassword(
                emailCtrl.text.trim(),
                otpCtrl.text.trim(),
                newPassCtrl.text,
              );
              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text(
                          'Password reset! Please log in with your new password.')),
                );
              }
            } catch (_) {
              setDialogState(() {
                dialogLoading = false;
                dialogError = 'Invalid or expired code.';
              });
            }
          }

          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            title: Text(step2 ? 'Enter Reset Code' : 'Forgot Password',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!step2) ...[
                    Text(
                      'Enter your email and we will send you a 6-digit reset code.',
                      style: GoogleFonts.poppins(
                          color: kText2, fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: emailCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ] else ...[
                    Text(
                      'A 6-digit code was sent to ${emailCtrl.text.trim()}.',
                      style: GoogleFonts.poppins(
                          color: kText2, fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: otpCtrl,
                      decoration: const InputDecoration(
                        labelText: '6-digit Code',
                        prefixIcon: Icon(Icons.pin_outlined),
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: newPassCtrl,
                      decoration: const InputDecoration(
                        labelText: 'New Password',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                      obscureText: true,
                    ),
                  ],
                  if (dialogError != null) ...[
                    const SizedBox(height: 10),
                    Text(dialogError!,
                        style: GoogleFonts.poppins(
                            color: kRed, fontSize: 13)),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: dialogLoading ? null : () => Navigator.pop(ctx),
                child: Text('Cancel',
                    style: GoogleFonts.poppins(color: kText2)),
              ),
              ElevatedButton(
                onPressed: dialogLoading
                    ? null
                    : (step2 ? submitReset : sendCode),
                child: dialogLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        step2 ? 'Reset Password' : 'Send Code',
                        style: GoogleFonts.poppins(),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── Register dialog ─────────────────────────────────────────────────────
  void _showRegisterDialog() {
    final nameCtrl  = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final passCtrl  = TextEditingController();
    String? dialogError;
    bool dialogLoading = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          title: Text('Create Account',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Phone (optional)',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  obscureText: true,
                ),
                if (dialogError != null) ...[
                  const SizedBox(height: 10),
                  Text(dialogError!,
                      style:
                          GoogleFonts.poppins(color: kRed, fontSize: 13)),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: dialogLoading ? null : () => Navigator.pop(ctx),
              child: Text('Cancel',
                  style: GoogleFonts.poppins(color: kText2)),
            ),
            ElevatedButton(
              onPressed: dialogLoading
                  ? null
                  : () async {
                      if (nameCtrl.text.trim().isEmpty ||
                          emailCtrl.text.trim().isEmpty ||
                          passCtrl.text.isEmpty) {
                        setDialogState(() => dialogError =
                            'Name, email and password are required.');
                        return;
                      }
                      setDialogState(() {
                        dialogLoading = true;
                        dialogError = null;
                      });
                      try {
                        await ApiService.register(
                          nameCtrl.text.trim(),
                          emailCtrl.text.trim(),
                          passCtrl.text,
                          phoneCtrl.text.trim().isEmpty
                              ? null
                              : phoneCtrl.text.trim(),
                        );
                        if (ctx.mounted) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Account created. Please log in.')),
                          );
                          _emailCtrl.text = emailCtrl.text.trim();
                        }
                      } catch (e, st) {
                        print('[REGISTER] Error: $e\n$st');
                        setDialogState(() {
                          dialogLoading = false;
                          dialogError =
                              'Registration failed: $e';
                        });
                      }
                    },
              child: dialogLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : Text('Register', style: GoogleFonts.poppins()),
            ),
          ],
        ),
      ),
    );
  }
}
