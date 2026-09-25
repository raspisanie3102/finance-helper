import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:finance_helper/main.dart';

void main() {
  testWidgets('При первом запуске показывается экран входа', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(FinanceHelperApp(prefs: prefs));
    await tester.pumpAndSettle();
    expect(find.text('С возвращением'), findsOneWidget);
    expect(find.text('Войти'), findsOneWidget);
    expect(find.text('Войти через Apple'), findsNothing);
  });

  testWidgets('Гостевой режим открывает онбординг с выбора режима',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(FinanceHelperApp(prefs: prefs));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Продолжить как гость'));
    await tester.pumpAndSettle();

    expect(
        find.text('Сколько людей будет пользоваться приложением?'),
        findsOneWidget);
  });

  testWidgets('Доход на онбординге редактируется и попадает в бюджет',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(FinanceHelperApp(prefs: prefs));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Продолжить как гость'));
    await tester.pumpAndSettle();

    // Шаг «Ваш доход».
    await tester.tap(find.text('Далее'));
    await tester.pumpAndSettle();
    expect(find.text('Ваш доход'), findsOneWidget);

    final field = find.byType(TextField);
    expect(field, findsOneWidget);
    await tester.enterText(field, '2000');
    await tester.pumpAndSettle();

    // Дойти до конца онбординга: страницы 2, 3, 4 и кнопка «Начать».
    await tester.tap(find.text('Далее'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Далее'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Далее'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Начать'));
    await tester.pumpAndSettle();

    // Новый доход отражён на карточке баланса («На счете»).
    // Форматтер разделяет разряды неразрывным пробелом.
    expect(find.text('2\u00A0000 BYN'), findsOneWidget);
  });

  testWidgets('Зарплата, аренда и накопления с онбординга идут в учёт',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(FinanceHelperApp(prefs: prefs));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Продолжить как гость'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Далее'));
    await tester.pumpAndSettle();
    expect(find.text('Ваш доход'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '4000');
    await tester.pump();

    await tester.tap(find.text('Далее'));
    await tester.pumpAndSettle();
    expect(find.text('Обязательные расходы'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '1000');
    await tester.pump();

    await tester.tap(find.text('Далее'));
    await tester.pumpAndSettle();
    expect(find.text('Сколько хотите откладывать?'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '200');
    await tester.pump();

    await tester.tap(find.text('Далее'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Начать'));
    await tester.pumpAndSettle();

    // На счете = зарплата. Зарезервировано = аренда + накопления + план 800.
    expect(find.text('4\u00A0000 BYN'), findsOneWidget);
    expect(find.text('2\u00A0000 BYN'), findsWidgets);
    expect(find.text('Аренда квартиры'), findsOneWidget);
  });

  testWidgets('Вход без регистрации показывает ошибку', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(FinanceHelperApp(prefs: prefs));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextField, 'Email или номер телефона'),
      'anna@mail.com',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Пароль'),
      'secret1',
    );
    await tester.pump();
    await tester.tap(find.text('Войти'));
    await tester.pumpAndSettle();

    expect(
      find.text('Аккаунт не найден. Сначала зарегистрируйтесь'),
      findsOneWidget,
    );
    expect(find.text('С возвращением'), findsOneWidget);
  });
}
