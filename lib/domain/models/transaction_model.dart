import 'package:flutter/foundation.dart';
import 'expense_category.dart';
import 'incomeCategory.dart';

enum ExpenseType { expense, income }

class TransactionModel {
  final String title;
  final double amount;
  final DateTime date;
  final ExpenseType type;
  final dynamic category; // ExpenseCategory أو IncomeCategory

  TransactionModel({
    required this.title,
    required this.amount,
    required this.date,
    required this.type,
    required this.category,
  });
}
