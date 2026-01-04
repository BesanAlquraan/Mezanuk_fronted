import 'package:flutter/material.dart';
import '../../domain/models/budget.dart';
import '../../domain/models/expense.dart';

class MonthlyBudgetHealth {
  final DateTime month;
  final int healthScore;

  MonthlyBudgetHealth({
    required this.month,
    required this.healthScore,
  });
}

class BudgetStore extends ChangeNotifier {
  final List<Budget> _budgets = [];
  final List<MonthlyBudgetHealth> _monthlyHealth = [];

  List<Budget> get budgets => _budgets;
  List<MonthlyBudgetHealth> get monthlyHealth => _monthlyHealth;

  // ===============================
  // PERIOD TOGGLE (Monthly / Weekly)
  // ===============================
  bool isMonthly = true;

  void setPeriod(bool monthly) {
    isMonthly = monthly;
    notifyListeners();
  }

  // ===============================
  // CRUD
  // ===============================
  void addBudget(Budget budget) {
    _budgets.add(budget);
    notifyListeners();
  }

  void updateBudget(String categoryId, double newLimit) {
    final index = _budgets.indexWhere((b) => b.categoryId == categoryId);
    if (index != -1) {
      _budgets[index] = Budget(
        categoryId: _budgets[index].categoryId,
        categoryName: _budgets[index].categoryName,
        limit: newLimit,
        spent: _budgets[index].spent,
        isMonthly: _budgets[index].isMonthly,
      );
      notifyListeners();
    }
  }

  void deleteBudget(String categoryId) {
    _budgets.removeWhere((b) => b.categoryId == categoryId);
    notifyListeners();
  }

  // ===============================
  // CALCULATIONS
  // ===============================
  void calculateSpentFromTransactions(List<Expense> transactions) {
    for (final budget in _budgets) {
      final total = transactions
          .where((e) => e.category.name == budget.categoryName)
          .fold(0.0, (sum, e) => sum + e.amount);
      budget.spent = total;
    }
    notifyListeners();
  }

  // ===============================
  // SMART INSIGHTS 🧠
  // ===============================
  Budget? getMostSpentBudget() {
    if (_budgets.isEmpty) return null;
    return _budgets.reduce((a, b) => a.spent > b.spent ? a : b);
  }

  Budget? getLeastHealthyBudget() {
    if (_budgets.isEmpty) return null;
    return _budgets.reduce(
        (a, b) => a.spentPercentage > b.spentPercentage ? a : b);
  }

  double calculateMonthlyDifference({
    required double currentMonth,
    required double lastMonth,
  }) {
    if (lastMonth == 0) return 0;
    return ((currentMonth - lastMonth) / lastMonth) * 100;
  }

  String monthlyInsight(double current, double last) {
    final diff =
        calculateMonthlyDifference(currentMonth: current, lastMonth: last);
    if (diff > 0) {
      return "📈 Spending increased by ${diff.toStringAsFixed(1)}% compared to last month";
    }
    if (diff < 0) {
      return "📉 Great! Spending decreased by ${diff.abs().toStringAsFixed(1)}%";
    }
    return "➖ Spending unchanged from last month";
  }

  // ===============================
  // BUDGET HEALTH SCORE 🔋
  // ===============================
  int get healthScore {
    if (_budgets.isEmpty) return 100;

    double score = 0;
    for (final b in _budgets) {
      if (b.spentPercentage < 0.7) score += 100;
      else if (b.spentPercentage < 0.9) score += 60;
      else score += 20;
    }
    return (score / _budgets.length).round();
  }

  Color get healthColor {
    final score = healthScore;
    if (score >= 70) return Colors.green;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }

  String get healthStatusText {
    final score = healthScore;
    if (score >= 70) return "Excellent 💚";
    if (score >= 40) return "Needs Attention ⚠️";
    return "Danger 🚨";
  }

  // ===============================
  // MONTHLY HEALTH
  // ===============================
  void saveMonthlyHealth(DateTime month) {
    final existing = _monthlyHealth.indexWhere(
        (m) => m.month.year == month.year && m.month.month == month.month);
    if (existing != -1) {
      _monthlyHealth[existing] =
          MonthlyBudgetHealth(month: month, healthScore: healthScore);
    } else {
      _monthlyHealth.add(MonthlyBudgetHealth(
        month: month,
        healthScore: healthScore,
      ));
    }
  }

  int predictNextMonthHealth() {
    if (_monthlyHealth.length < 2) return healthScore;

    final last = _monthlyHealth.last.healthScore;
    final beforeLast = _monthlyHealth[_monthlyHealth.length - 2].healthScore;

    final trend = last - beforeLast;

    return (last + trend).clamp(0, 100);
  }
}

// ===============================
// BUDGET EXTENSIONS
// ===============================
extension BudgetExtensions on Budget {
  double get spentPercentage => limit == 0 ? 0 : spent / limit;

  Color get healthColor {
    if (spentPercentage < 0.7) return Colors.green;
    if (spentPercentage < 0.9) return Colors.orange;
    return Colors.red;
  }
}
