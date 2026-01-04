import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/expense_store.dart';
import '../../domain/models/expense_category.dart';
import '../../constants/colors.dart';
import '../state/settings_store.dart';

class ExpenseCategoriesPage extends StatelessWidget {
  const ExpenseCategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<ExpenseStore>();
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
        title: Text(t.of('expense_categories')), // تم الترجمة
        backgroundColor: kAppBarColor,
      ),
      body: categories.isEmpty
          ? Center(
              child: Text(
                t.of('no_categories_yet'), // تم الترجمة
                style: TextStyle(fontSize: 16, color: kTextSecondaryColor),
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
                return _CategoryCard(
                  category: c,
                  t:t,
                  onTap: () =>
                      _addOrEditCategoryDialog(context, store, t, category: c),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kPrimaryColor,
        onPressed: () => _addOrEditCategoryDialog(context, store, t),
        child: const Icon(Icons.add, color: kTextLightColor),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final ExpenseCategory category;
  final VoidCallback onTap;
final dynamic t;
  const _CategoryCard({
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
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              t.of(category.type.name.toLowerCase()), // ترجمة نوع الصرف
              style: TextStyle(
                fontSize: 13,
                color: kTextSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _addOrEditCategoryDialog(
  BuildContext context,
  ExpenseStore store,
  dynamic t, {
  ExpenseCategory? category,
}) {
  final isEdit = category != null;
  final nameController = TextEditingController(text: category?.name ?? "");

  ExpenseType type = category?.type ?? ExpenseType.Variable;
  Color color = category?.color ?? kCategoryBlue;
  IconData icon = category?.icon ?? Icons.category;

  final iconsList = [
    Icons.fastfood,
    Icons.directions_car,
    Icons.home,
    Icons.shopping_cart,
    Icons.school,
    Icons.local_cafe,
    Icons.movie,
    Icons.flight,
    Icons.phone,
    Icons.pets,
  ];

  final colorsList = [
    kCategoryBlue,
    kCategoryRed,
    kCategoryGreen,
    kCategoryOrange,
    kCategoryPurple,
    kCategoryTeal,
    kCategoryIndigo,
    kCategoryAmber,
  ];

  showDialog(
    context: context,
    builder: (_) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        backgroundColor: kCardBackgroundColor,
        title: Text(
          isEdit ? t.of('edit_category') : t.of('add_category'), // ترجمة
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
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: kDividerColor)),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: kPrimaryColor)),
                ),
                style: TextStyle(color: kTextDarkColor),
              ),
              const SizedBox(height: 12),
              DropdownButton<ExpenseType>(
                value: type,
                isExpanded: true,
                items: ExpenseType.values
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(
                          t.of(e.name.toLowerCase()), // ترجمة نوع
                          style: TextStyle(color: kTextDarkColor),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setDialogState(() => type = v!),
              ),
              const SizedBox(height: 12),
              Align(
                  alignment: Alignment.centerLeft,
                  child: Text(t.of('pick_color'),
                      style: TextStyle(color: kTextDarkColor))),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: colorsList.map((c) {
                  return GestureDetector(
                    onTap: () => setDialogState(() => color = c),
                    child: CircleAvatar(
                      backgroundColor: c,
                      child: color == c
                          ? const Icon(Icons.check, color: Colors.white)
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              Align(
                  alignment: Alignment.centerLeft,
                  child: Text(t.of('pick_icon'),
                      style: TextStyle(color: kTextDarkColor))),
              const SizedBox(height: 6),
              Wrap(
                spacing: 12,
                children: iconsList.map((ic) {
                  return GestureDetector(
                    onTap: () => setDialogState(() => icon = ic),
                    child: CircleAvatar(
                      backgroundColor: icon == ic
                          ? color.withOpacity(0.2)
                          : kDividerColor,
                      child: Icon(ic, color: icon == ic ? color : kTextSecondaryColor),
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
            style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isEmpty) return;

              if (isEdit) {
                final index = store.categories.indexOf(category!);
                store.updateCategory(
                  index,
                  category.copyWith(
                    name: name,
                    type: type,
                    color: color,
                    icon: icon,
                  ),
                );
              } else {
                store.addCategory(
                  ExpenseCategory(
                    name: name,
                    type: type,
                    color: color,
                    icon: icon,
                    createdAt: DateTime.now(),
                  ),
                );
              }
              Navigator.pop(context);
            },
            child: Text(t.of('save'), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ),
  );
}
