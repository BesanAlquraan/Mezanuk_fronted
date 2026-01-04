import 'package:flutter/material.dart';
import 'package:my_app/presentation/pages/income_category.dart';
import 'package:my_app/constants/colors.dart';
import 'package:provider/provider.dart';
import 'package:my_app/presentation/state/settings_store.dart';
import 'package:my_app/presentation/pages/expense_categories_page.dart';

class CategoryPage extends StatelessWidget {
  const CategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLargeScreen = size.width > 600;

    final store = Provider.of<SettingsStore>(context);
    final t = store.translations; // JSON translations

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: Text(t.of('categories')), // استخدم الترجمات
        backgroundColor: kAppBarColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isLargeScreen ? 2 : 1,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 3,
          ),
          children: [
            _CategoryCard(
              title: t.of('income_categories'), // ترجمة
              icon: Icons.arrow_downward,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const IncomeCategoriesPage()),
                );
              },
            ),
            _CategoryCard(
              title: t.of('expense_categories'), // ترجمة
              icon: Icons.arrow_upward,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ExpenseCategoriesPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: kCardBackgroundColor,
      borderRadius: BorderRadius.circular(12),
      elevation: 4,
      shadowColor: kShadowColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, color: kPrimaryColor, size: 40),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: kTextDarkColor,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: kDividerColor),
            ],
          ),
        ),
      ),
    );
  }
}
