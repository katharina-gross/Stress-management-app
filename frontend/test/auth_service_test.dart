import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:your_app/services/auth_service.dart';
import 'package:your_app/screens/add_session_screen.dart';
import 'package:your_app/models/advice.dart';
import 'package:your_app/generated/l10n.dart';

class MockAuthService extends Mock implements AuthService {}

void main() {
  // 1. Базовый тест отображения
  testWidgets('Renders AddSessionScreen correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AddSessionScreen(),
        localizationsDelegates: [S.delegate],
      ),
    );

    expect(find.text('Add Session'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byType(Slider), findsOneWidget);
    expect(find.text('Stress Level'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  // 2. Тест ввода данных
  testWidgets('Can enter description and adjust stress level',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: AddSessionScreen(),
            localizationsDelegates: [S.delegate],
          ),
        );

        // Тест ввода текста
        const testText = 'Test session description';
        await tester.enterText(find.byType(TextField), testText);
        expect(find.text(testText), findsOneWidget);

        // Тест изменения слайдера
        final slider = find.byType(Slider);
        await tester.drag(slider, const Offset(50, 0));
        await tester.pump();
        expect(tester.widget<Slider>(slider).value, greaterThan(5.0));
      });

  // 3. Тест валидации
  testWidgets('Shows error when saving with empty description',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: AddSessionScreen(),
            localizationsDelegates: [S.delegate],
          ),
        );

        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.text('Description cannot be empty'), findsOneWidget);
      });

  // 4. Тест успешного сохранения
  testWidgets('Successfully saves session and navigates',
          (WidgetTester tester) async {
        final mockAuthService = MockAuthService();
        when(mockAuthService.addSession(any, any, any))
            .thenAnswer((_) => Future.value());
        when(mockAuthService.getAIAdvice(any, any, any))
            .thenAnswer((_) async => Advice(adviceText: 'Test advice'));

        await tester.pumpWidget(
          Provider<AuthService>.value(
            value: mockAuthService,
            child: MaterialApp(
              home: AddSessionScreen(),
              localizationsDelegates: [S.delegate],
              routes: {
                '/success': (_) => const Scaffold(body: Text('Success Screen')),
              },
            ),
          ),
        );

        await tester.enterText(find.byType(TextField), 'Valid description');
        await tester.tap(find.byType(ElevatedButton));
        await tester.pumpAndSettle();

        expect(find.text('Success Screen'), findsOneWidget);
      });

  // 5. Тест обработки ошибок
  testWidgets('Shows error when saving fails', (WidgetTester tester) async {
    final mockAuthService = MockAuthService();
    when(mockAuthService.addSession(any, any, any))
        .thenThrow(Exception('Test error'));

    await tester.pumpWidget(
      Provider<AuthService>.value(
        value: mockAuthService,
        child: MaterialApp(
          home: AddSessionScreen(),
          localizationsDelegates: [S.delegate],
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'Valid description');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.textContaining('Test error'), findsOneWidget);
  });
}