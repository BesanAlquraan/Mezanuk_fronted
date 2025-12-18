import 'package:flutter/material.dart';

enum ResetOption { email, phone }

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _inputController = TextEditingController();
  bool _isLoading = false;
  ResetOption _resetOption = ResetOption.email;

  bool _isHover = false;
  bool _isBackPressed = false;

  // Validators
  String? _validateInput(String? value) {
    if (value == null || value.isEmpty) {
      return _resetOption == ResetOption.email
          ? '⚠️ Please enter your email'
          : '⚠️ Please enter your phone number';
    }

    if (_resetOption == ResetOption.email) {
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(value)) return '⚠️ Enter a valid email';
    } else {
      final phoneRegex = RegExp(r'^\d{10,15}$');
      if (!phoneRegex.hasMatch(value)) return '⚠️ Enter a valid phone number';
    }
    return null;
  }

  // Send reset link
  void _sendResetLink() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isLoading = false);

    _showDialog(
      'Reset Link Sent',
      _resetOption == ResetOption.email
          ? 'Please check your email for the reset link.'
          : 'A reset code has been sent to your phone.',
    );
  }

  // Dialog
  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK')),
        ],
      ),
    );
  }

  // Responsive Sizes
  double _getResponsiveWidth(double screenWidth) {
    if (screenWidth < 600) return screenWidth * 0.9; // Mobile
    if (screenWidth < 1024) return 450; // Tablet
    return 500; // Desktop
  }

  double _getResponsiveText(double screenWidth, double base) {
    if (screenWidth < 600) return base * 0.9; // Mobile
    if (screenWidth < 1024) return base; // Tablet
    return base * 1.1; // Desktop
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final containerWidth = _getResponsiveWidth(screenWidth);
    final textSize = _getResponsiveText(screenWidth, 16);
    final titleSize = _getResponsiveText(screenWidth, 28);

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF162E47),
                  Color(0xFF2C3D5D),
                  Color(0xFF415A77),
                  Color(0xFF899DB8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Decorative Circles
          Positioned(top: -60, left: -40, child: _buildCircle(150, Colors.white.withOpacity(0.15))),
          Positioned(top: 200, right: -70, child: _buildCircle(200, Colors.white.withOpacity(0.1))),
          Positioned(bottom: 100, left: -60, child: _buildCircle(180, Colors.white.withOpacity(0.08))),
          Positioned(bottom: -50, right: -40, child: _buildCircle(130, Colors.white.withOpacity(0.12))),

          // App Name
          Positioned(
            top: 20,
            left: 30,
            child: Text(
              'Meezanuk',
              style: TextStyle(
                color: Colors.white,
                fontSize: _getResponsiveText(screenWidth, 34),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),

          // Form
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: screenWidth < 600 ? 16 : 0),
              child: Container(
                width: containerWidth,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      SizedBox(height: screenWidth < 600 ? 16 : 20),
                      Text(
                        'Reset Your Password',
                        style: TextStyle(
                          fontSize: titleSize,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF001F54),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Select how you want to receive your password reset link/code.',
                        style: TextStyle(fontSize: textSize, color: Colors.black54),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),

                      // Radio Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Radio<ResetOption>(
                            value: ResetOption.email,
                            groupValue: _resetOption,
                            onChanged: (value) => setState(() => _resetOption = value!),
                          ),
                          const Text('Email'),
                          const SizedBox(width: 30),
                          Radio<ResetOption>(
                            value: ResetOption.phone,
                            groupValue: _resetOption,
                            onChanged: (value) => setState(() => _resetOption = value!),
                          ),
                          const Text('Phone'),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Input Field
                      TextFormField(
                        controller: _inputController,
                        decoration: InputDecoration(
                          labelText: _resetOption == ResetOption.email ? 'Email' : 'Phone Number',
                          hintText:
                              _resetOption == ResetOption.email ? 'Enter your email' : 'Enter your phone number',
                          prefixIcon:
                              Icon(_resetOption == ResetOption.email ? Icons.email_outlined : Icons.phone),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.grey[50],
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.blue, width: 2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType:
                            _resetOption == ResetOption.email ? TextInputType.emailAddress : TextInputType.phone,
                        validator: _validateInput,
                      ),
                      const SizedBox(height: 30),

                      // Send Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : ElevatedButton(
                                onPressed: _sendResetLink,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: Text(
                                  _resetOption == ResetOption.email ? 'Send Reset Link' : 'Send Reset Code',
                                  style: TextStyle(fontSize: textSize, fontWeight: FontWeight.bold),
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
                            'Back to Login',
                            style: TextStyle(
                              color: _isBackPressed || _isHover ? Colors.grey : Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
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

  Widget _buildCircle(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }
}
