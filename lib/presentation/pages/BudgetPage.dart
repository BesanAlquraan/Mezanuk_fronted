import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../presentation/state/BudgetStore.dart';
import '../../presentation/state/expense_store.dart';
import 'package:my_app/domain/models/budget.dart';
import '../../constants/colors.dart';
import '../../presentation/state/settings_store.dart';

class BudgetPage extends StatefulWidget {
  const BudgetPage({super.key});

  @override
  State<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final budgetStore = context.read<BudgetStore>();
    final expenseStore = context.read<ExpenseStore>();
    budgetStore.calculateSpentFromTransactions(expenseStore.expenses);
  }

  @override
  Widget build(BuildContext context) {
    final settingsStore = context.watch<SettingsStore>();
    final t = settingsStore.translations; // JSON للترجمة
    final budgetStore = context.watch<BudgetStore>();
    final expenseStore = context.watch<ExpenseStore>();
    final now = DateTime.now();
    budgetStore.saveMonthlyHealth(DateTime(now.year, now.month));

    final displayedBudgets = budgetStore.budgets
        .where((b) => b.isMonthly == budgetStore.isMonthly)
        .toList();

    final size = MediaQuery.of(context).size;
    final isLargeScreen = size.width > 600;

    // دالة مساعدة لعرض العملة
    String formatCurrency(double value) {
      return "${value.toStringAsFixed(2)} ${settingsStore.currency}";
    }

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: Text(t.of('budget')),
        backgroundColor: kAppBarColor,
      ),
      body: Column(
        children: [
          _buildBudgetAlerts(displayedBudgets, t),
          _buildPeriodToggle(budgetStore, t),
          _buildBudgetComparisonCard(displayedBudgets, t, formatCurrency),
          Expanded(
            child: ListView(
              children: [
                _buildHealthCard(budgetStore, t),
                _buildPredictionCard(budgetStore, t),
                _buildSmartInsightsCard(displayedBudgets, t, formatCurrency),
                _buildMonthlyHealthChart(budgetStore),
                ..._buildBudgetsList(displayedBudgets, expenseStore, t, formatCurrency),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddBudgetDialog(context, t),
        backgroundColor: kButtonPrimaryColor,
        child: const Icon(Icons.add, color: kTextLightColor),
      ),
    );
  }

  // ===================== Alerts =====================
  Widget _buildBudgetAlerts(List<Budget> budgets, dynamic t) {
    final alerts = <String>[];

    for (var budget in budgets) {
      if (budget.spentPercentage >= 1.0) {
        alerts.add("${t.of('alert_exceeded')} ${budget.categoryName}!");
      } else if (budget.spentPercentage >= 0.8) {
        alerts.add("${t.of('alert_reached')} ${budget.categoryName} ${(budget.spentPercentage * 100).toStringAsFixed(0)}%");
      }
    }

    if (alerts.isEmpty) return const SizedBox.shrink();

    return Column(
      children: alerts
          .map(
            (msg) => Container(
              width: double.infinity,
              color: msg.contains(t.of('alert_exceeded')) ? kCategoryRed : kCategoryOrange,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 12),
              child: Text(
                msg,
                style: const TextStyle(
                    color: kTextLightColor, fontWeight: FontWeight.bold),
              ),
            ),
          )
          .toList(),
    );
  }

  // ===================== Period Toggle =====================
  Widget _buildPeriodToggle(BudgetStore budgetStore, dynamic t) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ChoiceChip(
            label: Text(t.of('monthly')),
            selectedColor: kButtonPrimaryColor,
            labelStyle: TextStyle(
                color: budgetStore.isMonthly ? kTextLightColor : kTextDarkColor),
            selected: budgetStore.isMonthly,
            onSelected: (_) => budgetStore.setPeriod(true),
          ),
          const SizedBox(width: 12),
          ChoiceChip(
            label: Text(t.of('weekly')),
            selectedColor: kButtonPrimaryColor,
            labelStyle: TextStyle(
                color: !budgetStore.isMonthly ? kTextLightColor : kTextDarkColor),
            selected: !budgetStore.isMonthly,
            onSelected: (_) => budgetStore.setPeriod(false),
          ),
        ],
      ),
    );
  }

  // ===================== Comparison Card =====================
  Widget _buildBudgetComparisonCard(List<Budget> budgets, dynamic t, String Function(double) formatCurrency) {
    final totalBudget = budgets.fold(0.0, (sum, b) => sum + b.limit);
    final totalSpent = budgets.fold(0.0, (sum, b) => sum + b.spent);
    final remaining = totalBudget - totalSpent;

    Color statusColor;
    if (totalSpent > totalBudget) {
      statusColor = kCategoryRed;
    } else if (totalSpent >= totalBudget * 0.8) {
      statusColor = kCategoryOrange;
    } else {
      statusColor = kCategoryGreen;
    }

    return Card(
      color: kCardBackgroundColor,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildComparisonColumn(t.of('total_budget'), totalBudget, kCategoryBlue, formatCurrency),
            _buildComparisonColumn(t.of('spent'), totalSpent, statusColor, formatCurrency),
            _buildComparisonColumn(t.of('remaining'), remaining, kCategoryGreen, formatCurrency),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonColumn(String title, double value, Color color, String Function(double) formatCurrency) {
    return Column(
      children: [
        Text(title,
            style: TextStyle(
                fontWeight: FontWeight.bold, color: kTextDarkColor)),
        const SizedBox(height: 6),
        Text(formatCurrency(value),
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }

  // ===================== Health Card =====================
  Widget _buildHealthCard(BudgetStore budgetStore, dynamic t) {
    return Card(
      color: kCardBackgroundColor,
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              t.of('budget_health'),
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: kTextDarkColor),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 120,
              width: 120,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: budgetStore.healthScore / 100,
                    strokeWidth: 10,
                    color: budgetStore.healthColor,
                    backgroundColor: kDividerColor,
                  ),
                  Center(
                    child: Text(
                      "${budgetStore.healthScore}%",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: budgetStore.healthColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              budgetStore.healthStatusText,
              style: TextStyle(color: kTextSecondaryColor),
            ),
          ],
        ),
      ),
    );
  }

  // ===================== Prediction Card =====================
  Widget _buildPredictionCard(BudgetStore budgetStore, dynamic t) {
    return Card(
      color: kCardBackgroundColor,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.auto_graph, color: kCategoryPurple),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                "${t.of('predicted_next_month')}: ${budgetStore.predictNextMonthHealth()}%",
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: kCategoryPurple),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===================== Smart Insights =====================
  Widget _buildSmartInsightsCard(List<Budget> budgets, dynamic t, String Function(double) formatCurrency) {
    if (budgets.isEmpty) return const SizedBox.shrink();
    budgets.sort((a, b) => b.spent.compareTo(a.spent));
    final highest = budgets.first;
    final leastHealthy =
        budgets.reduce((a, b) => a.spentPercentage > b.spentPercentage ? a : b);

    return Card(
      color: kCardBackgroundColor,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.of('smart_insights'),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kTextDarkColor),
            ),
            const SizedBox(height: 12),
            Text(
              "${t.of('highest_spending')}: ${highest.categoryName} (${formatCurrency(highest.spent)})",
              style: TextStyle(color: kTextDarkColor),
            ),
            const SizedBox(height: 8),
            Text(
              "${t.of('least_healthy')}: ${leastHealthy.categoryName} (${(leastHealthy.spentPercentage * 100).toStringAsFixed(0)}%)",
              style: TextStyle(color: kTextDarkColor),
            ),
          ],
        ),
      ),
    );
  }

  // ===================== Monthly Health Chart =====================
  Widget _buildMonthlyHealthChart(BudgetStore budgetStore) {
    if (budgetStore.monthlyHealth.isEmpty) return const SizedBox.shrink();
    return Card(
      color: kCardBackgroundColor,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 150,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: true),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      int index = value.toInt();
                      if (index < budgetStore.monthlyHealth.length) {
                        final month =
                            budgetStore.monthlyHealth[index].month.month;
                        return Text(month.toString());
                      }
                      return const Text('');
                    },
                  ),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: List.generate(
                    budgetStore.monthlyHealth.length,
                    (i) => FlSpot(i.toDouble(),
                        budgetStore.monthlyHealth[i].healthScore.toDouble()),
                  ),
                  isCurved: true,
                  color: kCategoryGreen,
                  barWidth: 3,
                  dotData: FlDotData(show: true),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===================== Budgets List =====================
  List<Widget> _buildBudgetsList(List<Budget> budgets, ExpenseStore expenseStore, dynamic t, String Function(double) formatCurrency) {
    return budgets.map((budget) {
      final budgetExpenses = expenseStore.expenses
          .where((e) => e.category.name == budget.categoryName)
          .toList();

      return Card(
        color: kCardBackgroundColor,
        margin: const EdgeInsets.all(8),
        child: ExpansionTile(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                budget.categoryName,
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: kTextDarkColor),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: budget.healthColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "${budget.healthScore}%",
                  style: TextStyle(
                      color: budget.healthColor, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          subtitle: LinearProgressIndicator(
            value: budget.spentPercentage.clamp(0, 1),
            color: budget.healthColor,
            backgroundColor: kDividerColor,
            minHeight: 10,
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${t.of('spent')}: ${formatCurrency(budget.spent)} / ${t.of('limit')}: ${formatCurrency(budget.limit)}",
                    style: TextStyle(color: kTextDarkColor),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 150,
                    child: PieChart(
                      PieChartData(
                        sections: [
                          PieChartSectionData(
                            value: budget.spent,
                            color: budget.healthColor,
                            title: "${(budget.spentPercentage * 100).toStringAsFixed(0)}%",
                            titleStyle: TextStyle(
                                color: kTextLightColor, fontWeight: FontWeight.bold),
                          ),
                          PieChartSectionData(
                            value: (budget.limit - budget.spent)
                                .clamp(0, double.infinity),
                            color: kDividerColor,
                            title: '',
                          ),
                        ],
                        sectionsSpace: 2,
                        centerSpaceRadius: 30,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    t.of('transactions'),
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold, color: kTextDarkColor),
                  ),
                  ...budgetExpenses.map(
                    (e) => ListTile(
                      dense: true,
                      title: Text(
                        e.title,
                        style: TextStyle(color: kTextDarkColor),
                      ),
                      trailing: Text(
                        formatCurrency(e.amount),
                        style: TextStyle(color: kTextSecondaryColor),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  // ===================== Add Budget Dialog =====================
  void _showAddBudgetDialog(BuildContext context, dynamic t) {
    final budgetStore = context.read<BudgetStore>();
    final expenseStore = context.read<ExpenseStore>();

    String? selectedCategory;
    double limit = 0;
    bool isMonthly = true;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          backgroundColor: kCardBackgroundColor,
          title: Text(t.of('add_budget'), style: TextStyle(color: kTextDarkColor)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: t.of('category'),
                  labelStyle: TextStyle(color: kTextDarkColor),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: kDividerColor),
                  ),
                ),
                items: expenseStore.categories
                    .map((c) => DropdownMenuItem(
                          value: c.name,
                          child: Text(c.name, style: TextStyle(color: kTextDarkColor)),
                        ))
                    .toList(),
                onChanged: (v) => selectedCategory = v,
              ),
              TextField(
                decoration: InputDecoration(
                  labelText: t.of('limit'),
                  labelStyle: TextStyle(color: kTextDarkColor),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: kDividerColor),
                  ),
                ),
                keyboardType: TextInputType.number,
                onChanged: (v) => limit = double.tryParse(v) ?? 0,
                style: TextStyle(color: kTextDarkColor),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ChoiceChip(
                    label: Text(t.of('monthly')),
                    selectedColor: kButtonPrimaryColor,
                    labelStyle: TextStyle(
                        color: isMonthly ? kTextLightColor : kTextDarkColor),
                    selected: isMonthly,
                    onSelected: (_) => setState(() => isMonthly = true),
                  ),
                  const SizedBox(width: 12),
                  ChoiceChip(
                    label: Text(t.of('weekly')),
                    selectedColor: kButtonPrimaryColor,
                    labelStyle: TextStyle(
                        color: !isMonthly ? kTextLightColor : kTextDarkColor),
                    selected: !isMonthly,
                    onSelected: (_) => setState(() => isMonthly = false),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (selectedCategory != null && limit > 0) {
                  budgetStore.addBudget(Budget(
                    categoryId: selectedCategory!,
                    categoryName: selectedCategory!,
                    limit: limit,
                    isMonthly: isMonthly,
                  ));
                }
                Navigator.pop(context);
              },
              child: Text(t.of('add'), style: TextStyle(color: kButtonPrimaryColor)),
            ),
          ],
        );
      }),
    );
  }
}
