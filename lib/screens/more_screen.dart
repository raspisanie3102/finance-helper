import 'package:flutter/material.dart';

import '../format.dart';
import '../store.dart';
import '../theme.dart';
import '../widgets/app_icons.dart';
import '../widgets/common.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

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
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                child: Text(
                  'Ещё',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: pal.text,
                  ),
                ),
              ),
              // Профиль
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: AppCard(
                  child: Row(
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: pal.sage,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text('🧑', style: TextStyle(fontSize: 24)),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              app.userName,
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: pal.text,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${app.city} · BYN',
                              style:
                                  TextStyle(fontSize: 13, color: pal.sub),
                            ),
                            if ((app.user?.email ?? '').isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                app.user!.email,
                                style: TextStyle(fontSize: 12, color: pal.sub),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const Text(
                        '🌿',
                        style: TextStyle(fontSize: 22),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Режим бюджета
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Режим бюджета',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: pal.text,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        app.pairMode
                            ? 'Общий бюджет пары: общий остаток, дневной лимит, '
                                'порции еды, стоимость развлечений и цели '
                                'пересчитаны на двоих'
                            : 'Личный бюджет: план, питание и развлечения рассчитаны для одного',
                        style: TextStyle(
                          fontSize: 12.5,
                          height: 1.4,
                          color: pal.sub,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SegmentedControl(
                        labels: const ['Только я', 'Я и партнёр'],
                        selected: app.pairMode ? 1 : 0,
                        onChanged: (i) => app.setPairMode(i == 1),
                      ),
                      if (app.pairMode && app.pairConnected) ...[
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: pal.cardAlt,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              AppIconPair(
                                size: 26,
                                color: AppColors.emeraldBright,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Код приглашения',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        color: pal.sub,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      app.inviteCode,
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1.2,
                                        color: AppColors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Партнёр подключён',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      color: pal.sub,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${app.partnerName} · '
                                    '${formatCurrency(app.partnerIncome)}',
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700,
                                      color: pal.text,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Совокупный доход: ${formatCurrency(app.combinedIncome)}. '
                          'Расходы можно отмечать как личные или общие — '
                          'автор выбирается при добавлении операции',
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.4,
                            color: pal.sub,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Тема оформления
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Тема оформления',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: pal.text,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SegmentedControl(
                        labels: const ['☀️ Светлая', '🌙 Тёмная', '⚙️ Как в системе'],
                        selected: switch (app.themeMode) {
                          ThemeMode.light => 0,
                          ThemeMode.dark => 1,
                          _ => 2,
                        },
                        onChanged: (i) => app.setThemeMode(
                          i == 0
                              ? ThemeMode.light
                              : i == 1
                                  ? ThemeMode.dark
                                  : ThemeMode.system,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Настройки
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: AppCard(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 6),
                  child: Column(
                    children: [
                      _SettingsRow(
                        emoji: '🔔',
                        title: 'Уведомления о платежах',
                        trailing: Switch(
                          value: true,
                          activeThumbColor: AppColors.green,
                          onChanged: (_) {},
                        ),
                      ),
                      Divider(height: 1, color: pal.divider),
                      _SettingsRow(
                        emoji: '💵',
                        title: 'Валюта',
                        trailing: Text(
                          'BYN',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: pal.sub,
                          ),
                        ),
                      ),
                      Divider(height: 1, color: pal.divider),
                      _SettingsRow(
                        emoji: 'ℹ️',
                        title: 'О приложении',
                        trailing: Text(
                          'Прототип 0.4',
                          style: TextStyle(
                            fontSize: 14,
                            color: pal.sub,
                          ),
                        ),
                      ),
                      Divider(height: 1, color: pal.divider),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          app.signOut();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Вы вышли из аккаунта. Возвращайтесь! 👋'),
                            ),
                          );
                        },
                        child: _SettingsRow(
                          emoji: '🚪',
                          title: 'Выйти из аккаунта',
                          trailing: Icon(
                            Icons.chevron_right_rounded,
                            size: 20,
                            color: pal.sub,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  'Финансовый помощник',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: pal.sub,
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

class _SettingsRow extends StatelessWidget {
  final String emoji;
  final String title;
  final Widget trailing;

  const _SettingsRow({
    required this.emoji,
    required this.title,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final pal = palOf(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text(emoji, style: const TextStyle(fontSize: 17)),
          ),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: pal.text,
              ),
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
