import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data.dart';

/// Глобальное состояние приложения (прототип — в памяти).
///
/// Все суммы хранятся числами; отображение — только через
/// formatCurrency() из format.dart, всегда в BYN.
class AppState extends ChangeNotifier {
  AppState({required SharedPreferences prefs}) : _prefs = prefs {
    tourCompleted = _prefs.getBool('tourCompleted') ?? false;
  }

  final SharedPreferences _prefs;

  // ── Настройки ──
  ThemeMode themeMode = ThemeMode.system;
  bool pairMode = false;
  bool tourCompleted = false;
  final String userName = 'Александр';
  final String city = 'Минск, Беларусь';

  // ── Бюджет (демо-значения по ТЗ) ──
  static const double income = 3500; // доход
  static const double reserved = 1020; // обязательные платежи + накопления (остаток месяца)
  static const double dailyPlan = 120; // дневной план
  static const double monthlyMandatory = 1500;
  static const double monthlySavings = 500;
  static const double monthlyPlanned = 800;

  final List<Expense> expenses = [];

  double get spentToday =>
      expenses.fold(0, (sum, e) => sum + e.amount);

  /// «Доступно сейчас» — пересчитывается после каждого расхода.
  double get availableNow => income - reserved - spentToday;

  /// «Сегодня можно потратить».
  double get dailyLeft => (dailyPlan - spentToday).clamp(0, double.infinity);

  // ── Питание ──
  final Map<String, int> mealIdx = {'Завтрак': 0, 'Обед': 0, 'Ужин': 0};
  final Set<String> selectedMeals = {};

  Dish currentDish(String slot) => mealSlots[slot]![mealIdx[slot]!];

  double get menuTotal =>
      mealSlots.keys.fold(0, (sum, s) => sum + currentDish(s).price);

  /// «Не хочу» — предложить следующий вариант блюда.
  Dish rejectMeal(String slot) {
    final list = mealSlots[slot]!;
    mealIdx[slot] = (mealIdx[slot]! + 1) % list.length;
    notifyListeners();
    return currentDish(slot);
  }

  void toggleMeal(String slot) {
    if (!selectedMeals.remove(slot)) selectedMeals.add(slot);
    notifyListeners();
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

  double get shoppingTotal =>
      shopping.where((s) => !s.checked).fold(0, (sum, s) => sum + s.price);

  // ── Действия ──
  void completeTour() {
    tourCompleted = true;
    _prefs.setBool('tourCompleted', true);
    notifyListeners();
  }

  void addExpense(double amount, String category, [String who = 'Я']) {
    expenses.add(Expense(amount, category, who));
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    themeMode = mode;
    notifyListeners();
  }

  void setPairMode(bool value) {
    pairMode = value;
    notifyListeners();
  }
}

/// Доступ к состоянию из любого виджета под MaterialApp.
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
      : super(notifier: state);

  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;
}
