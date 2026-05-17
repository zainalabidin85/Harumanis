import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HarvestBadge extends StatelessWidget {
  final DateTime harvestDate;
  final int daysToHarvest;

  const HarvestBadge({
    super.key,
    required this.harvestDate,
    required this.daysToHarvest,
  });

  Color get _color {
    if (daysToHarvest <= 14) return Colors.red.shade600;
    if (daysToHarvest <= 30) return Colors.orange.shade600;
    return Colors.green.shade600;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color),
      ),
      child: Text(
        '${DateFormat('d MMM yyyy').format(harvestDate)} · $daysToHarvest days',
        style: TextStyle(color: _color, fontWeight: FontWeight.w600, fontSize: 12),
      ),
    );
  }
}
