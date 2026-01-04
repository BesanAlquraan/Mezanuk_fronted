import 'incomeCategory.dart';

class Income {
  final String title;
  final double amount;
  final DateTime date;
  final IncomeCategory category;

  Income({
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
  });

  Income copyWith({
    String? title,
    double? amount,
    DateTime? date,
    IncomeCategory? category,
  }) {
    return Income(
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      category: category ?? this.category,
    );
  }
}
