import 'package:flutter/material.dart';
import 'package:my_app/constants/colors.dart';
import 'package:my_app/ui/authentication/loginPage.dart';
class HomePage extends StatelessWidget {
  bool userHasImage = false;
  HomePage({super.key});
  
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor:  kBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: kBottomNavBarColor,
        foregroundColor: kTextDarkColor,
        title: const Text('Home', style: TextStyle(fontWeight: FontWeight.w600)),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {},
        ),
       actions: [
  Padding(
    padding: const EdgeInsets.only(right: 16),
    child: PopupMenuButton<int>(
      
      icon: CircleAvatar(
        radius: 20,
        backgroundColor: Colors.grey[200],
        backgroundImage: userHasImage 
      ? AssetImage('assets/avatar.png')  // إذا المستخدم عنده صورة
      : null,                             // إذا لا يوجد صورة، استخدمي child
  child: userHasImage
      ? null                              // لا شيء إذا هناك صورة
      : const Icon(Icons.person, color: kDotInactiveColor),    ),
      itemBuilder: (context) => [
        const PopupMenuItem<int>(value: 0, child: Text('Login')),
        const PopupMenuItem<int>(value: 1, child: Text('Profile')),
        const PopupMenuItem<int>(value: 2, child: Text('Settings')),
        const PopupMenuItem<int>(value: 3, child: Text('Notifications')),
        const PopupMenuItem<int>(value: 2, child: Text('Logout')),
    
    
      ],
      onSelected: (value) {
        switch (value) {
          case 0:
            Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
            break;
          case 1:
            // تسجيل الخروج
            break;
          case 2:
            // الانتقال للإعدادات
            break;
        }
      },
    ),
  ),
],

      ),
      // تم حذف FloatingActionButton

      bottomNavigationBar: BottomAppBar(
        // shape: const CircularNotchedRectangle(), // تم التعليق لأنها غير مطلوبة بدون FAB
        color: kBottomNavBarColor,
        elevation: 10,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // الجانب الأيسر
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.home),
                    onPressed: () {
                      // انتقل للصفحة الرئيسية
                    },
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(Icons.receipt_long),
                    onPressed: () {
                      // انتقل لمصاريف المستخدم
                    },
                  ),
                ],
              ),

              // الجانب الأيمن
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.savings),
                    onPressed: () {
                      // انتقل للأهداف
                    },
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(Icons.category),
                    onPressed: () {
                      // انتقل للملف الشخصي
                    },
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
            const Text('Welcome !',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('Hi, Mohammed', style: TextStyle(color: kDotInactiveColor)),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: size.width > 600 ? 3 : 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: const [
                  HomeCard(
                    title: 'Expense Management',
                    icon: Icons.receipt_long,
                  ),
                  HomeCard(
                    title: 'Budget Management',
                    icon: Icons.account_balance_wallet,
                  ),
                  HomeCard(
                    title: 'Goals',
                    icon: Icons.savings,
                  ),
                  HomeCard(
                    title: 'Report',
                    icon: Icons.insert_chart_outlined,
                  ),
                  HomeCard(
                    title: 'Advisor',
                    icon: Icons.school,
                  ),
                  HomeCard(
                    title: 'Category',
                    icon: Icons.category,
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

  const HomeCard({super.key, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Icon(icon, size: 60, color: kAppBarColor ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
