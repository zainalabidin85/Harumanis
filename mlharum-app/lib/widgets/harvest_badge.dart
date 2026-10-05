import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../theme.dart';
import '../l10n/l10n.dart';

class HarvestBadge extends StatelessWidget {
  final DateTime harvestDate;
  final int daysToHarvest;

  const HarvestBadge({
    super.key,
    required this.harvestDate,
    required this.daysToHarvest,
  });

  Color get _color {
    if (daysToHarvest <= 14) return kRed;
    if (daysToHarvest <= 30) return kAmber;
    return kGreenMid;
  }

  IconData get _icon {
    if (daysToHarvest <= 14) return Icons.agriculture_rounded;
    if (daysToHarvest <= 30) return Icons.schedule_rounded;
    return Icons.calendar_today_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: _color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, color: _color, size: 12),
          const SizedBox(width: 5),
          Text(
            context.l10n.harvestBadgeLabel(DateFormat('d MMM yyyy', Localizations.localeOf(context).languageCode).format(harvestDate), daysToHarvest),
            style: GoogleFonts.poppins(
              color: _color,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
