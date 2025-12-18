import 'package:flutter/material.dart';
import 'ui/home/home_wrapper.dart'; // عدّلي المسار حسب مكان الملف

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeWrapper(), // ✅ هذه صفحة الـ Main
    );
  }
}
