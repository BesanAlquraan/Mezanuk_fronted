import 'package:flutter/foundation.dart';
import 'expense_category.dart';
import 'incomeCategory.dart';
import 'expense.dart' as exp;
import 'income.dart';

enum TransactionType { expense, income }

class SiteReportModel {
  final String title;
  final double amount;
  final DateTime date;
  final TransactionType type;
  final dynamic category; // ExpenseCategory أو IncomeCategory

  SiteReportModel({
    required this.title,
    required this.amount,
    required this.date,
    required this.type,
    required this.category,
  });

  // ✅ Getter لتسهيل الوصول لاسم الفئة
  String get categoryName {
    if (category == null) return "Unknown";
    return category.name ?? "Unknown";
  }

  factory SiteReportModel.fromExpense(exp.Expense e) {
    return SiteReportModel(
      title: e.title,
      amount: e.amount,
      date: e.date,
      type: TransactionType.expense,
      category: e.category,
    );
  }

  factory SiteReportModel.fromIncome(Income i) {
    return SiteReportModel(
      title: i.title,
      amount: i.amount,
      date: i.date,
      type: TransactionType.income,
      category: i.category,
    );
  }
}
