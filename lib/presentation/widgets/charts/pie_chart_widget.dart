import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';

import 'package:my_app/domain/models/expense.dart';
import 'package:my_app/domain/models/expense_category.dart' as cat;
import 'package:my_app/presentation/state/settings_store.dart';

class SmallResponsivePieChart extends StatefulWidget {
  final List<Expense> expenses;
  final ExpenseType? pieFilterType;

  const SmallResponsivePieChart({
    super.key,
    required this.expenses,
    this.pieFilterType,
  });

  @override
  State<SmallResponsivePieChart> createState() =>
      _SmallResponsivePieChartState();
}

class _SmallResponsivePieChartState extends State<SmallResponsivePieChart> {
  int? touchedIndex;

  @override
  Widget build(BuildContext context) {
    final t = context.watch<SettingsStore>().translations;

    // ===== Group expenses by category =====
    final Map<cat.ExpenseCategory, double> categoryTotals = {};

    for (var e in widget.expenses) {
      if (widget.pieFilterType != null &&
          e.category.type != widget.pieFilterType) {
        continue;
      }
      categoryTotals[e.category] =
          (categoryTotals[e.category] ?? 0) + e.amount;
    }

    final data = categoryTotals.entries.toList();
    final total = categoryTotals.values.fold(0.0, (a, b) => a + b);

    if (data.isEmpty || total == 0) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Text(
            t.of('no_data_available'),
            style: const TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final diameter =
            (constraints.maxWidth < constraints.maxHeight
                    ? constraints.maxWidth
                    : constraints.maxHeight) *
                0.7;

        final radius = diameter * 0.35;
        final fontSize = diameter * 0.06;
        final badgeOffset = radius * 1.1;

        return SizedBox(
          height: diameter,
          child: PieChart(
            PieChartData(
              sections: data.asMap().entries.map((entry) {
                final index = entry.key;
                final category = entry.value.key;
                final amount = entry.value.value;
                final percent = amount / total;
                final isTouched = index == touchedIndex;

                return PieChartSectionData(
                  value: amount,
                  color: category.color,
                  radius: isTouched ? radius * 1.1 : radius,
                  title: "${(percent * 100).toStringAsFixed(1)}%",
                  titleStyle: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: fontSize,
                    shadows: const [
                      Shadow(
                        color: Colors.black26,
                        offset: Offset(2, 2),
                        blurRadius: 3,
                      ),
                    ],
                  ),
                  borderSide:
                      const BorderSide(color: Colors.white, width: 2),
                  badgeWidget: isTouched
                      ? Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: fontSize * 0.4,
                            vertical: fontSize * 0.25,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 2,
                                offset: Offset(1, 1),
                              )
                            ],
                          ),
                          child: Text(
                            "${t.of(category.name)}\n${t.of('currency_symbol')}${amount.toStringAsFixed(2)}",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: fontSize * 0.7,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : null,
                  badgePositionPercentageOffset: badgeOffset / radius,
                );
              }).toList(),
              sectionsSpace: 4,
              centerSpaceRadius: radius * 0.35,
              borderData: FlBorderData(show: false),
              pieTouchData: PieTouchData(
                touchCallback: (event, response) {
                  setState(() {
                    if (response?.touchedSection?.touchedSection != null) {
                      touchedIndex =
                          response!.touchedSection!.touchedSectionIndex;
                    } else {
                      touchedIndex = null;
                    }
                  });
                },
              ),
            ),
            swapAnimationDuration: const Duration(milliseconds: 800),
            swapAnimationCurve: Curves.easeOutCubic,
          ),
        );
      },
    );
  }
}
