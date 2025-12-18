import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'home_web.dart';
//import 'onboarding_page.dart';
import 'splash_screen.dart'; 
class HomeWrapper extends StatelessWidget {
  const HomeWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return const HomePageWeb();
    } else {
      return  SplashScreen();
    }
  }
}
