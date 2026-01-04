import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'LoginPage.dart';
import 'dashboard_page.dart';
import 'package:my_app/constants/colors.dart';
import 'package:my_app/presentation/state/settings_store.dart';
import '../../../services/bank_api_service.dart';
import 'package:my_app/presentation/state/bank_link_store.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Simulate userId from SignUp API
  String currentUserId = "u10"; // مؤقت، لاحقًا جاي من تسجيل المستخدم

  void _signUp() {
    if (!_formKey.currentState!.validate()) return;
    _showLinkBankDialog(currentUserId);
  }

  void _showLinkBankDialog(String currentUserId) {
    String? selectedAccountNumber;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return ChangeNotifierProvider(
          create: (_) => BankLinkStore(),
          child: Consumer<BankLinkStore>(
            builder: (context, store, _) => AlertDialog(
              title: const Text("Link Bank Account"),
              content: FutureBuilder<List<Map<String, dynamic>>>(
                future: BankApiService.getAccounts(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final userAccounts = snapshot.data!
                      .where((acc) => acc['userId'] == currentUserId)
                      .toList();

                  if (userAccounts.isEmpty) {
                    return const Text("No bank accounts found for this user.");
                  }

                  return DropdownButtonFormField<String>(
                    value: selectedAccountNumber,
                    decoration: const InputDecoration(
                      labelText: "Select Account",
                    ),
                    items: userAccounts.map((acc) {
                      return DropdownMenuItem<String>(
                        value: acc['accountNumber'],
                        child: Text("${acc['accountNumber']} (${acc['currency']})"),
                      );
                    }).toList(),
                    onChanged: (value) {
                      selectedAccountNumber = value;
                    },
                    validator: (value) =>
                        value == null ? "Please select an account" : null,
                  );
                },
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _goToDashboard();
                  },
                  child: const Text("Skip"),
                ),
                ElevatedButton(
                  onPressed: store.isLoading
                      ? null
                      : () async {
                          if (selectedAccountNumber == null) return;

                          final success = await store
                              .linkAccount(selectedAccountNumber!.trim());
                          if (success) {
                            Navigator.pop(context);
                            _goToDashboard();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      "Failed to link the account. Try again.")),
                            );
                          }
                        },
                  child: store.isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text("Link"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _goToDashboard() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const DashboardPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<SettingsStore>().translations;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 22, 46, 71),
                  Color.fromARGB(255, 44, 61, 93),
                  Color(0xFF415A77),
                  Color.fromARGB(255, 137, 157, 184),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          const Positioned(
            top: 10,
            left: 30,
            child: Text(
              'Meezanuk',
              style: TextStyle(
                color: kTextLightColor,
                fontSize: 34,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 0),
              child: Container(
                width: isMobile ? double.infinity : 500,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: kCardBackgroundColor.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Text(
                      t.of('create_account'),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: kTextDarkColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      t.of('signup_subtitle'),
                      style: const TextStyle(
                        color: kTextSecondaryColor,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 30),
                    _buildForm(t),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(dynamic t) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _textField(
                  _firstNameController,
                  t.of('first_name'),
                  t.of('first_name_hint'),
                  Icons.person_outline,
                  t.of('first_name_error'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _textField(
                  _lastNameController,
                  t.of('last_name'),
                  t.of('last_name_hint'),
                  Icons.person_outline,
                  t.of('last_name_error'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _textField(
            _emailController,
            t.of('email'),
            'you@example.com',
            Icons.email_outlined,
            t.of('email_error'),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 20),
          _textField(
            _descriptionController,
            t.of('description'),
            t.of('description_hint'),
            Icons.description_outlined, null,
          ),
          const SizedBox(height: 20),
          _textField(
            _phoneController,
            t.of('phone'),
            t.of('phone_hint'),
            Icons.phone_outlined,
            t.of('phone_error'),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 20),
          _passwordField(
            _passwordController,
            t.of('password'),
            _obscurePassword,
            () => setState(() => _obscurePassword = !_obscurePassword),
          ),
          const SizedBox(height: 20),
          _passwordField(
            _confirmPasswordController,
            t.of('confirm_password'),
            _obscureConfirmPassword,
            () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _signUp,
              style: ElevatedButton.styleFrom(
                backgroundColor: kButtonPrimaryColor,
              ),
              child: Text(t.of('sign_up')),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(t.of('have_account')),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                ),
                child: Text(
                  t.of('login'),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: kPrimaryColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _textField(
          TextEditingController controller,
          String label,
          String hint,
          IconData icon,
          String? error, {
            TextInputType keyboardType = TextInputType.text,
          }) =>
      TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: error == null ? null : (v) => v!.isEmpty ? error : null,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon),
        ),
      );

  Widget _passwordField(
          TextEditingController controller,
          String label,
          bool obscure,
          VoidCallback toggle,
          ) =>
      TextFormField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.lock_outline),
          suffixIcon: IconButton(
            icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
            onPressed: toggle,
          ),
        ),
      );
}
