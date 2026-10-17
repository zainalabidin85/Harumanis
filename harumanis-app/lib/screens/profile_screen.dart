import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../l10n/l10n.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/locale_service.dart';
import '../theme.dart';
import '../widgets/page_route.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameCtrl     = TextEditingController();
  final _addressCtrl  = TextEditingController();
  final _phoneCtrl    = TextEditingController();
  final _whatsappCtrl = TextEditingController();

  bool _loading    = true;
  bool _saving     = false;
  String? _email;
  String? _error;
  String? _success;
  String _version  = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    _whatsappCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    final info = await PackageInfo.fromPlatform();
    _version = info.version;
    try {
      final me = await ApiService.getMe();
      _nameCtrl.text     = me['name']     as String? ?? '';
      _addressCtrl.text  = me['address']  as String? ?? '';
      _phoneCtrl.text    = me['phone']    as String? ?? '';
      _whatsappCtrl.text = me['whatsapp'] as String? ?? '';
      _email = me['email'] as String?;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (!mounted) return;
      _error = status == 401
          ? context.l10n.profileSessionExpiredRelogin
          : context.l10n.profileErrorLoadStatus('$status');
    } catch (e) {
      if (mounted) _error = context.l10n.profileErrorLoad(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    HapticFeedback.mediumImpact();
    setState(() { _saving = true; _error = null; _success = null; });
    try {
      await ApiService.updateMe(
        name:     _nameCtrl.text.trim().isEmpty     ? null : _nameCtrl.text.trim(),
        address:  _addressCtrl.text.trim().isEmpty  ? null : _addressCtrl.text.trim(),
        phone:    _phoneCtrl.text.trim().isEmpty    ? null : _phoneCtrl.text.trim(),
        whatsapp: _whatsappCtrl.text.trim().isEmpty ? null : _whatsappCtrl.text.trim(),
      );
      if (mounted) setState(() => _success = context.l10n.profileSaved);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final detail = e.response?.data is Map
          ? (e.response!.data as Map)['detail']?.toString()
          : null;
      if (!mounted) return;
      final l10n = context.l10n;
      final msg = status == 401
          ? l10n.profileSessionExpiredRelogin
          : detail != null
              ? l10n.profileErrorSaveStatusDetail('$status', detail)
              : l10n.profileErrorSaveStatus('$status');
      setState(() => _error = msg);
    } catch (e) {
      if (mounted) setState(() => _error = context.l10n.profileErrorSave(e.toString()));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _logout() async {
    HapticFeedback.mediumImpact();
    await AuthService.logout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
          context,
          FadeSlideRoute(page: const LoginScreen()),
          (_) => false);
    }
  }

  void _chooseLanguage() {
    final l10n = context.l10n;
    final current = LocaleController.instance.code;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final option in [
              ('ms', l10n.languageMalay),
              ('en', l10n.languageEnglish),
            ])
              ListTile(
                title: Text(option.$2, style: GoogleFonts.poppins(fontSize: 14)),
                trailing: current == option.$1
                    ? const Icon(Icons.check_rounded, color: kAmberPrimary)
                    : null,
                onTap: () {
                  Navigator.pop(sheetContext);
                  LocaleController.instance.setLocale(option.$1);
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: Text(context.l10n.profileTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: kAmberPrimary))
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Avatar ────────────────────────────────────────────────
                  Center(
                    child: Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        color: kAmberLight,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: kAmberMid.withValues(alpha: 0.3), width: 2),
                      ),
                      child: const Center(
                          child: Text('🥭', style: TextStyle(fontSize: 38))),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_email != null)
                    Center(
                      child: Text(_email!,
                          style: GoogleFonts.poppins(
                              fontSize: 13, color: kText2)),
                    ),
                  Center(
                    child: Text(context.l10n.profileBuyerAccount,
                        style: GoogleFonts.poppins(
                            fontSize: 12, color: kText3)),
                  ),
                  const SizedBox(height: 28),

                  // ── Personal Info ─────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: kCard,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: kCardShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(context.l10n.profilePersonalInfo,
                            style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: kText1)),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _nameCtrl,
                          decoration: InputDecoration(
                            labelText: context.l10n.commonFullName,
                            prefixIcon: const Icon(Icons.person_outline),
                          ),
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _addressCtrl,
                          decoration: InputDecoration(
                            labelText: context.l10n.profileDeliveryAddressLabel,
                            prefixIcon: const Icon(Icons.location_on_outlined),
                            hintText: context.l10n.deliveryAddressHint,
                          ),
                          textCapitalization: TextCapitalization.sentences,
                          textInputAction: TextInputAction.next,
                          maxLines: 3,
                          minLines: 1,
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _phoneCtrl,
                          decoration: InputDecoration(
                            labelText: context.l10n.profilePhoneLabel,
                            prefixIcon: const Icon(Icons.phone_outlined),
                            hintText: context.l10n.profilePhoneHint,
                          ),
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _whatsappCtrl,
                          decoration: InputDecoration(
                            labelText: context.l10n.profileWhatsappLabel,
                            prefixIcon: const Icon(Icons.chat_outlined),
                            hintText: context.l10n.profileWhatsappHint,
                            helperText: context.l10n.profileWhatsappHelper,
                            helperStyle:
                                GoogleFonts.poppins(fontSize: 11, color: kText3),
                            suffixIcon: _whatsappCtrl.text.isNotEmpty
                                ? const Icon(Icons.check_circle_rounded,
                                    color: kGreen, size: 20)
                                : null,
                          ),
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.done,
                          onChanged: (_) => setState(() {}),
                          onSubmitted: (_) => _save(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── Language ──────────────────────────────────────────────
                  Container(
                    decoration: BoxDecoration(
                      color: kCard,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: kCardShadow,
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.language_rounded, color: kAmberPrimary),
                      title: Text(context.l10n.languageRowTitle,
                          style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: kText1)),
                      subtitle: Text(
                          LocaleController.instance.code == 'ms'
                              ? context.l10n.languageMalay
                              : context.l10n.languageEnglish,
                          style: GoogleFonts.poppins(fontSize: 12, color: kText2)),
                      trailing: const Icon(Icons.chevron_right_rounded, color: kText3),
                      onTap: _chooseLanguage,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Feedback messages ─────────────────────────────────────
                  AnimatedSize(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                    child: _error != null
                        ? _Banner(
                            message: _error!,
                            color: const Color(0xFFFEF2F2),
                            border: const Color(0xFFFECACA),
                            icon: Icons.error_outline,
                            iconColor: kRed,
                            textColor: kRed,
                          )
                        : _success != null
                            ? _Banner(
                                message: _success!,
                                color: const Color(0xFFF0FDF4),
                                border: const Color(0xFFBBF7D0),
                                icon: Icons.check_circle_outline_rounded,
                                iconColor: kGreen,
                                textColor: kGreen,
                              )
                            : const SizedBox.shrink(),
                  ),

                  ElevatedButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2.5))
                        : Text(context.l10n.profileSaveButton),
                  ),
                  const SizedBox(height: 12),

                  // ── App info + Sign out ───────────────────────────────────
                  _InfoTile(
                    icon: Icons.info_outline_rounded,
                    label: context.l10n.profileAppVersion,
                    value: _version,
                  ),
                  const SizedBox(height: 10),
                  _InfoTile(
                    icon: Icons.eco_rounded,
                    label: context.l10n.profilePoweredBy,
                    value: 'MLharum AI · UniMAP',
                  ),
                  const SizedBox(height: 24),

                  OutlinedButton.icon(
                    icon: const Icon(Icons.logout_rounded),
                    label: Text(context.l10n.profileSignOut),
                    onPressed: _logout,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: kRed,
                      side: const BorderSide(color: kRed),
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _Banner extends StatelessWidget {
  final String message;
  final Color color, border, iconColor, textColor;
  final IconData icon;
  const _Banner({
    required this.message,
    required this.color,
    required this.border,
    required this.icon,
    required this.iconColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border),
        ),
        child: Row(children: [
          Icon(icon, color: iconColor, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message,
                style: GoogleFonts.poppins(fontSize: 13, color: textColor)),
          ),
        ]),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoTile(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(16),
          boxShadow: kCardShadow),
      child: Row(children: [
        Icon(icon, color: kAmberPrimary, size: 20),
        const SizedBox(width: 12),
        Expanded(
            child: Text(label,
                style: GoogleFonts.poppins(fontSize: 13, color: kText2))),
        Text(value,
            style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: kText1)),
      ]),
    );
  }
}
