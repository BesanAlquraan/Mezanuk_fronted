import 'package:flutter/material.dart';

enum IncomeType { Salary, Bonus, Other }

class IncomeCategory {
  final String name;
  final IncomeType type;
  final Color color;
  final IconData icon;
  final DateTime createdAt;

  IncomeCategory({
    required this.name,
    required this.type,
    required this.color,
    required this.icon,
    required this.createdAt,
  });

  IncomeCategory copyWith({
    String? name,
    IncomeType? type,
    Color? color,
    IconData? icon,
    DateTime? createdAt,
  }) {
    return IncomeCategory(
      name: name ?? this.name,
      type: type ?? this.type,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
