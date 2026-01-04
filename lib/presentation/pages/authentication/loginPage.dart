import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_app/constants/colors.dart';
import 'ForgetPassword.dart';
import 'SignUpPage.dart';
import '../../state/settings_store.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _rememberMe = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _loadRememberMe();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _slide = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  Future<void> _loadRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _rememberMe = prefs.getBool('rememberMe') ?? false;
      if (_rememberMe) {
        _emailController.text = prefs.getString('savedEmail') ?? '';
      }
    });
  }

  Future<void> _saveRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('rememberMe', _rememberMe);
    if (_rememberMe) {
      await prefs.setString('savedEmail', _emailController.text);
    } else {
      await prefs.remove('savedEmail');
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    await Future.delayed(const Duration(seconds: 2));

    // Dummy authentication
    if (_emailController.text != 'test@example.com' ||
        _passwordController.text != '123456') {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Invalid email or password';
      });
      return;
    }

    await _saveRememberMe();
    setState(() => _isLoading = false);

    // هنا يمكنك التنقل إلى الصفحة الرئيسية
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settingsStore = context.watch<SettingsStore>();
    final t = settingsStore.translations;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;

          return Stack(
            children: [
              // Gradient Background
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
              Positioned(
                  top: -60,
                  left: -40,
                  child: _circle(150, Colors.white.withOpacity(0.15))),
              Positioned(
                  top: 200,
                  right: -70,
                  child: _circle(200, Colors.white.withOpacity(0.1))),
              Positioned(
                  bottom: -50,
                  right: -40,
                  child: _circle(130, Colors.white.withOpacity(0.12))),

              // App Name
              Positioned(
                top: 20,
                left: 30,
                child: Text(
                  'Meezanuk',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 28 : 34,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              // Login Card
              Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 0),
                  child: FadeTransition(
                    opacity: _fade,
                    child: SlideTransition(
                      position: _slide,
                      child: Container(
                        width: isMobile ? double.infinity : 420,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
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
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                t.of('welcome_back'),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: isMobile ? 22 : 28,
                                  fontWeight: FontWeight.bold,
                                  color: kTextDarkColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                t.of('login_to_app'),
                                textAlign: TextAlign.center,
                                style: TextStyle(color: kTextSecondaryColor),
                              ),
                              const SizedBox(height: 30),

                              // Email
                              _inputField(
                                controller: _emailController,
                                label: t.of('email'),
                                hint: t.of('enter_email'),
                                icon: Icons.email_outlined,
                                keyboard: TextInputType.emailAddress,
                                validator: (v) =>
                                    (v == null || !v.contains('@'))
                                        ? t.of('enter_valid_email')
                                        : null,
                              ),
                              const SizedBox(height: 18),

                              // Password
                              _inputField(
                                controller: _passwordController,
                                label: t.of('password'),
                                hint: t.of('enter_password'),
                                icon: Icons.lock_outline,
                                obscure: _obscurePassword,
                                validator: (v) =>
                                    (v == null || v.length < 6)
                                        ? t.of('min_6_chars')
                                        : null,
                                suffix: IconButton(
                                  icon: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 200),
                                    child: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      key: ValueKey(_obscurePassword),
                                    ),
                                  ),
                                  onPressed: () => setState(
                                      () => _obscurePassword = !_obscurePassword),
                                ),
                              ),
                              SizedBox(height: isMobile ? 8 : 12),

                              // Options Row
                              _OptionsRow(
                                rememberMe: _rememberMe,
                                isMobile: isMobile,
                                onRememberChanged: (v) =>
                                    setState(() => _rememberMe = v),
                                onForgot: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            const ForgetPasswordScreen()),
                                  );
                                },
                                t: t,
                              ),

                              if (_errorMessage != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: Text(
                                    _errorMessage!,
                                    style: const TextStyle(color: Colors.red),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              const SizedBox(height: 20),

                              _PrimaryButton(
                                text: t.of('login'),
                                isMobile: isMobile,
                                isLoading: _isLoading,
                                onPressed: _login,
                              ),

                              const SizedBox(height: 12),
                              _Footer(
                                isMobile: isMobile,
                                onSignup: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => SignUpPage()),
                                  );
                                },
                                t: t,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType keyboard = TextInputType.text,
    bool obscure = false,
    Widget? suffix,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: kPrimaryColor, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _circle(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}

// ================= Components =================

class _OptionsRow extends StatelessWidget {
  final bool rememberMe;
  final bool isMobile;
  final ValueChanged<bool> onRememberChanged;
  final VoidCallback onForgot;
  final dynamic t;

  const _OptionsRow({
    required this.rememberMe,
    required this.isMobile,
    required this.onRememberChanged,
    required this.onForgot,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(value: rememberMe, onChanged: (v) => onRememberChanged(v!)),
        Expanded(
          child: Text(t.of('keep_logged_in'),
              style: TextStyle(fontSize: isMobile ? 13 : 14)),
        ),
        TextButton(onPressed: onForgot, child: Text(t.of('forgot_password'))),
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
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : Text(text, style: TextStyle(fontSize: isMobile ? 16 : 18)),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  final VoidCallback onSignup;
  final bool isMobile;
  final dynamic t;

  const _Footer({required this.onSignup, required this.isMobile, required this.t});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("${t.of('dont_have_account')} ", style: TextStyle(fontSize: isMobile ? 13 : 14)),
        TextButton(onPressed: onSignup, child: Text(t.of('sign_up'))),
      ],
    );
  }
}
