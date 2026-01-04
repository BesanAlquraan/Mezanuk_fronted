import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../domain/models/expense.dart' as exp;
import '../../domain/models/income.dart';
import '../../domain/models/expense_category.dart';
import '../../domain/models/incomeCategory.dart';
import '../../domain/models/report_model.dart';
import '../state/expense_store.dart';
import '../state/income_store.dart';

class SiteReportStore extends ChangeNotifier {
  ExpenseStore expenseStore;
  IncomeStore incomeStore;

  SiteReportStore({required this.expenseStore, required this.incomeStore});

  // ================= Getters =================
  List<exp.Expense> get expenses => expenseStore.expenses;
  List<Income> get incomes => incomeStore.incomes;
  List<ExpenseCategory> get expenseCategories => expenseStore.categories;
  List<IncomeCategory> get incomeCategories => incomeStore.categories;

  List<SiteReportModel> get allTransactions {
    final list = <SiteReportModel>[];
    list.addAll(expenses.map((e) => SiteReportModel.fromExpense(e)));
    list.addAll(incomes.map((i) => SiteReportModel.fromIncome(i)));
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  // ================= Summary =================
  double totalIncome() => incomes.fold(0.0, (p, i) => p + i.amount);
  double totalExpense() => expenses.fold(0.0, (p, e) => p + e.amount);
  double netBalance() => totalIncome() - totalExpense();
  double largestExpense() =>
      expenses.isEmpty ? 0 : expenses.map((e) => e.amount).reduce((a, b) => a > b ? a : b);

  Map<String, double> totalPerExpenseCategory() {
    final map = <String, double>{};
    for (var c in expenseCategories) {
      map[c.name] = expenses.where((e) => e.category == c).fold(0.0, (p, e) => p + e.amount);
    }
    return map;
  }

  Map<String, double> totalPerIncomeCategory() {
    final map = <String, double>{};
    for (var c in incomeCategories) {
      map[c.name] = incomes.where((i) => i.category == c).fold(0.0, (p, i) => p + i.amount);
    }
    return map;
  }

  // ================= Chart Data =================
  List<BarChartGroupData> monthlyChartData({bool income = false}) {
    final now = DateTime.now();
    List<BarChartGroupData> bars = [];
    for (int month = 1; month <= 12; month++) {
      final total = income
          ? incomes
              .where((i) => i.date.year == now.year && i.date.month == month)
              .fold(0.0, (p, i) => p + i.amount)
          : expenses
              .where((e) => e.date.year == now.year && e.date.month == month)
              .fold(0.0, (p, e) => p + e.amount);

      bars.add(BarChartGroupData(
        x: month,
        barRods: [
          BarChartRodData(
            toY: total,
            color: income ? Colors.green : Colors.red,
            width: 16,
            borderRadius: BorderRadius.circular(6),
          )
        ],
      ));
    }
    return bars;
  }

  // ================= Export =================
  void exportAll() {
    for (var t in allTransactions) {
      print(
          "${t.date} | ${t.type == TransactionType.expense ? "Expense" : "Income"} | ${t.category.name} | ${t.title} | ${t.amount}");
    }
  }

  // ================= Update Stores Dynamically =================
  void updateStores({required ExpenseStore expenseStore, required IncomeStore incomeStore}) {
    this.expenseStore = expenseStore;
    this.incomeStore = incomeStore;
    notifyListeners();
  }
}
