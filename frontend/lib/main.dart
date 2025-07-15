import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Экраны
import 'screens/login_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/home_screen.dart';
import 'screens/sessions_list_screen.dart';
import 'screens/add_session_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/recommendations_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/success_screen.dart';

// Локализация
import 'package:flutter_localizations/flutter_localizations.dart';
import 'generated/l10n.dart'; // <-- сюда
import 'providers/locale_provider.dart';

// Тема приложения
final ThemeData customLightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: const Color(0xFF7AC7A6),
  scaffoldBackgroundColor: const Color(0xFFF7F7F7),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF7AC7A6),
    foregroundColor: Colors.white,
    elevation: 0,
    iconTheme: IconThemeData(color: Colors.white),
  ),
  cardColor: Colors.white,
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.black87),
    bodyMedium: TextStyle(color: Colors.black87),
    titleLarge: TextStyle(color: Colors.black87),
  ),
  colorScheme: const ColorScheme.light(
    primary: Color(0xFF7AC7A6),
    secondary: Color(0xFF7AC7A6),
    background: Color(0xFFF7F7F7),
    surface: Colors.white,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onBackground: Colors.black87,
    onSurface: Colors.black87,
  ),
);

final ThemeData customDarkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: const Color(0xFF7AC7A6),
  scaffoldBackgroundColor: const Color(0xFF181A20),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF23272F),
    foregroundColor: Colors.white,
    elevation: 0,
    iconTheme: IconThemeData(color: Colors.white),
  ),
  cardColor: const Color(0xFF23272F),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.white),
    bodyMedium: TextStyle(color: Colors.white70),
    titleLarge: TextStyle(color: Colors.white),
  ),
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF7AC7A6),
    secondary: Color(0xFF7AC7A6),
    background: Color(0xFF181A20),
    surface: Color(0xFF23272F),
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onBackground: Colors.white,
    onSurface: Colors.white,
  ),
);

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadTheme();
  }
  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    _saveTheme(isDark);
    notifyListeners();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkMode') ?? false;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  Future<void> _saveTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', isDark);
  }
}

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();

    return MaterialApp(
      title: 'Stress Management App',
      theme: customLightTheme,
      darkTheme: customDarkTheme,
      themeMode: themeProvider.themeMode,

      // ← Локализация
      locale: localeProvider.locale,
      supportedLocales: S.delegate.supportedLocales,
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      routes: {
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegistrationScreen(),
        '/home': (_) => const HomeScreen(),
        '/sessions': (_) => const SessionsListScreen(),
        '/add_session': (_) => const AddSessionScreen(),
        '/stats': (_) => const StatsScreen(),
        '/success': (ctx) => throw UnimplementedError(),
        '/recommendations': (context) => const RecommendationsScreen(),
      },
    );
  }
}
