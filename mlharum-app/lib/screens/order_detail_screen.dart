import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/farm_order.dart';
import '../services/api_service.dart';
import '../theme.dart';
import '../l10n/l10n.dart';

class OrderDetailScreen extends StatefulWidget {
  final FarmOrder order;
  final ValueChanged<FarmOrder>? onStatusChanged;

  const OrderDetailScreen(
      {super.key, required this.order, this.onStatusChanged});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late FarmOrder _order;
  bool _updating = false;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
  }

  Future<void> _updateStatus(String newStatus) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(_actionLabel(newStatus),
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Text(_confirmMessage(newStatus),
            style: GoogleFonts.poppins(fontSize: 14, color: kText2)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child:
                Text(context.l10n.commonCancel, style: GoogleFonts.poppins(color: kText2)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  newStatus == 'cancelled' ? kRed : kGreenPrimary,
            ),
            child: Text(_actionLabel(newStatus),
                style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    HapticFeedback.mediumImpact();
    setState(() => _updating = true);
    try {
      final updated =
          await ApiService.updateOrderStatus(_order.id, newStatus);
      setState(() => _order = updated);
      widget.onStatusChanged?.call(updated);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(context.l10n.orderDetailStatusUpdated(orderStatusLabel(context.l10n, newStatus).toLowerCase()),
              style: GoogleFonts.poppins()),
          backgroundColor: newStatus == 'cancelled' ? kRed : kGreenMid,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(context.l10n.orderDetailErrorUpdate(e.toString()),
              style: GoogleFonts.poppins()),
          backgroundColor: kRed,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      }
    } finally {
      if (mounted) setState(() => _updating = false);
    }
  }

  String _actionLabel(String status) => switch (status) {
        'confirmed' => context.l10n.orderDetailConfirmOrder,
        'harvested' => context.l10n.orderDetailMarkHarvested,
        'delivered' => context.l10n.orderDetailMarkDelivered,
        'cancelled' => context.l10n.orderDetailCancelOrder,
        _ => status,
      };

  String _confirmMessage(String status) => switch (status) {
        'confirmed' =>
          context.l10n.orderDetailConfirmMsgConfirmed,
        'harvested' =>
          context.l10n.orderDetailConfirmMsgHarvested,
        'delivered' =>
          context.l10n.orderDetailConfirmMsgDelivered,
        'cancelled' =>
          context.l10n.orderDetailConfirmMsgCancelled,
        _ => context.l10n.orderDetailConfirmMsgOther(status),
      };

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('d MMM yyyy, h:mm a', Localizations.localeOf(context).languageCode);
    final dateFmt = DateFormat('d MMM yyyy', Localizations.localeOf(context).languageCode);

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: Text(context.l10n.orderDetailTitle('${_order.id}')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context, _order),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Status row ──────────────────────────────────────────────
            _Card(
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                Text(context.l10n.orderDetailStatus,
                    style:
                        GoogleFonts.poppins(fontSize: 14, color: kText2)),
                _StatusBadge(status: _order.status),
              ]),
            ),
            const SizedBox(height: 12),

            // ── Buyer info ──────────────────────────────────────────────
            _Card(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(context.l10n.orderDetailBuyer,
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: kText3)),
                const SizedBox(height: 4),
                Text(_order.buyerName,
                    style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: kText1)),
              ]),
            ),
            const SizedBox(height: 12),

            // ── Delivery address ────────────────────────────────────────
            _Card(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on_outlined,
                      size: 18, color: kGreenPrimary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(context.l10n.orderDetailDeliveryAddress,
                            style: GoogleFonts.poppins(
                                fontSize: 12, color: kText3)),
                        const SizedBox(height: 2),
                        Text(
                          _order.buyerAddress?.isNotEmpty == true
                              ? _order.buyerAddress!
                              : context.l10n.orderDetailNoAddress,
                          style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: _order.buyerAddress?.isNotEmpty == true
                                  ? kText1
                                  : kText3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Order details ───────────────────────────────────────────
            _Card(
              child: Column(children: [
                _Row(label: context.l10n.orderDetailQuantity, value: '${_order.quantityKg} kg'),
                _Row(
                    label: context.l10n.orderDetailPricePerKg,
                    value: 'RM ${_order.pricePerKg.toStringAsFixed(2)}'),
                const Divider(height: 20),
                _Row(
                  label: context.l10n.orderDetailTotal,
                  value: 'RM ${_order.totalPrice.toStringAsFixed(2)}',
                  bold: true,
                ),
                _Row(
                  label: context.l10n.orderDetailPayment,
                  value: _order.billplzPaid ? context.l10n.orderDetailPaidTick : context.l10n.orderDetailAwaitingPayment,
                  valueColor: _order.billplzPaid ? kGreenMid : kAmber,
                ),
                if (_order.paidAt != null)
                  _Row(
                      label: context.l10n.orderDetailPaidAt,
                      value: dateFmt.format(_order.paidAt!)),
                if (_order.targetHarvestDate != null)
                  _Row(
                      label: context.l10n.orderDetailTargetDate,
                      value: dateFmt.format(_order.targetHarvestDate!)),
                _Row(
                    label: context.l10n.orderDetailOrderedOn,
                    value: fmt.format(_order.createdAt)),
                if (_order.notes != null && _order.notes!.isNotEmpty) ...[
                  const Divider(height: 20),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      context.l10n.orderDetailNotes(_order.notes!),
                      style: GoogleFonts.poppins(
                          fontSize: 13, color: kText2),
                    ),
                  ),
                ],
              ]),
            ),
            const SizedBox(height: 24),

            // ── Action buttons ──────────────────────────────────────────
            if (_updating)
              const Center(
                  child: CircularProgressIndicator(color: kGreenPrimary))
            else ...[
              if (_order.status == 'pending') ...[
                ElevatedButton.icon(
                  icon: const Icon(Icons.check_rounded),
                  label: Text(context.l10n.orderDetailConfirmOrder),
                  onPressed: () => _updateStatus('confirmed'),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  icon: const Icon(Icons.close_rounded),
                  label: Text(context.l10n.orderDetailCancelOrder),
                  onPressed: () => _updateStatus('cancelled'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kRed,
                    side: const BorderSide(color: kRed),
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ],
              if (_order.status == 'confirmed') ...[
                ElevatedButton.icon(
                  icon: const Icon(Icons.agriculture_rounded),
                  label: Text(context.l10n.orderDetailMarkAsHarvested),
                  onPressed: () => _updateStatus('harvested'),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  icon: const Icon(Icons.close_rounded),
                  label: Text(context.l10n.orderDetailCancelOrder),
                  onPressed: () => _updateStatus('cancelled'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kRed,
                    side: const BorderSide(color: kRed),
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ],
              if (_order.status == 'harvested')
                ElevatedButton.icon(
                  icon: const Icon(Icons.local_shipping_rounded),
                  label: Text(context.l10n.orderDetailMarkAsDelivered),
                  onPressed: () => _updateStatus('delivered'),
                ),
              if (_order.status == 'delivered')
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: kGreenLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: kGreenMid.withValues(alpha: 0.3)),
                  ),
                  child: Row(children: [
                    const Icon(Icons.check_circle_rounded,
                        color: kGreenMid, size: 20),
                    const SizedBox(width: 10),
                    Text(context.l10n.orderDetailCompleted,
                        style: GoogleFonts.poppins(
                            fontSize: 13, color: kGreenPrimary)),
                  ]),
                ),
              if (_order.status == 'cancelled')
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: kRed.withValues(alpha: 0.2)),
                  ),
                  child: Row(children: [
                    const Icon(Icons.cancel_rounded,
                        color: kRed, size: 20),
                    const SizedBox(width: 10),
                    Text(context.l10n.orderDetailCancelled,
                        style: GoogleFonts.poppins(
                            fontSize: 13, color: kRed)),
                  ]),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: kCard,
            borderRadius: BorderRadius.circular(16),
            boxShadow: kCardShadow),
        child: child,
      );
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  final Color? valueColor;
  const _Row(
      {required this.label,
      required this.value,
      this.bold = false,
      this.valueColor});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style:
                      GoogleFonts.poppins(fontSize: 13, color: kText2)),
              Text(value,
                  style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight:
                          bold ? FontWeight.w700 : FontWeight.w500,
                      color: valueColor ??
                          (bold ? kGreenPrimary : kText1))),
            ]),
      );
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color, bg) = switch (status) {
      'pending'   => (context.l10n.orderStatusPending, kAmber, const Color(0xFFFEF3C7)),
      'confirmed' => (context.l10n.orderStatusConfirmed, const Color(0xFF0369A1), const Color(0xFFE0F2FE)),
      'harvested' => (context.l10n.orderStatusHarvested, kGreenMid, kGreenLight),
      'delivered' => (context.l10n.orderStatusDelivered, const Color(0xFF7C3AED), const Color(0xFFEDE9FE)),
      'cancelled' => (context.l10n.orderStatusCancelled, kRed, const Color(0xFFFEE2E2)),
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
