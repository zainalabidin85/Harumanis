import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/fruit.dart';
import '../theme.dart';
import 'harvest_badge.dart';

class FruitCard extends StatelessWidget {
  final FruitResult fruit;
  const FruitCard({super.key, required this.fruit});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: kCardShadow,
      ),
      child: Row(
        children: [
          // Green left accent bar
          Container(
            width: 5,
            height: 86,
            decoration: const BoxDecoration(
              color: kGreenMid,
              borderRadius:
                  BorderRadius.horizontal(left: Radius.circular(16)),
            ),
          ),
          const SizedBox(width: 14),
          const Text('🥭', style: TextStyle(fontSize: 30)),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fruit.label,
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: kText1),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${fruit.sizeCm.toStringAsFixed(1)} cm  ·  ${fruit.stageName}',
                    style: GoogleFonts.poppins(
                        color: kText2, fontSize: 13),
                  ),
                  const SizedBox(height: 7),
                  HarvestBadge(
                    harvestDate: fruit.harvestDate,
                    daysToHarvest: fruit.daysToHarvest,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }
}
