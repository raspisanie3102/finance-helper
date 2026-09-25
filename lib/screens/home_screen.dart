import 'package:flutter/material.dart';

import '../format.dart';
import '../store.dart';
import '../theme.dart';
import '../widgets/app_icons.dart';
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
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0E241C),
              AppColors.greenDark,
              Color(0xFF06110D),
            ],
            stops: [0.0, 0.45, 1.0],
          ),
        ),
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
              const SizedBox(height: 100),
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
                    'Привет, ${app.userName}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.emeraldGlow.withValues(alpha: 0.75),
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
            GlassCard(
              padding: EdgeInsets.zero,
              radius: 23,
              child: SizedBox(
                width: 46,
                height: 46,
                child: Center(
                  child: AppIconMark(
                    size: 22,
                    color: AppColors.emeraldBright,
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

class _BalanceCard extends StatelessWidget {
  const _BalanceCard();

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      key: HomeScreen.balanceKey,
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        radius: 24,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Доступно сейчас',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.emeraldGlow.withValues(alpha: 0.7),
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
              style: TextStyle(
                fontSize: 12.5,
                color: AppColors.darkSub.withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 1,
              color: Colors.white.withValues(alpha: 0.12),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'На счете',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.darkSub.withValues(alpha: 0.85),
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
                  color: Colors.white.withValues(alpha: 0.12),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Зарезервировано',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.darkSub.withValues(alpha: 0.85),
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
      child: GlassCard(
        color: pal.tipBg,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.green.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.green.withValues(alpha: 0.3),
                ),
              ),
              child: const Center(
                child: AppIconTip(size: 24, color: AppColors.emeraldBright),
              ),
            ),
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
    final tiles = <({Widget icon, String label, WidgetBuilder builder})>[
      (
        icon: const AppIconMeals(size: 22, color: AppColors.emeraldBright),
        label: 'Питание',
        builder: (_) => const MealsScreen(),
      ),
      (
        icon: const AppIconShopping(size: 22, color: AppColors.emeraldBright),
        label: 'Покупки',
        builder: (_) => const ShoppingScreen(),
      ),
      (
        icon: const AppIconEntertainment(
            size: 22, color: AppColors.emeraldBright),
        label: 'Развлечения',
        builder: (_) => const EntertainmentScreen(),
      ),
      (
        icon: const AppIconGoals(size: 22, color: AppColors.emeraldBright),
        label: 'Цели',
        builder: (_) => const GoalsScreen(showBack: true),
      ),
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
                icon: tiles[i].icon,
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
  final Widget icon;
  final String label;
  final VoidCallback onTap;

  const _Tile({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final pal = palOf(context);
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.green.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: AppColors.green.withValues(alpha: 0.28),
                ),
              ),
              child: Center(child: icon),
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
          padding:
              const EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 12),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Ближайшие платежи',
                  style: TextStyle(
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
                child: Text(
                  'Смотреть все',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.emeraldBright.withValues(alpha: 0.9),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GlassCard(
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
              color: AppColors.green.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: AppColors.green.withValues(alpha: 0.25),
              ),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 18)),
            ),
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
