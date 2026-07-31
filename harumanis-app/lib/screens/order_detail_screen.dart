import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/order.dart';
import '../models/testimonial.dart';
import '../services/api_service.dart';
import '../theme.dart';
import '../widgets/stage_badge.dart';

class OrderDetailScreen extends StatefulWidget {
  final Order order;
  final bool freshlyPlaced;
  const OrderDetailScreen({super.key, required this.order, this.freshlyPlaced = false});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late Order _order;
  Testimonial? _myReview;
  bool _payLoading = false;
  bool _refreshing = false;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
    if (_order.status == 'delivered') {
      ApiService.getMyReview(_order.farmId).then((r) {
        if (mounted) setState(() => _myReview = r);
      });
    }
  }

  Future<void> _refresh() async {
    setState(() => _refreshing = true);
    try {
      final orders = await ApiService.getMyOrders();
      final updated = orders.firstWhere(
        (o) => o.id == _order.id,
        orElse: () => _order,
      );
      if (mounted) setState(() => _order = updated);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  Future<void> _pay() async {
    HapticFeedback.mediumImpact();
    setState(() => _payLoading = true);
    try {
      final data = await ApiService.initiatePayment(_order.id);
      final url = Uri.parse(data['payment_url'] as String);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Payment failed: $e',
                style: GoogleFonts.poppins(fontSize: 13))));
      }
    } finally {
      if (mounted) setState(() => _payLoading = false);
    }
  }

  Future<void> _showReviewSheet() async {
    final result = await showModalBottomSheet<Testimonial>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ReviewSheet(
        farmId: _order.farmId,
        existing: _myReview,
      ),
    );
    if (result != null && mounted) {
      setState(() => _myReview = result);
    }
  }

  Future<void> _openWhatsApp(String number) async {
    final cleaned = number.replaceAll(RegExp(r'[^\d+]'), '');
    final msg = Uri.encodeComponent(
        'Hi, I placed Order #${_order.id} for ${_order.quantityKg} kg of Harumanis from ${_order.farmName}.');
    final uri = Uri.parse('https://wa.me/$cleaned?text=$msg');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('d MMM yyyy');
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: Text('Order #${_order.id}'),
        backgroundColor: kAmberPrimary,
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: kAmberPrimary,
        child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          // ── Freshly placed banner ─────────────────────────────────────
          if (widget.freshlyPlaced) ...[
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: kGreen.withValues(alpha: 0.3)),
              ),
              child: Row(children: [
                const Icon(Icons.check_circle_rounded, color: kGreen, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Order placed!',
                        style: GoogleFonts.poppins(
                            fontSize: 14, fontWeight: FontWeight.w600, color: kGreen)),
                    Text('Waiting for farmer to confirm your order.',
                        style: GoogleFonts.poppins(fontSize: 12, color: kText2)),
                  ]),
                ),
              ]),
            ),
          ],

          // ── Status ────────────────────────────────────────────────────
          _Card(
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Status', style: GoogleFonts.poppins(fontSize: 14, color: kText2)),
              StatusBadge(status: _order.status),
            ]),
          ),
          const SizedBox(height: 12),

          // ── Timeline ──────────────────────────────────────────────────
          _OrderTimeline(order: _order),
          const SizedBox(height: 12),

          // ── Farm & farmer ─────────────────────────────────────────────
          _Card(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Farm', style: GoogleFonts.poppins(fontSize: 13, color: kText3)),
              const SizedBox(height: 4),
              Text(_order.farmName,
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.w600, color: kText1)),
            ]),
          ),
          const SizedBox(height: 12),

          // ── Order details ─────────────────────────────────────────────
          _Card(
            child: Column(children: [
              _Row(label: 'Quantity', value: '${_order.quantityKg} kg'),
              _Row(label: 'Price per kg', value: 'RM ${_order.pricePerKg.toStringAsFixed(2)}'),
              const Divider(height: 20),
              _Row(
                label: 'Total',
                value: 'RM ${_order.totalPrice.toStringAsFixed(2)}',
                bold: true,
              ),
              _Row(label: 'Payment', value: _order.billplzPaid ? 'Paid ✓' : 'Pending'),
              if (_order.targetHarvestDate != null)
                _Row(label: 'Target date', value: fmt.format(_order.targetHarvestDate!)),
              _Row(label: 'Ordered on', value: fmt.format(_order.createdAt)),
              if (_order.notes != null && _order.notes!.isNotEmpty) ...[
                const Divider(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Notes: ${_order.notes}',
                      style: GoogleFonts.poppins(fontSize: 13, color: kText2)),
                ),
              ],
            ]),
          ),
          const SizedBox(height: 20),

          // ── Pay button (if confirmed but not paid) ────────────────────
          if (_order.status == 'confirmed' && !_order.billplzPaid) ...[
            ElevatedButton.icon(
              icon: const Icon(Icons.payment_rounded),
              label: const Text('Pay Now'),
              onPressed: _payLoading ? null : _pay,
              style: ElevatedButton.styleFrom(backgroundColor: kGreen),
            ),
            const SizedBox(height: 12),
          ],

          // ── Review button ─────────────────────────────────────────────
          if (_order.status == 'delivered') ...[
            OutlinedButton.icon(
              icon: Icon(
                _myReview != null ? Icons.rate_review_rounded : Icons.reviews_rounded,
                color: kAmberPrimary,
              ),
              label: Text(
                _myReview != null ? 'Edit Your Review' : 'Leave a Review',
                style: GoogleFonts.poppins(
                    fontSize: 14, fontWeight: FontWeight.w600, color: kAmberPrimary),
              ),
              onPressed: _showReviewSheet,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: kAmberPrimary),
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            if (_myReview != null) ...[
              const SizedBox(height: 6),
              _Card(
                child: Row(children: [
                  Row(
                    children: List.generate(5, (i) => Icon(
                      i < _myReview!.rating ? Icons.star_rounded : Icons.star_outline_rounded,
                      size: 16,
                      color: i < _myReview!.rating ? const Color(0xFFF59E0B) : kText3,
                    )),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _myReview!.comment ?? 'No comment',
                      style: GoogleFonts.poppins(fontSize: 13, color: kText2),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ]),
              ),
            ],
            const SizedBox(height: 12),
          ],

          // ── WhatsApp button ───────────────────────────────────────────
          if (_order.status != 'cancelled') ...[
            if (_order.farmerWhatsapp != null &&
                _order.farmerWhatsapp!.isNotEmpty)
              OutlinedButton.icon(
                icon: const Icon(Icons.chat_rounded),
                label: const Text('Contact Farmer via WhatsApp'),
                onPressed: () => _openWhatsApp(_order.farmerWhatsapp!),
                style: OutlinedButton.styleFrom(
                  foregroundColor: kGreen,
                  side: const BorderSide(color: kGreen),
                  minimumSize: const Size.fromHeight(52),
                  shape:
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(children: [
                  const Icon(Icons.chat_outlined, color: kText3, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Farmer has not added a WhatsApp number yet.',
                      style: GoogleFonts.poppins(fontSize: 13, color: kText2),
                    ),
                  ),
                ]),
              ),
          ],
        ]),
      ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: kCard, borderRadius: BorderRadius.circular(16), boxShadow: kCardShadow),
      child: child,
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  const _Row({required this.label, required this.value, this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 13, color: kText2)),
        Text(value,
            style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
                color: bold ? kAmberPrimary : kText1)),
      ]),
    );
  }
}

// ── Order Timeline ────────────────────────────────────────────────────────────

class _OrderTimeline extends StatelessWidget {
  final Order order;
  const _OrderTimeline({required this.order});

  @override
  Widget build(BuildContext context) {
    final isCancelled = order.status == 'cancelled';

    final steps = isCancelled
        ? [
            _TimelineStep(
              icon: Icons.receipt_long_rounded,
              label: 'Order Placed',
              timestamp: order.createdAt,
              done: true,
            ),
            _TimelineStep(
              icon: Icons.cancel_rounded,
              label: 'Cancelled',
              timestamp: order.cancelledAt,
              done: true,
              color: const Color(0xFFEF4444),
            ),
          ]
        : [
            _TimelineStep(
              icon: Icons.receipt_long_rounded,
              label: 'Order Placed',
              timestamp: order.createdAt,
              done: true,
            ),
            _TimelineStep(
              icon: Icons.check_circle_rounded,
              label: 'Confirmed by Farmer',
              timestamp: order.confirmedAt,
              done: order.confirmedAt != null ||
                  ['confirmed', 'harvested', 'delivered'].contains(order.status),
            ),
            _TimelineStep(
              icon: Icons.payment_rounded,
              label: 'Payment Received',
              timestamp: order.paidAt,
              done: order.billplzPaid,
            ),
            _TimelineStep(
              icon: Icons.agriculture_rounded,
              label: 'Harvested',
              timestamp: order.harvestedAt,
              done: order.harvestedAt != null ||
                  ['harvested', 'delivered'].contains(order.status),
            ),
            _TimelineStep(
              icon: Icons.local_shipping_rounded,
              label: 'Delivered',
              timestamp: order.deliveredAt,
              done: order.deliveredAt != null || order.status == 'delivered',
            ),
          ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: kCard, borderRadius: BorderRadius.circular(16), boxShadow: kCardShadow),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Order Progress',
              style: GoogleFonts.poppins(
                  fontSize: 13, fontWeight: FontWeight.w600, color: kText1)),
          const SizedBox(height: 14),
          ...steps.asMap().entries.map((e) {
            final i = e.key;
            final step = e.value;
            final isLast = i == steps.length - 1;
            return _TimelineRow(step: step, isLast: isLast);
          }),
        ],
      ),
    );
  }
}

class _TimelineStep {
  final IconData icon;
  final String label;
  final DateTime? timestamp;
  final bool done;
  final Color? color;

  const _TimelineStep({
    required this.icon,
    required this.label,
    this.timestamp,
    required this.done,
    this.color,
  });
}

// ── Review bottom sheet ───────────────────────────────────────────────────────

class _ReviewSheet extends StatefulWidget {
  final int farmId;
  final Testimonial? existing;
  const _ReviewSheet({required this.farmId, this.existing});

  @override
  State<_ReviewSheet> createState() => _ReviewSheetState();
}

class _ReviewSheetState extends State<_ReviewSheet> {
  int _rating = 0;
  final _commentCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      _rating = widget.existing!.rating;
      _commentCtrl.text = widget.existing!.comment ?? '';
    }
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a star rating.',
            style: GoogleFonts.poppins(fontSize: 13))),
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      Testimonial result;
      if (widget.existing != null) {
        result = await ApiService.updateReview(
            widget.farmId, widget.existing!.id, _rating, _commentCtrl.text.trim());
      } else {
        result = await ApiService.submitReview(
            widget.farmId, _rating, _commentCtrl.text.trim());
      }
      if (mounted) Navigator.pop(context, result);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit review. Please try again.',
              style: GoogleFonts.poppins(fontSize: 13))),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(
          child: Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
                color: kDivider, borderRadius: BorderRadius.circular(2)),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          widget.existing != null ? 'Edit Your Review' : 'Leave a Review',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: kText1),
        ),
        const SizedBox(height: 6),
        Text('How was your experience with this farm?',
            style: GoogleFonts.poppins(fontSize: 13, color: kText2)),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (i) => GestureDetector(
            onTap: () => setState(() => _rating = i + 1),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Icon(
                i < _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                size: 42,
                color: i < _rating ? const Color(0xFFF59E0B) : kText3,
              ),
            ),
          )),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _commentCtrl,
          maxLines: 3,
          maxLength: 300,
          decoration: InputDecoration(
            hintText: 'Share your experience (optional)',
            hintStyle: GoogleFonts.poppins(color: kText3, fontSize: 13),
          ),
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _submitting ? null : _submit,
            child: _submitting
                ? const SizedBox(
                    width: 22, height: 22,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text(widget.existing != null ? 'Update Review' : 'Submit Review',
                    style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600)),
          ),
        ),
      ]),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  final _TimelineStep step;
  final bool isLast;
  const _TimelineRow({required this.step, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final timeFmt = DateFormat('d MMM yyyy, h:mm a');
    final activeColor = step.color ?? kAmberPrimary;
    final pendingColor = const Color(0xFFD1D5DB);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Left: icon + connector line ──────────────────────────────
          SizedBox(
            width: 36,
            child: Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: step.done ? activeColor : pendingColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(step.icon,
                      size: 16,
                      color: step.done ? Colors.white : const Color(0xFF9CA3AF)),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: step.done ? activeColor.withValues(alpha: 0.3) : pendingColor,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // ── Right: label + timestamp ─────────────────────────────────
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(step.label,
                      style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: step.done ? FontWeight.w600 : FontWeight.w400,
                          color: step.done ? kText1 : const Color(0xFF9CA3AF))),
                  if (step.timestamp != null) ...[
                    const SizedBox(height: 2),
                    Text(timeFmt.format(step.timestamp!),
                        style: GoogleFonts.poppins(
                            fontSize: 11, color: kText3)),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
