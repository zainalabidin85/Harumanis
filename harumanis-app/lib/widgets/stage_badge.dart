import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../l10n/l10n.dart';
import '../theme.dart';

class StageBadge extends StatelessWidget {
  final int stage;
  const StageBadge({super.key, required this.stage});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final label = stageName(l10n, stage);
    final (color, bg) = switch (stage) {
      1 => (kText2, const Color(0xFFF3F4F6)),
      2 => (const Color(0xFF0369A1), const Color(0xFFE0F2FE)),
      3 => (kGreen, const Color(0xFFDCFCE7)),
      _ => (kText3, const Color(0xFFF3F4F6)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        l10n.stageBadge(stage, label),
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
    final label = orderStatusLabel(context.l10n, status);
    final (color, bg) = switch (status) {
      'pending'   => (kAmberPrimary, kAmberLight),
      'confirmed' => (const Color(0xFF0369A1), const Color(0xFFE0F2FE)),
      'harvested' => (kGreen, const Color(0xFFDCFCE7)),
      'delivered' => (const Color(0xFF7C3AED), const Color(0xFFEDE9FE)),
      'cancelled' => (kRed, const Color(0xFFFEE2E2)),
      _           => (kText2, const Color(0xFFF3F4F6)),
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
