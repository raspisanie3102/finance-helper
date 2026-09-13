import 'package:flutter/material.dart';

import '../data.dart';
import '../format.dart';
import '../store.dart';
import '../theme.dart';
import '../widgets/common.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  int tab = 0; // 0 — Предстоящие, 1 — История

  @override
  Widget build(BuildContext context) {
    final pal = palOf(context);
    final app = AppScope.of(context);
    final total =
        upcomingPayments.fold(0.0, (sum, p) => sum + p.amount);

    return StatusBarStyle(
      darkIcons: Theme.of(context).brightness != Brightness.dark,
      child: Scaffold(
        backgroundColor: pal.bg,
        body: SafeArea(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 28),
            children: [
              const ScreenHeader(title: 'Платежи'),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
                child: SegmentedControl(
                  labels: const ['Предстоящие', 'История'],
                  selected: tab,
                  onChanged: (i) => setState(() => tab = i),
                ),
              ),
              if (tab == 0) ...[
                for (final p in upcomingPayments)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child: _PaymentCard(emoji: p.emoji, name: p.name, date: p.date, amount: p.amount),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: AppCard(
                    color: pal.pinkBg,
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Всего предстоящих платежей',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: pal.pinkText,
                            ),
                          ),
                        ),
                        Text(
                          formatCurrency(total),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: pal.pinkText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                if (app.expenses.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 60),
                    child: Column(
                      children: [
                        const Text('🧾', style: TextStyle(fontSize: 42)),
                        const SizedBox(height: 12),
                        Text(
                          'Здесь появится история операций',
                          style: TextStyle(
                            fontSize: 14.5,
                            color: pal.sub,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  for (final e in app.expenses.reversed)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                      child: _PaymentCard(
                        emoji: _emojiFor(e.category),
                        name: '${e.category} · ${e.who}',
                        date:
                            '${e.date.hour.toString().padLeft(2, '0')}:${e.date.minute.toString().padLeft(2, '0')}',
                        amount: e.amount,
                      ),
                    ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _emojiFor(String category) {
    switch (category) {
      case 'Еда':
        return '🍽';
      case 'Покупки':
        return '🛍';
      case 'Развлечения':
        return '🎬';
      case 'Транспорт':
        return '🚌';
      case 'Дом':
        return '🏠';
      default:
        return '💳';
    }
  }
}

class _PaymentCard extends StatelessWidget {
  final String emoji;
  final String name;
  final String date;
  final double amount;

  const _PaymentCard({
    required this.emoji,
    required this.name,
    required this.date,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    final pal = palOf(context);
    return AppCard(
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: pal.sage,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 20))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    color: pal.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(date, style: TextStyle(fontSize: 12.5, color: pal.sub)),
              ],
            ),
          ),
          Text(
            formatCurrency(amount),
            style: TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w800,
              color: pal.text,
            ),
          ),
        ],
      ),
    );
  }
}
