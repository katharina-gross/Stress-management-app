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
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFA1C7BA),
          background: const Color(0xFFF9EEEC),
        ),
      ),
      home: const LoginScreen(),   // подключаем страницу
      initialRoute: '/login',
      routes: {
        '/login':    (ctx) => const LoginScreen(),
        '/register': (ctx) => const RegistrationScreen(),
        '/home'    : (_) => const Scaffold(
              body: Center(child: Text('Home (пока заглушка)')),
            ),
      },
      
    );
  }
}