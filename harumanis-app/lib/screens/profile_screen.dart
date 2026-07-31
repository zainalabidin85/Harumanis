import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
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
      _error = status == 401
          ? 'Session expired. Please log out and sign in again.'
          : 'Failed to load profile (error $status).';
    } catch (e) {
      _error = 'Failed to load profile: $e';
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
      if (mounted) setState(() => _success = 'Profile saved.');
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final detail = e.response?.data is Map
          ? (e.response!.data as Map)['detail']?.toString()
          : null;
      final msg = status == 401
          ? 'Session expired. Please log out and sign in again.'
          : 'Failed to save (error $status${detail != null ? ': $detail' : ''}).';
      if (mounted) setState(() => _error = msg);
    } catch (e) {
      if (mounted) setState(() => _error = 'Failed to save: $e');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: const Text('My Profile'),
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
                    child: Text('Buyer Account',
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
                        Text('Personal Info',
                            style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: kText1)),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _nameCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Full Name',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _addressCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Delivery Address',
                            prefixIcon: Icon(Icons.location_on_outlined),
                            hintText: 'Full address for mango delivery',
                          ),
                          textCapitalization: TextCapitalization.sentences,
                          textInputAction: TextInputAction.next,
                          maxLines: 3,
                          minLines: 1,
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _phoneCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Phone number',
                            prefixIcon: Icon(Icons.phone_outlined),
                            hintText: 'e.g. 0123456789',
                          ),
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _whatsappCtrl,
                          decoration: InputDecoration(
                            labelText: 'WhatsApp number',
                            prefixIcon: const Icon(Icons.chat_outlined),
                            hintText: 'e.g. 60123456789',
                            helperText:
                                'Farmers may contact you here about your order',
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
                        : const Text('Save Profile'),
                  ),
                  const SizedBox(height: 12),

                  // ── App info + Sign out ───────────────────────────────────
                  _InfoTile(
                    icon: Icons.info_outline_rounded,
                    label: 'App Version',
                    value: _version,
                  ),
                  const SizedBox(height: 10),
                  _InfoTile(
                    icon: Icons.eco_rounded,
                    label: 'Powered by',
                    value: 'MLharum AI · UniMAP',
                  ),
                  const SizedBox(height: 24),

                  OutlinedButton.icon(
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Sign Out'),
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
