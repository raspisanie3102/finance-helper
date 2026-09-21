import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:finance_helper/main.dart';

void main() {
  testWidgets('Экран регистрации: поля, валидация, чекбокс', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(FinanceHelperApp(prefs: prefs));
    await tester.pumpAndSettle();

    // Переход на экран регистрации.
    await tester.tap(find.text('Нет аккаунта? Зарегистрироваться',
        findRichText: true));
    await tester.pumpAndSettle();

    expect(find.text('Создать аккаунт'), findsOneWidget);
    expect(find.text('Это займёт меньше минуты'), findsOneWidget);
    expect(find.text('Зарегистрироваться через Apple'), findsNothing);
    expect(find.text('Уже есть аккаунт? Войти'), findsOneWidget);

    // Некорректный email — вежливая ошибка в реальном времени.
    final contactField =
        find.widgetWithText(TextField, 'Email или номер телефона');
    await tester.enterText(contactField, 'abc');
    await tester.pump();
    expect(find.text('Проверьте правильность email или номера телефона'),
        findsOneWidget);

    // Телефон тоже принимается.
    await tester.enterText(contactField, '+375 29 123-45-67');
    await tester.pump();
    expect(find.text('Проверьте правильность email или номера телефона'),
        findsNothing);

    // Короткий пароль — ненавязчивая подсказка-ошибка.
    await tester.enterText(find.widgetWithText(TextField, 'Пароль'), '123');
    await tester.pump();
    expect(find.text('Пароль должен быть не короче 6 символов'),
        findsOneWidget);

    // Разные пароли — «Пароли не совпадают».
    await tester.enterText(find.widgetWithText(TextField, 'Имя'), 'Анна');
    await tester.enterText(
        find.widgetWithText(TextField, 'Пароль'), 'пароль123');
    await tester.enterText(
        find.widgetWithText(TextField, 'Повторите пароль'), 'пароль321');
    await tester.pump();
    expect(find.text('Пароли не совпадают'), findsOneWidget);

    // Совпадающие пароли снимают обе ошибки.
    await tester.enterText(
        find.widgetWithText(TextField, 'Повторите пароль'), 'пароль123');
    await tester.pump();
    expect(find.text('Пароли не совпадают'), findsNothing);
    expect(find.text('Пароль должен быть не короче 6 символов'), findsNothing);

    // Успешная регистрация открывает онбординг с выбора режима.
    await tester.tap(find.byKey(const ValueKey('terms-checkbox')));
    await tester.pump();
    await tester.tap(find.text('Зарегистрироваться').last);
    await tester.pumpAndSettle();
    expect(
        find.text('Сколько людей будет пользоваться приложением?'),
        findsOneWidget);
  });
}
