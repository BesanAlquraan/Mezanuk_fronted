import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../domain/models/expense.dart' as exp;
import '../../domain/models/income.dart';
import '../../domain/models/expense_category.dart';
import '../../domain/models/incomeCategory.dart';
import 'expense_store.dart';
import 'income_store.dart';
import 'package:intl/intl.dart';

class TransactionStore extends ChangeNotifier {
  final ExpenseStore expenseStore;
  final IncomeStore incomeStore;

  TransactionStore({required this.expenseStore, required this.incomeStore});

  // =================== Getters ===================
  List<exp.Expense> get expenses => expenseStore.expenses;
  List<Income> get incomes => incomeStore.incomes;

  List<ExpenseCategory> get expenseCategories => expenseStore.categories;
  List<IncomeCategory> get incomeCategories => incomeStore.categories;

  // =================== CRUD ===================
  void addExpense(exp.Expense expense) {
    expenseStore.addExpense(expense);
    notifyListeners();
  }

  void updateExpense(exp.Expense oldExpense, exp.Expense newExpense) {
    final index = expenseStore.expenses.indexOf(oldExpense);
    if (index != -1) {
      expenseStore.updateExpense(index, newExpense);
      notifyListeners();
    }
  }

  void deleteExpense(exp.Expense expense) {
    final index = expenseStore.expenses.indexOf(expense);
    if (index != -1) {
      expenseStore.deleteExpense(index);
      notifyListeners();
    }
  }

  void addIncome(Income income) {
    incomeStore.addIncome(income);
    notifyListeners();
  }

  void updateIncome(Income oldIncome, Income newIncome) {
    final index = incomeStore.incomes.indexOf(oldIncome);
    if (index != -1) {
      incomeStore.updateIncome(index, newIncome);
      notifyListeners();
    }
  }

  void deleteIncome(Income income) {
    final index = incomeStore.incomes.indexOf(income);
    if (index != -1) {
      incomeStore.deleteIncome(index);
      notifyListeners();
    }
  }

  // =================== Filtering ===================
  List<dynamic> filterTransactions({
    String search = "",
    exp.ExpenseType? type,
    dynamic category,
    double? minAmount,
    double? maxAmount,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    List<dynamic> all = [...expenses, ...incomes];

    return all.where((t) {
      final title = t is exp.Expense ? t.title : (t as Income).title;
      final amount = t is exp.Expense ? t.amount : (t as Income).amount;
      final tDate = t is exp.Expense ? t.date : (t as Income).date;
      final tType = t is exp.Expense ? t.type : exp.ExpenseType.income;
      final tCategory = t is exp.Expense ? t.category : (t as Income).category;

      if (search.isNotEmpty && !title.toLowerCase().contains(search.toLowerCase())) return false;
      if (type != null && tType != type) return false;
      if (category != null && tCategory != category) return false;
      if (minAmount != null && amount < minAmount) return false;
      if (maxAmount != null && amount > maxAmount) return false;
      if (startDate != null && tDate.isBefore(startDate)) return false;
      if (endDate != null && tDate.isAfter(endDate)) return false;

      return true;
    }).toList();
  }

  // =================== Grouping ===================
  Map<String, List<dynamic>> groupByDate(List<dynamic> list) {
    Map<String, List<dynamic>> map = {};
    for (var t in list) {
      final date = t is exp.Expense ? t.date : (t as Income).date;
      final key = "${date.year}-${date.month}-${date.day}";
      map.putIfAbsent(key, () => []);
      map[key]!.add(t);
    }
    return map;
  }

  // =================== Summary ===================
  double totalToday({exp.ExpenseType? type}) {
    final today = DateTime.now();
    return expenses
        .where((e) => _isSameDay(e.date, today) && (type == null || e.type == type))
        .fold(0.0, (prev, e) => prev + e.amount);
  }

  double totalThisMonth({exp.ExpenseType? type}) {
    final now = DateTime.now();
    return expenses
        .where((e) => e.date.year == now.year && e.date.month == now.month && (type == null || e.type == type))
        .fold(0.0, (prev, e) => prev + e.amount);
  }

  double largestExpense({exp.ExpenseType? type}) {
    final filtered = expenses.where((e) => type == null || e.type == type).toList();
    if (filtered.isEmpty) return 0.0;
    return filtered.map((e) => e.amount).reduce((a, b) => a > b ? a : b);
  }

  double maxMonthlyExpense() {
    if (expenses.isEmpty) return 100.0;
    return expenses.map((e) => e.amount).reduce((a, b) => a > b ? a : b);
  }

  double totalForCategory(dynamic category, {exp.ExpenseType? type}) {
    if (category is ExpenseCategory) {
      return expenses.where((e) => e.category == category && (type == null || e.type == type)).fold(0.0, (prev, e) => prev + e.amount);
    } else if (category is IncomeCategory) {
      return incomes.where((i) => i.category == category).fold(0.0, (prev, i) => prev + i.amount);
    }
    return 0.0;
  }

  // =================== Chart Data ===================
  List<BarChartGroupData> monthlyChartData({exp.ExpenseType? type}) {
    final now = DateTime.now();
    List<BarChartGroupData> bars = [];
    for (int month = 1; month <= 12; month++) {
      final total = expenses
          .where((e) => e.date.year == now.year && e.date.month == month && (type == null || e.type == type))
          .fold(0.0, (prev, e) => prev + e.amount);

      bars.add(
        BarChartGroupData(
          x: month,
          barRods: [
            BarChartRodData(
              toY: total,
              color: const Color(0xff6A5AE0),
              width: 16,
              borderRadius: BorderRadius.circular(6),
            ),
          ],
        ),
      );
    }
    return bars;
  }

  // =================== Export ===================
  void exportTransactions() {
    for (var e in expenses) {
      print("${e.date} | ${e.category.name} | ${e.title} | ${e.amount}");
    }
    for (var i in incomes) {
      print("${i.date} | ${i.category.name} | ${i.title} | ${i.amount}");
    }
  }

  // =================== Helper ===================
  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
