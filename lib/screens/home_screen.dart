import 'package:flutter/material.dart';

import '../format.dart';
import '../store.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'entertainment_screen.dart';
import 'goals_screen.dart';
import 'meals_screen.dart';
import 'payments_screen.dart';
import 'shopping_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Цели для подсветки в туре-инструкции при первом запуске.
  static final GlobalKey balanceKey = GlobalKey();
  static final GlobalKey tipKey = GlobalKey();
  static final GlobalKey tilesKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final pal = palOf(context);

    return StatusBarStyle(
      child: Container(
        color: AppColors.greenDark,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _Header(),
              const _BalanceCard(),
              const SizedBox(height: 14),
              const _DailyBudgetTip(),
              const SizedBox(height: 6),
              const _QuickTiles(),
              const _PaymentsPreview(),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Твои деньги. Твои решения. Твоя жизнь.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: pal.sub,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Привет, ${app.userName} 👋',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF9FC3AE),
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'Финансовый помощник',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFF2A473A),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF3D5F4F), width: 1.5),
              ),
              child: const Center(
                child: Text('🌿', style: TextStyle(fontSize: 20)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard();

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      key: HomeScreen.balanceKey,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2B4A3B), Color(0xFF17281F)],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.greenDark.withValues(alpha: 0.5),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Доступно сейчас',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF9FC3AE),
              ),
            ),
            const SizedBox(height: 6),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.25),
                    end: Offset.zero,
                  ).animate(anim),
                  child: child,
                ),
              ),
              child: Text(
                formatCurrency(app.availableNow),
                key: ValueKey(app.availableNow),
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              app.pairMode && app.pairConnected
                  ? 'после обязательных платежей и накоплений · на двоих'
                  : 'после обязательных платежей и накоплений',
              style: const TextStyle(
                fontSize: 12.5,
                color: Color(0xFF87A795),
              ),
            ),
            const SizedBox(height: 16),
            Container(height: 1, color: const Color(0xFF33503F)),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'На счете',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF87A795),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        formatCurrency(app.combinedIncome),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 30,
                  color: const Color(0xFF33503F),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Зарезервировано',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF87A795),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        formatCurrency(app.reserved),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
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

class _DailyBudgetTip extends StatelessWidget {
  const _DailyBudgetTip();

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final pal = palOf(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      key: HomeScreen.tipKey,
      child: AppCard(
        color: pal.tipBg,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Text('💡', style: TextStyle(fontSize: 26)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Сегодня можно потратить',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: pal.tipText.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 3),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      '≈ ${formatCurrency(app.dailyLeft)}',
                      key: ValueKey(app.dailyLeft),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: pal.tipText,
                      ),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Ты остаёшься в рамках бюджета',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: pal.tipText.withValues(alpha: 0.75),
                    ),
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

class _QuickTiles extends StatelessWidget {
  const _QuickTiles();

  @override
  Widget build(BuildContext context) {
    final tiles = <({String emoji, String label, WidgetBuilder builder})>[
      (emoji: '🍽', label: 'Питание', builder: (_) => const MealsScreen()),
      (emoji: '🛒', label: 'Покупки', builder: (_) => const ShoppingScreen()),
      (emoji: '🎬', label: 'Развлечения', builder: (_) => const EntertainmentScreen()),
      (emoji: '🎯', label: 'Цели', builder: (_) => const GoalsScreen(showBack: true)),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 4),
      key: HomeScreen.tilesKey,
      child: Row(
        children: [
          for (var i = 0; i < tiles.length; i++) ...[
            if (i > 0) const SizedBox(width: 12),
            Expanded(
              child: _Tile(
                emoji: tiles[i].emoji,
                label: tiles[i].label,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: tiles[i].builder),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final String emoji;
  final String label;
  final VoidCallback onTap;

  const _Tile({required this.emoji, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final pal = palOf(context);
    return GestureDetector(
      onTap: onTap,
      child: AppCard(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: pal.sage,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Center(child: Text(emoji, style: const TextStyle(fontSize: 22))),
            ),
            const SizedBox(height: 9),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: pal.text,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentsPreview extends StatelessWidget {
  const _PaymentsPreview();

  @override
  Widget build(BuildContext context) {
    final pal = palOf(context);
    final app = AppScope.of(context);
    final preview = app.upcomingPayments.take(2).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, right: 4, top: 20, bottom: 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Ближайшие платежи',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                    color: Colors.white,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PaymentsScreen()),
                ),
                child: const Text(
                  'Смотреть все',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF9FC3AE),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Column(
              children: [
                for (var i = 0; i < preview.length; i++) ...[
                  _PaymentRow(
                    emoji: preview[i].emoji,
                    name: preview[i].name,
                    date: preview[i].date,
                    amount: preview[i].amount,
                  ),
                  if (i < preview.length - 1)
                    Divider(height: 1, color: pal.divider),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PaymentRow extends StatelessWidget {
  final String emoji;
  final String name;
  final String date;
  final double amount;

  const _PaymentRow({
    required this.emoji,
    required this.name,
    required this.date,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    final pal = palOf(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: pal.sage,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 18))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: pal.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  date,
                  style: TextStyle(fontSize: 12.5, color: pal.sub),
                ),
              ],
            ),
          ),
          Text(
            formatCurrency(amount),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: pal.text,
            ),
          ),
        ],
      ),
    );
  }
}
