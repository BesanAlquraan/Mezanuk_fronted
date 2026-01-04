//import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_app/constants/colors.dart';
import 'package:my_app/presentation/pages/home/home_mobile.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int currentPage = 0;
  final int totalPages = 5;

 Future<void> _completeOnboarding() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('onboardingCompleted', true);

  if (!mounted) return;

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => HomePage(),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                currentPage = index;
              });
            },
            children: [
              OnboardingPageTemplate(
                context,
                'Grow Your Wealth',
                'Discover smart ways to grow your money and make it work for you.',
                'assets/undraw_wallet_diag.png',
              ),
              OnboardingPageTemplate(
                context,
                'Savings',
                'Build your savings effortlessly and watch them grow.',
                'assets/undraw_savings_uwjn.png',
              ),
              OnboardingPageTemplate(
                context,
                'Track Your Expenses',
                'Keep an eye on your spending and manage your budget efficiently.',
                'assets/undraw_data-reports_l2u3.png',
              ),
              OnboardingPageTemplate(
                context,
                'Financial Goals',
                'Set clear financial goals and stay motivated to reach them.',
                'assets/undraw_crypto-flowers_5m2p.png',
              ),
              OnboardingPageTemplate(
                context,
                'Start the Mezanuk!',
                '',
                'assets/undraw_mobile-payments_uate.png',
              ),
            ],
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: _completeOnboarding,
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      fontSize: 18,
                      color: kTextDarkColor,
                    ),
                  ),
                ),
                Row(
                  children: List.generate(
                    totalPages,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: currentPage == index ? 12 : 8,
                      height: currentPage == index ? 12 : 8,
                      decoration: BoxDecoration(
                        color: currentPage == index
                            ? kDotActiveColor
                            : kDotInactiveColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: currentPage == totalPages - 1
                      ? _completeOnboarding
                      : () => _pageController.nextPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          ),
                  child: Text(
                    currentPage == totalPages - 1 ? 'Start' : 'Next',
                    style: TextStyle(
                      fontSize: 18,
                      color: kTextLightColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget OnboardingPageTemplate(
    BuildContext context, String title, String description, String imagePath) {
  return Container(
    alignment: Alignment.center,
    width: MediaQuery.of(context).size.width,
    height: MediaQuery.of(context).size.height,
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          imagePath,
          height: 400,
        ),
        const SizedBox(height: 40),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: kPrimaryColor,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          description,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: kTextDarkColor,
          ),
        ),
      ],
    ),
  );
}
