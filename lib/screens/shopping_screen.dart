import 'package:flutter/material.dart';

import '../data.dart';
import '../format.dart';
import '../store.dart';
import '../theme.dart';
import '../widgets/common.dart';

class ShoppingScreen extends StatefulWidget {
  const ShoppingScreen({super.key});

  @override
  State<ShoppingScreen> createState() => _ShoppingScreenState();
}

class _ShoppingScreenState extends State<ShoppingScreen> {
  int period = 0; // 0 — Сегодня, 1 — На неделю, 2 — Всё

  @override
  Widget build(BuildContext context) {
    final pal = palOf(context);
    final app = AppScope.of(context);
    // Для прототипа список один; переключатель периода меняет подпись.
    final items = app.shopping;

    return StatusBarStyle(
      darkIcons: Theme.of(context).brightness != Brightness.dark,
      child: Scaffold(
        backgroundColor: pal.bg,
        body: SafeArea(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 28),
            children: [
              const ScreenHeader(title: 'Покупки'),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: SegmentedControl(
                  labels: const ['Сегодня', 'На неделю', 'Всё'],
                  selected: period,
                  onChanged: (i) => setState(() => period = i),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        period == 0
                            ? 'Список на сегодня'
                            : period == 1
                                ? 'Список на неделю'
                                : 'Все продукты',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: pal.text,
                        ),
                      ),
                    ),
                    Text(
                      '${items.where((i) => !i.checked).length} позиций',
                      style: TextStyle(fontSize: 13, color: pal.sub),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: AppCard(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: AnimatedBuilder(
                    animation: app,
                    builder: (context, _) => Column(
                      children: [
                        for (var i = 0; i < items.length; i++) ...[
                          _ShopRow(
                            item: items[i],
                            onTap: () => app.toggleShoppingItem(i),
                          ),
                          if (i < items.length - 1)
                            Divider(height: 1, color: pal.divider),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Примерная стоимость',
                        style: TextStyle(fontSize: 14, color: pal.sub),
                      ),
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: Text(
                        formatCurrency(app.shoppingTotal, showFraction: true),
                        key: ValueKey(app.shoppingTotal),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: pal.text,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: PrimaryButton(
                  label: 'Купить',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Сравнение цен по магазинам Минска будет в следующей версии 🛒',
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShopRow extends StatelessWidget {
  final ShopItem item;
  final VoidCallback onTap;
  const _ShopRow({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final pal = palOf(context);
    return Opacity(
      opacity: item.checked ? 0.45 : 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            GestureDetector(
              onTap: onTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: item.checked ? AppColors.green : Colors.transparent,
                  border: item.checked
                      ? null
                      : Border.all(color: pal.divider, width: 2),
                ),
                child: item.checked
                    ? const Icon(Icons.check_rounded,
                        size: 16, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Text(item.emoji, style: const TextStyle(fontSize: 19)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: pal.text,
                    ),
                  ),
                  Text(
                    item.qty,
                    style: TextStyle(fontSize: 12, color: pal.sub),
                  ),
                ],
              ),
            ),
            Text(
              formatCurrency(item.price, showFraction: true),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: pal.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
