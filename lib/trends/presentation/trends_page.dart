import 'package:calories/core/constants/ksizes.dart';
import 'package:calories/core/di/service_locator.dart';
import 'package:calories/core/ui/app_card.dart';
import 'package:calories/trends/domain/i_trends_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class TrendsPage extends StatefulWidget {
  const TrendsPage({super.key});

  @override
  State<TrendsPage> createState() => _TrendsPageState();
}

class _TrendsPageState extends State<TrendsPage> {
  late final ITrendsService _trends;
  int _days = 7;

  @override
  void initState() {
    super.initState();
    _trends = getIt<ITrendsService>();
  }

  @override
  Widget build(BuildContext context) {
    final data = _trends.getDailyTotals(days: _days);
    final List<FlSpot> spots = List<FlSpot>.generate(
      data.length,
      (int idx) => FlSpot(idx.toDouble(), data[idx].calorieTotal.toDouble()),
    );
    final double adherence = _trends.getAdherencePercent(days: _days);
    final int streak = _trends.getAdherenceStreak();

    return Padding(
      padding: const EdgeInsets.only(bottom: 80),
      child: ListView(
        padding: const EdgeInsets.all(KSizes.margin4x),
        children: <Widget>[
          AppCard(
            child: Row(
              children: [
                SegmentedButton<int>(
                  segments: const <ButtonSegment<int>>[
                    ButtonSegment<int>(value: 7, label: Text('7d')),
                    ButtonSegment<int>(value: 30, label: Text('30d')),
                  ],
                  selected: <int>{_days},
                  onSelectionChanged: (s) => setState(() => _days = s.first),
                ),
                const Spacer(),
                Text('Adherence: ${adherence.toStringAsFixed(0)}%  Streak: $streak'),
              ],
            ),
          ),
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
                      spots: spots,
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
          const AppCard(child: Text('Insights (avg deficit/surplus, best day) — TBD')),
          const AppCard(child: Text('Weight trend — TBD')),
        ],
      ),
    );
  }
}
