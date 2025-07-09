import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();          // ← ключ формы
  final _username = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  // —–– логика нажатия «Login» –––
  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      // здесь всё ок → можно отправлять запрос к серверу
      // TODO: авторизация / запрос к Go-бэкенду
    } else {
      // валидация не прошла → покажем SnackBar
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
            // листья — без изменений
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

            // --- содержимое ---
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Form(                      // ← оборачиваем в Form
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Welcome back!',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 48),

                      // Username
                      TextFormField(
                        controller: _username,
                        decoration: _inputDecoration('Username'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Username cannot be empt';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Password
                      TextFormField(
                        controller: _password,
                        obscureText: true,
                        decoration: _inputDecoration('Password'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password cannot be empty';
                          }
                          // ≥ 5 символов и хотя бы одна латинская буква
                          final hasLetter = RegExp(r'[A-Za-z]').hasMatch(value);
                          if (value.length < 5 || !hasLetter) {
                            return 'Password must be at least 5 characters and contain a letter';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),

                      // Login button
                      _filledButton(
                        label: 'Login',
                        onTap: _handleLogin,
                      ),
                      const SizedBox(height: 64),

                      Text(
                        'Create an account',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 24),

                      // Sign-up button
                      _filledButton(
                        label: 'Sign up',
                        onTap: () {
                          // TODO: переход на экран регистрации
                        },
                      ),
                      const SizedBox(height: 32),
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

  // общий стиль полей ввода
  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFF838383),
            width: 1.2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFF838383),
            width: 1.6,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Colors.redAccent,
            width: 1.2,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Colors.redAccent,
            width: 1.6,
          ),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      );

  // общий вид кнопок
  Widget _filledButton({
    required String label,
    required VoidCallback onTap,
  }) =>
      SizedBox(
        width: double.infinity,
        height: 56,
        child: FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFA1C7BA),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onPressed: onTap,
          child: Text(
            label,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
      );
}