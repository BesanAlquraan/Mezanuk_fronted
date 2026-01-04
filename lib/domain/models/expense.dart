import 'expense_category.dart';

enum ExpenseType { income, expense } // جديد

class Expense {
  final String title;
  final double amount;
  final DateTime date;
  final ExpenseCategory category;
  final ExpenseType type; // جديد

  Expense({
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    this.type = ExpenseType.expense, // القيمة الافتراضية: Expense
  });
}
