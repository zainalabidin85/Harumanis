import 'package:flutter/material.dart';
import '../models/fruit.dart';
import 'harvest_badge.dart';

class FruitCard extends StatelessWidget {
  final FruitResult fruit;

  const FruitCard({super.key, required this.fruit});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            const Text('🥭', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fruit.label,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${fruit.sizeCm} cm  ·  ${fruit.stageName}',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  HarvestBadge(
                    harvestDate: fruit.harvestDate,
                    daysToHarvest: fruit.daysToHarvest,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
