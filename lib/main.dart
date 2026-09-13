import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'data.dart';
import 'format.dart';
import 'screens/goals_screen.dart';
import 'screens/home_screen.dart';
import 'screens/more_screen.dart';
import 'screens/plan_screen.dart';
import 'store.dart';
import 'theme.dart';
import 'widgets/common.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );
  runApp(const FinanceHelperApp());
}

class FinanceHelperApp extends StatelessWidget {
  const FinanceHelperApp({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppState();
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
  bool onboarded = false;

  @override
  Widget build(BuildContext context) {
    if (!onboarded) {
      return OnboardingScreen(onDone: () => setState(() => onboarded = true));
    }

    final screens = [
      const HomeScreen(),
      const PlanScreen(),
      const GoalsScreen(),
      const MoreScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: tab, children: screens),
      extendBody: true,
      bottomNavigationBar: FinanceNavBar(
        selectedIndex: tab,
        onTap: (i) => setState(() => tab = i),
        onAdd: _showAddSheet,
      ),
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

  static const pages = [
    ('🌿', 'Добро пожаловать в Финансовый помощник',
        'Планируйте деньги так, чтобы оставалось место для жизни.'),
    ('👥', 'Сколько людей будет пользоваться приложением?', ''),
    ('💰', 'Ваш доход', 'Ежемесячная сумма в BYN'),
    ('🏠', 'Обязательные расходы', 'Аренда, коммунальные, связь'),
    ('🌱', 'Сколько хотите откладывать?', 'Накопления и цели'),
    ('✨', 'Что вам интересно?', ''),
  ];

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pal = palOf(context);
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
                onPageChanged: (i) => setState(() => page = i),
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
                        if (i == 1) ...[
                          const SizedBox(height: 28),
                          const _ChoiceCard(
                              emoji: '🧑', label: 'Только я', selected: true),
                          const SizedBox(height: 10),
                          const _ChoiceCard(
                              emoji: '💑', label: 'Я и партнёр', selected: false),
                        ],
                        if (i == 2 || i == 3 || i == 4) ...[
                          const SizedBox(height: 28),
                          _AmountDemo(
                              text: i == 2
                                  ? '3 500 BYN'
                                  : i == 3
                                      ? '1 500 BYN'
                                      : '500 BYN'),
                        ],
                        if (i == 5) ...[
                          const SizedBox(height: 28),
                          const _ChoiceCard(
                              emoji: '🍽', label: 'Питание', selected: true),
                          const SizedBox(height: 10),
                          const _ChoiceCard(
                              emoji: '🎬', label: 'Развлечения', selected: true),
                          const SizedBox(height: 10),
                          const _ChoiceCard(
                              emoji: '🛒', label: 'Покупки', selected: false),
                          const SizedBox(height: 10),
                          const _ChoiceCard(
                              emoji: '🌱', label: 'Накопления', selected: true),
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
  final String emoji;
  final String label;
  final bool selected;
  const _ChoiceCard({
    required this.emoji,
    required this.label,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    final pal = palOf(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: selected ? pal.sage : pal.card,
        borderRadius: BorderRadius.circular(16),
        border: selected
            ? Border.all(color: AppColors.green, width: 1.5)
            : Border.all(color: pal.sageBorder),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
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
    );
  }
}

class _AmountDemo extends StatelessWidget {
  final String text;
  const _AmountDemo({required this.text});

  @override
  Widget build(BuildContext context) {
    final pal = palOf(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: pal.card,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: pal.shadow, blurRadius: 14, offset: const Offset(0, 6)),
        ],
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.8,
          color: pal.text,
        ),
      ),
    );
  }
}

// ───────────────────── Bottom sheet: добавление ─────────────────────

class AddSheet extends StatefulWidget {
  const AddSheet({super.key});

  @override
  State<AddSheet> createState() => _AddSheetState();
}

class _AddSheetState extends State<AddSheet> {
  int type = 0; // Расход | Доход | Платёж | Покупка | Накопление
  int category = 0;
  final amountController = TextEditingController(text: '35');

  static const types = ['Расход', 'Доход', 'Платёж', 'Покупка', 'Накопление'];

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pal = palOf(context);
    final app = AppScope.of(context);
    final isExpense = type == 0;

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
                      label: types[i],
                      selected: type == i,
                      onTap: () => setState(() => type = i),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
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
                if (isExpense) ...[
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
                const SizedBox(height: 22),
                PrimaryButton(
                  label: 'Добавить',
                  onTap: () {
                    final value = double.tryParse(
                            amountController.text.replaceAll(',', '.')) ??
                        0;
                    if (type == 0 && value > 0) {
                      app.addExpense(value, expenseCategories[category]);
                    }
                    Navigator.of(context).pop();
                    if (type == 0 && value > 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Расход ${formatCurrency(value)} добавлен. '
                            'Сегодня можно потратить ≈ ${formatCurrency(app.dailyLeft)}',
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Пока реализовано добавление расходов 🙂'),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
