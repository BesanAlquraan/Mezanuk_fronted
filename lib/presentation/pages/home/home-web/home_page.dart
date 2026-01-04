import 'package:flutter/material.dart';

class HomePageWeb extends StatelessWidget {
  const HomePageWeb({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Smart Finance',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(onPressed: () {}, child: const Text('Home')),
          TextButton(onPressed: () {}, child: const Text('Features')),
          TextButton(onPressed: () {}, child: const Text('Reports')),
          TextButton(onPressed: () {}, child: const Text('Login')),
          const SizedBox(width: 20),
        ],
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 60),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Manage Your Money Smarter',
                          style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Track expenses, set budgets, and achieve your financial goals with our smart finance system.',
                          style: TextStyle(fontSize: 18, color: Colors.black54),
                        ),
                        SizedBox(height: 30),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Image.network(
                      'https://cdn-icons-png.flaticon.com/512/3135/3135706.png',
                      height: 300,
                    ),
                  ),
                ],
              ),
            ),

            // Features Section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 40),
              color: Colors.white,
              child: Column(
                children: [
                  const Text(
                    'Main Features',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: const [
                      FeatureCard(
                        icon: Icons.account_balance_wallet,
                        title: 'Expense Tracking',
                        description: 'Monitor all your daily expenses easily.',
                      ),
                      FeatureCard(
                        icon: Icons.pie_chart,
                        title: 'Budget Planning',
                        description: 'Create budgets and control your spending.',
                      ),
                      FeatureCard(
                        icon: Icons.trending_up,
                        title: 'Reports',
                        description: 'Visual reports to analyze your finances.',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.black,
              child: const Center(
                child: Text(
                  '© 2025 Smart Finance System',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 260,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(icon, size: 50, color: Colors.blue),
            const SizedBox(height: 20),
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(description, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}
