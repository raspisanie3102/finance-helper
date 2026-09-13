import 'package:flutter/material.dart';

import '../data.dart';
import '../format.dart';
import '../store.dart';
import '../theme.dart';
import '../widgets/common.dart';

class PlanScreen extends StatelessWidget {
  const PlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pal = palOf(context);
    final app = AppScope.of(context);

    return StatusBarStyle(
      darkIcons: Theme.of(context).brightness != Brightness.dark,
      child: Scaffold(
        backgroundColor: pal.bg,
        body: SafeArea(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 28),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'План',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          color: pal.text,
                        ),
                      ),
                    ),
                    Text(
                      'Сентябрь 2026',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: pal.sub,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right_rounded,
                        size: 18, color: AppColors.green),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const _DayStrip(),
              const SizedBox(height: 16),
              _TodayCard(app: app),
              const SizedBox(height: 12),
              _TipCard(app: app),
              const SizedBox(height: 12),
              const _MonthStructureCard(),
            ],
          ),
        ),
      ),
    );
  }
}

class _DayStrip extends StatelessWidget {
  const _DayStrip();

  @override
  Widget build(BuildContext context) {
    final pal = palOf(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: AppCard(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            for (final d in weekDays)
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  decoration: BoxDecoration(
                    color: d.today ? AppColors.green : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        d.day,
                        style: TextStyle(
                          fontSize: 10.5,
                          color: d.today
                              ? const Color(0xFFBFD8C9)
                              : pal.sub,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        d.date,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: d.today ? Colors.white : pal.text,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TodayCard extends StatelessWidget {
  final AppState app;
  const _TodayCard({required this.app});

  @override
  Widget build(BuildContext context) {
    final pal = palOf(context);
    final byCategory = <String, double>{};
    for (final e in app.expenses) {
      byCategory[e.category] = (byCategory[e.category] ?? 0) + e.amount;
    }
    // Рацион на сегодня уже входит в план питания
    byCategory['Питание'] = (byCategory['Еда'] ?? 0) + app.menuTotal;
    byCategory.remove('Еда');

    final rows = <({String emoji, String name, double amount})>[
      (emoji: '🍽', name: 'Питание', amount: byCategory['Питание'] ?? 0),
      (emoji: '🎬', name: 'Развлечения', amount: byCategory['Развлечения'] ?? 0),
      (emoji: '🛍', name: 'Покупки', amount: byCategory['Покупки'] ?? 0),
      (emoji: '🚌', name: 'Транспорт', amount: byCategory['Транспорт'] ?? 0),
      (emoji: '🏠', name: 'Дом', amount: byCategory['Дом'] ?? 0),
    ];
    final total = rows.fold(0.0, (sum, r) => sum + r.amount);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Сегодня, 13 сентября',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: pal.text,
              ),
            ),
            const SizedBox(height: 14),
            for (final r in rows) ...[
              Row(
                children: [
                  Text(r.emoji, style: const TextStyle(fontSize: 17)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      r.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: pal.sub,
                      ),
                    ),
                  ),
                  Text(
                    formatCurrency(r.amount),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: r.amount > 0 ? pal.text : pal.sub,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            Divider(height: 1, color: pal.divider),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Итого за день',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: pal.text,
                    ),
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Text(
                    formatCurrency(total),
                    key: ValueKey(total),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.green,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  final AppState app;
  const _TipCard({required this.app});

  @override
  Widget build(BuildContext context) {
    final pal = palOf(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: AppCard(
        color: pal.tipBg,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Text('💡', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 12),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Text(
                  'Осталось ≈ ${formatCurrency(app.dailyLeft)}, чтобы уложиться в дневной бюджет',
                  key: ValueKey(app.dailyLeft),
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                    color: pal.tipText,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthStructureCard extends StatelessWidget {
  const _MonthStructureCard();

  @override
  Widget build(BuildContext context) {
    final pal = palOf(context);
    final rows = <({String emoji, String name, double amount, bool positive})>[
      (emoji: '💰', name: 'Доход', amount: AppState.income, positive: true),
      (emoji: '🏠', name: 'Обязательные расходы', amount: -AppState.monthlyMandatory, positive: false),
      (emoji: '🌱', name: 'Накопления', amount: -AppState.monthlySavings, positive: false),
      (emoji: '🛍', name: 'Планируемые расходы', amount: -AppState.monthlyPlanned, positive: false),
    ];
    const free = 700.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'План на месяц',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: pal.text,
              ),
            ),
            const SizedBox(height: 14),
            for (final r in rows) ...[
              Row(
                children: [
                  Text(r.emoji, style: const TextStyle(fontSize: 17)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      r.name,
                      style: TextStyle(fontSize: 14, color: pal.sub),
                    ),
                  ),
                  Text(
                    formatCurrency(r.amount),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: r.positive ? AppColors.green : pal.text,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            Divider(height: 1, color: pal.divider),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Свободно',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: pal.text,
                    ),
                  ),
                ),
                Text(
                  formatCurrency(free),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
