import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stress_management_app/main.dart';

void main() {
  group('ThemeData Tests', () {
    test('Light theme has correct primary color', () {
      expect(customLightTheme.primaryColor, const Color(0xFF7AC7A6));
    });

    test('Dark theme has correct scaffold background', () {
      expect(customDarkTheme.scaffoldBackgroundColor, const Color(0xFF181A20));
    });

    test('Light theme app bar has white icons', () {
      expect(customLightTheme.appBarTheme.iconTheme?.color, Colors.white);
    });

    test('Dark theme text colors are correct', () {
      expect(customDarkTheme.textTheme.bodyLarge?.color, Colors.white);
      expect(customDarkTheme.textTheme.bodyMedium?.color, Colors.white70);
    });
  });
}
