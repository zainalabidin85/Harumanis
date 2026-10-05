import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/locale_service.dart';
import '../widgets/language_toggle.dart';
import '../services/push_notification_service.dart';
import '../theme.dart';
import '../widgets/page_route.dart';
import 'home_screen.dart';
import '../l10n/l10n.dart';

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
        setState(() => _error = context.l10n.loginErrorBuyerAccount);
        return;
      }
      await AuthService.saveRole(role!);
      final farmId = me['farm_id'] as int?;
      if (farmId != null) await AuthService.saveFarmId(farmId);
      unawaited(LocaleController.instance.syncToAccount());
      if (await PushNotificationService.requestPermission()) {
        await PushNotificationService.registerToken();
      }
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
        setState(() => _error = context.l10n.loginErrorInvalidCredentials);
      } else if (e.type == DioExceptionType.connectionError ||
                 e.type == DioExceptionType.unknown) {
        setState(() => _error = context.l10n.loginErrorNoConnection);
      } else {
        setState(() => _error = context.l10n.loginErrorFailed(e.message ?? ''));
      }
    } catch (e, st) {
      HapticFeedback.vibrate();
      print('[LOGIN] Unexpected error: $e\n$st');
      setState(() => _error = context.l10n.commonErrorWithDetail(e.toString()));
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
            child: Stack(
              children: [
                Column(
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
                                context.l10n.loginTagline,
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
                                    context.l10n.loginWelcomeBack,
                                    style: GoogleFonts.poppins(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: kText1,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    context.l10n.loginSubtitle,
                                    style: GoogleFonts.poppins(
                                        fontSize: 14, color: kText2),
                                  ),
                                  const SizedBox(height: 28),
                                  TextField(
                                    controller: _emailCtrl,
                                    decoration: InputDecoration(
                                      labelText: context.l10n.commonEmail,
                                      prefixIcon: Icon(Icons.email_outlined),
                                    ),
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                  ),
                                  const SizedBox(height: 14),
                                  TextField(
                                    controller: _passwordCtrl,
                                    decoration: InputDecoration(
                                      labelText: context.l10n.commonPassword,
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
                                        context.l10n.loginForgotPasswordLink,
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
                                        : Text(context.l10n.loginSignInButton),
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
                                            TextSpan(
                                                text: context.l10n.loginNoAccountPrompt),
                                            TextSpan(
                                              text: context.l10n.loginRegister,
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
                const Positioned(top: 4, right: 8, child: LanguageToggle()),
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
                  () => dialogError = context.l10n.loginErrorEnterEmail);
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
                dialogError = context.l10n.loginErrorSendCodeFailed;
              });
            }
          }

          Future<void> submitReset() async {
            if (otpCtrl.text.trim().isEmpty ||
                newPassCtrl.text.isEmpty) {
              setDialogState(
                  () => dialogError = context.l10n.loginErrorFillAllFields);
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
                  SnackBar(
                      content: Text(
                          context.l10n.loginPasswordResetDone)),
                );
              }
            } catch (_) {
              setDialogState(() {
                dialogLoading = false;
                dialogError = context.l10n.loginErrorInvalidCode;
              });
            }
          }

          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            title: Text(step2 ? context.l10n.loginEnterResetCodeTitle : context.l10n.loginForgotPasswordTitle,
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!step2) ...[
                    Text(
                      context.l10n.loginForgotPasswordBody,
                      style: GoogleFonts.poppins(
                          color: kText2, fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: emailCtrl,
                      decoration: InputDecoration(
                        labelText: context.l10n.commonEmail,
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ] else ...[
                    Text(
                      context.l10n.loginCodeSentTo(emailCtrl.text.trim()),
                      style: GoogleFonts.poppins(
                          color: kText2, fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: otpCtrl,
                      decoration: InputDecoration(
                        labelText: context.l10n.loginSixDigitCodeLabel,
                        prefixIcon: Icon(Icons.pin_outlined),
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: newPassCtrl,
                      decoration: InputDecoration(
                        labelText: context.l10n.loginNewPasswordLabel,
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
                child: Text(context.l10n.commonCancel,
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
                        step2 ? context.l10n.loginResetPasswordButton : context.l10n.loginSendCodeButton,
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
          title: Text(context.l10n.loginCreateAccountTitle,
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: context.l10n.commonFullName,
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailCtrl,
                  decoration: InputDecoration(
                    labelText: context.l10n.commonEmail,
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneCtrl,
                  decoration: InputDecoration(
                    labelText: context.l10n.loginPhoneOptionalLabel,
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passCtrl,
                  decoration: InputDecoration(
                    labelText: context.l10n.commonPassword,
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
              child: Text(context.l10n.commonCancel,
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
                            context.l10n.loginErrorRegisterRequired);
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
                            SnackBar(
                                content: Text(
                                    context.l10n.loginAccountCreated)),
                          );
                          _emailCtrl.text = emailCtrl.text.trim();
                        }
                      } catch (e, st) {
                        print('[REGISTER] Error: $e\n$st');
                        setDialogState(() {
                          dialogLoading = false;
                          dialogError =
                              context.l10n.loginErrorRegisterFailed(e.toString());
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
                  : Text(context.l10n.loginRegister, style: GoogleFonts.poppins()),
            ),
          ],
        ),
      ),
    );
  }
}
