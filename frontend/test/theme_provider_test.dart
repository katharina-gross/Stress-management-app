import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stress_management_app/main.dart';

void main() {
  group('ThemeProvider', () {
    late ThemeProvider themeProvider;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      themeProvider = ThemeProvider();
    });

    test('initial theme mode is system', () {
      expect(themeProvider.themeMode, ThemeMode.system);
    });

    test('toggleTheme changes theme mode to dark when true', () {
      themeProvider.toggleTheme(true);
      expect(themeProvider.themeMode, ThemeMode.dark);
    });

    test('toggleTheme changes theme mode to light when false', () {
      themeProvider.toggleTheme(false);
      expect(themeProvider.themeMode, ThemeMode.light);
    });

    test('_loadTheme loads dark theme when preference is true', () async {
      SharedPreferences.setMockInitialValues({'isDarkMode': true});
      await themeProvider._loadTheme();
      expect(themeProvider.themeMode, ThemeMode.dark);
    });

    test('_loadTheme loads light theme when preference is false', () async {
      SharedPreferences.setMockInitialValues({'isDarkMode': false});
      await themeProvider._loadTheme();
      expect(themeProvider.themeMode, ThemeMode.light);
    });

    test('_saveTheme saves the correct preference', () async {
      SharedPreferences.setMockInitialValues({});
      await themeProvider._saveTheme(true);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('isDarkMode'), true);
    });
  });
}