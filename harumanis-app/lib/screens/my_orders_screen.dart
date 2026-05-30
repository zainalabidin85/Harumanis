import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/order.dart';
import '../services/api_service.dart';
import '../theme.dart';
import '../widgets/page_route.dart';
import '../widgets/stage_badge.dart';
import 'order_detail_screen.dart';

class MyOrdersScreen extends StatefulWidget {
  final int? paymentOrderId;
  const MyOrdersScreen({super.key, this.paymentOrderId});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  List<Order> _orders = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load(showSuccessBanner: widget.paymentOrderId != null);
  }

  Future<void> _load({bool showSuccessBanner = false}) async {
    setState(() { _loading = true; _error = null; });
    try {
      _orders = await ApiService.getMyOrders();
      if (showSuccessBanner && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Payment confirmed! Your order is now active.',
                    style: GoogleFonts.poppins(fontSize: 13),
                  ),
                ),
              ]),
              backgroundColor: kGreen,
              duration: const Duration(seconds: 4),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        });
      }
    } catch (e) {
      _error = 'Failed to load orders.';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: const Text('My Orders'),
        backgroundColor: kAmberPrimary,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(_error!, style: GoogleFonts.poppins(color: kText2)),
                    const SizedBox(height: 16),
                    ElevatedButton(onPressed: _load, child: const Text('Retry')),
                  ]),
                )
              : _orders.isEmpty
                  ? Center(
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        const Text('🛍️', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 16),
                        Text('No orders yet',
                            style: GoogleFonts.poppins(fontSize: 16, color: kText2)),
                        const SizedBox(height: 6),
                        Text('Browse farms and place your first order!',
                            style: GoogleFonts.poppins(fontSize: 13, color: kText3)),
                      ]),
                    )
                  : RefreshIndicator(
                      onRefresh: _load,
                      color: kAmberPrimary,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(20),
                        itemCount: _orders.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (ctx, i) => _OrderTile(order: _orders[i]),
                      ),
                    ),
    );
  }
}

class _OrderTile extends StatelessWidget {
  final Order order;
  const _OrderTile({required this.order});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('d MMM yyyy');
    return GestureDetector(
      onTap: () => Navigator.push(
          context, FadeSlideRoute(page: OrderDetailScreen(order: order))),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: kCard, borderRadius: BorderRadius.circular(16), boxShadow: kCardShadow),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
              child: Text(order.farmName,
                  style: GoogleFonts.poppins(
                      fontSize: 14, fontWeight: FontWeight.w600, color: kText1)),
            ),
            StatusBadge(status: order.status),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            Text('${order.quantityKg} kg · RM ${order.totalPrice.toStringAsFixed(2)}',
                style: GoogleFonts.poppins(fontSize: 13, color: kText2)),
            const Spacer(),
            Text(fmt.format(order.createdAt),
                style: GoogleFonts.poppins(fontSize: 11, color: kText3)),
          ]),
          if (!order.billplzPaid && order.status == 'confirmed')
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: kAmberLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(children: [
                  const Icon(Icons.payment_rounded, color: kAmberPrimary, size: 14),
                  const SizedBox(width: 6),
                  Text('Payment pending — tap to pay',
                      style: GoogleFonts.poppins(
                          fontSize: 11, color: kAmberPrimary, fontWeight: FontWeight.w500)),
                ]),
              ),
            ),
        ]),
      ),
    );
  }
}
