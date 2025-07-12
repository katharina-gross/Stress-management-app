import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/home_screen.dart'; // Импорт HomeScreen
import 'screens/sessions_list_screen.dart';
void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stress Management',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Montserrat',
        scaffoldBackgroundColor: const Color(0xFFF9F5EB),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7FC6A6),
          secondary: const Color(0xFFA3D9C9), // lightMint
        ),
        textTheme: ThemeData.light().textTheme.copyWith(
          headlineMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
          titleLarge: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegistrationScreen(),
        '/home': (context) => const HomeScreen(),
        '/sessions' : (context) => const SessionsListScreen(),
      },
    );
  }
}
