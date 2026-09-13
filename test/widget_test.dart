import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:finance_helper/main.dart';

void main() {
  testWidgets('Онбординг показывается при первом запуске', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(FinanceHelperApp(prefs: prefs));
    expect(find.text('Добро пожаловать в Финансовый помощник'), findsOneWidget);
  });
}
