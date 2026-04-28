import 'package:flutter/material.dart';

class ChartWidget extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final String title;

  const ChartWidget({
    super.key,
    required this.data,
    this.title = 'Données',
  });

  @override
  Widget build(BuildContext context) {
    final max = data.isEmpty
        ? 1.0
        : data
            .map((e) => ((e['amount'] ?? e['total_amount'] ?? 0) as num).toDouble())
            .fold<double>(0, (a, b) => a > b ? a : b);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...data.take(8).map((row) {
              final value = ((row['amount'] ?? row['total_amount'] ?? 0) as num).toDouble();
              final label = (row['name'] ?? row['month'] ?? '-').toString();
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    SizedBox(width: 80, child: Text(label, overflow: TextOverflow.ellipsis)),
                    Expanded(
                      child: LinearProgressIndicator(value: max == 0 ? 0 : value / max),
                    ),
                    const SizedBox(width: 8),
                    Text(value.toStringAsFixed(0)),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
