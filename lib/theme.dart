import 'package:flutter/material.dart';

/// Цветовая система «Финансового помощника».
/// Светлая тема: молочный фон, мягкий и глубокий зелёный, бежевые акценты.
/// Тёмная тема: тёмный зелёно-графитовый фон, более светлые зелёные карточки.
class AppColors {
  // Общие
  static const greenDark = Color(0xFF1B2E23); // глубокий зелёный
  static const greenDeep = Color(0xFF15261C);
  static const green = Color(0xFF2E5E4E); // основной акцент
  static const greenSoft = Color(0xFF35604F);

  // Светлая тема
  static const cream = Color(0xFFF7F5EF); // молочный фон
  static const sage = Color(0xFFDCE8DC); // мягкий светло-зелёный
  static const sageBorder = Color(0xFFE3EDE2);
  static const cardLight = Colors.white;
  static const ink = Color(0xFF182420); // тёмно-графитовый текст
  static const subLight = Color(0xFF77857B); // нейтральный серий
  static const tipYellow = Color(0xFFFBF3D9); // приглушённый бежево-жёлтый
  static const tipYellowText = Color(0xFF87743B);
  static const pink = Color(0xFFF8E0DC);

  // Тёмная тема
  static const darkBg = Color(0xFF0F1A13); // очень тёмный зелёно-графитовый
  static const darkCard = Color(0xFF1A2A1F); // карточки чуть светлее фона
  static const darkCardAlt = Color(0xFF223528);
  static const darkText = Colors.white;
  static const darkSub = Color(0xFF9FB0A2);
  static const accentDark = Color(0xFF7FBF9E); // мягкий зелёный акцент
  static const darkTip = Color(0xFF2A3320);
  static const darkTipText = Color(0xFFD8CE9A);
  static const darkPink = Color(0xFF3A2A28);
  static const darkPinkText = Color(0xFFEBBDB2);
}

/// Палитра, зависящая от текущей темы. Используется на всех экранах,
/// чтобы обе темы выглядели продуманно, а не как инверсия.
class Pal {
  final Color bg;
  final Color card;
  final Color cardAlt;
  final Color text;
  final Color sub;
  final Color accent; // основной зелёный акцент
  final Color onAccent;
  final Color sage; // светло-зелёная подложка
  final Color sageBorder;
  final Color tipBg;
  final Color tipText;
  final Color pinkBg;
  final Color pinkText;
  final Color header; // тёмная шапка/карта баланса
  final Color divider;
  final Color shadow;

  const Pal({
    required this.bg,
    required this.card,
    required this.cardAlt,
    required this.text,
    required this.sub,
    required this.accent,
    required this.onAccent,
    required this.sage,
    required this.sageBorder,
    required this.tipBg,
    required this.tipText,
    required this.pinkBg,
    required this.pinkText,
    required this.header,
    required this.divider,
    required this.shadow,
  });
}

const palLight = Pal(
  bg: AppColors.cream,
  card: AppColors.cardLight,
  cardAlt: Color(0xFFEFF3EC),
  text: AppColors.ink,
  sub: AppColors.subLight,
  accent: AppColors.green,
  onAccent: Colors.white,
  sage: AppColors.sage,
  sageBorder: AppColors.sageBorder,
  tipBg: AppColors.tipYellow,
  tipText: AppColors.tipYellowText,
  pinkBg: AppColors.pink,
  pinkText: Color(0xFF9A5C4E),
  header: AppColors.greenDark,
  divider: Color(0xFFEAE7DD),
  shadow: Color(0x1422521F),
);

const palDark = Pal(
  bg: AppColors.darkBg,
  card: AppColors.darkCard,
  cardAlt: AppColors.darkCardAlt,
  text: AppColors.darkText,
  sub: AppColors.darkSub,
  accent: AppColors.accentDark,
  onAccent: AppColors.greenDeep,
  sage: Color(0xFF24352A),
  sageBorder: Color(0xFF2C3F33),
  tipBg: AppColors.darkTip,
  tipText: AppColors.darkTipText,
  pinkBg: AppColors.darkPink,
  pinkText: AppColors.darkPinkText,
  header: Color(0xFF16241B),
  divider: Color(0xFF27362C),
  shadow: Color(0x40000000),
);

Pal palOf(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark ? palDark : palLight;

class AppTheme {
  static ThemeData light() => _base(
        Brightness.light,
        ColorScheme.light(
          primary: AppColors.green,
          onPrimary: Colors.white,
          secondary: AppColors.greenDark,
          onSecondary: Colors.white,
          surface: Colors.white,
          onSurface: AppColors.ink,
        ),
        AppColors.cream,
      );

  static ThemeData dark() => _base(
        Brightness.dark,
        ColorScheme.dark(
          primary: AppColors.accentDark,
          onPrimary: AppColors.greenDeep,
          secondary: AppColors.accentDark,
          onSecondary: AppColors.greenDeep,
          surface: AppColors.darkCard,
          onSurface: AppColors.darkText,
        ),
        AppColors.darkBg,
      );

  static ThemeData _base(Brightness brightness, ColorScheme scheme, Color bg) {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: bg,
      splashFactory: InkSparkle.splashFactory,
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.greenDark,
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
