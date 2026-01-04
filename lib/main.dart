import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ================= State Stores =================
import 'package:my_app/presentation/state/expense_store.dart';
import 'package:my_app/presentation/state/income_store.dart';
import 'package:my_app/presentation/state/TransactionStore.dart';
import 'package:my_app/presentation/state/BudgetStore.dart';
import 'package:my_app/presentation/state/goal_store.dart';
import 'package:my_app/presentation/state/settings_store.dart';
import 'package:my_app/presentation/state/report_store.dart';

// ================= UI =================
import 'presentation/pages/home/home_wrapper.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        // ===== Base Stores =====
        ChangeNotifierProvider(create: (_) => ExpenseStore()),
        ChangeNotifierProvider(create: (_) => IncomeStore()),
        ChangeNotifierProvider(create: (_) => BudgetStore()),
        ChangeNotifierProvider(create: (_) => GoalStore()),
        ChangeNotifierProvider(create: (_) => SettingsStore()),

        // ===== Transaction Store =====
        ChangeNotifierProxyProvider2<ExpenseStore, IncomeStore, TransactionStore>(
          create: (context) => TransactionStore(
            expenseStore: context.read<ExpenseStore>(),
            incomeStore: context.read<IncomeStore>(),
          ),
          update: (_, expenseStore, incomeStore, transactionStore) => transactionStore!,
        ),

        // ===== Site Report Store =====
        ChangeNotifierProxyProvider2<ExpenseStore, IncomeStore, SiteReportStore>(
          create: (context) => SiteReportStore(
            expenseStore: context.read<ExpenseStore>(),
            incomeStore: context.read<IncomeStore>(),
          ),
          update: (_, expenseStore, incomeStore, siteReportStore) {
            siteReportStore!..updateStores(expenseStore: expenseStore, incomeStore: incomeStore);
            return siteReportStore;
          },
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // نستخدم watch هنا لكي يعيد بناء MaterialApp عند تغيير SettingsStore
    final settingsStore = context.watch<SettingsStore>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My App',
      locale: Locale(settingsStore.language), // لغة التطبيق ديناميكية
      theme: settingsStore.isDarkMode ? ThemeData.dark() : ThemeData.light(), // ثيم ديناميكي
      builder: (context, child) {
        // تطبيق TextScaleFactor لكل التطبيق
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaleFactor: settingsStore.textScale,
          ),
          child: child!,
        );
      },
      home: const HomeWrapper(), // الصفحة الرئيسية للتطبيق
    );
  }
}
