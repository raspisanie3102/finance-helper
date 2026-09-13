import 'package:flutter_test/flutter_test.dart';

import 'package:finance_helper/main.dart';

void main() {
  testWidgets('Онбординг показывается при первом запуске', (tester) async {
    await tester.pumpWidget(const FinanceHelperApp());
    expect(find.text('Добро пожаловать в Финансовый помощник'), findsOneWidget);
  });
}
