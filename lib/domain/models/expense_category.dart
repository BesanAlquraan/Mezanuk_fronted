import 'package:flutter/material.dart';

enum ExpenseType { Fixed, Variable, Emergency }

class ExpenseCategory {
  final String name;
  final IconData icon;
  final Color color;
  final ExpenseType type;
  final DateTime createdAt;

  ExpenseCategory({
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
    required this.createdAt,
  });

  ExpenseCategory copyWith({
    String? name,
    IconData? icon,
    Color? color,
    ExpenseType? type,
    DateTime? createdAt,
  }) {
    return ExpenseCategory(
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
