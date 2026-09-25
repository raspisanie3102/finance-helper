import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data.dart';
import 'format.dart';
import 'screens/auth_screen.dart';
import 'screens/goals_screen.dart';
import 'screens/home_screen.dart';
import 'screens/more_screen.dart';
import 'screens/plan_screen.dart';
import 'store.dart';
import 'theme.dart';
import 'widgets/app_icons.dart';
import 'widgets/common.dart';
import 'widgets/tour.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );
  final prefs = await SharedPreferences.getInstance();
  runApp(FinanceHelperApp(prefs: prefs));
}

class FinanceHelperApp extends StatelessWidget {
  final SharedPreferences prefs;

  const FinanceHelperApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    final state = AppState(prefs: prefs);
    return AnimatedBuilder(
      animation: state,
      builder: (context, _) {
        // Пересобираем MaterialApp только при смене темы,
        // чтобы тема переключалась мгновенно и без «перезагрузки» данных.
        return _ThemeScope(state: state, themeMode: state.themeMode);
      },
    );
  }
}

/// MaterialApp + глобальное состояние через InheritedNotifier.
class _ThemeScope extends StatelessWidget {
  final AppState state;
  final ThemeMode themeMode;

  const _ThemeScope({required this.state, required this.themeMode});

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: state,
      child: MaterialApp(
        title: 'Финансовый помощник',
        debugShowCheckedModeBanner: false,
        themeMode: themeMode,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        home: const RootShell(),
      ),
    );
  }
}

/// Корневой контейнер: онбординг → табы → bottom sheet добавления.
class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int tab = 0;
  final navAddKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);

    // Авторизация — самый первый экран при первом открытии.
    if (app.user == null) {
      return const AuthScreen();
    }

    if (!app.onboarded) {
      return OnboardingScreen(onDone: app.completeOnboarding);
    }

    final screens = [
      const HomeScreen(),
      const PlanScreen(),
      const GoalsScreen(),
      const MoreScreen(),
    ];

    final showTour = !app.tourCompleted;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: palOf(context).bg,
          body: IndexedStack(index: tab, children: screens),
          extendBody: true,
          bottomNavigationBar: FinanceNavBar(
            selectedIndex: tab,
            onTap: (i) => setState(() => tab = i),
            onAdd: _showAddSheet,
            addButtonKey: navAddKey,
          ),
        ),
        // Краткая инструкция при первом запуске: подсвечивает
        // ключевые элементы главного экрана шаг за шагом.
        if (showTour && tab == 0)
          SizedBox.expand(
            child: TourOverlay(
              steps: [
                TourStep(
                  key: HomeScreen.balanceKey,
                  emoji: '💰',
                  title: 'Доступно сейчас',
                  text: 'Это ваши деньги после обязательных платежей и '
                      'накоплений. Сумма всегда актуальна.',
                ),
                TourStep(
                  key: HomeScreen.tipKey,
                  emoji: '💡',
                  title: 'Сегодня можно потратить',
                  text: 'Ваш дневной лимит. Пересчитывается автоматически '
                      'после каждого расхода, дохода и платежа.',
                ),
                TourStep(
                  key: HomeScreen.tilesKey,
                  emoji: '🍽',
                  title: 'Питание и развлечения',
                  text: 'Меню на день и варианты отдыха — подобраны под '
                      'ваш бюджет, чтобы вы оставались в плане.',
                ),
                TourStep(
                  key: navAddKey,
                  emoji: '➕',
                  title: 'Быстрое добавление',
                  text: 'Нажмите «+», чтобы записать расход за пару '
                      'секунд — дневной лимит пересчитается сам.',
                ),
              ],
              onFinish: app.completeTour,
            ),
          ),
      ],
    );
  }

  /// Быстрое добавление: Расход | Доход | Платёж | Покупка | Накопление.
  void _showAddSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddSheet(),
    );
  }
}

// ───────────────────────── Онбординг ─────────────────────────

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onDone;
  const OnboardingScreen({super.key, required this.onDone});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final controller = PageController();
  int page = 0;
  int pairChoice = 0; // 0 — «Только я», 1 — «Я и партнёр»
  final Set<String> interests = {'Питание', 'Развлечения', 'Накопления'};

  // План месяца: суммы редактируются и сразу сохраняются.
  final incomeController = TextEditingController(text: '3 500');
  final mandatoryController = TextEditingController(text: '1 500');
  final savingsController = TextEditingController(text: '500');
  bool amountsSynced = false;

  @override
  void dispose() {
    controller.dispose();
    incomeController.dispose();
    mandatoryController.dispose();
    savingsController.dispose();
    super.dispose();
  }

  /// Заполняем поля сохранёнными значениями плана (однократно).
  void _syncAmountControllers(AppState app) {
    if (amountsSynced) return;
    amountsSynced = true;
    incomeController.text = _amountText(app.income);
    mandatoryController.text = _amountText(app.monthlyMandatory);
    savingsController.text = _amountText(app.monthlySavings);
  }

  static String _amountText(double v) =>
      v % 1 == 0 ? v.toStringAsFixed(0) : v.toStringAsFixed(2);

  static double? _parseAmount(String raw) {
    final v = double.tryParse(
        raw.replaceAll(RegExp(r'\s'), '').replaceAll(',', '.'));
    return v != null && v >= 0 ? v : null;
  }

  /// Любое изменение суммы сразу пересчитывает бюджет и дневной лимит.
  void _saveAmounts() {
    final app = AppScope.of(context);
    final income = _parseAmount(incomeController.text);
    if (income != null) app.setIncome(income);
    final mandatory = _parseAmount(mandatoryController.text);
    if (mandatory != null) app.setMonthlyMandatory(mandatory);
    final savings = _parseAmount(savingsController.text);
    if (savings != null) app.setMonthlySavings(savings);
  }

  static const pages = [
    ('👨‍❤️‍👩', 'Сколько людей будет пользоваться приложением?', ''),
    ('💰', 'Ваш доход', 'Ежемесячная сумма в BYN'),
    ('🏠', 'Обязательные расходы', 'Аренда, коммунальные, связь'),
    ('🌱', 'Сколько хотите откладывать?', 'Накопления и цели'),
    ('✨', 'Что вам интересно?', ''),
  ];

  /// Выбор режима на онбординге сразу применяет состояние приложения.
  void _choosePairMode(int choice) {
    setState(() => pairChoice = choice);
    AppScope.of(context).setPairMode(choice == 1);
  }

  void _toggleInterest(String label) {
    if (!interests.remove(label)) interests.add(label);
  }

  @override
  Widget build(BuildContext context) {
    final pal = palOf(context);
    final app = AppScope.of(context);
    _syncAmountControllers(app);
    final isLast = page == pages.length - 1;

    return Scaffold(
      backgroundColor: pal.bg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: controller,
                itemCount: pages.length,
                onPageChanged: (i) {
                  _saveAmounts();
                  setState(() => page = i);
                },
                itemBuilder: (context, i) {
                  final (emoji, title, subtitle) = pages[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(emoji, style: const TextStyle(fontSize: 72)),
                        const SizedBox(height: 32),
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            height: 1.25,
                            letterSpacing: -0.4,
                            color: pal.text,
                          ),
                        ),
                        if (subtitle.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(
                            subtitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.45,
                              color: pal.sub,
                            ),
                          ),
                        ],
                        if (i == 0) ...[
                          const SizedBox(height: 28),
                          _ChoiceCard(
                              leading: AppIconSolo(
                                size: 24,
                                color: pairChoice == 0
                                    ? AppColors.green
                                    : pal.sub,
                              ),
                              label: 'Только я',
                              selected: pairChoice == 0,
                              onTap: () => _choosePairMode(0)),
                          const SizedBox(height: 10),
                          _ChoiceCard(
                              leading: AppIconPair(
                                size: 24,
                                color: pairChoice == 1
                                    ? AppColors.green
                                    : pal.sub,
                              ),
                              label: 'Я и партнёр',
                              selected: pairChoice == 1,
                              onTap: () => _choosePairMode(1)),
                        ],
                        if (i == 1 || i == 2 || i == 3) ...[
                          const SizedBox(height: 28),
                          _AmountField(
                            controller: i == 1
                                ? incomeController
                                : i == 2
                                    ? mandatoryController
                                    : savingsController,
                            hint: i == 1
                                ? '3 500'
                                : i == 2
                                    ? '1 500'
                                    : '500',
                            onChanged: (_) => _saveAmounts(),
                          ),
                        ],
                        if (i == 4) ...[
                          const SizedBox(height: 28),
                          _ChoiceCard(
                              leading: AppIconMeals(
                                size: 22,
                                color: interests.contains('Питание')
                                    ? AppColors.green
                                    : pal.sub,
                              ),
                              label: 'Питание',
                              selected: interests.contains('Питание'),
                              onTap: () => setState(() =>
                                  _toggleInterest('Питание'))),
                          const SizedBox(height: 10),
                          _ChoiceCard(
                              leading: AppIconEntertainment(
                                size: 22,
                                color: interests.contains('Развлечения')
                                    ? AppColors.green
                                    : pal.sub,
                              ),
                              label: 'Развлечения',
                              selected: interests.contains('Развлечения'),
                              onTap: () => setState(() =>
                                  _toggleInterest('Развлечения'))),
                          const SizedBox(height: 10),
                          _ChoiceCard(
                              leading: AppIconShopping(
                                size: 22,
                                color: interests.contains('Покупки')
                                    ? AppColors.green
                                    : pal.sub,
                              ),
                              label: 'Покупки',
                              selected: interests.contains('Покупки'),
                              onTap: () => setState(
                                  () => _toggleInterest('Покупки'))),
                          const SizedBox(height: 10),
                          _ChoiceCard(
                              leading: AppIconGoals(
                                size: 22,
                                color: interests.contains('Накопления')
                                    ? AppColors.green
                                    : pal.sub,
                              ),
                              label: 'Накопления',
                              selected: interests.contains('Накопления'),
                              onTap: () => setState(() =>
                                  _toggleInterest('Накопления'))),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < pages.length; i++)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: i == page ? 22 : 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: i == page ? AppColors.green : pal.divider,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  PrimaryButton(
                    label: isLast ? 'Начать' : 'Далее',
                    onTap: () {
                      _saveAmounts();
                      if (isLast) {
                        widget.onDone();
                      } else {
                        controller.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  final Widget leading;
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  const _ChoiceCard({
    required this.leading,
    required this.label,
    required this.selected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final pal = palOf(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.green.withValues(alpha: 0.16)
              : pal.glassFill,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? AppColors.green.withValues(alpha: 0.55)
                : pal.glassBorder,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            SizedBox(width: 28, height: 28, child: Center(child: leading)),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: pal.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Редактируемая сумма плана: доход, обязательные расходы, накопления.
class _AmountField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String hint;
  const _AmountField({
    required this.controller,
    required this.onChanged,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    final pal = palOf(context);
    return TextField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.8,
        color: pal.text,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.8,
          color: pal.sub.withValues(alpha: 0.45),
        ),
        suffixText: 'BYN',
        suffixStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.green,
        ),
        filled: true,
        fillColor: pal.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      ),
    );
  }
}

// ───────────────────── Bottom sheet: добавление ─────────────────────

/// Быстрое добавление операций: Расход | Доход | Платёж | Покупка |
/// Накопление. Любая операция моментально пересчитывает дневной лимит.
class AddSheet extends StatefulWidget {
  const AddSheet({super.key});

  @override
  State<AddSheet> createState() => _AddSheetState();
}

class _AddSheetState extends State<AddSheet> {
  OpType type = OpType.expense;
  int category = 0;
  int author = 0; // 0 — Я, 1 — партнёр, 2 — общие
  int goalIdx = 0;
  String paymentName = '';
  final amountController = TextEditingController(text: '35');

  static const types = OpType.values;

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pal = palOf(context);
    final app = AppScope.of(context);
    final inPair = app.pairMode && app.pairConnected;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: pal.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: pal.divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Новое добавление',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: pal.text,
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 38,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: types.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, i) => FilterChipPill(
                      label: types[i].label,
                      selected: type == types[i],
                      onTap: () => setState(() => type = types[i]),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                if (type == OpType.payment) ...[
                  TextField(
                    style: TextStyle(fontSize: 15, color: pal.text),
                    decoration: InputDecoration(
                      hintText: 'За что платёж (необязательно)',
                      hintStyle: TextStyle(fontSize: 14, color: pal.sub),
                      filled: true,
                      fillColor: pal.cardAlt,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 14),
                    ),
                    onChanged: (v) => paymentName = v.trim(),
                  ),
                  const SizedBox(height: 12),
                ],
                Text(
                  'Сумма',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: pal.sub),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: amountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.8,
                    color: pal.text,
                  ),
                  decoration: InputDecoration(
                    suffixText: 'BYN',
                    suffixStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.green,
                    ),
                    filled: true,
                    fillColor: pal.cardAlt,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                  ),
                ),
                if (type == OpType.expense) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Категория',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: pal.sub),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 38,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: expenseCategories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, i) => FilterChipPill(
                        label: expenseCategories[i],
                        selected: category == i,
                        onTap: () => setState(() => category = i),
                      ),
                    ),
                  ),
                ],
                if (type == OpType.savings) ...[
                  const SizedBox(height: 16),
                  Text(
                    'В какую цель отложить',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: pal.sub),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 38,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: app.goals.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, i) => FilterChipPill(
                        label: '${app.goals[i].emoji} ${app.goals[i].name}',
                        selected: goalIdx == i,
                        onTap: () => setState(() => goalIdx = i),
                      ),
                    ),
                  ),
                ],
                if (inPair && type != OpType.savings) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Автор операции',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: pal.sub),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      for (var i = 0; i < 3; i++) ...[
                        if (i > 0) const SizedBox(width: 8),
                        Expanded(
                          child: FilterChipPill(
                            label: [
                              'Я',
                              app.partnerName,
                              'Общие',
                            ][i],
                            selected: author == i,
                            onTap: () => setState(() => author = i),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
                const SizedBox(height: 22),
                PrimaryButton(
                  label: 'Добавить',
                  onTap: () => _submit(context, app),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submit(BuildContext context, AppState app) {
    final value =
        double.tryParse(amountController.text.replaceAll(',', '.')) ?? 0;
    if (value <= 0) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите сумму больше нуля')),
      );
      return;
    }

    final who = app.pairMode && app.pairConnected
        ? ['Я', app.partnerName, 'Общие'][author]
        : 'Я';

    switch (type) {
      case OpType.expense:
        app.addOperation(type, value, expenseCategories[category], who);
        break;
      case OpType.purchase:
        app.addOperation(type, value, 'Покупки', who);
        break;
      case OpType.payment:
        app.addOperation(type, value,
            paymentName.isEmpty ? 'Платёж' : paymentName, who);
        break;
      case OpType.savings:
        app.addSavings(value, app.goals[goalIdx]);
        break;
      case OpType.income:
        app.addOperation(type, value, 'Доход');
        break;
    }
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          type == OpType.income
              ? 'Доход ${formatCurrency(value)} зачислен. '
                  'Доступно сейчас ${formatCurrency(app.availableNow)}'
              : type == OpType.savings
                  ? '${formatCurrency(value)} отложено в «${app.goals[goalIdx].name}» 🌱 '
                      'Осталось на день ≈ ${formatCurrency(app.dailyLeft)}'
                  : '${types[type.index].label} ${formatCurrency(value)} записан'
                      '${who == 'Общие' ? ' (общий)' : who == 'Я' ? '' : ' (${app.partnerName})'}. '
                      'Сегодня можно потратить ≈ ${formatCurrency(app.dailyLeft)}',
        ),
      ),
    );
  }
}
