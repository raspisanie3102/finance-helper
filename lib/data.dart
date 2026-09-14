// ─────────────────────────── Модели ───────────────────────────

class Ingredient {
  final String name;
  final String qty;
  final double price;
  const Ingredient(this.name, this.qty, this.price);
}

class Dish {
  final String name;
  final String emoji;
  final double price;
  final int kcal;
  final int minutes;
  final int protein;
  final int fat;
  final int carbs;
  final List<Ingredient> ingredients;
  const Dish({
    required this.name,
    required this.emoji,
    required this.price,
    required this.kcal,
    required this.minutes,
    required this.protein,
    required this.fat,
    required this.carbs,
    required this.ingredients,
  });
}

class Entertainment {
  final String title;
  final String category;
  final String emoji;
  final String address;
  final String distance;
  final String when;
  final double price;
  final double rating;
  final String description;
  const Entertainment({
    required this.title,
    required this.category,
    required this.emoji,
    required this.address,
    required this.distance,
    required this.when,
    required this.price,
    required this.rating,
    required this.description,
  });
}

class PaymentItem {
  final String name;
  final String emoji;
  final String date;
  final double amount;
  const PaymentItem(this.name, this.emoji, this.date, this.amount);
}

class Goal {
  final String name;
  final String emoji;
  double current; // накопил(и) на текущий момент
  final double target;
  final double partnerCurrent; // вклад партнёра в общую цель (демо)
  bool shared;
  Goal(
    this.name,
    this.emoji,
    this.current,
    this.target, {
    this.partnerCurrent = 0,
    this.shared = false,
  });

  /// Общий прогресс для режима «Пара».
  double get combinedCurrent => current + partnerCurrent;
}

class ShopItem {
  final String name;
  final String emoji;
  final String qty;
  final double price;
  bool checked;
  ShopItem(this.name, this.emoji, this.qty, this.price, {this.checked = false});
}

/// Тип операции, добавляемой через центральную кнопку «+».
enum OpType { expense, income, payment, purchase, savings }

extension OpTypeInfo on OpType {
  String get label => switch (this) {
        OpType.expense => 'Расход',
        OpType.income => 'Доход',
        OpType.payment => 'Платёж',
        OpType.purchase => 'Покупка',
        OpType.savings => 'Накопление',
      };
}

/// Любая финансовая операция: расход, доход, платёж, покупка, накопление.
class Operation {
  final OpType type;
  final double amount;
  final String category; // категория расхода / название платежа / цель
  final String who; // «Я», имя партнёра или «Общие»
  final DateTime date;
  Operation(
    this.type,
    this.amount,
    this.category,
    this.who,
  ) : date = DateTime.now();
}

// ─────────────────────────── Питание ───────────────────────────

/// Варианты блюд по слотам. Первый вариант — рекомендованный по ТЗ.
const Map<String, List<Dish>> mealSlots = {
  'Завтрак': [
    Dish(
      name: 'Овсянка с ягодами',
      emoji: '🥣',
      price: 6,
      kcal: 320,
      minutes: 10,
      protein: 12,
      fat: 8,
      carbs: 45,
      ingredients: [
        Ingredient('Овсяные хлопья', '100 г', 0.85),
        Ingredient('Молоко', '200 мл', 1.10),
        Ingredient('Ягоды', '100 г', 2.50),
        Ingredient('Мёд', '1 ч. л.', 0.40),
      ],
    ),
    Dish(
      name: 'Омлет с овощами',
      emoji: '🍳',
      price: 7,
      kcal: 380,
      minutes: 15,
      protein: 18,
      fat: 22,
      carbs: 9,
      ingredients: [
        Ingredient('Яйца', '3 шт.', 1.30),
        Ingredient('Молоко', '100 мл', 0.55),
        Ingredient('Помидоры', '1 шт.', 0.60),
        Ingredient('Сыр', '30 г', 0.90),
      ],
    ),
    Dish(
      name: 'Сырники со сметаной',
      emoji: '🥞',
      price: 9,
      kcal: 450,
      minutes: 20,
      protein: 24,
      fat: 18,
      carbs: 38,
      ingredients: [
        Ingredient('Творог', '400 г', 2.80),
        Ingredient('Яйцо', '1 шт.', 0.45),
        Ingredient('Сметана', '100 г', 0.90),
        Ingredient('Мука', '2 ст. л.', 0.15),
      ],
    ),
    Dish(
      name: 'Творог с мёдом и орехами',
      emoji: '🍯',
      price: 5,
      kcal: 290,
      minutes: 5,
      protein: 20,
      fat: 12,
      carbs: 22,
      ingredients: [
        Ingredient('Творог', '200 г', 1.40),
        Ingredient('Мёд', '1 ст. л.', 0.80),
        Ingredient('Орехи', '30 г', 0.90),
      ],
    ),
  ],
  'Обед': [
    Dish(
      name: 'Паста с курицей и овощами',
      emoji: '🍝',
      price: 18,
      kcal: 620,
      minutes: 25,
      protein: 38,
      fat: 16,
      carbs: 74,
      ingredients: [
        Ingredient('Макароны', '150 г', 0.95),
        Ingredient('Куриное филе', '250 г', 3.80),
        Ingredient('Овощи', '200 г', 1.60),
        Ingredient('Сыр', '30 г', 0.90),
      ],
    ),
    Dish(
      name: 'Куриный суп с лапшой',
      emoji: '🍲',
      price: 14,
      kcal: 410,
      minutes: 40,
      protein: 28,
      fat: 10,
      carbs: 46,
      ingredients: [
        Ingredient('Куриное филе', '200 г', 3.00),
        Ingredient('Лапша', '80 г', 0.60),
        Ingredient('Овощи для бульона', '250 г', 1.40),
      ],
    ),
    Dish(
      name: 'Гречка с котлетой',
      emoji: '🍛',
      price: 16,
      kcal: 580,
      minutes: 30,
      protein: 32,
      fat: 22,
      carbs: 58,
      ingredients: [
        Ingredient('Гречка', '120 г', 0.70),
        Ingredient('Фарш', '200 г', 3.40),
        Ingredient('Лук', '1 шт.', 0.35),
      ],
    ),
    Dish(
      name: 'Салат «Цезарь» с курицей',
      emoji: '🥗',
      price: 17,
      kcal: 430,
      minutes: 15,
      protein: 30,
      fat: 21,
      carbs: 18,
      ingredients: [
        Ingredient('Куриное филе', '200 г', 3.00),
        Ingredient('Салат айсберг', '150 г', 1.80),
        Ingredient('Соус цезарь', '50 мл', 1.20),
        Ingredient('Сухарики', '40 г', 0.50),
      ],
    ),
  ],
  'Ужин': [
    Dish(
      name: 'Запечённая рыба с овощами',
      emoji: '🐟',
      price: 25,
      kcal: 520,
      minutes: 35,
      protein: 42,
      fat: 20,
      carbs: 34,
      ingredients: [
        Ingredient('Филе рыбы', '300 г', 7.50),
        Ingredient('Картофель', '300 г', 0.90),
        Ingredient('Овощи', '250 г', 2.10),
        Ingredient('Сметана', '50 г', 0.60),
      ],
    ),
    Dish(
      name: 'Паста с курицей',
      emoji: '🍝',
      price: 22,
      kcal: 610,
      minutes: 25,
      protein: 36,
      fat: 15,
      carbs: 76,
      ingredients: [
        Ingredient('Макароны', '150 г', 0.95),
        Ingredient('Куриное филе', '250 г', 3.80),
        Ingredient('Соус', '100 мл', 1.30),
      ],
    ),
    Dish(
      name: 'Картофельная запеканка с фаршем',
      emoji: '🥔',
      price: 19,
      kcal: 640,
      minutes: 45,
      protein: 30,
      fat: 26,
      carbs: 66,
      ingredients: [
        Ingredient('Картофель', '500 г', 1.50),
        Ingredient('Фарш', '250 г', 4.20),
        Ingredient('Лук', '1 шт.', 0.35),
        Ingredient('Сыр', '50 г', 1.10),
      ],
    ),
    Dish(
      name: 'Тушёная индейка с рисом',
      emoji: '🍚',
      price: 21,
      kcal: 560,
      minutes: 35,
      protein: 40,
      fat: 14,
      carbs: 62,
      ingredients: [
        Ingredient('Филе индейки', '280 г', 6.30),
        Ingredient('Рис', '120 г', 0.80),
        Ingredient('Овощи', '200 г', 1.60),
      ],
    ),
  ],
};

/// Фотографии блюд (скачаны из открытой базы TheMealDB в assets).
/// Ключ — название блюда; если фото нет, UI показывает эмодзи-заглушку.
const Map<String, String> dishImages = {
  'Овсянка с ягодами': 'assets/images/dishes/oatmeal_berries.jpg',
  'Омлет с овощами': 'assets/images/dishes/omelette_veg.jpg',
  'Сырники со сметаной': 'assets/images/dishes/syrniki.jpg',
  'Творог с мёдом и орехами': 'assets/images/dishes/cottage_honey.jpg',
  'Паста с курицей и овощами': 'assets/images/dishes/pasta_chicken_veg.jpg',
  'Куриный суп с лапшой': 'assets/images/dishes/chicken_soup.jpg',
  'Гречка с котлетой': 'assets/images/dishes/buckwheat_cutlet.jpg',
  'Салат «Цезарь» с курицей': 'assets/images/dishes/caesar.jpg',
  'Запечённая рыба с овощами': 'assets/images/dishes/baked_fish.jpg',
  'Паста с курицей': 'assets/images/dishes/pasta_chicken.jpg',
  'Картофельная запеканка с фаршем':
      'assets/images/dishes/potato_casserole.jpg',
  'Тушёная индейка с рисом': 'assets/images/dishes/turkey_rice.jpg',
  'Поке с лососем': 'assets/images/dishes/poke_salmon.jpg',
  'Борщ с говядиной': 'assets/images/dishes/borscht.jpg',
  'Блины с творогом': 'assets/images/dishes/pancakes_curd.jpg',
  'Гречневая каша с грибами': 'assets/images/dishes/buckwheat_mushroom.jpg',
};

/// Популярные блюда (горизонтальная лента).
const List<Dish> popularDishes = [
  Dish(
    name: 'Поке с лососем',
    emoji: '🍣',
    price: 28,
    kcal: 480,
    minutes: 15,
    protein: 32,
    fat: 14,
    carbs: 52,
    ingredients: [
      Ingredient('Рис', '150 г', 0.60),
      Ingredient('Лосось', '150 г', 9.80),
      Ingredient('Овощи', '150 г', 1.80),
      Ingredient('Соус', '40 мл', 0.90),
    ],
  ),
  Dish(
    name: 'Борщ с говядиной',
    emoji: '🍲',
    price: 13,
    kcal: 390,
    minutes: 60,
    protein: 24,
    fat: 12,
    carbs: 40,
    ingredients: [
      Ingredient('Говядина', '250 г', 6.50),
      Ingredient('Свёкла', '1 шт.', 0.55),
      Ingredient('Капуста', '300 г', 0.80),
      Ingredient('Картофель', '300 г', 0.90),
    ],
  ),
  Dish(
    name: 'Блины с творогом',
    emoji: '🥞',
    price: 12,
    kcal: 470,
    minutes: 30,
    protein: 20,
    fat: 16,
    carbs: 58,
    ingredients: [
      Ingredient('Мука', '200 г', 0.50),
      Ingredient('Молоко', '500 мл', 1.30),
      Ingredient('Творог', '250 г', 1.80),
      Ingredient('Яйца', '2 шт.', 0.90),
    ],
  ),
  Dish(
    name: 'Гречневая каша с грибами',
    emoji: '🍄',
    price: 11,
    kcal: 350,
    minutes: 25,
    protein: 12,
    fat: 9,
    carbs: 58,
    ingredients: [
      Ingredient('Гречка', '150 г', 0.85),
      Ingredient('Шампиньоны', '250 г', 2.40),
      Ingredient('Лук', '1 шт.', 0.35),
    ],
  ),
];

// ─────────────────────── Развлечения (Минск) ───────────────────────

const List<Entertainment> entertainments = [
  Entertainment(
    title: 'Кинотеатр «Октябрьская»',
    category: 'Кино',
    emoji: '🎬',
    address: 'пр. Независимости, 73',
    distance: '1,8 км',
    when: 'Сегодня, 19:30',
    price: 15,
    rating: 4.7,
    description:
        'Вечерний сеанс в одном из главных кинотеатров Минска. '
        'Уютные залы, попкорн и новые фильмы недели.',
  ),
  Entertainment(
    title: 'Квест «Тайна старого замка»',
    category: 'Квесты',
    emoji: '🎯',
    address: 'ул. Октябрьская, 16',
    distance: '2,4 км',
    when: 'Сегодня, 18:00',
    price: 40,
    rating: 4.9,
    description:
        'Атмосферный квест для компании 2–4 человека. Загадки, декорации '
        'и один час настоящего приключения в центре города.',
  ),
  Entertainment(
    title: 'Театр им. Янки Купалы',
    category: 'Театр',
    emoji: '🎭',
    address: 'ул. Энгельса, 7',
    distance: '3,1 км',
    when: 'Сб, 19:00',
    price: 35,
    rating: 4.8,
    description:
        '«Пинская шляхта» — классика национального репертуара. '
        'Партер или бельэтаж на ваш выбор.',
  ),
  Entertainment(
    title: 'Кинотеатр «Мир»',
    category: 'Кино',
    emoji: '🍿',
    address: 'ул. Ленина, 4',
    distance: '2,6 км',
    when: 'Сегодня, 20:00',
    price: 12,
    rating: 4.6,
    description:
        'Кинотеатр в самом центре Минска с вечерними сеансами '
        'и атмосферой старого города.',
  ),
  Entertainment(
    title: 'Художественный музей',
    category: 'Выставки',
    emoji: '🎨',
    address: 'ул. Ленина, 20',
    distance: '2,1 км',
    when: 'Сегодня, 10:00–20:00',
    price: 8,
    rating: 4.7,
    description:
        'Национальный художественный музей: белорусская и мировая '
        'живопись, временные выставки современных художников.',
  ),
  Entertainment(
    title: 'Концерт во Дворце спорта',
    category: 'Концерты',
    emoji: '🎵',
    address: 'пр. Победителей, 4',
    distance: '4,2 км',
    when: '28 сентября, 19:00',
    price: 60,
    rating: 4.5,
    description:
        'Большой концерт в главном концертном зале Минска. '
        'Билеты от 60 BYN, сектора на выбор.',
  ),
  Entertainment(
    title: 'Прогулка по Парку Горького',
    category: 'Прогулки',
    emoji: '🌳',
    address: 'ул. Фрунзе, 2',
    distance: '1,2 км',
    when: 'Весь день',
    price: 0,
    rating: 4.9,
    description:
        'Любимый парк минчан: колесо обозрения, набережная Свислочи '
        'и вечерняя подсветка. Идеально для спокойного вечера.',
  ),
  Entertainment(
    title: 'Ужин для двоих в «Васильках»',
    category: 'Для пары',
    emoji: '🕯',
    address: 'пр. Независимости, 21',
    distance: '1,6 км',
    when: 'Сегодня, 19:00',
    price: 55,
    rating: 4.6,
    description:
        'Белорусская кухня и уютная атмосфера. Ужин на двоих '
        'в среднем 55 BYN на человека.',
  ),
];

const List<String> entertainmentCategories = [
  'Все',
  'Кино',
  'Квесты',
  'Театр',
  'Концерты',
  'Выставки',
  'Прогулки',
  'Для пары',
];

// ─────────────────────── Платежи и цели ───────────────────────

const List<PaymentItem> upcomingPayments = [
  PaymentItem('Аренда квартиры', '🏠', '20 сентября', 1200),
  PaymentItem('Интернет', '🌐', '22 сентября', 32),
  PaymentItem('Коммунальные услуги', '💧', '25 сентября', 85),
  PaymentItem('Мобильная связь', '📱', '28 сентября', 15),
  PaymentItem('Подписка на музыку', '🎵', '30 сентября', 12),
];

final List<Goal> goalsSeed = [
  Goal('Путешествие в Италию', '✈️', 42000, 100000,
      partnerCurrent: 15000, shared: true),
  Goal('Новый ноутбук', '💻', 35000, 120000,
      partnerCurrent: 8000, shared: true),
  Goal('Финансовая подушка', '🛟', 12000, 50000),
];

final List<ShopItem> defaultShopping = [
  ShopItem('Овсяные хлопья', '🌾', '100 г', 0.85),
  ShopItem('Молоко', '🥛', '1 л', 2.10),
  ShopItem('Яйца', '🥚', '6 шт.', 2.60),
  ShopItem('Куриное филе', '🍗', '500 г', 7.50),
  ShopItem('Сыр', '🧀', '300 г', 5.40),
  ShopItem('Помидоры', '🍅', '500 г', 3.20),
  ShopItem('Хлеб', '🍞', '400 г', 1.80),
  ShopItem('Ягоды', '🫐', '300 г', 4.30),
];

/// Категории расходов (ТЗ, п. 33).
const List<String> expenseCategories = [
  'Еда',
  'Покупки',
  'Развлечения',
  'Транспорт',
  'Дом',
  'Другое',
];

/// Дни недели для ленты питания/плана — реальные, относительно сегодня.
class WeekDay {
  final String day;
  final String date;
  final bool today;
  const WeekDay(this.day, this.date, this.today);
}

const _weekdayShort = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];

List<WeekDay> currentWeekDays([DateTime? now]) {
  final n = now ?? DateTime.now();
  // Понедельник текущей недели (weekday: Пн = 1 … Вс = 7).
  final monday = DateTime(n.year, n.month, n.day - (n.weekday - 1));
  return [
    for (var i = 0; i < 7; i++)
      WeekDay(
        _weekdayShort[i],
        '${monday.day + i}',
        monday.day + i == n.day,
      ),
  ];
}

const _monthGenitive = [
  'января',
  'февраля',
  'марта',
  'апреля',
  'мая',
  'июня',
  'июля',
  'августа',
  'сентября',
  'октября',
  'ноября',
  'декабря',
];

const _monthNominative = [
  'Январь',
  'Февраль',
  'Март',
  'Апрель',
  'Май',
  'Июнь',
  'Июль',
  'Август',
  'Сентябрь',
  'Октябрь',
  'Ноябрь',
  'Декабрь',
];

/// «14 сентября» — для заголовка «Сегодня».
String todayLabel([DateTime? now]) {
  final n = now ?? DateTime.now();
  return '${n.day} ${_monthGenitive[n.month - 1]}';
}

/// «Сентябрь 2026» — для шапок календарей.
String monthLabel([DateTime? now]) {
  final n = now ?? DateTime.now();
  return '${_monthNominative[n.month - 1]} ${n.year}';
}

/// Сколько дней осталось в месяце (включая сегодня) — для дневного лимита.
int daysLeftInMonth([DateTime? now]) {
  final n = now ?? DateTime.now();
  final daysInMonth = DateTime(n.year, n.month + 1, 0).day;
  return daysInMonth - n.day + 1;
}
