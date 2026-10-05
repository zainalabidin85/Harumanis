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
  String _version     = '';

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
    final info = await PackageInfo.fromPlatform();
    _version = info.version;
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
          ? context.l10n.profileSessionExpiredRelogin
          : context.l10n.profileErrorLoadStatus('$status');
    } catch (e) {
      _error = context.l10n.profileErrorLoad(e.toString());
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
          ? context.l10n.profileSessionExpired
          : context.l10n.profileErrorUpdateStatus('$status');
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
          SnackBar(content: Text(context.l10n.commonErrorWithDetail(e.toString()), style: GoogleFonts.poppins()),
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
          content: Text(context.l10n.profileErrorSavePriceStatus('$status'),
              style: GoogleFonts.poppins()),
          backgroundColor: kRed,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(context.l10n.commonErrorWithDetail(e.toString()), style: GoogleFonts.poppins()),
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
      if (mounted) setState(() => _success = context.l10n.profileSaved);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final detail = e.response?.data is Map
          ? (e.response!.data as Map)['detail']?.toString()
          : null;
      final msg = status == 401
          ? context.l10n.profileSessionExpiredRelogin
          : context.l10n.profileErrorSaveStatus('$status${detail != null ? ': $detail' : ''}');
      if (mounted) setState(() => _error = msg);
    } catch (e) {
      if (mounted) setState(() => _error = context.l10n.profileErrorSave(e.toString()));
    } finally {
      if (mounted) setState(() => _saving = false);
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
                    ? const Icon(Icons.check_rounded, color: kGreenPrimary)
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
                    child: Text(context.l10n.profileFarmerAccount,
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
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _phoneCtrl,
                          decoration: InputDecoration(
                            labelText: context.l10n.profilePhoneLabel,
                            prefixIcon: Icon(Icons.phone_outlined),
                            hintText: context.l10n.profilePhoneHint,
                          ),
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 14),

                        // ── WhatsApp ─────────────────────────────────────
                        TextField(
                          controller: _whatsappCtrl,
                          decoration: InputDecoration(
                            labelText: context.l10n.profileWhatsappLabel,
                            prefixIcon: const Icon(Icons.chat_outlined),
                            hintText: context.l10n.profileWhatsappHint,
                            helperText: context.l10n.profileVisibleToBuyers,
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
                  const SizedBox(height: 16),

                  // ── Language ─────────────────────────────────────────────
                  Container(
                    decoration: BoxDecoration(
                      color: kCard,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: kCardShadow,
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.language_rounded, color: kGreenPrimary),
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
                            Text(context.l10n.profileFarmInfo,
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
                                child: Text(context.l10n.profileNotSetUp,
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
                          decoration: InputDecoration(
                            labelText: context.l10n.profileFarmNameLabel,
                            prefixIcon: Icon(Icons.agriculture_outlined),
                          ),
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _farmLocCtrl,
                          decoration: InputDecoration(
                            labelText: context.l10n.profileLocationLabel,
                            prefixIcon: Icon(Icons.location_on_outlined),
                            hintText: context.l10n.profileLocationHint,
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
                          Text('Beli Harumanis',
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
                                  Text(context.l10n.profileListOnBeli,
                                      style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: kText1)),
                                  const SizedBox(height: 2),
                                  Text(
                                    _isPublic
                                        ? context.l10n.profileListedPublic
                                        : context.l10n.profileListedPrivate,
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
                                  decoration: InputDecoration(
                                    labelText: context.l10n.profilePricePerKgLabel,
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
                                      child: Text(context.l10n.commonSave,
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
                                  context.l10n.profileSetPriceHint,
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
                        Text(context.l10n.profileBankDetails,
                            style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: kText1)),
                        const SizedBox(height: 4),
                        Text(context.l10n.profileBankDetailsSubtitle,
                            style: GoogleFonts.poppins(
                                fontSize: 12, color: kText2)),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _bankNameCtrl,
                          decoration: InputDecoration(
                            labelText: context.l10n.profileBankNameLabel,
                            prefixIcon: Icon(Icons.account_balance_outlined),
                            hintText: context.l10n.profileBankNameHint,
                          ),
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _bankAccountNumCtrl,
                          decoration: InputDecoration(
                            labelText: context.l10n.profileAccountNumberLabel,
                            prefixIcon: Icon(Icons.numbers_rounded),
                            hintText: context.l10n.profileAccountNumberHint,
                          ),
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _bankAccountNameCtrl,
                          decoration: InputDecoration(
                            labelText: context.l10n.profileAccountHolderLabel,
                            prefixIcon: Icon(Icons.badge_outlined),
                            hintText: context.l10n.profileAccountHolderHint,
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
                        : Text(context.l10n.profileSaveButton),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Ai-Harumanis v$_version',
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
