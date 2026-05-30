import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
import '../theme.dart';

class PayoutsScreen extends StatefulWidget {
  const PayoutsScreen({super.key});
  @override
  State<PayoutsScreen> createState() => _PayoutsScreenState();
}

class _PayoutsScreenState extends State<PayoutsScreen> {
  List<dynamic> _payouts = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      _payouts = await ApiService.getPayouts();
    } on DioException catch (e) {
      _error = 'Failed (error ${e.response?.statusCode}).';
    } catch (e) {
      _error = 'Error: $e';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showPayout(Map<String, dynamic> order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _PayoutSheet(order: order, onDone: _load),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Text(_error!, style: GoogleFonts.poppins(color: kRed)));

    if (_payouts.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.check_circle_outline_rounded, size: 56, color: kGreen),
          const SizedBox(height: 12),
          Text('All payouts complete!', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: kText1)),
          const SizedBox(height: 4),
          Text('No pending farmer payouts.', style: GoogleFonts.poppins(fontSize: 13, color: kText3)),
        ]),
      );
    }

    final totalAmount = _payouts.fold<double>(
        0, (sum, o) => sum + (o['total_price'] as num).toDouble() * 0.98);

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kIndigo700, borderRadius: BorderRadius.circular(16),
            ),
            child: Row(children: [
              const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${_payouts.length} payouts pending',
                    style: GoogleFonts.poppins(fontSize: 13, color: Colors.white70)),
                Text('RM ${totalAmount.toStringAsFixed(2)}',
                    style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
              ]),
            ]),
          ),
          const SizedBox(height: 16),
          ...(_payouts.map((o) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _PayoutTile(order: o as Map<String, dynamic>, onTap: () => _showPayout(o)),
          ))),
        ],
      ),
    );
  }
}

class _PayoutTile extends StatelessWidget {
  final Map<String, dynamic> order;
  final VoidCallback onTap;
  const _PayoutTile({required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final net = (order['total_price'] as num).toDouble() * 0.98;
    final bankName = order['farmer_bank_name'] as String? ?? '—';
    final accountNum = order['farmer_bank_account_number'] as String? ?? '—';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(14), boxShadow: kCardShadow),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(order['farm_name'] as String,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14, color: kText1)),
              const SizedBox(height: 2),
              Text('$bankName · $accountNum',
                  style: GoogleFonts.poppins(fontSize: 12, color: kText3)),
              const SizedBox(height: 2),
              Text('Order #${order['id']} · ${(order['quantity_kg'] as num).toStringAsFixed(1)} kg',
                  style: GoogleFonts.poppins(fontSize: 12, color: kText3)),
            ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('RM ${net.toStringAsFixed(2)}',
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: kIndigo700)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: kOrange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
              child: Text('PENDING', style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: kOrange)),
            ),
          ]),
        ]),
      ),
    );
  }
}

class _PayoutSheet extends StatefulWidget {
  final Map<String, dynamic> order;
  final VoidCallback onDone;
  const _PayoutSheet({required this.order, required this.onDone});
  @override
  State<_PayoutSheet> createState() => _PayoutSheetState();
}

class _PayoutSheetState extends State<_PayoutSheet> {
  final _refCtrl = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() { _refCtrl.dispose(); super.dispose(); }

  Future<void> _record() async {
    if (_refCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Please enter the transfer reference number.');
      return;
    }
    setState(() { _saving = true; _error = null; });
    try {
      await ApiService.recordPayout(widget.order['id'] as int, _refCtrl.text.trim());
      if (mounted) { Navigator.pop(context); widget.onDone(); }
    } on DioException catch (e) {
      final detail = e.response?.data is Map ? e.response!.data['detail'] : null;
      setState(() { _error = detail ?? 'Failed (error ${e.response?.statusCode}).'; _saving = false; });
    } catch (e) {
      setState(() { _error = 'Error: $e'; _saving = false; });
    }
  }

  void _openInvoice() {
    final url = ApiService.payoutInvoiceUrl(widget.order['id'] as int);
    launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final gross = (order['total_price'] as num).toDouble();
    final fee   = gross * 0.02;
    final net   = gross - fee;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text('Payout · Order #${order['id']}',
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: kText1)),
          const Spacer(),
          IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
        ]),
        const Divider(height: 20),
        _row('Farmer', order['farm_name'] as String),
        _row('Bank', order['farmer_bank_name'] as String? ?? '—'),
        _row('Account No.', order['farmer_bank_account_number'] as String? ?? '—'),
        _row('Account Name', order['farmer_bank_account_name'] as String? ?? '—'),
        const Divider(height: 20),
        _row('Buyer paid', 'RM ${gross.toStringAsFixed(2)}'),
        _row('Platform fee (2%)', '− RM ${fee.toStringAsFixed(2)}'),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(color: kIndigo50, borderRadius: BorderRadius.circular(10)),
          child: Row(children: [
            Text('Net payout to farmer',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: kIndigo700)),
            const Spacer(),
            Text('RM ${net.toStringAsFixed(2)}',
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: kIndigo700)),
          ]),
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onLongPress: () {
            Clipboard.setData(ClipboardData(text: order['farmer_bank_account_number'] as String? ?? ''));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Account number copied')));
          },
          child: TextField(
            controller: _refCtrl,
            decoration: const InputDecoration(
              labelText: 'Transfer Reference No.',
              prefixIcon: Icon(Icons.tag_rounded),
              hintText: 'e.g. DuitNow ref or bank transaction ID',
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _record(),
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 8),
          Text(_error!, style: GoogleFonts.poppins(fontSize: 13, color: kRed)),
        ],
        const SizedBox(height: 16),
        Row(children: [
          Expanded(
            child: ElevatedButton(
              onPressed: _saving ? null : _record,
              child: _saving
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                  : const Text('Mark as Paid'),
            ),
          ),
          const SizedBox(width: 10),
          OutlinedButton(
            onPressed: _openInvoice,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              side: const BorderSide(color: kIndigo700),
            ),
            child: const Icon(Icons.open_in_new_rounded, color: kIndigo700, size: 18),
          ),
        ]),
      ]),
    );
  }

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(children: [
      SizedBox(width: 120, child: Text(label, style: GoogleFonts.poppins(fontSize: 13, color: kText3))),
      Expanded(child: Text(value, style: GoogleFonts.poppins(fontSize: 13, color: kText1))),
    ]),
  );
}
