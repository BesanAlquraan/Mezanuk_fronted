import 'package:flutter/material.dart';

class Budget {
  final String categoryId;
  final String categoryName;

  double limit;
  double spent;
bool isMonthly;
  /// جديد: الفترة يمكن أن تكون 'Monthly' أو 'Weekly'
  String period;

  Budget({
    required this.categoryId,
    required this.categoryName,
    required this.limit,
    this.spent = 0,
    this.period = 'Monthly',
    this.isMonthly = true, // القيمة الافتراضية
  });

  /// نسبة الصرف (0 → فوق 1)
  double get spentPercentage => limit == 0 ? 0 : spent / limit;

  /// Health لكل تصنيف (0 → 1)
  double get healthPercentage => (1 - spentPercentage).clamp(0, 1);

  /// Health كنسبة مئوية (0 → 100)
  int get healthScore => (healthPercentage * 100).round();

  /// مؤشر صحة Budget
  bool get isHealthy => spentPercentage < 0.7;

  /// لون الصحة للـ UI
  Color get healthColor {
    if (healthScore >= 70) return Colors.green;
    if (healthScore >= 40) return Colors.orange;
    return Colors.red;
  }
}
