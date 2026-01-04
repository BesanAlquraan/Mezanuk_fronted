import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_app/presentation/state/income_store.dart';
import 'package:my_app/domain/models/incomeCategory.dart';
import 'package:my_app/constants/colors.dart';
import '../state/settings_store.dart';

class IncomeCategoriesPage extends StatelessWidget {
  const IncomeCategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<IncomeStore>();
    final categories = store.categories;

    final screenWidth = MediaQuery.of(context).size.width;
    final crossCount = screenWidth > 900
        ? 4
        : screenWidth > 600
            ? 3
            : 2;

    final settingsStore = Provider.of<SettingsStore>(context);
    final t = settingsStore.translations;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: Text(t.of('income_categories')), // ترجمة
        backgroundColor: kAppBarColor,
      ),
      body: categories.isEmpty
          ? Center(
              child: Text(
                t.of('no_categories_yet'), // ترجمة
                style: TextStyle(color: kTextSecondaryColor),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: categories.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossCount,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                mainAxisExtent: 160,
              ),
              itemBuilder: (context, index) {
                final c = categories[index];
                return _IncomeCategoryCard(
                  category: c,
                  t: t, // تمرير t
                  onTap: () => _addOrEditIncomeCategoryDialog(context, store, t, category: c),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kAppBarColor,
        onPressed: () => _addOrEditIncomeCategoryDialog(context, store, t),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _IncomeCategoryCard extends StatelessWidget {
  final IncomeCategory category;
  final VoidCallback onTap;
  final dynamic t; // إضافة t

  const _IncomeCategoryCard({
    required this.category,
    required this.onTap,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: kCardBackgroundColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: kShadowColor,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: category.color.withOpacity(0.15),
              child: Icon(category.icon, color: category.color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              category.name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: kTextDarkColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              t.of(category.type.name.toLowerCase()), // ترجمة نوع الدخل
              style: TextStyle(fontSize: 13, color: kTextSecondaryColor),
            ),
          ],
        ),
      ),
    );
  }
}

void _addOrEditIncomeCategoryDialog(
  BuildContext context,
  IncomeStore store,
  dynamic t, { // تمرير t
  IncomeCategory? category,
}) {
  final isEdit = category != null;
  final nameController = TextEditingController(text: category?.name ?? "");
  IncomeType type = category?.type ?? IncomeType.Salary;
  Color color = category?.color ?? kCategoryGreen;
  IconData icon = category?.icon ?? Icons.attach_money;

  final iconsList = [
    Icons.attach_money,
    Icons.card_giftcard,
    Icons.savings,
    Icons.monetization_on,
  ];

  final colorsList = [
    kCategoryGreen,
    kCategoryBlue,
    kCategoryOrange,
    kCategoryPurple,
    kCategoryTeal,
  ];

  showDialog(
    context: context,
    builder: (_) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        backgroundColor: kCardBackgroundColor,
        title: Text(
          isEdit ? t.of('edit_income_category') : t.of('add_income_category'), // ترجمة
          style: TextStyle(color: kTextDarkColor),
        ),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: t.of('category_name'), // ترجمة
                  labelStyle: TextStyle(color: kTextSecondaryColor),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: kPrimaryColor),
                  ),
                ),
                style: TextStyle(color: kTextDarkColor),
              ),
              const SizedBox(height: 12),
              DropdownButton<IncomeType>(
                value: type,
                isExpanded: true,
                items: IncomeType.values
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(
                          t.of(e.name.toLowerCase()), // ترجمة نوع الدخل
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setDialogState(() => type = v!),
              ),
              const SizedBox(height: 12),
              Align(
                  alignment: Alignment.centerLeft,
                  child: Text(t.of('pick_color'), style: TextStyle(color: kTextDarkColor))),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: colorsList.map((c) {
                  return GestureDetector(
                    onTap: () => setDialogState(() => color = c),
                    child: CircleAvatar(
                      backgroundColor: c,
                      child: color == c ? const Icon(Icons.check, color: Colors.white) : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              Align(
                  alignment: Alignment.centerLeft,
                  child: Text(t.of('pick_icon'), style: TextStyle(color: kTextDarkColor))),
              const SizedBox(height: 6),
              Wrap(
                spacing: 12,
                children: iconsList.map((ic) {
                  return GestureDetector(
                    onTap: () => setDialogState(() => icon = ic),
                    child: CircleAvatar(
                      backgroundColor: icon == ic ? color.withOpacity(0.2) : kDividerColor,
                      child: Icon(ic, color: icon == ic ? color : kTextDarkColor),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t.of('cancel'), style: TextStyle(color: kTextSecondaryColor)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: kButtonPrimaryColor),
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isEmpty) return;
              if (isEdit) {
                final index = store.categories.indexOf(category!);
                store.updateCategory(index, category.copyWith(name: name, type: type, color: color, icon: icon));
              } else {
                store.addCategory(IncomeCategory(name: name, type: type, color: color, icon: icon, createdAt: DateTime.now()));
              }
              Navigator.pop(context);
            },
            child: Text(t.of('save')), // ترجمة
          ),
        ],
      ),
    ),
  );
}
