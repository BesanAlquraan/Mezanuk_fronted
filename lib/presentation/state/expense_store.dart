import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../domain/models/expense.dart' as exp;
import '../../domain/models/expense_category.dart' as cat;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ExpenseStore extends ChangeNotifier {
  final List<cat.ExpenseCategory> _categories = [];
  final List<exp.Expense> _expenses = [];

  List<cat.ExpenseCategory> get categories => _categories;
  List<exp.Expense> get expenses => _expenses;

  // ===== فلترة الكاتيجوري حسب النوع =====
  List<cat.ExpenseCategory> getCategoriesByType(exp.ExpenseType type) {
    return _categories.where((c) => c.type == type).toList();
  }

  // ===== Category Management =====
  void addCategory(cat.ExpenseCategory category) {
    _categories.add(category);
    notifyListeners();
  }

  void updateCategory(int index, cat.ExpenseCategory category) {
    _categories[index] = category;
    notifyListeners();
  }

  void deleteCategory(int index) {
    final catItem = _categories[index];
    _expenses.removeWhere((e) => e.category == catItem);
    _categories.removeAt(index);
    notifyListeners();
  }

  // ===== Expense Management =====
  void addExpense(exp.Expense expense) {
    _expenses.add(expense);
    notifyListeners();
  }

  void updateExpense(int index, exp.Expense expense) {
    _expenses[index] = expense;
    notifyListeners();
  }

  void deleteExpense(int index) {
    _expenses.removeAt(index);
    notifyListeners();
  }

  // ===== Filtering & Search =====
  List<exp.Expense> filterExpenses({
    String search = "",
    cat.ExpenseCategory? category,
    exp.ExpenseType? type,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return _expenses.where((e) {
      final matchSearch = e.title.toLowerCase().contains(search.toLowerCase());
      final matchCategory = category == null || e.category == category;
      final matchType = type == null || e.type == type;
      final matchStart = startDate == null || e.date.isAfter(startDate.subtract(const Duration(days: 1)));
      final matchEnd = endDate == null || e.date.isBefore(endDate.add(const Duration(days: 1)));
      return matchSearch && matchCategory && matchType && matchStart && matchEnd;
    }).toList();
  }

  // ===== Summary Calculations =====
  double total({exp.ExpenseType? type}) =>
      _expenses.where((e) => type == null || e.type == type).fold(0.0, (sum, e) => sum + e.amount);

  double totalToday({exp.ExpenseType? type}) {
    final today = DateTime.now();
    return _expenses.where((e) {
      final sameDay = e.date.year == today.year && e.date.month == today.month && e.date.day == today.day;
      final matchType = type == null || e.type == type;
      return sameDay && matchType;
    }).fold(0.0, (sum, e) => sum + e.amount);
  }

  double totalThisMonth({exp.ExpenseType? type}) {
    final now = DateTime.now();
    return _expenses.where((e) {
      final sameMonth = e.date.year == now.year && e.date.month == now.month;
      final matchType = type == null || e.type == type;
      return sameMonth && matchType;
    }).fold(0.0, (sum, e) => sum + e.amount);
  }

  double largestExpense({exp.ExpenseType? type}) {
    final filtered = _expenses.where((e) => type == null || e.type == type).toList();
    if (filtered.isEmpty) return 0.0;
    return filtered.map((e) => e.amount).reduce((a, b) => a > b ? a : b);
  }

  double totalForCategory(cat.ExpenseCategory category, {exp.ExpenseType? type}) {
    return _expenses
        .where((e) => e.category == category && (type == null || e.type == type))
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  // ===== Grouping =====
  Map<String, List<exp.Expense>> groupByDate(List<exp.Expense> list) {
    Map<String, List<exp.Expense>> map = {};
    for (var expense in list) {
      String key = "${expense.date.year}-${expense.date.month}-${expense.date.day}";
      map.putIfAbsent(key, () => []);
      map[key]!.add(expense);
    }
    return map;
  }

  // ===== Bar Chart / Chart Data =====
  double maxMonthlyExpense({exp.ExpenseType? type}) {
    if (_expenses.isEmpty) return 100.0;
    Map<int, double> monthlyTotals = {};
    for (var e in _expenses.where((e) => type == null || e.type == type)) {
      monthlyTotals[e.date.month] = (monthlyTotals[e.date.month] ?? 0) + e.amount;
    }
    return (monthlyTotals.values.isEmpty ? 0.0 : monthlyTotals.values.reduce((a, b) => a > b ? a : b)) * 1.2;
  }

  List<BarChartGroupData> monthlyChartData({exp.ExpenseType? type}) {
    Map<int, double> monthlyTotals = {};
    for (var e in _expenses.where((e) => type == null || e.type == type)) {
      monthlyTotals[e.date.month] = (monthlyTotals[e.date.month] ?? 0) + e.amount;
    }
    return List.generate(12, (i) {
      final month = i + 1;
      final value = monthlyTotals[month] ?? 0.0;
      return BarChartGroupData(
        x: month,
        barRods: [
          BarChartRodData(
            toY: value,
            color: const Color(0xff6A5AE0),
            width: 16,
            borderRadius: BorderRadius.circular(6),
          ),
        ],
      );
    });
  }

  // ===== Export PDF / Excel =====
  void exportTransactions({exp.ExpenseType? type}) async {
    final filtered = _expenses.where((e) => type == null || e.type == type).toList();
    if (filtered.isEmpty) return;

    // --- PDF ---
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (context) => pw.ListView.builder(
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final e = filtered[index];
            return pw.Text(
                "${e.date.day}-${e.date.month}-${e.date.year} | ${e.category.name} | ${e.title} | ${e.type.name} | \$${e.amount}");
          },
        ),
      ),
    );
    await Printing.layoutPdf(onLayout: (format) => pdf.save());

    // --- Excel ---
    // يمكنك إضافة كود حفظ Excel هنا
  }
}
