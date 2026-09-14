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
    final inPair = app.pairMode && app.pairConnected;

    final header = widget.showBack
        ? ScreenHeader(
            title: 'Цели',
            trailing: _AddGoalButton(onTap: _showNewGoalSheet),
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
                  _AddGoalButton(onTap: _showNewGoalSheet),
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
              AnimatedBuilder(
                animation: app,
                builder: (context, _) {
                  final myGoals =
                      app.goals.where((g) => !g.shared).toList();
                  final sharedGoals =
                      app.goals.where((g) => g.shared).toList();

                  if (tab == 0) {
                    return Column(
                      children: [
                        for (final g in myGoals)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                            child: _GoalCard(goal: g),
                          ),
                      ],
                    );
                  }
                  if (inPair) {
                    return Column(
                      children: [
                        for (final g in sharedGoals)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                            child: _GoalCard(
                              goal: g,
                              shared: true,
                              partnerName: app.partnerName,
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 2, 20, 0),
                          child: Text(
                            'Общие цели копятся вдвоём: накопления каждого '
                            'идут в общий прогресс',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12.5,
                              height: 1.4,
                              color: pal.sub,
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: AppCard(
                      child: Column(
                        children: [
                          const Text('👨‍❤️‍👩', style: TextStyle(fontSize: 38)),
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
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: GestureDetector(
                  onTap: _showNewGoalSheet,
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

  /// Создание новой цели: название и целевая сумма.
  void _showNewGoalSheet() {
    final pal = palOf(context);
    final app = AppScope.of(context);
    final nameController = TextEditingController();
    final targetController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
          child: Container(
            decoration: BoxDecoration(
              color: pal.card,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(28)),
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
                      'Новая цель',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: pal.text,
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: nameController,
                      autofocus: true,
                      style: TextStyle(fontSize: 16, color: pal.text),
                      decoration: _inputDecoration('Название', pal),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: targetController,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      style: TextStyle(fontSize: 16, color: pal.text),
                      decoration:
                          _inputDecoration('Сумма, BYN', pal).copyWith(
                        prefixText: '',
                      ),
                    ),
                    const SizedBox(height: 18),
                    PrimaryButton(
                      label: 'Создать',
                      onTap: () {
                        final name = nameController.text.trim();
                        final target = double.tryParse(
                                targetController.text.replaceAll(',', '.')) ??
                            0;
                        if (name.isEmpty || target <= 0) return;
                        app.addGoal(Goal(name, '🎯', 0, target,
                            shared: app.pairMode && app.pairConnected && tab == 1));
                        Navigator.of(sheetContext).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Цель «$name» создана 🎯'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  InputDecoration _inputDecoration(String hint, Pal pal) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(fontSize: 14, color: pal.sub),
      filled: true,
      fillColor: pal.cardAlt,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
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
  final String? partnerName;
  const _GoalCard({required this.goal, this.shared = false, this.partnerName});

  @override
  Widget build(BuildContext context) {
    final pal = palOf(context);
    final current = shared ? goal.combinedCurrent : goal.current;
    final progress = (current / goal.target).clamp(0.0, 1.0);

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
                      shared
                          ? 'Общая цель · вдвоём'
                          : 'Личная цель',
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
                  shared && goal.partnerCurrent > 0
                      ? '${formatCurrency(current)} из ${formatCurrency(goal.target)} · '
                          'вклад ${partnerName ?? 'партнёра'}: ${formatCurrency(goal.partnerCurrent)}'
                      : '${formatCurrency(current)} из ${formatCurrency(goal.target)}',
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
