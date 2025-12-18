import 'package:flutter/material.dart';
import 'package:my_app/constants/colors.dart';
//import 'package:my_app/authentication/ForgetPassword.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _rememberMe = false;
  bool _isLoading = false;
  bool _obscurePassword = true;

  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isMobile ? 12 : 20),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isMobile ? double.infinity : 420,
              ),
              child: FadeTransition(
                opacity: _fade,
                child: SlideTransition(
                  position: _slide,
                  child: _CardContainer(
                    isMobile: isMobile,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _Header(isMobile: isMobile),
                        SizedBox(height: isMobile ? 20 : 28),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              _InputField(
                                controller: _emailController,
                                label: 'Email',
                                hint: 'Enter your email',
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                isMobile: isMobile,
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'Enter your email';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: isMobile ? 14 : 18),
                              _InputField(
                                controller: _passwordController,
                                label: 'Password',
                                hint: 'Enter your password',
                                icon: Icons.lock_outline,
                                obscure: _obscurePassword,
                                isMobile: isMobile,
                                validator: (v) {
                                  if (v == null || v.length < 6) {
                                    return 'Min 6 characters';
                                  }
                                  return null;
                                },
                                suffix: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                  onPressed: () => setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  }),
                                ),
                              ),
                              SizedBox(height: isMobile ? 8 : 10),
                              _OptionsRow(
                                rememberMe: _rememberMe,
                                isMobile: isMobile,
                                onRememberChanged: (v) =>
                                    setState(() => _rememberMe = v),
                                onForgot: () {},
                              ),
                              SizedBox(height: isMobile ? 14 : 18),
                              _PrimaryButton(
                                text: 'Login',
                                isMobile: isMobile,
                                isLoading: _isLoading,
                                onPressed: _login,
                              ),
                              SizedBox(height: isMobile ? 16 : 20),
                              _Footer(isMobile: isMobile, onSignup: () {}),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/* ================= Components ================= */

class _CardContainer extends StatelessWidget {
  final Widget child;
  final bool isMobile;

  const _CardContainer({required this.child, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: kCardBackgroundColor,
        borderRadius: BorderRadius.circular(isMobile ? 14 : 20),
        boxShadow: const [
          BoxShadow(color: kShadowColor, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: child,
    );
  }
}

class _Header extends StatelessWidget {
  final bool isMobile;
  const _Header({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Welcome Back',
          style: TextStyle(
            fontSize: isMobile ? 22 : 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        const Text('Login to continue'),
      ],
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final Widget? suffix;
  final bool obscure;
  final bool isMobile;
  final TextInputType keyboardType;
  final String? Function(String?) validator;

  const _InputField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.validator,
    required this.isMobile,
    this.suffix,
    this.obscure = false,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: EdgeInsets.symmetric(
          vertical: isMobile ? 14 : 18,
          horizontal: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

class _OptionsRow extends StatelessWidget {
  final bool rememberMe;
  final bool isMobile;
  final ValueChanged<bool> onRememberChanged;
  final VoidCallback onForgot;

  const _OptionsRow({
    required this.rememberMe,
    required this.isMobile,
    required this.onRememberChanged,
    required this.onForgot,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(value: rememberMe, onChanged: (v) => onRememberChanged(v!)),
        Expanded(
          child: Text(
            'Keep me logged in',
            style: TextStyle(fontSize: isMobile ? 13 : 14),
          ),
        ),
        TextButton(onPressed: onForgot, child: const Text('Forgot Password?')),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String text;
  final bool isMobile;
  final bool isLoading;
  final VoidCallback onPressed;

  const _PrimaryButton({
    required this.text,
    required this.isMobile,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: isMobile ? 46 : 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(text, style: TextStyle(fontSize: isMobile ? 16 : 18)),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  final VoidCallback onSignup;
  final bool isMobile;

  const _Footer({required this.onSignup, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: TextStyle(fontSize: isMobile ? 13 : 14),
        ),
        TextButton(onPressed: onSignup, child: const Text('Sign Up')),
      ],
    );
  }
}
