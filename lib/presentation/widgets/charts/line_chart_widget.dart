import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:my_app/domain/models/expense.dart';
import 'package:my_app/presentation/state/settings_store.dart';

class LineChartWidget extends StatelessWidget {
  final List<Expense> expenses;

  const LineChartWidget({
    super.key,
    required this.expenses,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.watch<SettingsStore>().translations;

    final now = DateTime.now();
    final Map<int, double> dailyTotals = {};

    // ===== Group expenses by day (current month) =====
    for (var e in expenses) {
      if (e.date.month == now.month && e.date.year == now.year) {
        dailyTotals[e.date.day] =
            (dailyTotals[e.date.day] ?? 0) + e.amount;
      }
    }

    final days = dailyTotals.keys.toList()..sort();

    if (days.isEmpty) {
      return SizedBox(
        height: 250,
        child: Center(
          child: Text(
            t.of('no_data_this_month'),
            style: const TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    final spots = days.asMap().entries.map((entry) {
      final index = entry.key;
      final day = entry.value;
      return FlSpot(index.toDouble(), dailyTotals[day]!);
    }).toList();

    double textScale = MediaQuery.of(context).size.width / 400;
    textScale = textScale.clamp(0.8, 1.2);

    return SizedBox(
      height: 250,
      child: LineChart(
        LineChartData(
          minY: 0,
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= days.length) {
                    return const SizedBox();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      days[index].toString(),
                      style: TextStyle(
                        fontSize: 12 * textScale,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 10,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: TextStyle(
                      fontSize: 12 * textScale,
                      color: Colors.grey[700],
                    ),
                  );
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              barWidth: 3,
              gradient: const LinearGradient(
                colors: [Colors.blue, Colors.lightBlueAccent],
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    Colors.blueAccent.withOpacity(0.3),
                    Colors.transparent,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              dotData: FlDotData(show: true),
            ),
          ],
          gridData: FlGridData(
            show: true,
            horizontalInterval: 10,
          ),
          borderData: FlBorderData(
            show: true,
            border: Border(
              left: BorderSide(color: Colors.grey[400]!),
              bottom: BorderSide(color: Colors.grey[400]!),
            ),
          ),
          lineTouchData: LineTouchData(
            handleBuiltInTouches: true,
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final day = days[spot.x.toInt()];
                  return LineTooltipItem(
                    '${t.of('day')} $day\n${t.of('currency_symbol')}${spot.y.toStringAsFixed(2)}',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }
}
