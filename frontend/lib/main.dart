import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/registration_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter × Go demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        // базовый нежно-розовый фон и «пастельно-зелёный» акцент
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFA1C7BA),   // тот же зелёный, чтобы всё гармонировало
          background: const Color(0xFFF9EEEC),  // фон
        ),
      ),
      home: const LoginScreen(),   // ← подключаем страницу
      initialRoute: '/login',
      routes: {
        '/login':    (ctx) => const LoginScreen(),
        '/register': (ctx) => const RegistrationScreen(),
      },
    );
  }
}