import 'package:calories/core/constants/ksizes.dart';
import 'package:calories/core/ui/app_card.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class TrendsPage extends StatelessWidget {
  const TrendsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<FlSpot> weekSpots = <FlSpot>[
      const FlSpot(0, 2000),
      const FlSpot(1, 1800),
      const FlSpot(2, 2100),
      const FlSpot(3, 1950),
      const FlSpot(4, 2200),
      const FlSpot(5, 2050),
      const FlSpot(6, 1900),
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 80),
      child: ListView(
        padding: const EdgeInsets.all(KSizes.margin4x),
        children: <Widget>[
          AppCard(
            child: SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: <LineChartBarData>[
                    LineChartBarData(
                      spots: weekSpots,
                      isCurved: true,
                      color: Theme.of(context).colorScheme.primary,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const AppCard(child: Text('Adherence & insights (placeholder)')),
          const AppCard(child: Text('Weight trend (placeholder)')),
        ],
      ),
    );
  }
}
