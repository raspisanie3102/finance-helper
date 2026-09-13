import 'package:flutter/material.dart';

import '../data.dart';
import '../format.dart';
import '../store.dart';
import '../theme.dart';
import '../widgets/common.dart';

class GoalsScreen extends StatefulWidget {
  final bool showBack;
  const GoalsScreen({super.key, this.showBack = false});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  int tab = 0; // 0 — Мои цели, 1 — Общие цели

  @override
  Widget build(BuildContext context) {
    final pal = palOf(context);
    final app = AppScope.of(context);

    final header = widget.showBack
        ? ScreenHeader(
            title: 'Цели',
            trailing: _AddGoalButton(onTap: _demoToast),
          )
        : SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Цели',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: pal.text,
                      ),
                    ),
                  ),
                  _AddGoalButton(onTap: _demoToast),
                ],
              ),
            ),
          );

    return StatusBarStyle(
      darkIcons: Theme.of(context).brightness != Brightness.dark,
      child: Scaffold(
        backgroundColor: pal.bg,
        body: SafeArea(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 28),
            children: [
              header,
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
                child: SegmentedControl(
                  labels: const ['Мои цели', 'Общие цели'],
                  selected: tab,
                  onChanged: (i) => setState(() => tab = i),
                ),
              ),
              if (tab == 0)
                for (final g in goals)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child: _GoalCard(goal: g),
                  )
              else if (app.pairMode)
                for (final g in goals.take(2))
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child: _GoalCard(goal: g, shared: true),
                  )
              else
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: AppCard(
                    child: Column(
                      children: [
                        const Text('💑', style: TextStyle(fontSize: 38)),
                        const SizedBox(height: 12),
                        Text(
                          'Включите общий бюджет пары',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: pal.text,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Общие цели появятся после включения режима\n«Я и партнёр» в разделе «Ещё»',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.45,
                            color: pal.sub,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: GestureDetector(
                  onTap: _demoToast,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      color: pal.sage,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add_rounded,
                            size: 20, color: AppColors.green),
                        const SizedBox(width: 6),
                        Text(
                          'Новая цель',
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: pal.text,
                          ),
                        ),
                      ],
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

  void _demoToast() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Создание цели будет в следующей версии 🎯')),
    );
  }
}

class _AddGoalButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddGoalButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final pal = palOf(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: pal.card,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: pal.shadow,
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Icon(Icons.add_rounded, size: 24, color: AppColors.green),
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final Goal goal;
  final bool shared;
  const _GoalCard({required this.goal, this.shared = false});

  @override
  Widget build(BuildContext context) {
    final pal = palOf(context);
    final progress = goal.current / goal.target;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: pal.sage,
                  borderRadius: BorderRadius.circular(14),
                ),
                child:
                    Center(child: Text(goal.emoji, style: const TextStyle(fontSize: 20))),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: pal.text,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      shared ? 'Общая цель · вдвоём' : 'Личная цель',
                      style: TextStyle(fontSize: 12, color: pal.sub),
                    ),
                  ],
                ),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => LinearProgressIndicator(
                value: value,
                minHeight: 8,
                backgroundColor: pal.sage,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.green),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${formatCurrency(goal.current)} из ${formatCurrency(goal.target)}',
                  style: TextStyle(fontSize: 13, color: pal.sub),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
