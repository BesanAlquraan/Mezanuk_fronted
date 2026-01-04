import 'package:flutter/material.dart';
import '../../domain/models/incomeCategory.dart';
import '../../domain/models/income.dart';

class IncomeStore extends ChangeNotifier {
  final List<IncomeCategory> _categories = [];
  final List<Income> _incomes = [];

  List<IncomeCategory> get categories => _categories;
  List<Income> get incomes => _incomes;

  // ===== Category Management =====
  void addCategory(IncomeCategory category) {
    _categories.add(category);
    notifyListeners();
  }

  void updateCategory(int index, IncomeCategory category) {
    _categories[index] = category;
    notifyListeners();
  }

  void removeCategory(int index) {
    final catItem = _categories[index];
    _incomes.removeWhere((i) => i.category == catItem);
    _categories.removeAt(index);
    notifyListeners();
  }

  // ===== Income Management =====
  void addIncome(Income income) {
    _incomes.add(income);
    notifyListeners();
  }

  void updateIncome(int index, Income income) {
    _incomes[index] = income;
    notifyListeners();
  }

  void deleteIncome(int index) {
    _incomes.removeAt(index);
    notifyListeners();
  }

  // ===== Filtering & Summary =====
  List<Income> filterIncomes({
    String search = "",
    IncomeCategory? category,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return _incomes.where((i) {
      final matchSearch = i.title.toLowerCase().contains(search.toLowerCase());
      final matchCategory = category == null || i.category == category;
      final matchStart = startDate == null || i.date.isAfter(startDate.subtract(const Duration(days: 1)));
      final matchEnd = endDate == null || i.date.isBefore(endDate.add(const Duration(days: 1)));
      return matchSearch && matchCategory && matchStart && matchEnd;
    }).toList();
  }

  double total() => _incomes.fold(0.0, (sum, i) => sum + i.amount);
}
