import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../domain/models/expense.dart' as exp;
import '../../domain/models/income.dart';
import '../../domain/models/expense_category.dart' as cat;
import '../../domain/models/incomeCategory.dart';
import '../state/settings_store.dart';

class TransactionTile extends StatelessWidget {
  final dynamic transaction; // يمكن أن يكون Expense أو Income
  final VoidCallback? onEdit;

  const TransactionTile({
    super.key,
    required this.transaction,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.watch<SettingsStore>().translations;
    final isExpense = transaction is exp.Expense;

    final title = isExpense ? transaction.title : (transaction as Income).title;
    final amount = isExpense ? transaction.amount : (transaction as Income).amount;
    final date = isExpense ? transaction.date : (transaction as Income).date;
    final category = isExpense ? transaction.category : (transaction as Income).category;

    // إذا لم تحتوي الفئة على icon أو color، نضع قيم افتراضية
    final icon = (category is cat.ExpenseCategory || category is IncomeCategory)
        ? category.icon
        : Icons.attach_money;
    final color = (category is cat.ExpenseCategory || category is IncomeCategory)
        ? category.color
        : Colors.green;

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title),
      subtitle: Text(
        "${t.of(category.name)} • ${DateFormat('dd-MM-yyyy').format(date)}", // ✅ ترجمة الاسم
      ),
      trailing: Text("${t.of('currency_symbol')}${amount.toStringAsFixed(2)}"), // ✅ ديناميكية العملة
      onTap: onEdit,
    );
  }
}
