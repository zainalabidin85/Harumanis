import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameCtrl           = TextEditingController();
  final _phoneCtrl          = TextEditingController();
  final _whatsappCtrl       = TextEditingController();
  final _farmNameCtrl       = TextEditingController();
  final _farmLocCtrl        = TextEditingController();
  final _priceCtrl          = TextEditingController();
  final _bankNameCtrl       = TextEditingController();
  final _bankAccountNumCtrl = TextEditingController();
  final _bankAccountNameCtrl = TextEditingController();

  bool _loading       = true;
  bool _saving        = false;
  bool _isPublic      = false;
  bool _toggleLoading = false;
  double? _pricePerKg;
  bool _priceSaving   = false;
  int? _farmId;
  String? _error;
  String? _success;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _whatsappCtrl.dispose();
    _farmNameCtrl.dispose();
    _farmLocCtrl.dispose();
    _priceCtrl.dispose();
    _bankNameCtrl.dispose();
    _bankAccountNumCtrl.dispose();
    _bankAccountNameCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final me = await ApiService.getMe();
      _nameCtrl.text             = me['name']                as String? ?? '';
      _phoneCtrl.text            = me['phone']               as String? ?? '';
      _whatsappCtrl.text         = me['whatsapp']            as String? ?? '';
      _bankNameCtrl.text         = me['bank_name']           as String? ?? '';
      _bankAccountNumCtrl.text   = me['bank_account_number'] as String? ?? '';
      _bankAccountNameCtrl.text  = me['bank_account_name']   as String? ?? '';
      _farmId = me['farm_id'] as int?;
      if (_farmId != null) {
        await AuthService.saveFarmId(_farmId!);
        final farm = await ApiService.getFarm(_farmId!);
        _farmNameCtrl.text = farm['name']     as String? ?? '';
        _farmLocCtrl.text  = farm['location'] as String? ?? '';
        _isPublic   = farm['is_public']   as bool?   ?? false;
        _pricePerKg = (farm['price_per_kg'] as num?)?.toDouble();
        if (_pricePerKg != null && _pricePerKg! > 0) {
          _priceCtrl.text = _pricePerKg!.toStringAsFixed(2);
        }
      }
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      _error = status == 401
          ? 'Session expired. Please log out and log in again.'
          : 'Failed to load profile (error $status).';
    } catch (e) {
      _error = 'Failed to load profile: $e';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggleVisibility(bool value) async {
    if (_farmId == null) return;
    setState(() { _toggleLoading = true; _isPublic = value; });
    try {
      await ApiService.updateFarm(_farmId!, isPublic: value);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final msg = status == 401
          ? 'Session expired. Please log in again.'
          : 'Failed to update (error $status).';
      if (mounted) {
        setState(() => _isPublic = !value);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg, style: GoogleFonts.poppins()),
              backgroundColor: kRed),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isPublic = !value);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e', style: GoogleFonts.poppins()),
              backgroundColor: kRed),
        );
      }
    } finally {
      if (mounted) setState(() => _toggleLoading = false);
    }
  }

  Future<void> _savePrice() async {
    final price = double.tryParse(_priceCtrl.text);
    if (price == null || price <= 0 || _farmId == null) return;
    setState(() => _priceSaving = true);
    try {
      await ApiService.updateFarm(_farmId!, pricePerKg: price);
      if (mounted) setState(() => _pricePerKg = price);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to save price (error $status).',
              style: GoogleFonts.poppins()),
          backgroundColor: kRed,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e', style: GoogleFonts.poppins()),
          backgroundColor: kRed,
        ));
      }
    } finally {
      if (mounted) setState(() => _priceSaving = false);
    }
  }

  Future<void> _save() async {
    HapticFeedback.mediumImpact();
    setState(() { _saving = true; _error = null; _success = null; });
    try {
      await ApiService.updateMe(
        name:               _nameCtrl.text.trim().isEmpty             ? null : _nameCtrl.text.trim(),
        phone:              _phoneCtrl.text.trim().isEmpty            ? null : _phoneCtrl.text.trim(),
        whatsapp:           _whatsappCtrl.text.trim().isEmpty         ? null : _whatsappCtrl.text.trim(),
        bankName:           _bankNameCtrl.text.trim().isEmpty         ? null : _bankNameCtrl.text.trim(),
        bankAccountNumber:  _bankAccountNumCtrl.text.trim().isEmpty   ? null : _bankAccountNumCtrl.text.trim(),
        bankAccountName:    _bankAccountNameCtrl.text.trim().isEmpty  ? null : _bankAccountNameCtrl.text.trim(),
      );
      if (_farmNameCtrl.text.trim().isNotEmpty) {
        if (_farmId == null) {
          final newId = await ApiService.createFarm(
            _farmNameCtrl.text.trim(),
            _farmLocCtrl.text.trim(),
          );
          await AuthService.saveFarmId(newId);
          if (mounted) setState(() => _farmId = newId);
        } else {
          await ApiService.updateFarm(
            _farmId!,
            name:     _farmNameCtrl.text.trim(),
            location: _farmLocCtrl.text.trim().isEmpty ? null : _farmLocCtrl.text.trim(),
          );
        }
      }
      if (mounted) setState(() => _success = 'Profile saved.');
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final detail = e.response?.data is Map
          ? (e.response!.data as Map)['detail']?.toString()
          : null;
      final msg = status == 401
          ? 'Session expired. Please log out and log in again.'
          : 'Failed to save (error $status${detail != null ? ': $detail' : ''}).';
      if (mounted) setState(() => _error = msg);
    } catch (e) {
      if (mounted) setState(() => _error = 'Failed to save: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
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
          ? const Center(child: CircularProgressIndicator(color: kGreenPrimary))
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Avatar ──────────────────────────────────────────────
                  Center(
                    child: Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        color: kGreenLight,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: kGreenMid.withValues(alpha: 0.3), width: 2),
                      ),
                      child: const Center(
                          child: Text('🌿', style: TextStyle(fontSize: 38))),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text('Farmer Account',
                        style: GoogleFonts.poppins(
                            fontSize: 13, color: kText2)),
                  ),
                  const SizedBox(height: 28),

                  // ── Form ────────────────────────────────────────────────
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

                        // ── WhatsApp ─────────────────────────────────────
                        TextField(
                          controller: _whatsappCtrl,
                          decoration: InputDecoration(
                            labelText: 'WhatsApp number',
                            prefixIcon: const Icon(Icons.chat_outlined),
                            hintText: 'e.g. 60123456789',
                            helperText:
                                'Buyers contact you here after placing an order',
                            helperStyle:
                                GoogleFonts.poppins(fontSize: 11, color: kText3),
                            suffixIcon: _whatsappCtrl.text.isNotEmpty
                                ? const Icon(Icons.check_circle_rounded,
                                    color: kGreenMid, size: 20)
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

                  // ── Farm Info ────────────────────────────────────────────
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
                        Row(
                          children: [
                            Text('Farm Info',
                                style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: kText1)),
                            if (_farmId == null) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: kOrange.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text('Not set up',
                                    style: GoogleFonts.poppins(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: kOrange)),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _farmNameCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Farm Name',
                            prefixIcon: Icon(Icons.agriculture_outlined),
                          ),
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _farmLocCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Location',
                            prefixIcon: Icon(Icons.location_on_outlined),
                            hintText: 'e.g. Perlis, Malaysia',
                          ),
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _save(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Marketplace toggle ───────────────────────────────────
                  if (_farmId != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: kCard,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: kCardShadow,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Marketplace',
                              style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: kText1)),
                          const SizedBox(height: 16),
                          Row(children: [
                            Container(
                              width: 44, height: 44,
                              decoration: BoxDecoration(
                                color: _isPublic
                                    ? const Color(0xFFFEF3C7)
                                    : const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.storefront_rounded,
                                color: _isPublic
                                    ? const Color(0xFFB45309)
                                    : kText3,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('List on Harumanis',
                                      style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: kText1)),
                                  const SizedBox(height: 2),
                                  Text(
                                    _isPublic
                                        ? 'Buyers can see and order your fruit'
                                        : 'Your farm is private',
                                    style: GoogleFonts.poppins(
                                        fontSize: 12, color: kText2),
                                  ),
                                ],
                              ),
                            ),
                            _toggleLoading
                                ? const SizedBox(
                                    width: 24, height: 24,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: kGreenPrimary))
                                : Switch.adaptive(
                                    value: _isPublic,
                                    onChanged: _toggleVisibility,
                                    activeTrackColor: const Color(0xFFB45309),
                                  ),
                          ]),
                          if (_isPublic) ...[
                            const Divider(height: 24),
                            Row(children: [
                              Expanded(
                                child: TextField(
                                  controller: _priceCtrl,
                                  decoration: const InputDecoration(
                                    labelText: 'Price per kg (RM)',
                                    prefixText: 'RM ',
                                    prefixIcon: Icon(Icons.sell_rounded),
                                    isDense: true,
                                  ),
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                ),
                              ),
                              const SizedBox(width: 10),
                              _priceSaving
                                  ? const SizedBox(
                                      width: 36, height: 36,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2, color: kGreenPrimary))
                                  : TextButton(
                                      onPressed: _savePrice,
                                      child: Text('Save',
                                          style: GoogleFonts.poppins(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: kGreenPrimary)),
                                    ),
                            ]),
                            if (_pricePerKg == null || _pricePerKg! <= 0)
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  'Set your price so buyers can place orders.',
                                  style: GoogleFonts.poppins(
                                      fontSize: 11, color: kOrange),
                                ),
                              ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // ── WhatsApp info card ───────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: kGreenLight,
                      borderRadius: BorderRadius.circular(14),
                      border:
                          Border.all(color: kGreenMid.withValues(alpha: 0.25)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline_rounded,
                            color: kGreenPrimary, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Your WhatsApp number is shown to buyers in the Harumanis app so they can contact you directly after placing an order.',
                            style: GoogleFonts.poppins(
                                fontSize: 12, color: kGreenPrimary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Bank Details ─────────────────────────────────────────
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
                        Text('Bank Details',
                            style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: kText1)),
                        const SizedBox(height: 4),
                        Text('Used for receiving payouts from Harumanis sales.',
                            style: GoogleFonts.poppins(
                                fontSize: 12, color: kText2)),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _bankNameCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Bank Name',
                            prefixIcon: Icon(Icons.account_balance_outlined),
                            hintText: 'e.g. Maybank',
                          ),
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _bankAccountNumCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Account Number',
                            prefixIcon: Icon(Icons.numbers_rounded),
                            hintText: 'e.g. 1234567890',
                          ),
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _bankAccountNameCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Account Holder Name',
                            prefixIcon: Icon(Icons.badge_outlined),
                            hintText: 'Name as on bank card',
                          ),
                          textCapitalization: TextCapitalization.characters,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _save(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Feedback messages ───────────────────────────────────
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
                                color: kGreenLight,
                                border: kGreenMid,
                                icon: Icons.check_circle_outline_rounded,
                                iconColor: kGreenPrimary,
                                textColor: kGreenPrimary,
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
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Ai-Harumanis v1.5.1',
                      style: GoogleFonts.poppins(fontSize: 12, color: kText3),
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
