import 'package:flutter/material.dart';

class UpcomingActivityChart extends StatelessWidget {
  final Map<String, double> weeklyData;

  const UpcomingActivityChart({super.key, required this.weeklyData});

  @override
  Widget build(BuildContext context) {
    double maxY = weeklyData.values.fold(0, (prev, e) => e > prev ? e : prev);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: weeklyData.entries.map((entry) {
        final day = entry.key;
        final value = entry.value;
        final barWidth = (value / (maxY == 0 ? 1 : maxY)) * 200; // 200px width max

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              SizedBox(width: 30, child: Text(day)),
              Container(
                width: barWidth,
                height: 12,
                color: Colors.blue,
              ),
              const SizedBox(width: 8),
              Text("${value.toInt()}"),
            ],
          ),
        );
      }).toList(),
    );
  }
}
