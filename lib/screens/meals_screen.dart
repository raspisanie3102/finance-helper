import 'package:flutter/material.dart';

import '../data.dart';
import '../format.dart';
import '../store.dart';
import '../theme.dart';
import '../widgets/common.dart';

class MealsScreen extends StatelessWidget {
  const MealsScreen({super.key});

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
              const ScreenHeader(title: 'Питание'),
              const SizedBox(height: 18),
              const _WeekStrip(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Меню на сегодня',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: pal.text,
                        ),
                      ),
                    ),
                    Text(
                      '≈ ${formatCurrency(app.menuTotal)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.green,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              for (final slot in mealSlots.keys)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: _MealCard(slot: slot),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
                child: _WeekMenuButton(onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Меню на неделю ≈ 356 BYN — вписывается в план 🌱',
                      ),
                    ),
                  );
                }),
              ),
              SectionTitle('Популярные блюда', action: 'Все', onAction: () {}),
              SizedBox(
                height: 190,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: popularDishes.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, i) =>
                      _PopularDishCard(dish: popularDishes[i]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Фотография блюда из assets; если фото нет — эмодзи-заглушка.
class DishPhoto extends StatelessWidget {
  final Dish dish;
  final double? width;
  final double height;
  final BorderRadius radius;

  const DishPhoto({
    super.key,
    required this.dish,
    this.width,
    required this.height,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    final pal = palOf(context);
    final path = dishImages[dish.name];

    if (path == null) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(color: pal.sage, borderRadius: radius),
        child: Center(
          child: Text(dish.emoji, style: const TextStyle(fontSize: 26)),
        ),
      );
    }

    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        width: width,
        height: height,
        child: Image.asset(
          path,
          fit: BoxFit.cover,
          frameBuilder: (context, child, frame, wasSync) {
            if (wasSync) return child;
            return AnimatedOpacity(
              opacity: frame == null ? 0 : 1,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              child: child,
            );
          },
          errorBuilder: (_, __, ___) => Container(
            color: pal.sage,
            child: Center(
              child:
                  Text(dish.emoji, style: const TextStyle(fontSize: 26)),
            ),
          ),
        ),
      ),
    );
  }
}

class _WeekStrip extends StatelessWidget {
  const _WeekStrip();

  @override
  Widget build(BuildContext context) {
    final pal = palOf(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: AppCard(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  'Сентябрь 2026',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: pal.sub,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.chevron_right_rounded,
                    size: 18, color: AppColors.green),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                for (final d in weekDays)
                  Expanded(
                    child: GestureDetector(
                      onTap: () {},
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: d.today ? AppColors.green : Colors.transparent,
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: Column(
                          children: [
                            Text(
                              d.day,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: d.today
                                    ? const Color(0xFFBFD8C9)
                                    : pal.sub,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              d.date,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: d.today ? Colors.white : pal.text,
                              ),
                            ),
                          ],
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

class _MealCard extends StatelessWidget {
  final String slot;
  const _MealCard({required this.slot});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final pal = palOf(context);
    final dish = app.currentDish(slot);
    final selected = app.selectedMeals.contains(slot);

    return AppCard(
      child: Row(
        children: [
          DishPhoto(
            dish: dish,
            width: 56,
            height: 56,
            radius: BorderRadius.circular(16),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  slot,
                  style: TextStyle(fontSize: 12, color: pal.sub),
                ),
                const SizedBox(height: 3),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Text(
                    dish.name,
                    key: ValueKey(dish.name),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: pal.text,
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '≈ ${formatCurrency(dish.price)} · ${dish.minutes} мин',
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.green,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            children: [
              GestureDetector(
                onTap: () => app.toggleMeal(slot),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: selected ? AppColors.green : pal.cardAlt,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    selected ? Icons.check_rounded : Icons.add_rounded,
                    size: 24,
                    color: selected ? Colors.white : AppColors.green,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () {
                  final next = app.rejectMeal(slot);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Хорошо, вот ещё вариант: ${next.name} '
                        '≈ ${formatCurrency(next.price)}',
                      ),
                    ),
                  );
                },
                child: Text(
                  'Не хочу',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: pal.sub,
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

class _WeekMenuButton extends StatelessWidget {
  final VoidCallback onTap;
  const _WeekMenuButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final pal = palOf(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: pal.sage,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('🌱', style: const TextStyle(fontSize: 17)),
            const SizedBox(width: 8),
            Text(
              'Сформировать меню на неделю',
              style: TextStyle(
                fontSize: 14.5,
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

class _PopularDishCard extends StatelessWidget {
  final Dish dish;
  const _PopularDishCard({required this.dish});

  @override
  Widget build(BuildContext context) {
    final pal = palOf(context);
    return GestureDetector(
      onTap: () => showDishSheet(context, dish),
      child: AppCard(
        padding: const EdgeInsets.all(12),
        child: SizedBox(
          width: 130,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DishPhoto(
                dish: dish,
                width: double.infinity,
                height: 78,
                radius: BorderRadius.circular(14),
              ),
              const SizedBox(height: 10),
              Text(
                dish.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: pal.text,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '≈ ${formatCurrency(dish.price)}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.green,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Карточка блюда: фото, БЖУ, время, ингредиенты с ценами.
Future<void> showDishSheet(BuildContext context, Dish dish) {
  final pal = palOf(context);
  final app = AppScope.of(context);
  final ingredientsTotal =
      dish.ingredients.fold(0.0, (sum, i) => sum + i.price);

  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(sheetContext).size.height * 0.88,
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
            DishPhoto(
              dish: dish,
              width: double.infinity,
              height: 170,
              radius: BorderRadius.circular(22),
            ),
            const SizedBox(height: 16),
            Text(
              dish.name,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
                color: pal.text,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Text(
                  '≈ ${formatCurrency(dish.price)}',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${dish.kcal} ккал · ${dish.minutes} минут',
                  style: TextStyle(fontSize: 13.5, color: pal.sub),
                ),
              ],
            ),
            const SizedBox(height: 14),
            AppCard(
              color: pal.cardAlt,
              padding: const EdgeInsets.all(14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _Nutrition('Белки', '${dish.protein} г'),
                  _Nutrition('Жиры', '${dish.fat} г'),
                  _Nutrition('Углеводы', '${dish.carbs} г'),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Ингредиенты',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: pal.text,
              ),
            ),
            const SizedBox(height: 10),
            for (final ing in dish.ingredients)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        ing.name,
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: pal.text,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        ing.qty,
                        style: TextStyle(fontSize: 13, color: pal.sub),
                      ),
                    ),
                    Text(
                      formatCurrency(ing.price, showFraction: true),
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: pal.text,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Итого ориентировочно',
                    style: TextStyle(fontSize: 14, color: pal.sub),
                  ),
                ),
                Text(
                  '≈ ${formatCurrency(ingredientsTotal, showFraction: true)}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: pal.text,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Цены ориентировочные, по магазинам Минска',
              style: TextStyle(fontSize: 11.5, color: pal.sub),
            ),
            const SizedBox(height: 18),
            PrimaryButton(
              label: 'Добавить в рацион',
              onTap: () => Navigator.of(sheetContext).pop(),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                app.addIngredientsToShopping(dish);
                Navigator.of(sheetContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Продукты для «${dish.name}» добавлены в список покупок 🛒',
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: pal.sage,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Добавить продукты в список покупок',
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

class _Nutrition extends StatelessWidget {
  final String label;
  final String value;
  const _Nutrition(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    final pal = palOf(context);
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: pal.text,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 12, color: pal.sub)),
      ],
    );
  }
}
