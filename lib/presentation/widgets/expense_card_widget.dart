import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/models/expense.dart';
import '../state/settings_store.dart';

class ExpenseCardWidget extends StatelessWidget {
  final Expense expense;
  final VoidCallback? onTap;

  const ExpenseCardWidget({super.key, required this.expense, this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = context.watch<SettingsStore>().translations;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: expense.category.color,
            child: Icon(expense.category.icon, color: Colors.white),
          ),
          title: Text(expense.title),
          subtitle: Text(t.of(expense.category.name)), // ✅ ترجمة الاسم
          trailing: Text("${t.of('currency_symbol')}${expense.amount.toStringAsFixed(2)}"), // ✅ ديناميكية العملة
        ),
      ),
    );
  }
}
