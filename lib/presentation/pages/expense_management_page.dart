import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../domain/models/expense.dart' as exp;
import '../../domain/models/expense_category.dart' as cat;
import '../state/expense_store.dart';
import '../state/settings_store.dart';
import '../../constants/colors.dart';

class ExpenseManagementPage extends StatefulWidget {
  const ExpenseManagementPage({super.key});

  @override
  State<ExpenseManagementPage> createState() => _ExpenseManagementPageState();
}

class _ExpenseManagementPageState extends State<ExpenseManagementPage> {
  String searchQuery = '';
  cat.ExpenseCategory? selectedCategory;
  double? minAmount;
  double? maxAmount;
  DateTime? startDate;
  DateTime? endDate;

  final TextEditingController minController = TextEditingController();
  final TextEditingController maxController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final store = context.watch<ExpenseStore>();
    final settings = context.watch<SettingsStore>();
    final t = settings.translations;

    final currencySymbol = settings.currencySymbol; // يدعم الديناميكية

    final filteredExpenses = store.filterExpenses(
      search: searchQuery,
      category: selectedCategory,
      startDate: startDate,
      endDate: endDate,
    )
    .where((e) => e.type == exp.ExpenseType.expense)
    .where((e) =>
        (minAmount == null || e.amount >= minAmount!) &&
        (maxAmount == null || e.amount <= maxAmount!))
    .toList();

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: Text(t.of('expense_management')),
        backgroundColor: kPrimaryColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Summary Cards
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _summaryCard(t.of('today'), store.totalToday(type: exp.ExpenseType.expense) , currencySymbol),
                  _summaryCard(t.of('this_month'), store.totalThisMonth(type: exp.ExpenseType.expense) , currencySymbol),
                  _summaryCard(t.of('largest'), store.largestExpense(type: exp.ExpenseType.expense), currencySymbol),
                ],
              ),
            ),

            // Filters
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  TextField(
                    decoration: InputDecoration(
                        hintText: t.of('search_transaction'),
                        hintStyle: TextStyle(color: kTextSecondaryColor),
                        prefixIcon: Icon(Icons.search, color: kTextSecondaryColor),
                        filled: true,
                        fillColor: kCardBackgroundColor,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none)
                    ),
                    style: TextStyle(color: kTextDarkColor),
                    onChanged: (val) => setState(() => searchQuery = val),
                  ),
                  const SizedBox(height: 8),
                  DropdownButton<cat.ExpenseCategory>(
                    value: selectedCategory,
                    isExpanded: true,
                    hint: Text(t.of('filter_by_category'), style: TextStyle(color: kTextSecondaryColor)),
                    items: [null, ...store.categories].map((catItem) {
                      if (catItem == null) return DropdownMenuItem<cat.ExpenseCategory>(
                        value: null,
                        child: Text(t.of('all_categories')),
                      );
                      return DropdownMenuItem(
                        value: catItem,
                        child: Text(catItem.name, style: TextStyle(color: kTextDarkColor)),
                      );
                    }).toList(),
                    onChanged: (cat.ExpenseCategory? cat) => setState(() => selectedCategory = cat),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: minController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                              labelText: t.of('min_amount'),
                              labelStyle: TextStyle(color: kTextSecondaryColor),
                              border: OutlineInputBorder()
                          ),
                          style: TextStyle(color: kTextDarkColor),
                          onChanged: (val) => setState(() => minAmount = double.tryParse(val)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: maxController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                              labelText: t.of('max_amount'),
                              labelStyle: TextStyle(color: kTextSecondaryColor),
                              border: OutlineInputBorder()
                          ),
                          style: TextStyle(color: kTextDarkColor),
                          onChanged: (val) => setState(() => maxAmount = double.tryParse(val)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: kPrimaryColor),
                          ),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: startDate ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) setState(() => startDate = picked);
                          },
                          child: Text(
                            startDate == null
                              ? t.of('start_date')
                              : "${startDate!.day}-${startDate!.month}-${startDate!.year}",
                            style: TextStyle(color: kTextDarkColor),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: kPrimaryColor),
                          ),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: endDate ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) setState(() => endDate = picked);
                          },
                          child: Text(
                            endDate == null
                              ? t.of('end_date')
                              : "${endDate!.day}-${endDate!.month}-${endDate!.year}",
                            style: TextStyle(color: kTextDarkColor),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Pie Chart
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: store.categories.map((catItem) {
                    final total = filteredExpenses
                        .where((e) => e.category == catItem)
                        .fold<double>(0, (sum, e) => sum + e.amount);
                    return PieChartSectionData(
                      value: total,
                      title: catItem.name,
                      color: catItem.color,
                      radius: 50,
                      titleStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: kTextDarkColor),
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Expenses List
            filteredExpenses.isEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long, size: 80, color: kTextSecondaryColor),
                      const SizedBox(height: 8),
                      Text(t.of('no_expenses_found'), style: TextStyle(color: kTextSecondaryColor)),
                    ],
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredExpenses.length,
                    itemBuilder: (context, index) {
                      final e = filteredExpenses[index];
                      return Card(
                        color: kCardBackgroundColor,
                        child: ListTile(
                          leading: Icon(e.category.icon, color: e.category.color),
                          title: Text(e.title, style: TextStyle(color: kTextDarkColor)),
                          subtitle: Text(
                            "${e.category.name} - $currencySymbol${e.amount.toStringAsFixed(2)}\n${e.date.toLocal().toString().split(' ')[0]}",
                            style: TextStyle(color: kTextSecondaryColor),
                          ),
                          isThreeLine: true,
                        ),
                      );
                    },
                  ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard(String title, double amount, String currencySymbol) {
    return Card(
      color: kCardBackgroundColor,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: kTextDarkColor)),
            const SizedBox(height: 4),
            Text("$currencySymbol${amount.toStringAsFixed(2)}", style: TextStyle(fontWeight: FontWeight.bold, color: kPrimaryColor)),
          ],
        ),
      ),
    );
  }
}
