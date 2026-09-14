import 'package:flutter/material.dart';

import '../data.dart';
import '../format.dart';
import '../store.dart';
import '../theme.dart';
import '../widgets/common.dart';

class EntertainmentScreen extends StatefulWidget {
  const EntertainmentScreen({super.key});

  @override
  State<EntertainmentScreen> createState() => _EntertainmentScreenState();
}

class _EntertainmentScreenState extends State<EntertainmentScreen> {
  String category = 'Все';

  @override
  Widget build(BuildContext context) {
    final pal = palOf(context);
    final app = AppScope.of(context);
    final inPair = app.pairMode && app.pairConnected;

    final items = app.orderedEntertainments(category);

    return StatusBarStyle(
      darkIcons: Theme.of(context).brightness != Brightness.dark,
      child: Scaffold(
        backgroundColor: pal.bg,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const ScreenHeader(title: 'Развлечения'),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
                child: AppCard(
                  color: pal.tipBg,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      const Text('💡', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          inPair
                              ? 'Сегодня можно потратить на двоих ≈ ${formatCurrency(app.dailyLeft)}'
                              : 'Сегодня можно потратить ≈ ${formatCurrency(app.dailyLeft)}',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: pal.tipText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: entertainmentCategories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) => FilterChipPill(
                    label: entertainmentCategories[i],
                    selected: category == entertainmentCategories[i],
                    onTap: () =>
                        setState(() => category = entertainmentCategories[i]),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: items.isEmpty
                    ? const _EmptyState()
                    : AnimatedBuilder(
                        animation: app,
                        builder: (context, _) => ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
                          itemCount: app.orderedEntertainments(category).length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, i) => _EntertainmentCard(
                            item: app.orderedEntertainments(category)[i],
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final pal = palOf(context);
    final app = AppScope.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🎈', style: TextStyle(fontSize: 42)),
          const SizedBox(height: 12),
          Text(
            'Варианты закончились',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: pal.text,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            app.entSkips.isEmpty
                ? 'В этой категории пока ничего нет'
                : 'Пропущенные варианты исключены из выдачи',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: pal.sub,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: app.resetEntertainmentSkips,
            child: Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: pal.sage,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'Показать снова',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: pal.text,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EntertainmentCard extends StatelessWidget {
  final Entertainment item;
  const _EntertainmentCard({required this.item});

  void _skip(BuildContext context) {
    final app = AppScope.of(context);
    app.skipEntertainment(item);
    final totalSkips = app.entSkips[item.title] ?? 0;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          totalSkips >= 2
              ? '«${item.title}» больше не будем предлагать 🚫'
              : 'Тогда попробуем что-нибудь другое ✨',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pal = palOf(context);
    final app = AppScope.of(context);
    final inPair = app.pairMode && app.pairConnected;
    final price = app.entertainmentPrice(item);
    final fits = price <= app.dailyLeft;
    final over = price - app.dailyLeft;

    return Dismissible(
      key: ValueKey('ent-${item.title}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _skip(context),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: pal.sage,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text('Не подходит 👋', style: TextStyle(fontSize: 15)),
      ),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    color: pal.sage,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(item.emoji, style: const TextStyle(fontSize: 28)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: pal.text,
                              ),
                            ),
                          ),
                          Text(
                            formatFromPrice(price),
                            style: const TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${item.emoji} ${item.category} · ${item.distance}',
                        style: TextStyle(fontSize: 12.5, color: pal.sub),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '📍 ${item.address}',
                        style: TextStyle(fontSize: 12.5, color: pal.sub),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '🕐 ${item.when}',
                        style: TextStyle(fontSize: 12.5, color: pal.sub),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                // Зелёный бэдж — вписывается в лимит, бежевый — выход за него.
                color: fits ? pal.sage : pal.tipBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                fits
                    ? inPair && item.category != 'Для пары'
                        ? '✓ Подходит бюджету · на двоих'
                        : '✓ Подходит вашему бюджету'
                    : 'Выход за дневной бюджет: +${formatCurrency(over)}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: fits ? AppColors.green : pal.tipText,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => showEntertainmentSheet(context, item),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      decoration: BoxDecoration(
                        color: AppColors.green,
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Text(
                        'Подробнее',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => _skip(context),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                    decoration: BoxDecoration(
                      color: pal.cardAlt,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Text(
                      'Не подходит',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: pal.sub,
                      ),
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

/// Полная карточка развлечения.
Future<void> showEntertainmentSheet(
  BuildContext context,
  Entertainment item,
) {
  final pal = palOf(context);
  final app = AppScope.of(context);
  final inPair = app.pairMode && app.pairConnected;
  final price = app.entertainmentPrice(item);

  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(sheetContext).size.height * 0.9,
        ),
        decoration: BoxDecoration(
          color: pal.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
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
            const SizedBox(height: 16),
            Container(
              height: 140,
              decoration: BoxDecoration(
                color: pal.sage,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Center(
                child: Text(item.emoji, style: const TextStyle(fontSize: 60)),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              item.title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
                color: pal.text,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              '${item.category} · ★ ${item.rating.toStringAsFixed(1)}',
              style: TextStyle(fontSize: 13.5, color: pal.sub),
            ),
            const SizedBox(height: 14),
            _InfoRow(icon: '📍', text: item.address),
            _InfoRow(icon: '📏', text: '${item.distance} от вас'),
            _InfoRow(icon: '🕐', text: item.when),
            _InfoRow(
              icon: '💵',
              text: inPair && item.category != 'Для пары'
                  ? '${formatFromPrice(price)} на двоих'
                  : formatFromPrice(price),
              value: true,
            ),
            const SizedBox(height: 12),
            Text(
              item.description,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: pal.sub,
              ),
            ),
            const SizedBox(height: 18),
            PrimaryButton(
              label: price <= 0
                  ? 'Выбрать'
                  : 'Выбрать · ${formatCurrency(price)}',
              onTap: () {
                Navigator.of(sheetContext).pop();
                app.pickEntertainment(item);
                if (price > 0) {
                  app.addExpense(
                    price,
                    'Развлечения',
                    inPair ? 'Общие' : 'Я',
                  );
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      price > 0
                          ? 'Выбрано! Сегодня можно потратить ≈ ${formatCurrency(app.dailyLeft)}'
                          : 'Отличный бесплатный вариант 🌳',
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                Navigator.of(sheetContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Карта будет в следующей версии 🗺')),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: pal.sage,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Показать на карте',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: pal.text,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

class _InfoRow extends StatelessWidget {
  final String icon;
  final String text;
  final bool value;
  const _InfoRow({required this.icon, required this.text, this.value = false});

  @override
  Widget build(BuildContext context) {
    final pal = palOf(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 26,
            child: Text(icon, style: const TextStyle(fontSize: 15)),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: pal.sub,
                fontWeight: value ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
