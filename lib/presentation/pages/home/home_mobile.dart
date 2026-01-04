import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_app/constants/colors.dart';
import 'package:my_app/presentation/pages/authentication/loginPage.dart';
import 'package:my_app/presentation/pages/settings_page.dart';
import 'package:my_app/presentation/pages/CategoryPage.dart';
import 'package:my_app/presentation/pages/AdvisorScreen.dart';
import 'package:my_app/presentation/pages/BudgetPage.dart';
import 'package:my_app/presentation/state/settings_store.dart';
import 'package:my_app/presentation/pages/expense_management_page.dart';
import 'package:my_app/presentation/pages/transactions_page.dart';
import 'package:my_app/presentation/pages/report_page.dart';
import 'package:my_app/presentation/pages/goals_page.dart';
class HomePage extends StatelessWidget {
  bool userHasImage = false;
  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final settings = context.watch<SettingsStore>();

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: kBottomNavBarColor,
        foregroundColor: kTextDarkColor,
        title: Text(
          settings.language == 'en' ? 'Home' : 'الرئيسية',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20 * settings.textScale,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: PopupMenuButton<int>(
              icon: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey[200],
                backgroundImage: userHasImage
                    ? const AssetImage('assets/avatar.png')
                    : null,
                child: userHasImage
                    ? null
                    : const Icon(Icons.person, color: kDotInactiveColor),
              ),
              itemBuilder: (context) => [
                PopupMenuItem<int>(
                    value: 0,
                    child: Text(settings.language == 'en' ? 'Login' : 'تسجيل الدخول')),
                PopupMenuItem<int>(
                    value: 1,
                    child: Text(settings.language == 'en' ? 'Profile' : 'الملف الشخصي')),
                PopupMenuItem<int>(
                    value: 2,
                    child: Text(settings.language == 'en' ? 'Settings' : 'الإعدادات')),
                PopupMenuItem<int>(
                    value: 3,
                    child: Text(settings.language == 'en' ? 'Logout' : 'تسجيل الخروج')),
              ],
              onSelected: (value) {
                switch (value) {
                  case 0:
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const LoginPage()));
                    break;
                  case 2:
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const SettingsPage()));
                    break;
                  case 1:
                  case 3:
                    // إضافة وظائف الملف الشخصي وتسجيل الخروج لاحقاً
                    break;
                }
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: kBottomNavBarColor,
        elevation: 10,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.home),
                    onPressed: () {},
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(Icons.receipt_long),
                    onPressed: () {},
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.savings),
                    onPressed: () {},
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(Icons.category),
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(size.width * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              settings.language == 'en' ? 'Welcome !' : 'مرحباً !',
              style: TextStyle(
                  fontSize: 22 * settings.textScale,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              settings.language == 'en' ? 'Hi, Mohammed' : 'مرحباً، محمد',
              style: TextStyle(
                  color: kDotInactiveColor, fontSize: 16 * settings.textScale),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: size.width > 600 ? 3 : 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  HomeCard(
                    title: settings.language == 'en'
                        ? 'Expense Management'
                        : 'إدارة المصاريف',
                    icon: Icons.receipt_long,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ExpenseManagementPage()),
                      );
                    },
                  ),
                  HomeCard(
                    title: settings.language == 'en' ? 'Transactions' : 'المعاملات',
                    icon: Icons.account_balance_wallet,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const TransactionsPage()),
                      );
                    },
                  ),
                  HomeCard(
                    title: settings.language == 'en' ? 'Budget' : 'الميزانية',
                    icon: Icons.savings,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const BudgetPage()),
                      );
                    },
                  ),
                  HomeCard(
                    title: settings.language == 'en' ? 'Report' : 'التقارير',
                    icon: Icons.insert_chart_outlined,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ReportsPage()),
                      );
                    },
                  ),
                  HomeCard(
                    title: settings.language == 'en' ? 'Advisor' : 'المستشار',
                    icon: Icons.school,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => AdvisorPage()),
                      );
                    },
                  ),
                  HomeCard(
                    title: settings.language == 'en' ? 'Category' : 'الفئات',
                    icon: Icons.category,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => CategoryPage()),
                      );
                    },
                  ),
                   HomeCard(
                    title: settings.language == 'en' ? 'Goals' : 'الاهداف',
                    icon: Icons.category,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => GoalsPage ()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;

  const HomeCard({
    super.key,
    required this.title,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsStore>();
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: kBottomNavBarColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 60, color: kAppBarColor),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16 * settings.textScale,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
