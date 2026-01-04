import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/models/expense_category.dart';
import '../state/settings_store.dart';

class ExpenseCard extends StatelessWidget {
  final ExpenseCategory category;
  final double totalForCategory;
  final double totalExpenses;
  final VoidCallback? onTap;

  const ExpenseCard({
    super.key,
    required this.category,
    required this.totalForCategory,
    required this.totalExpenses,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.watch<SettingsStore>().translations;
    final percent = totalExpenses == 0 ? 0.0 : totalForCategory / totalExpenses;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: category.color.withOpacity(0.15),
              child: Icon(category.icon, color: category.color),
            ),
            const Spacer(),
            Text(
              t.of(category.name), // ✅ ترجمة الاسم
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              "${totalForCategory.toStringAsFixed(2)} ${t.of('currency_symbol')}", // ✅ ديناميكية العملة
            ),
            const SizedBox(height: 6),
            LinearProgressIndicator(
              value: percent,
              color: category.color,
              backgroundColor: Colors.grey.shade200,
            ),
          ],
        ),
      ),
    );
  }
}
