import 'package:flutter/material.dart';
import 'package:stress_management_app/services/auth_service.dart'; 


class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController  = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService _authService = AuthService();


  @override
  void dispose() {
    _nicknameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _handleSignUp() async {
  if (_formKey.currentState!.validate()) {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    try {
      await _authService.register(email, password);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Регистрация успешна'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Если нужно — переход на экран логина:
      Navigator.pushReplacementNamed(context, '/login');

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка регистрации: ${e.toString()}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please check the fields and correct the errors'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9EEEC),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              right: 0,
              top: 0,
              child: Image.asset('assets/images/leaf_top.png', width: 190),
            ),
            Positioned(
              left: 0,
              bottom: 0,
              child: Image.asset('assets/images/leaf_bottom.png', width: 190),
            ),

            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 64),

                      // Новый заголовок
                      const Text(
                        'Creating an account',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 48),

                      // Nickname
                      TextFormField(
                        controller: _nicknameController,
                        decoration: _inputDecoration('Nickname'),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Nickname cannot be empty'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // Email
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: _inputDecoration('Email'),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Email cannot be empty';
                          }
                          // простой RegExp для базовой проверки
                          final emailReg = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                          if (!emailReg.hasMatch(v.trim())) {
                            return 'Enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),


                      // Password
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: _inputDecoration('Password'),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Password cannot be empty';
                          }
                          final hasLetter = RegExp(r'[A-Za-z]').hasMatch(v);
                          if (v.length < 5 || !hasLetter) {
                            return 'Password must be at least 5 characters\nand contain a letter';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Confirm Password
                      TextFormField(
                        controller: _confirmController,
                        obscureText: true,
                        decoration: _inputDecoration('Repeat Password'),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Please repeat your password';
                          }
                          if (v != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),

                      // Кнопка регистрации
                      _filledButton(
                        label: 'Sign Up',
                        onTap: _handleSignUp,
                      ),

                      const SizedBox(height: 16),
                      // Кнопка возврата на логин
                      Center(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Back to Log in'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF838383), width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF838383), width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
        ),
      );

  Widget _filledButton({
    required String label,
    required VoidCallback onTap,
  }) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFA1C7BA),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onPressed: onTap,
          child: Text(label,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        ),
      );
}
