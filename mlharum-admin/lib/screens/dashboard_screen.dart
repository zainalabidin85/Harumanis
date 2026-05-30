import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? _stats;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      _stats = await ApiService.getStats();
    } on DioException catch (e) {
      _error = 'Failed to load (error ${e.response?.statusCode}).';
    } catch (e) {
      _error = 'Error: $e';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Text(_error!, style: GoogleFonts.poppins(color: kRed)));
    final s = _stats!;

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _section('Users', [
            _StatCard('Total Users',    '${s['total_users']}',    Icons.people_rounded,      kIndigo700),
            _StatCard('Farmers',         '${s['farmers']}',        Icons.agriculture_rounded, kGreen),
            _StatCard('Buyers',          '${s['buyers']}',         Icons.shopping_bag_rounded, kOrange),
            _StatCard('Suspended',       '${s['suspended']}',      Icons.block_rounded,        kRed),
          ]),
          const SizedBox(height: 20),
          _section('Farms & Orders', [
            _StatCard('Total Farms',    '${s['total_farms']}',    Icons.map_rounded,          kIndigo500),
            _StatCard('Public Farms',   '${s['public_farms']}',   Icons.storefront_rounded,   kGreen),
            _StatCard('Total Orders',   '${s['total_orders']}',   Icons.receipt_rounded,      kIndigo700),
            _StatCard('Pending Orders', '${s['pending_orders']}', Icons.pending_rounded,      kOrange),
          ]),
          const SizedBox(height: 20),
          _section('Revenue', [
            _StatCard('Total Revenue',    'RM ${(s['revenue_total'] as num).toStringAsFixed(2)}',    Icons.attach_money_rounded, kGreen),
            _StatCard('Payouts Pending',  '${s['payout_pending_count']}',                             Icons.hourglass_top_rounded, kOrange),
            _StatCard('Payout Amount',    'RM ${(s['payout_pending_amount'] as num).toStringAsFixed(2)}', Icons.account_balance_wallet_rounded, kRed),
          ]),
        ],
      ),
    );
  }

  Widget _section(String title, List<Widget> cards) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: kText3,
          letterSpacing: 0.5)),
      const SizedBox(height: 10),
      GridView.count(
        crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.6,
        children: cards,
      ),
    ],
  );
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatCard(this.label, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCard, borderRadius: BorderRadius.circular(16), boxShadow: kCardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 22),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: kText1)),
              Text(label, style: GoogleFonts.poppins(fontSize: 11, color: kText3)),
            ],
          ),
        ],
      ),
    );
  }
}
