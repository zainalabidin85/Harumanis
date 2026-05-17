import 'package:flutter/material.dart';
import '../models/fruit.dart';
import '../widgets/fruit_card.dart';

class ResultScreen extends StatelessWidget {
  final DetectionResponse result;
  const ResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tree ${result.treeNumber}'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            color: Colors.green.shade50,
            child: Text(
              '${result.mangoCount} mango${result.mangoCount == 1 ? '' : 'es'} detected',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.green.shade800,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: result.fruits.length,
              itemBuilder: (context, index) => FruitCard(fruit: result.fruits[index]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Label and wrap each fruit on the tree using the numbers above.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Done', style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
