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
    expect(find.text('Войти через Apple'), findsOneWidget);
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
}
