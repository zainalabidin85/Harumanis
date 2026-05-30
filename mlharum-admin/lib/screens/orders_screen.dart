import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../theme.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});
  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<dynamic> _orders = [];
  bool _loading = true;
  String? _error;
  String? _statusFilter;
  bool? _paidFilter;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      _orders = await ApiService.getOrders(status: _statusFilter, paid: _paidFilter);
    } on DioException catch (e) {
      _error = 'Failed (error ${e.response?.statusCode}).';
    } catch (e) {
      _error = 'Error: $e';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showDetail(Map<String, dynamic> order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _OrderSheet(order: order),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            for (final s in [null, 'pending', 'confirmed', 'harvested', 'delivered', 'cancelled']) ...[
              _statusChip(s == null ? 'All' : s[0].toUpperCase() + s.substring(1), s),
              const SizedBox(width: 6),
            ],
            const SizedBox(width: 8),
            FilterChip(
              label: const Text('Paid only'),
              selected: _paidFilter == true,
              onSelected: (v) { setState(() => _paidFilter = v ? true : null); _load(); },
              selectedColor: kGreen.withValues(alpha: 0.15),
              labelStyle: GoogleFonts.poppins(fontSize: 12,
                  color: _paidFilter == true ? kGreen : kText2),
            ),
          ]),
        ),
      ),
      Expanded(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text(_error!, style: GoogleFonts.poppins(color: kRed)))
                : _orders.isEmpty
                    ? Center(child: Text('No orders found.', style: GoogleFonts.poppins(color: kText3)))
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _orders.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (_, i) => _OrderTile(order: _orders[i], onTap: () => _showDetail(_orders[i])),
                        ),
                      ),
      ),
    ]);
  }

  Widget _statusChip(String label, String? value) {
    final selected = _statusFilter == value;
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) { setState(() => _statusFilter = value); _load(); },
      selectedColor: kIndigo100,
      labelStyle: GoogleFonts.poppins(fontSize: 12, color: selected ? kIndigo700 : kText2),
    );
  }
}

class _OrderTile extends StatelessWidget {
  final Map<String, dynamic> order;
  final VoidCallback onTap;
  const _OrderTile({required this.order, required this.onTap});

  Color _statusColor(String status) => switch (status) {
    'pending'   => kOrange,
    'confirmed' => kIndigo500,
    'harvested' => kIndigo700,
    'delivered' => kGreen,
    'cancelled' => kRed,
    _           => kText3,
  };

  @override
  Widget build(BuildContext context) {
    final status = order['status'] as String;
    final paid = order['billplz_paid'] as bool? ?? false;
    final date = order['created_at'] != null
        ? DateFormat('dd MMM yyyy').format(DateTime.parse(order['created_at'] as String))
        : '—';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(14), boxShadow: kCardShadow),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('#${order['id']} · ${order['farm_name']}',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13, color: kText1)),
              Text('${order['buyer_name']} · RM ${(order['total_price'] as num).toStringAsFixed(2)}',
                  style: GoogleFonts.poppins(fontSize: 12, color: kText3)),
              const SizedBox(height: 6),
              Row(children: [
                _badge(status, _statusColor(status)),
                const SizedBox(width: 6),
                _badge(paid ? 'Paid' : 'Unpaid', paid ? kGreen : kOrange),
                const Spacer(),
                Text(date, style: GoogleFonts.poppins(fontSize: 11, color: kText3)),
              ]),
            ]),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right_rounded, color: kText3),
        ]),
      ),
    );
  }

  Widget _badge(String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
    decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
    child: Text(text, style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
  );
}

class _OrderSheet extends StatelessWidget {
  final Map<String, dynamic> order;
  const _OrderSheet({required this.order});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.92,
      minChildSize: 0.4,
      expand: false,
      builder: (_, ctrl) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: ListView(controller: ctrl, children: [
          Row(children: [
            Text('Order #${order['id']}',
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: kText1)),
            const Spacer(),
            IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
          ]),
          const Divider(height: 20),
          _row('Farm', order['farm_name'] as String),
          _row('Buyer', '${order['buyer_name']} (${order['buyer_email']})'),
          _row('Quantity', '${(order['quantity_kg'] as num).toStringAsFixed(1)} kg'),
          _row('Price/kg', 'RM ${(order['price_per_kg'] as num).toStringAsFixed(2)}'),
          _row('Total', 'RM ${(order['total_price'] as num).toStringAsFixed(2)}'),
          _row('Status', (order['status'] as String).toUpperCase()),
          _row('Payment', (order['billplz_paid'] as bool? ?? false) ? 'Paid ✓' : 'Unpaid'),
          if (order['notes'] != null) _row('Notes', order['notes'] as String),
          if (order['target_harvest_date'] != null) _row('Target harvest', order['target_harvest_date'] as String),
        ]),
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(width: 110, child: Text(label, style: GoogleFonts.poppins(fontSize: 13, color: kText3))),
      Expanded(child: Text(value, style: GoogleFonts.poppins(fontSize: 13, color: kText1))),
    ]),
  );
}
