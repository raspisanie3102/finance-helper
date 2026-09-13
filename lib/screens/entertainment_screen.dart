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
  final List<String> skipped = [];

  @override
  Widget build(BuildContext context) {
    final pal = palOf(context);
    final app = AppScope.of(context);

    final items = entertainments
        .where((e) =>
            (category == 'Все' || e.category == category) &&
            !skipped.contains(e.title))
        .toList();

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
                      Text('💡', style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Сегодня можно потратить ≈ ${formatCurrency(app.dailyLeft)}',
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
                    ? _EmptyState(onReset: () => setState(() => skipped.clear()))
                    : ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, i) => _EntertainmentCard(
                          item: items[i],
                          onSkip: () {
                            setState(() => skipped.add(items[i].title));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Тогда попробуем что-нибудь другое ✨'),
                              ),
                            );
                          },
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
  final VoidCallback onReset;
  const _EmptyState({required this.onReset});

  @override
  Widget build(BuildContext context) {
    final pal = palOf(context);
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
          GestureDetector(
            onTap: onReset,
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
  final VoidCallback onSkip;

  const _EntertainmentCard({required this.item, required this.onSkip});

  @override
  Widget build(BuildContext context) {
    final pal = palOf(context);
    final app = AppScope.of(context);
    final fits = item.price <= app.dailyLeft;
    final over = item.price - app.dailyLeft;

    return AppCard(
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
                          formatFromPrice(item.price),
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
              color: fits ? pal.sage : pal.pinkBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              fits
                  ? '✓ Подходит вашему бюджету'
                  : 'Выход за дневной бюджет: +${formatCurrency(over)}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: fits ? AppColors.green : pal.pinkText,
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
                onTap: onSkip,
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
              text: formatFromPrice(item.price),
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
              label: item.price <= 0 ? 'Выбрать' : 'Выбрать · ${formatCurrency(item.price)}',
              onTap: () {
                Navigator.of(sheetContext).pop();
                if (item.price > 0) {
                  app.addExpense(item.price, 'Развлечения');
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      item.price > 0
                          ? 'Выбрано! После выбора останется ≈ ${formatCurrency(app.dailyLeft)}'
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
