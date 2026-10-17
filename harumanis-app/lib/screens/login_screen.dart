import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../l10n/l10n.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/locale_service.dart';
import '../theme.dart';
import '../widgets/language_toggle.dart';
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
        setState(() => _error = context.l10n.loginErrorFarmerAccount);
        return;
      }
      unawaited(LocaleController.instance.syncToAccount());
      if (mounted) {
        Navigator.pushReplacement(context, FadeSlideRoute(page: const MarketplaceScreen()));
      }
    } on DioException catch (e) {
      HapticFeedback.vibrate();
      final status = e.response?.statusCode;
      setState(() {
        if (status == 401) {
          _error = context.l10n.loginErrorInvalidCredentials;
        } else if (e.type == DioExceptionType.connectionError ||
                   e.type == DioExceptionType.unknown) {
          _error = context.l10n.commonNoConnection;
        } else {
          _error = context.l10n.loginErrorFailed;
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
                  child: Stack(
                    children: [
                      Positioned.fill(
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
                                Text(context.l10n.loginTagline,
                                    style: GoogleFonts.poppins(
                                        fontSize: 13, color: Colors.white.withValues(alpha: 0.75))),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const Positioned(top: 4, right: 8, child: LanguageToggle()),
                    ],
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
                              Text(context.l10n.loginWelcomeBack,
                                  style: GoogleFonts.poppins(
                                      fontSize: 24, fontWeight: FontWeight.bold, color: kText1)),
                              const SizedBox(height: 4),
                              Text(context.l10n.loginSubtitle,
                                  style: GoogleFonts.poppins(fontSize: 14, color: kText2)),
                              const SizedBox(height: 28),
                              TextField(
                                controller: _emailCtrl,
                                decoration: InputDecoration(
                                    labelText: context.l10n.commonEmail, prefixIcon: const Icon(Icons.email_outlined)),
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                              ),
                              const SizedBox(height: 14),
                              TextField(
                                controller: _passwordCtrl,
                                decoration: InputDecoration(
                                  labelText: context.l10n.commonPassword,
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
                                  child: Text(context.l10n.loginForgotPasswordLink,
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
                                    : Text(context.l10n.loginSignInButton),
                              ),
                              const SizedBox(height: 16),
                              GestureDetector(
                                onTap: _loading ? null : _showRegister,
                                child: Center(
                                  child: RichText(
                                    text: TextSpan(
                                      style: GoogleFonts.poppins(fontSize: 14, color: kText2),
                                      children: [
                                        TextSpan(text: context.l10n.loginNoAccountPrompt),
                                        TextSpan(
                                          text: context.l10n.loginRegister,
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

    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) {
          Future<void> sendCode() async {
            if (emailCtrl.text.trim().isEmpty) {
              setSt(() => dialogError = l10n.loginErrorEnterEmail);
              return;
            }
            setSt(() { dialogLoading = true; dialogError = null; });
            try {
              await ApiService.forgotPassword(emailCtrl.text.trim());
              setSt(() { dialogLoading = false; step2 = true; });
            } catch (_) {
              setSt(() { dialogLoading = false; dialogError = l10n.loginErrorSendCodeFailed; });
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
                    SnackBar(content: Text(l10n.loginPasswordResetDone)));
              }
            } catch (_) {
              setSt(() { dialogLoading = false; dialogError = l10n.loginErrorInvalidCode; });
            }
          }

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(step2 ? l10n.loginEnterResetCodeTitle : l10n.loginForgotPasswordTitle,
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            content: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                if (!step2) ...[
                  Text(l10n.loginForgotPasswordBody,
                      style: GoogleFonts.poppins(color: kText2, fontSize: 13)),
                  const SizedBox(height: 16),
                  TextField(controller: emailCtrl,
                      decoration: InputDecoration(
                          labelText: l10n.commonEmail, prefixIcon: const Icon(Icons.email_outlined)),
                      keyboardType: TextInputType.emailAddress),
                ] else ...[
                  Text(l10n.loginCodeSentTo(emailCtrl.text.trim()),
                      style: GoogleFonts.poppins(color: kText2, fontSize: 13)),
                  const SizedBox(height: 16),
                  TextField(controller: otpCtrl,
                      decoration: InputDecoration(
                          labelText: l10n.loginSixDigitCodeLabel, prefixIcon: const Icon(Icons.pin_outlined)),
                      keyboardType: TextInputType.number, maxLength: 6),
                  const SizedBox(height: 8),
                  TextField(controller: newPassCtrl,
                      decoration: InputDecoration(
                          labelText: l10n.loginNewPasswordLabel, prefixIcon: const Icon(Icons.lock_outline)),
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
                  child: Text(l10n.commonCancel, style: GoogleFonts.poppins(color: kText2))),
              ElevatedButton(
                onPressed: dialogLoading ? null : (step2 ? submitReset : sendCode),
                child: dialogLoading
                    ? const SizedBox(width: 18, height: 18,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(step2 ? l10n.loginResetPasswordButton : l10n.loginSendCodeButton,
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
    final l10n = context.l10n;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(l10n.loginCreateAccountTitle,
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(controller: nameCtrl,
                  decoration: InputDecoration(
                      labelText: l10n.commonFullName, prefixIcon: const Icon(Icons.person_outline)),
                  textCapitalization: TextCapitalization.words),
              const SizedBox(height: 12),
              TextField(controller: emailCtrl,
                  decoration: InputDecoration(
                      labelText: l10n.commonEmail, prefixIcon: const Icon(Icons.email_outlined)),
                  keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 12),
              TextField(controller: addressCtrl,
                  decoration: InputDecoration(
                      labelText: l10n.loginDeliveryAddressRequiredLabel,
                      prefixIcon: const Icon(Icons.location_on_outlined),
                      hintText: l10n.deliveryAddressHint),
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 2,
                  minLines: 1),
              const SizedBox(height: 12),
              TextField(controller: phoneCtrl,
                  decoration: InputDecoration(
                      labelText: l10n.loginPhoneOptionalLabel, prefixIcon: const Icon(Icons.phone_outlined)),
                  keyboardType: TextInputType.phone),
              const SizedBox(height: 12),
              TextField(controller: waCtrl,
                  decoration: InputDecoration(
                      labelText: l10n.loginWhatsappOptionalLabel,
                      prefixIcon: const Icon(Icons.chat_outlined)),
                  keyboardType: TextInputType.phone),
              const SizedBox(height: 12),
              TextField(controller: passCtrl,
                  decoration: InputDecoration(
                      labelText: l10n.commonPassword, prefixIcon: const Icon(Icons.lock_outline)),
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
                child: Text(l10n.commonCancel, style: GoogleFonts.poppins(color: kText2))),
            ElevatedButton(
              onPressed: dialogLoading
                  ? null
                  : () async {
                      if (nameCtrl.text.trim().isEmpty ||
                          emailCtrl.text.trim().isEmpty ||
                          addressCtrl.text.trim().isEmpty ||
                          passCtrl.text.isEmpty) {
                        setSt(() => dialogError = l10n.loginErrorRegisterRequired);
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
                              SnackBar(content: Text(l10n.loginAccountCreated)));
                          _emailCtrl.text = emailText;
                        }
                      } catch (e) {
                        setSt(() { dialogLoading = false; dialogError = l10n.loginErrorRegisterFailed(e.toString()); });
                      }
                    },
              child: dialogLoading
                  ? const SizedBox(width: 18, height: 18,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(l10n.loginRegister, style: GoogleFonts.poppins()),
            ),
          ],
        ),
      ),
    );
  }
}
