import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:finance_helper/data.dart';
import 'package:finance_helper/store.dart';

void main() {
  late AppState app;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    app = AppState(prefs: prefs);
  });

  test('Регистрация сохраняет пользователя в JSON без дубликатов', () async {
    expect(
      app.registerAccount(
        name: 'Анна',
        contact: 'anna@mail.com',
        password: 'secret1',
      ),
      isNull,
    );
    expect(app.user?.name, 'Анна');
    expect(app.registeredUsers, hasLength(1));

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('registeredUsersJson');
    expect(raw, isNotNull);
    final list = jsonDecode(raw!) as List<dynamic>;
    expect(list, hasLength(1));
    expect(list.first['email'], 'anna@mail.com');
    expect(list.first['passwordHash'], stubPasswordHash('secret1'));

    app.signOut();
    expect(app.user, isNull);
    expect(app.registeredUsers, hasLength(1));

    expect(
      app.registerAccount(
        name: 'Анна',
        contact: 'Anna@mail.com',
        password: 'secret1',
      ),
      'Такой пользователь уже зарегистрирован',
    );
    expect(app.registeredUsers, hasLength(1));
    expect(app.user, isNull);
  });

  test('Вход пускает только с верным паролем существующего аккаунта', () {
    expect(
      app.signInWithPassword('anna@mail.com', 'secret1'),
      'Аккаунт не найден. Сначала зарегистрируйтесь',
    );

    app.registerAccount(
      name: 'Анна',
      contact: '+375 29 123-45-67',
      password: 'secret1',
    );
    app.signOut();

    expect(
      app.signInWithPassword('+375291234567', 'wrong1'),
      'Неверный пароль',
    );
    expect(app.user, isNull);

    expect(app.signInWithPassword('+375 29 123-45-67', 'secret1'), isNull);
    expect(app.user?.name, 'Анна');
  });

  test('После перезапуска список аккаунтов читается из JSON', () async {
    app.registerAccount(
      name: 'Игорь',
      contact: 'igor@mail.com',
      password: 'qwerty',
    );
    app.signOut();

    final prefs = await SharedPreferences.getInstance();
    final restored = AppState(prefs: prefs);
    expect(restored.user, isNull);
    expect(restored.registeredUsers, hasLength(1));
    expect(restored.signInWithPassword('igor@mail.com', 'qwerty'), isNull);
    expect(restored.user?.name, 'Игорь');
  });

  test('Суммы онбординга сохраняются в бюджет и платежи', () {
    expect(app.registerAccount(
      name: 'Анна',
      contact: 'anna@mail.com',
      password: 'secret1',
    ), isNull);

    app.setIncome(4000);
    app.setMonthlyMandatory(1000);
    app.setMonthlySavings(200);
    app.completeOnboarding();

    expect(app.income, 4000);
    expect(app.monthlyMandatory, 1000);
    expect(app.monthlySavings, 200);
    expect(app.reserved, 2000); // 1000 + 200 + 800
    expect(app.availableNow, 2000); // 4000 - 2000
    expect(
      app.upcomingPayments.fold(0.0, (sum, p) => sum + p.amount),
      closeTo(1000, 0.01),
    );
    expect(app.upcomingPayments.first.name, 'Аренда квартиры');
    expect(app.onboarded, isTrue);

    app.signOut();
    expect(app.signInWithPassword('anna@mail.com', 'secret1'), isNull);
    expect(app.income, 4000);
    expect(app.monthlyMandatory, 1000);
    expect(app.monthlySavings, 200);
    expect(app.onboarded, isTrue);
  });
}
