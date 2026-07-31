import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';

class StageBadge extends StatelessWidget {
  final int stage;
  const StageBadge({super.key, required this.stage});

  @override
  Widget build(BuildContext context) {
    final (label, color, bg) = switch (stage) {
      1 => ('Early', kText2, const Color(0xFFF3F4F6)),
      2 => ('Bagging', const Color(0xFF0369A1), const Color(0xFFE0F2FE)),
      3 => ('Pre-harvest', kGreen, const Color(0xFFDCFCE7)),
      _ => ('Unknown', kText3, const Color(0xFFF3F4F6)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'Stage $stage · $label',
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color, bg) = switch (status) {
      'pending'   => ('Pending', kAmberPrimary, kAmberLight),
      'confirmed' => ('Confirmed', const Color(0xFF0369A1), const Color(0xFFE0F2FE)),
      'harvested' => ('Harvested', kGreen, const Color(0xFFDCFCE7)),
      'delivered' => ('Delivered', const Color(0xFF7C3AED), const Color(0xFFEDE9FE)),
      'cancelled' => ('Cancelled', kRed, const Color(0xFFFEE2E2)),
      _           => (status, kText2, const Color(0xFFF3F4F6)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
