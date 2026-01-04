import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../state/TransactionStore.dart';
import '../state/settings_store.dart';
import '../../domain/models/expense.dart' as exp;
import '../../domain/models/income.dart';
import '../../domain/models/expense_category.dart' as cat;
import '../../domain/models/incomeCategory.dart';
import '../widgets/transaction_tile.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  String searchQuery = "";
  cat.ExpenseCategory? selectedCategory;
  exp.ExpenseType? selectedType;
  double? minAmount;
  double? maxAmount;
  DateTime? startDate;
  DateTime? endDate;

  final TextEditingController minController = TextEditingController();
  final TextEditingController maxController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final store = context.watch<TransactionStore>();
    final settings = context.watch<SettingsStore>();
    final t = settings.translations; // ترجمات JSON
    final currency = settings.currencySymbol; // رمز العملة ديناميكي

    return Scaffold(
      appBar: AppBar(
        title: Text(t.of('transactions')),
        backgroundColor: const Color(0xff6A5AE0),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => store.exportTransactions(),
            tooltip: t.of('export'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xff6A5AE0),
        child: const Icon(Icons.add),
        onPressed: () => _showTransactionDialog(context, t: t, currency: currency),
        tooltip: t.of('add_transaction'),
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 900;
        final isTablet = constraints.maxWidth > 600 && constraints.maxWidth <= 900;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummarySection(store, t, currency, isDesktop, isTablet),
                const SizedBox(height: 16),
                if (store.expenses.isNotEmpty)
                  _buildChartSection(store, isDesktop, isTablet, t, currency),
                const SizedBox(height: 16),
                _buildFilters(store, t, isDesktop),
                const SizedBox(height: 16),
                _buildTransactionList(store, t, currency),
              ],
            ),
          ),
        );
      }),
    );
  }

  // ================= Summary Section =================
  Widget _buildSummarySection(TransactionStore store, dynamic t, String currency, bool isDesktop, bool isTablet) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _summaryCard(t.of('today'), store.totalToday(), currency),
          const SizedBox(width: 12),
          _summaryCard(t.of('this_month'), store.totalThisMonth(), currency),
          const SizedBox(width: 12),
          _summaryCard(t.of('largest'), store.largestExpense(), currency),
        ],
      ),
    );
  }

  Widget _summaryCard(String title, double amount, String currency) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("$currency${amount.toStringAsFixed(2)}",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // ================= Chart Section =================
  Widget _buildChartSection(TransactionStore store, bool isDesktop, bool isTablet, dynamic t, String currency) {
    double fontSize = isDesktop ? 14 : isTablet ? 12 : 10;
    double reservedSize = isDesktop ? 40 : isTablet ? 32 : 28;
    double rotationAngle = isDesktop || isTablet ? 0 : 45;

    return LayoutBuilder(builder: (context, constraints) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 6)),
          ],
        ),
        child: SizedBox(
          width: constraints.maxWidth,
          height: 300,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: store.maxMonthlyExpense() * 1.2,
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final month = DateFormat.MMM()
                        .format(DateTime(DateTime.now().year, group.x.toInt()));
                    return BarTooltipItem(
                      "$month\n$currency${rod.toY.toStringAsFixed(2)}",
                      const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: reservedSize,
                    getTitlesWidget: (val, meta) =>
                        Text("$currency${val.toInt()}", style: TextStyle(fontSize: fontSize, color: Colors.black54)),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: reservedSize,
                    getTitlesWidget: (val, meta) {
                      final month = DateFormat.MMM()
                          .format(DateTime(DateTime.now().year, val.toInt()));
                      return Transform.rotate(
                        angle: rotationAngle * 3.1415927 / 180,
                        child: Text(month,
                            style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600, color: Colors.black87)),
                      );
                    },
                  ),
                ),
              ),
              barGroups: store.monthlyChartData(),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: store.maxMonthlyExpense() / 5,
                getDrawingHorizontalLine: (value) =>
                    FlLine(color: Colors.grey.withOpacity(0.2), strokeWidth: 1),
              ),
              borderData: FlBorderData(show: false),
            ),
          ),
        ),
      );
    });
  }

  // ================= Filters =================
  Widget _buildFilters(TransactionStore store, dynamic t, bool isDesktop) {
    return Column(
      children: [
        TextField(
          decoration: InputDecoration(
            hintText: t.of('search_transaction'),
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onChanged: (val) => setState(() => searchQuery = val),
        ),
        const SizedBox(height: 8),
        DropdownButton<cat.ExpenseCategory?>(
          value: selectedCategory,
          isExpanded: true,
          hint: Text(t.of('filter_by_category')),
          items: [null, ...store.expenseCategories].map((c) {
            if (c == null) {
              return DropdownMenuItem<cat.ExpenseCategory?>(
                value: null,
                child: Text(t.of('all_categories')),
              );
            }
            return DropdownMenuItem<cat.ExpenseCategory?>(
              value: c,
              child: Text(c.name),
            );
          }).toList(),
          onChanged: (c) => setState(() => selectedCategory = c),
        ),
        const SizedBox(height: 8),
        DropdownButton<exp.ExpenseType?>(
          value: selectedType,
          isExpanded: true,
          hint: Text(t.of('filter_by_type')),
          items: [null, exp.ExpenseType.income, exp.ExpenseType.expense].map((type) {
            if (type == null) {
              return DropdownMenuItem<exp.ExpenseType?>(
                value: null,
                child: Text(t.of('all_types')),
              );
            }
            return DropdownMenuItem<exp.ExpenseType?>(
              value: type,
              child: Text(type == exp.ExpenseType.income ? t.of('income') : t.of('expense')),
            );
          }).toList(),
          onChanged: (tVal) => setState(() => selectedType = tVal),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: minController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: t.of('min_amount'), border: OutlineInputBorder()),
                onChanged: (val) => setState(() => minAmount = double.tryParse(val)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: maxController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: t.of('max_amount'), border: OutlineInputBorder()),
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
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: startDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => startDate = picked);
                },
                child: Text(startDate == null
                    ? t.of('start_date')
                    : DateFormat('dd-MM-yyyy').format(startDate!)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: endDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => endDate = picked);
                },
                child: Text(endDate == null
                    ? t.of('end_date')
                    : DateFormat('dd-MM-yyyy').format(endDate!)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ================= Transactions List =================
  Widget _buildTransactionList(TransactionStore store, dynamic t, String currency) {
    final allTransactions = [...store.expenses, ...store.incomes];

    final filtered = allTransactions.where((tr) {
      final title = tr is exp.Expense ? tr.title : (tr as Income).title;
      final amount = tr is exp.Expense ? tr.amount : (tr as Income).amount;
      final date = tr is exp.Expense ? tr.date : (tr as Income).date;
      final type = tr is exp.Expense ? tr.type : exp.ExpenseType.income;
      final category = tr is exp.Expense ? tr.category : (tr as Income).category;

      if (searchQuery.isNotEmpty && !title.toLowerCase().contains(searchQuery.toLowerCase())) return false;
      if (minAmount != null && amount < minAmount!) return false;
      if (maxAmount != null && amount > maxAmount!) return false;
      if (startDate != null && date.isBefore(startDate!)) return false;
      if (endDate != null && date.isAfter(endDate!)) return false;
      if (selectedType != null && type != selectedType) return false;
      if (selectedCategory != null && category != selectedCategory) return false;

      return true;
    }).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(t.of('no_transactions_yet'), style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _showTransactionDialog(context, t: t, currency: currency),
              child: Text(t.of('add_first_transaction')),
            ),
          ],
        ),
      );
    }

    Map<DateTime, List<dynamic>> grouped = {};
    for (var tr in filtered) {
      final date = tr is exp.Expense ? tr.date : (tr as Income).date;
      final key = DateTime(date.year, date.month, date.day);
      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(tr);
    }

    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: grouped.entries.map((entry) {
        final date = entry.key;
        final transactions = entry.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(DateFormat('dd-MM-yyyy').format(date),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...transactions.map((tItem) => Dismissible(
                  key: ValueKey(tItem),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 16),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  secondaryBackground: Container(
                    color: Colors.blue,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    child: const Icon(Icons.edit, color: Colors.white),
                  ),
                  onDismissed: (direction) {
                    final store = context.read<TransactionStore>();
                    if (direction == DismissDirection.startToEnd) {
                      if (tItem is exp.Expense) {
                        store.deleteExpense(tItem);
                      } else {
                        store.deleteIncome(tItem as Income);
                      }
                    } else {
                      _showTransactionDialog(context, transaction: tItem, t: t, currency: currency);
                    }
                  },
                  child: TransactionTile(
                    transaction: tItem,
                    onEdit: () => _showTransactionDialog(context, transaction: tItem, t: t, currency: currency),
                  ),
                )),
            const SizedBox(height: 16),
          ],
        );
      }).toList(),
    );
  }

  // ================= Add/Edit Dialog =================
  void _showTransactionDialog(BuildContext context,
      {dynamic transaction, required dynamic t, required String currency}) {
    final isEdit = transaction != null;

    final titleController = TextEditingController(text: isEdit ? transaction.title : '');
    final amountController = TextEditingController(text: isEdit ? transaction.amount.toString() : '');

    exp.ExpenseType dialogSelectedType =
        isEdit ? (transaction is exp.Expense ? transaction.type : exp.ExpenseType.income) : exp.ExpenseType.expense;

    dynamic dialogSelectedCategory = isEdit ? transaction.category : null;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) {
          final store = context.watch<TransactionStore>();
          final categories = dialogSelectedType == exp.ExpenseType.expense
              ? store.expenseCategories
              : store.incomeCategories;

          if (dialogSelectedCategory == null && categories.isNotEmpty) {
            dialogSelectedCategory = categories.first;
          }

          return AlertDialog(
            title: Text(isEdit ? t.of('edit_transaction') : t.of('add_transaction')),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(labelText: t.of('title')),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: "${t.of('amount')} ($currency)"),
                  ),
                  const SizedBox(height: 12),
                  DropdownButton<exp.ExpenseType>(
                    value: dialogSelectedType,
                    isExpanded: true,
                    items: exp.ExpenseType.values
                        .map((type) => DropdownMenuItem(
                              value: type,
                              child: Text(type == exp.ExpenseType.income ? t.of('income') : t.of('expense')),
                            ))
                        .toList(),
                    onChanged: (type) {
                      if (type != null) {
                        setDialogState(() {
                          dialogSelectedType = type;
                          final newCategories = type == exp.ExpenseType.expense
                              ? store.expenseCategories
                              : store.incomeCategories;
                          dialogSelectedCategory = newCategories.isNotEmpty ? newCategories.first : null;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButton(
                    value: dialogSelectedCategory,
                    isExpanded: true,
                    hint: Text(t.of('select_category')),
                    items: categories.map((c) {
                      String label = '';
                      if (c is cat.ExpenseCategory) label = c.name;
                      if (c is IncomeCategory) label = c.name;
                      return DropdownMenuItem(value: c, child: Text(label));
                    }).toList(),
                    onChanged: (c) {
                      if (c != null) setDialogState(() => dialogSelectedCategory = c);
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text(t.of('cancel'))),
              ElevatedButton(
                onPressed: () {
                  if (titleController.text.isEmpty ||
                      (double.tryParse(amountController.text) ?? 0) <= 0 ||
                      dialogSelectedCategory == null) return;

                  final store = context.read<TransactionStore>();

                  if (dialogSelectedType == exp.ExpenseType.expense) {
                    final newExpense = exp.Expense(
                      title: titleController.text,
                      amount: double.tryParse(amountController.text) ?? 0,
                      date: isEdit ? transaction.date : DateTime.now(),
                      category: dialogSelectedCategory as cat.ExpenseCategory,
                      type: dialogSelectedType,
                    );

                    if (isEdit) {
                      store.updateExpense(transaction as exp.Expense, newExpense);
                    } else {
                      store.addExpense(newExpense);
                    }
                  } else {
                    final newIncome = Income(
                      title: titleController.text,
                      amount: double.tryParse(amountController.text) ?? 0,
                      date: isEdit ? transaction.date : DateTime.now(),
                      category: dialogSelectedCategory as IncomeCategory,
                    );

                    if (isEdit) {
                      store.updateIncome(transaction as Income, newIncome);
                    } else {
                      store.addIncome(newIncome);
                    }
                  }

                  Navigator.pop(context);
                },
                child: Text(isEdit ? t.of('save') : t.of('add')),
              ),
            ],
          );
        },
      ),
    );
  }
}
