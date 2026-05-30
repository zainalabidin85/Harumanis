import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/farm.dart';
import '../services/api_service.dart';
import '../theme.dart';
import '../widgets/page_route.dart';
import 'order_detail_screen.dart';

class OrderScreen extends StatefulWidget {
  final FarmDetail farm;
  const OrderScreen({super.key, required this.farm});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final _qtyCtrl   = TextEditingController(text: '10');
  final _notesCtrl = TextEditingController();
  DateTime? _targetDate;
  bool _loading = false;
  String? _error;

  double get _qty        => double.tryParse(_qtyCtrl.text) ?? 0;
  double get _basePrice  => widget.farm.pricePerKg ?? 0;
  double get _price      => _basePrice * (1 + kPlatformFeeRate);
  double get _total      => _qty * _price;

  @override
  void dispose() {
    _qtyCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.farm.earliestHarvestDate ?? DateTime.now().add(const Duration(days: 14)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 180)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: kAmberPrimary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _targetDate = picked);
  }

  Future<void> _submit() async {
    if (_qty <= 0) {
      setState(() => _error = 'Please enter a valid quantity.');
      return;
    }
    if (_price <= 0) {
      setState(() => _error = 'This farm has not set a price yet.');
      return;
    }
    HapticFeedback.mediumImpact();
    setState(() { _loading = true; _error = null; });
    try {
      final order = await ApiService.createOrder(
        farmId: widget.farm.farmId,
        quantityKg: _qty,
        targetHarvestDate: _targetDate,
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      );
      if (mounted) {
        Navigator.pushReplacement(
            context, FadeSlideRoute(page: OrderDetailScreen(order: order, freshlyPlaced: true)));
      }
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'Failed to place order. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: const Text('Place Order'),
        backgroundColor: kAmberPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Farm summary ───────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                  color: kCard, borderRadius: BorderRadius.circular(20), boxShadow: kCardShadow),
              child: Row(children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                      color: kAmberLight, borderRadius: BorderRadius.circular(14)),
                  child: const Center(child: Text('🥭', style: TextStyle(fontSize: 22))),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(widget.farm.farmName,
                        style: GoogleFonts.poppins(
                            fontSize: 15, fontWeight: FontWeight.w600, color: kText1)),
                    Text('${widget.farm.totalActiveFruits} fruits available · ${widget.farm.farmerName}',
                        style: GoogleFonts.poppins(fontSize: 12, color: kText2)),
                  ]),
                ),
              ]),
            ),
            const SizedBox(height: 20),

            // ── Order form ─────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                  color: kCard, borderRadius: BorderRadius.circular(20), boxShadow: kCardShadow),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Order Details',
                    style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: kText1)),
                const SizedBox(height: 16),
                TextField(
                  controller: _qtyCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Quantity (kg)',
                    prefixIcon: Icon(Icons.scale_outlined),
                    suffixText: 'kg',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    border: Border.all(color: kDivider),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(children: [
                    const Icon(Icons.sell_rounded, color: kText2, size: 20),
                    const SizedBox(width: 12),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Price per kg',
                          style: GoogleFonts.poppins(fontSize: 14, color: kText2)),
                      Text('incl. 2% platform fee',
                          style: GoogleFonts.poppins(fontSize: 11, color: kText3)),
                    ]),
                    const Spacer(),
                    Text(
                      _price > 0 ? 'RM ${_price.toStringAsFixed(2)} / kg' : 'Not set',
                      style: GoogleFonts.poppins(
                          fontSize: 14, fontWeight: FontWeight.w600,
                          color: _price > 0 ? kText1 : kRed),
                    ),
                  ]),
                ),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      border: Border.all(color: kDivider),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(children: [
                      const Icon(Icons.calendar_today_outlined, color: kText2, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _targetDate != null
                              ? 'Target harvest: ${DateFormat('d MMM yyyy').format(_targetDate!)}'
                              : 'Target harvest date (optional)',
                          style: GoogleFonts.poppins(
                              fontSize: 14, color: _targetDate != null ? kText1 : kText3),
                        ),
                      ),
                      if (_targetDate != null)
                        GestureDetector(
                          onTap: () => setState(() => _targetDate = null),
                          child: const Icon(Icons.close, color: kText3, size: 18),
                        ),
                    ]),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _notesCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Notes to farmer (optional)',
                    prefixIcon: Icon(Icons.notes_rounded),
                  ),
                  maxLines: 2,
                ),
              ]),
            ),
            const SizedBox(height: 14),

            // ── Total ──────────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: kAmberLight,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: kAmberMid.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total Amount',
                      style: GoogleFonts.poppins(
                          fontSize: 15, fontWeight: FontWeight.w600, color: kText1)),
                  Text('RM ${_total.toStringAsFixed(2)}',
                      style: GoogleFonts.poppins(
                          fontSize: 22, fontWeight: FontWeight.w700, color: kAmberPrimary)),
                ],
              ),
            ),
            const SizedBox(height: 14),

            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFECACA)),
                  ),
                  child: Text(_error!, style: GoogleFonts.poppins(color: kRed, fontSize: 13)),
                ),
              ),

            ElevatedButton(
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const SizedBox(height: 20, width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                  : const Text('Confirm Order'),
            ),

            const SizedBox(height: 12),
            Text(
              'Order is sent to the farmer for confirmation. Payment is done after farmer confirms.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 11, color: kText3),
            ),
          ],
        ),
      ),
    );
  }
}
