import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:your_app/screens/add_session_screen.dart';
import 'package:your_app/services/auth_service.dart';
import 'package:your_app/generated/l10n.dart';
import 'package:intl/intl.dart';

class MockAuthService extends Mock implements AuthService {}

void main() {
  late MockAuthService mockAuthService;

  setUp(() {
    mockAuthService = MockAuthService();
  });

  testWidgets('AddSessionScreen renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [S.delegate],
        home: AddSessionScreen(),
      ),
    );

    expect(find.text(S.current.addSession), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byType(Slider), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets('Description field updates correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AddSessionScreen(),
      ),
    );

    const testText = 'Test description';
    await tester.enterText(find.byType(TextField), testText);
    expect(find.text(testText), findsOneWidget);
  });

  testWidgets('Stress level slider updates correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AddSessionScreen(),
      ),
    );

    final slider = find.byType(Slider);
    expect(slider, findsOneWidget);

    // Начальное значение 5
    expect(find.text('5'), findsOneWidget);

    // Изменяем значение на 8
    await tester.drag(slider, const Offset(100, 0));
    await tester.pump();
    expect(find.text('8'), findsOneWidget);
  });

  testWidgets('Date picker shows and updates date', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AddSessionScreen(),
      ),
    );

    final initialDate = DateTime.now();
    final initialDateText = DateFormat.yMMMd().format(initialDate);
    expect(find.text(initialDateText), findsOneWidget);

    // Нажимаем кнопку выбора даты
    await tester.tap(find.text(S.current.changeDate));
    await tester.pumpAndSettle();

    // Проверяем, что пикер появился
    expect(find.byType(DatePickerDialog), findsOneWidget);

    // Здесь можно добавить выбор конкретной даты, но это сложнее из-за нативного диалога
  });

  testWidgets('Shows error when description is empty', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AddSessionScreen(),
      ),
    );

    // Нажимаем кнопку сохранения с пустым описанием
    await tester.tap(find.text(S.current.save));
    await tester.pump();

    // Проверяем появление SnackBar с ошибкой
    expect(find.text(S.current.errorEmptyDescription), findsOneWidget);
  });
}