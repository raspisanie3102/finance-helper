import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data.dart';

/// Глобальное состояние приложения.
///
/// Все суммы хранятся числами; отображение — только через
/// formatCurrency() из format.dart, всегда в BYN.
///
/// Дневной лимит считается по формуле ТЗ: из доступного остатка
/// вычитаются обязательные платежи, накопления и запланированные
/// расходы, результат делится на количество оставшихся дней месяца.
/// Лимит пересчитывается после каждой новой операции.
class AppState extends ChangeNotifier {
  AppState({required SharedPreferences prefs}) : _prefs = prefs {
    tourCompleted = _prefs.getBool('tourCompleted') ?? false;
    final themeIdx = _prefs.getInt('themeMode') ?? 2;
    themeMode = ThemeMode.values[themeIdx.clamp(0, 2)];
    pairMode = _prefs.getBool('pairMode') ?? false;
    pairConnected = _prefs.getBool('pairConnected') ?? false;
    inviteCode = _prefs.getString('inviteCode') ?? '';

    // План месяца задаётся на онбординге и сохраняется.
    income = _prefs.getDouble('income') ?? 3500;
    monthlyMandatory = _prefs.getDouble('monthlyMandatory') ?? 1500;
    monthlySavings = _prefs.getDouble('monthlySavings') ?? 500;

    _loadRegisteredUsers();

    // Восстановление сессии: авторизованный пользователь пропускает
    // экраны входа и регистрации.
    final savedEmail = _prefs.getString('authEmail');
    if (savedEmail != null) {
      user = User(
        name: _prefs.getString('authName') ?? 'Александр',
        email: savedEmail,
        passwordHash: _prefs.getString('authHash') ?? '',
        authProvider: _prefs.getString('authProvider') ?? 'email',
      );
    }
  }

  final SharedPreferences _prefs;

  static const _usersJsonKey = 'registeredUsersJson';

  // ── Настройки ──
  ThemeMode themeMode = ThemeMode.system;
  bool tourCompleted = false;
  User? user;
  List<User> registeredUsers = [];
  final String city = 'Минск, Беларусь';

  /// Имя для приветствий: из аккаунта или демо-имя по умолчанию.
  String get userName {
    final name = user?.name.trim() ?? '';
    return name.isEmpty ? 'Александр' : name;
  }

  // ── Режим «Пара» ──
  bool pairMode = false;
  bool pairConnected = false;
  String inviteCode = '';
  final String partnerName = 'Мария';
  final double partnerIncome = 2900; // доход партнёра (демо-сценарий)

  // ── Бюджет (демо-значения по ТЗ; меняются на онбординге) ──
  double income = 3500; // месячный доход (пополняется операциями «Доход»)
  double monthlyMandatory = 1500; // обязательные расходы
  double monthlySavings = 500; // накопления
  static const double monthlyPlanned = 800; // запланированные расходы

  /// Обязательные платежи + накопления + запланированные расходы месяца.
  double get reserved => monthlyMandatory + monthlySavings + monthlyPlanned;

  /// Совокупный доход пары — в режиме «Я и партнёр».
  double get combinedIncome =>
      pairMode && pairConnected ? income + partnerIncome : income;

  /// Порций приёма пищи: в паре всё пересчитывается на двоих.
  int get portions => pairMode && pairConnected ? 2 : 1;

  final List<Operation> operations = [];

  /// Расходы и покупки за сегодня.
  double get spentToday {
    final now = DateTime.now();
    return operations
        .where((o) =>
            (o.type == OpType.expense || o.type == OpType.purchase) &&
            _sameDay(o.date, now))
        .fold(0, (sum, o) => sum + o.amount);
  }

  /// Оплаченные платежи и довнесённые накопления (сверх плана месяца).
  double get extraOutflows =>
      operations
          .where((o) => o.type == OpType.payment || o.type == OpType.savings)
          .fold(0, (sum, o) => sum + o.amount);

  /// «Доступно сейчас» — пересчитывается после каждой операции.
  double get availableNow =>
      combinedIncome - reserved - spentToday - extraOutflows;

  /// «Сегодня можно потратить»: доступный остаток, делённый на
  /// количество оставшихся дней месяца (включая сегодня).
  double get dailyLeft =>
      (availableNow / daysLeftInMonth()).clamp(0, double.infinity);

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  // ── Питание ──
  final Map<String, int> mealIdx = {'Завтрак': 0, 'Обед': 0, 'Ужин': 0};
  final Set<String> selectedMeals = {};

  /// Умное обучение: сколько раз блюдо выбрали и сколько раз пропустили.
  final Map<String, int> dishPicks = {};
  final Map<String, int> dishSkips = {};

  Dish currentDish(String slot) => mealSlots[slot]![mealIdx[slot]!];

  /// Стоимость рациона на сегодня; в паре — на двоих.
  double get menuTotal =>
      mealSlots.keys.fold(0.0, (sum, s) => sum + currentDish(s).price) *
      portions;

  /// «Не хочу» (кнопка или свайп влево): пропущенное блюдо запоминается,
  /// следующее подбирается в том же ценовом диапазоне, а часто
  /// пропускаемые блюда (2+ раза) больше не предлагаются.
  Dish rejectMeal(String slot) {
    final list = mealSlots[slot]!;
    final current = currentDish(slot);
    dishSkips[current.name] = (dishSkips[current.name] ?? 0) + 1;

    final candidates = list
        .where((d) => d.name != current.name)
        .where((d) => (dishSkips[d.name] ?? 0) < 2)
        .toList();
    // Тот же ценовой диапазон: ±30% от цены текущего блюда.
    final sameRange = candidates
        .where((d) =>
            d.price >= current.price * 0.7 && d.price <= current.price * 1.3)
        .toList();
    final pool = (sameRange.isNotEmpty ? sameRange : candidates).toList();
    if (pool.isEmpty) {
      // Все варианты пропущены — сбрасываем «память» по слоту и идём по кругу.
      for (final d in list) {
        dishSkips[d.name] = 0;
      }
      mealIdx[slot] = (mealIdx[slot]! + 1) % list.length;
      notifyListeners();
      return currentDish(slot);
    }
    // Часто выбираемые получают приоритет, быстрые рецепты — бонус.
    pool.sort((a, b) {
      final byPicks =
          (dishPicks[b.name] ?? 0).compareTo(dishPicks[a.name] ?? 0);
      if (byPicks != 0) return byPicks;
      return a.minutes.compareTo(b.minutes);
    });
    mealIdx[slot] = list.indexOf(pool.first);
    notifyListeners();
    return currentDish(slot);
  }

  void toggleMeal(String slot) {
    if (!selectedMeals.remove(slot)) {
      selectedMeals.add(slot);
      final dish = currentDish(slot);
      dishPicks[dish.name] = (dishPicks[dish.name] ?? 0) + 1;
    }
    notifyListeners();
  }

  void pickDish(Dish dish) =>
      dishPicks[dish.name] = (dishPicks[dish.name] ?? 0) + 1;

  /// Популярные блюда: приоритет часто выбираемым и быстрым рецептам.
  List<Dish> get recommendedPopular {
    final list = [...popularDishes];
    list.sort((a, b) {
      final byPicks =
          (dishPicks[b.name] ?? 0).compareTo(dishPicks[a.name] ?? 0);
      if (byPicks != 0) return byPicks;
      return a.minutes.compareTo(b.minutes);
    });
    return list;
  }

  // ── Список покупок ──
  final List<ShopItem> shopping = List.of(defaultShopping);

  void toggleShoppingItem(int i) {
    shopping[i].checked = !shopping[i].checked;
    notifyListeners();
  }

  void addIngredientsToShopping(Dish dish) {
    for (final ing in dish.ingredients) {
      final exists = shopping.any((s) => s.name == ing.name);
      if (!exists) {
        shopping.add(ShopItem(ing.name, '🛒', ing.qty, ing.price));
      }
    }
    notifyListeners();
  }

  /// Сумма отмеченных продуктов.
  double get checkedShoppingTotal =>
      shopping.where((s) => s.checked).fold(0, (sum, s) => sum + s.price);

  /// Сумма неотмеченных (предстоящих) продуктов.
  double get shoppingTotal =>
      shopping.where((s) => !s.checked).fold(0, (sum, s) => sum + s.price);

  /// «Купить»: подтверждение списка сразу списывает сумму из бюджета.
  double buyCheckedItems() {
    final bought = shopping.where((s) => s.checked).toList();
    if (bought.isEmpty) return 0;
    final total = bought.fold(0.0, (sum, s) => sum + s.price);
    operations.add(Operation(
      OpType.purchase,
      total,
      'Покупки',
      pairMode && pairConnected ? 'Общие' : 'Я',
    ));
    shopping.removeWhere((s) => s.checked);
    notifyListeners();
    return total;
  }

  // ── Развлечения: умная выдача ──
  final Map<String, int> entPicks = {};
  final Map<String, int> entSkips = {};

  /// Пропуск (кнопка или свайп): 2 пропуска — вариант исключается
  /// из выдачи автоматически.
  void skipEntertainment(Entertainment item) {
    entSkips[item.title] = (entSkips[item.title] ?? 0) + 1;
    notifyListeners();
  }

  /// «Показать снова»: сбрасывает исключённые варианты.
  void resetEntertainmentSkips() {
    entSkips.clear();
    notifyListeners();
  }

  void pickEntertainment(Entertainment item) =>
      entPicks[item.title] = (entPicks[item.title] ?? 0) + 1;

  /// Отсортированные варианты: часто выбираемые категории выше,
  /// регулярно пропускаемые исключены.
  List<Entertainment> orderedEntertainments(String categoryFilter) {
    final excluded =
        entSkips.entries.where((e) => e.value >= 2).map((e) => e.key).toSet();
    final items = entertainments
        .where((e) =>
            (categoryFilter == 'Все' || e.category == categoryFilter) &&
            !excluded.contains(e.title))
        .toList();
    items.sort((a, b) {
      final byPicks =
          (entPicks[b.title] ?? 0).compareTo(entPicks[a.title] ?? 0);
      if (byPicks != 0) return byPicks;
      return b.rating.compareTo(a.rating);
    });
    return items;
  }

  /// Стоимость развлечения с учётом количества человек; варианты
  /// «Для пары» уже рассчитаны на двоих.
  double entertainmentPrice(Entertainment item) {
    if (pairMode && pairConnected && item.category != 'Для пары') {
      return item.price * 2;
    }
    return item.price;
  }

  // ── Цели ──
  final List<Goal> goals = List.of(goalsSeed);

  /// «Накопление»: сумма уходит из доступного остатка в выбранную цель.
  void addSavings(double amount, Goal goal) {
    goal.current += amount;
    operations.add(Operation(OpType.savings, amount, goal.name, 'Я'));
    notifyListeners();
  }

  void addGoal(Goal goal) {
    goals.add(goal);
    notifyListeners();
  }

  // ── Действия ──
  void completeTour() {
    tourCompleted = true;
    _prefs.setBool('tourCompleted', true);
    notifyListeners();
  }

  // ── Авторизация: локальный JSON-список аккаунтов ──

  void _loadRegisteredUsers() {
    final raw = _prefs.getString(_usersJsonKey);
    if (raw == null || raw.isEmpty) return;
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      registeredUsers = [
        for (final item in list)
          if (item is Map) User.fromJson(Map<String, dynamic>.from(item)),
      ];
    } catch (_) {
      registeredUsers = [];
    }
  }

  void _persistRegisteredUsers() {
    _prefs.setString(
      _usersJsonKey,
      jsonEncode(registeredUsers.map((u) => u.toJson()).toList()),
    );
  }

  User? findUserByContact(String contact) {
    final key = normalizeContact(contact);
    if (key.isEmpty) return null;
    for (final u in registeredUsers) {
      if (normalizeContact(u.email) == key) return u;
    }
    return null;
  }

  /// Регистрация. Возвращает текст ошибки или `null` при успехе.
  String? registerAccount({
    required String name,
    required String contact,
    required String password,
  }) {
    final trimmedName = name.trim();
    final trimmedContact = contact.trim();
    if (trimmedName.length < 2) return 'Введите имя';
    if (trimmedContact.isEmpty) return 'Укажите email или номер телефона';
    if (findUserByContact(trimmedContact) != null) {
      return 'Такой пользователь уже зарегистрирован';
    }
    final newUser = User(
      name: trimmedName,
      email: trimmedContact,
      passwordHash: stubPasswordHash(password),
      authProvider: 'email',
    );
    registeredUsers.add(newUser);
    _persistRegisteredUsers();
    completeSignIn(newUser);
    return null;
  }

  /// Вход по email/телефону и паролю. Возвращает ошибку или `null`.
  String? signInWithPassword(String contact, String password) {
    final existing = findUserByContact(contact);
    if (existing == null) {
      return 'Аккаунт не найден. Сначала зарегистрируйтесь';
    }
    if (existing.passwordHash != stubPasswordHash(password)) {
      return 'Неверный пароль';
    }
    completeSignIn(existing);
    return null;
  }

  void signInAsGuest() {
    completeSignIn(const User(
      name: 'Гость',
      email: '',
      passwordHash: '',
      authProvider: 'guest',
    ));
  }

  /// Сохраняет текущую сессию. Список аккаунтов при выходе не очищается.
  void completeSignIn(User newUser) {
    user = newUser;
    _prefs.setString('authEmail', newUser.email);
    _prefs.setString('authName', newUser.name);
    _prefs.setString('authProvider', newUser.authProvider);
    _prefs.setString('authHash', newUser.passwordHash);
    notifyListeners();
  }

  void signOut() {
    user = null;
    _prefs.remove('authEmail');
    _prefs.remove('authName');
    _prefs.remove('authProvider');
    _prefs.remove('authHash');
    notifyListeners();
  }

  void addExpense(double amount, String category, [String who = 'Я']) {
    operations.add(Operation(OpType.expense, amount, category, who));
    notifyListeners();
  }

  /// Универсальное добавление операции через центральный «+».
  void addOperation(OpType type, double amount, String category,
      [String who = 'Я']) {
    if (type == OpType.income) {
      income += amount;
    } else {
      operations.add(Operation(type, amount, category, who));
    }
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    themeMode = mode;
    _prefs.setInt('themeMode', mode.index);
    notifyListeners();
  }

  // ── План месяца: задаётся на онбординге, сохраняется ──

  void setIncome(double value) {
    if (value < 0) return;
    income = value;
    _prefs.setDouble('income', value);
    notifyListeners();
  }

  void setMonthlyMandatory(double value) {
    if (value < 0) return;
    monthlyMandatory = value;
    _prefs.setDouble('monthlyMandatory', value);
    notifyListeners();
  }

  void setMonthlySavings(double value) {
    if (value < 0) return;
    monthlySavings = value;
    _prefs.setDouble('monthlySavings', value);
    notifyListeners();
  }

  /// Включение режима «Пара»: генерируется код приглашения, к общему
  /// бюджету подключается партнёр. Баланс, дневной лимит, порции еды,
  /// стоимость развлечений и цели пересчитываются на двоих.
  void setPairMode(bool value) {
    pairMode = value;
    if (value) {
      if (inviteCode.isEmpty) {
        inviteCode = _generateInviteCode();
        _prefs.setString('inviteCode', inviteCode);
      }
      if (!pairConnected) {
        pairConnected = true; // демо: партнёр подключается по коду
        _prefs.setBool('pairConnected', true);
      }
    }
    _prefs.setBool('pairMode', pairMode);
    notifyListeners();
  }

  static String _generateInviteCode() {
    const alphabet = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';
    final rnd = Random();
    final body = String.fromCharCodes(List.generate(
        5, (_) => alphabet.codeUnitAt(rnd.nextInt(alphabet.length))));
    return 'FH-$body';
  }
}

/// Доступ к состоянию из любого виджета под MaterialApp.
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
      : super(notifier: state);

  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;
}
