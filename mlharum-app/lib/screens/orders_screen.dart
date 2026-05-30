import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/farm_order.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../theme.dart';
import '../widgets/page_route.dart';
import 'order_detail_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  List<FarmOrder> _orders = [];
  bool _loading = true;
  String? _error;
  String _filter = 'all';
  late TabController _tabCtrl;

  static const _tabs = [
    ('all', 'All'),
    ('pending', 'Pending'),
    ('confirmed', 'Confirmed'),
    ('harvested', 'Harvested'),
    ('delivered', 'Delivered'),
    ('cancelled', 'Cancelled'),
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _tabs.length, vsync: this);
    _tabCtrl.addListener(() {
      if (!_tabCtrl.indexIsChanging) {
        setState(() => _filter = _tabs[_tabCtrl.index].$1);
      }
    });
    _load();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final farmId = await AuthService.getFarmId();
      if (farmId == null) {
        _error = 'No farm linked to your account.';
        return;
      }
      _orders = await ApiService.getFarmOrders(farmId);
    } catch (e) {
      _error = 'Failed to load orders.';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<FarmOrder> get _filtered => _filter == 'all'
      ? _orders
      : _orders.where((o) => o.status == _filter).toList();

  int _count(String status) =>
      _orders.where((o) => o.status == status).length;

  @override
  Widget build(BuildContext context) {
    final pendingCount = _count('pending');

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: Row(children: [
          const Text('Incoming Orders'),
          if (pendingCount > 0) ...[
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$pendingCount new',
                style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              ),
            ),
          ],
        ]),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabCtrl,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle:
              GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
          tabs: _tabs.map((t) {
            final count = t.$1 == 'all' ? _orders.length : _count(t.$1);
            return Tab(
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(t.$2),
                if (count > 0 && t.$1 != 'all') ...[
                  const SizedBox(width: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: t.$1 == 'pending'
                          ? kAmber
                          : Colors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('$count',
                        style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                  ),
                ],
              ]),
            );
          }).toList(),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: kGreenPrimary))
          : _error != null
              ? Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                      Text(_error!,
                          style: GoogleFonts.poppins(color: kText2)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                          onPressed: _load, child: const Text('Retry')),
                    ]))
              : RefreshIndicator(
                  onRefresh: _load,
                  color: kGreenPrimary,
                  child: _filtered.isEmpty
                      ? ListView(
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.5,
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('📦',
                                        style: TextStyle(fontSize: 48)),
                                    const SizedBox(height: 16),
                                    Text(
                                        _filter == 'all'
                                            ? 'No orders yet'
                                            : 'No ${_filter} orders',
                                        style: GoogleFonts.poppins(
                                            fontSize: 16, color: kText2)),
                                    const SizedBox(height: 6),
                                    Text(
                                        'Orders from buyers will appear here.',
                                        style: GoogleFonts.poppins(
                                            fontSize: 13, color: kText3)),
                                  ]),
                            ),
                          ],
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(20),
                          itemCount: _filtered.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (ctx, i) => _OrderTile(
                            order: _filtered[i],
                            onStatusChanged: (updated) {
                              setState(() {
                                final idx =
                                    _orders.indexWhere((o) => o.id == updated.id);
                                if (idx != -1) _orders[idx] = updated;
                              });
                            },
                          ),
                        ),
                ),
    );
  }
}

// ── Order tile ────────────────────────────────────────────────────────────────

class _OrderTile extends StatelessWidget {
  final FarmOrder order;
  final ValueChanged<FarmOrder> onStatusChanged;

  const _OrderTile(
      {required this.order, required this.onStatusChanged});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('d MMM yyyy');
    return GestureDetector(
      onTap: () async {
        HapticFeedback.lightImpact();
        final updated = await Navigator.push<FarmOrder>(
          context,
          FadeSlideRoute(
              page: OrderDetailScreen(
                  order: order, onStatusChanged: onStatusChanged)),
        );
        if (updated != null) onStatusChanged(updated);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(16),
          boxShadow: kCardShadow,
          border: order.status == 'pending'
              ? Border.all(color: kAmber.withValues(alpha: 0.4), width: 1.5)
              : null,
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
              child: Text(
                order.buyerName,
                style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: kText1),
              ),
            ),
            _StatusBadge(status: order.status),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            Text(
              '${order.quantityKg} kg  ·  RM ${order.totalPrice.toStringAsFixed(2)}',
              style: GoogleFonts.poppins(fontSize: 13, color: kText2),
            ),
            const Spacer(),
            if (order.billplzPaid)
              Row(children: [
                const Icon(Icons.check_circle_rounded,
                    size: 14, color: kGreenMid),
                const SizedBox(width: 4),
                Text('Paid',
                    style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: kGreenMid)),
              ])
            else
              Text('Unpaid',
                  style:
                      GoogleFonts.poppins(fontSize: 11, color: kText3)),
          ]),
          const SizedBox(height: 6),
          Text(
            'Ordered ${fmt.format(order.createdAt)}',
            style: GoogleFonts.poppins(fontSize: 11, color: kText3),
          ),
        ]),
      ),
    );
  }
}

// ── Status badge ──────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color, bg) = switch (status) {
      'pending'   => ('Pending', kAmber, const Color(0xFFFEF3C7)),
      'confirmed' => ('Confirmed', const Color(0xFF0369A1), const Color(0xFFE0F2FE)),
      'harvested' => ('Harvested', kGreenMid, kGreenLight),
      'delivered' => ('Delivered', const Color(0xFF7C3AED), const Color(0xFFEDE9FE)),
      'cancelled' => ('Cancelled', kRed, const Color(0xFFFEE2E2)),
      _           => (status, kText2, const Color(0xFFF3F4F6)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: GoogleFonts.poppins(
              fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    );
  }
}
