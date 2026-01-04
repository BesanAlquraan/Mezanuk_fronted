import 'package:flutter/material.dart';
import 'package:my_app/constants/colors.dart';
import 'package:provider/provider.dart';
import '../../state/settings_store.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  bool _isLoading = false;
  bool _isHover = false;
  bool _isBackPressed = false;

  // Email Validator
  String? _validateEmail(String? value, dynamic t) {
    if (value == null || value.isEmpty) {
      return t.of('enter_email'); // ⚠️ Please enter your email
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return t.of('enter_valid_email'); // ⚠️ Enter a valid email
    }
    return null;
  }

  // Send Reset Link (Mock)
  void _sendResetLink(dynamic t) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isLoading = false);

    _showDialog(t.of('reset_link_sent'), t.of('check_email')); 
  }

  // Dialog
  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Responsive helpers
  double _responsiveWidth(double screenWidth) {
    if (screenWidth < 600) return screenWidth * 0.9;
    if (screenWidth < 1024) return 450;
    return 500;
  }

  double _responsiveText(double screenWidth, double base) {
    if (screenWidth < 600) return base * 0.9;
    if (screenWidth < 1024) return base;
    return base * 1.1;
  }

  @override
  Widget build(BuildContext context) {
    final store = Provider.of<SettingsStore>(context);
    final t = store.translations; // JSON translations

    final screenWidth = MediaQuery.of(context).size.width;
    final containerWidth = _responsiveWidth(screenWidth);
    final titleSize = _responsiveText(screenWidth, 28);
    final textSize = _responsiveText(screenWidth, 16);

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [kPrimaryColor, Color(0xFF2C3D5D)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Decorative Circles
          Positioned(top: -60, left: -40, child: _circle(150, Colors.white.withOpacity(0.15))),
          Positioned(top: 200, right: -70, child: _circle(200, Colors.white.withOpacity(0.1))),
          Positioned(bottom: 100, left: -60, child: _circle(180, Colors.white.withOpacity(0.08))),
          Positioned(bottom: -50, right: -40, child: _circle(130, Colors.white.withOpacity(0.12))),

          // App Name
          Positioned(
            top: 20,
            left: 30,
            child: Text(
              'Meezanuk',
              style: TextStyle(
                color: Colors.white,
                fontSize: _responsiveText(screenWidth, 34),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),

          // Form Card
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: screenWidth < 600 ? 16 : 0),
              child: Container(
                width: containerWidth,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: kCardBackgroundColor.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      SizedBox(height: screenWidth < 600 ? 16 : 20),

                      // Title
                      Text(
                        t.of('reset_password'), // Reset Your Password
                        style: TextStyle(
                          fontSize: titleSize,
                          fontWeight: FontWeight.bold,
                          color: kTextDarkColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),

                      // Subtitle
                      Text(
                        t.of('enter_email_to_reset'), // Enter your email to receive a password reset link.
                        style: TextStyle(
                          fontSize: textSize,
                          color: kTextSecondaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),

                      // Email Field
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: t.of('email'), // Email
                          hintText: t.of('enter_email'), // Enter your email
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: kPrimaryColor, width: 2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (val) => _validateEmail(val, t),
                      ),
                      const SizedBox(height: 30),

                      // Send Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: _isLoading
                            ? const Center(
                                child: CircularProgressIndicator(color: kPrimaryColor),
                              )
                            : ElevatedButton(
                                onPressed: () => _sendResetLink(t),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kPrimaryColor,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  t.of('send_reset_link'), // Send Reset Link
                                  style: TextStyle(
                                    fontSize: textSize,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                      ),
                      const SizedBox(height: 20),

                      // Back to Login
                      MouseRegion(
                        onEnter: (_) => setState(() => _isHover = true),
                        onExit: (_) => setState(() => _isHover = false),
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTapDown: (_) => setState(() => _isBackPressed = true),
                          onTapUp: (_) {
                            setState(() => _isBackPressed = false);
                            Navigator.pop(context);
                          },
                          onTapCancel: () => setState(() => _isBackPressed = false),
                          child: Text(
                            t.of('back_to_login'), // Back to Login
                            style: TextStyle(
                              color: _isBackPressed || _isHover
                                  ? Colors.grey
                                  : kPrimaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circle(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      );

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}
