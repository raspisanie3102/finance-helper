import 'package:flutter/material.dart';

/// Изумрудно-люксовая палитра «Финансового помощника».
/// Тёмный emerald как основной look; светлая — мягкий вариант той же гаммы.
class AppColors {
  // Ядро
  static const greenDark = Color(0xFF0A1612);
  static const greenDeep = Color(0xFF0E1F18);
  static const green = Color(0xFF10B981);
  static const greenSoft = Color(0xFF1A3D32);
  static const emeraldBright = Color(0xFF34D399);
  static const emeraldGlow = Color(0xFF6EE7B7);

  // Светлая тема (мягкий emerald, не крем)
  static const cream = Color(0xFFEEF6F2);
  static const sage = Color(0xFFD4EDE3);
  static const sageBorder = Color(0xFFB8DCCE);
  static const cardLight = Color(0xFFF5FBF8);
  static const ink = Color(0xFF0F241C);
  static const subLight = Color(0xFF5A7A6C);
  static const tipYellow = Color(0xFFD1FAE5);
  static const tipYellowText = Color(0xFF065F46);
  static const pink = Color(0xFFE8F5F0);

  // Тёмная тема (люкс)
  static const darkBg = Color(0xFF0A1612);
  static const darkCard = Color(0x14FFFFFF);
  static const darkCardAlt = Color(0x1AFFFFFF);
  static const darkText = Color(0xFFF0FDF8);
  static const darkSub = Color(0xFF8BA89A);
  static const accentDark = Color(0xFF34D399);
  static const darkTip = Color(0x2810B981);
  static const darkTipText = Color(0xFFA7F3D0);
  static const darkPink = Color(0x2210B981);
  static const darkPinkText = Color(0xFF6EE7B7);

  // Glass
  static const glassFill = Color(0x14FFFFFF);
  static const glassFillStrong = Color(0x1FFFFFFF);
  static const glassBorder = Color(0x33FFFFFF);
  static const glassHighlight = Color(0x22FFFFFF);
}

/// Палитра, зависящая от текущей темы.
class Pal {
  final Color bg;
  final Color card;
  final Color cardAlt;
  final Color text;
  final Color sub;
  final Color accent;
  final Color onAccent;
  final Color sage;
  final Color sageBorder;
  final Color tipBg;
  final Color tipText;
  final Color pinkBg;
  final Color pinkText;
  final Color header;
  final Color divider;
  final Color shadow;
  final Color glassFill;
  final Color glassBorder;

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
    required this.glassFill,
    required this.glassBorder,
  });
}

const palLight = Pal(
  bg: AppColors.cream,
  card: AppColors.cardLight,
  cardAlt: Color(0xFFE4F2EB),
  text: AppColors.ink,
  sub: AppColors.subLight,
  accent: AppColors.green,
  onAccent: Colors.white,
  sage: AppColors.sage,
  sageBorder: AppColors.sageBorder,
  tipBg: AppColors.tipYellow,
  tipText: AppColors.tipYellowText,
  pinkBg: AppColors.pink,
  pinkText: Color(0xFF047857),
  header: AppColors.greenDeep,
  divider: Color(0xFFC5DFD3),
  shadow: Color(0x1810B981),
  glassFill: Color(0xCCF5FBF8),
  glassBorder: Color(0x6610B981),
);

const palDark = Pal(
  bg: AppColors.darkBg,
  card: AppColors.darkCard,
  cardAlt: AppColors.darkCardAlt,
  text: AppColors.darkText,
  sub: AppColors.darkSub,
  accent: AppColors.accentDark,
  onAccent: AppColors.greenDeep,
  sage: Color(0xFF163528),
  sageBorder: Color(0x33FFFFFF),
  tipBg: AppColors.darkTip,
  tipText: AppColors.darkTipText,
  pinkBg: AppColors.darkPink,
  pinkText: AppColors.darkPinkText,
  header: Color(0xFF07120E),
  divider: Color(0x22FFFFFF),
  shadow: Color(0x66000000),
  glassFill: AppColors.glassFill,
  glassBorder: AppColors.glassBorder,
);

Pal palOf(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark ? palDark : palLight;

class AppTheme {
  static ThemeData light() => _base(
        Brightness.light,
        ColorScheme.light(
          primary: AppColors.green,
          onPrimary: Colors.white,
          secondary: AppColors.greenDeep,
          onSecondary: Colors.white,
          surface: AppColors.cardLight,
          onSurface: AppColors.ink,
        ),
        AppColors.cream,
      );

  static ThemeData dark() => _base(
        Brightness.dark,
        ColorScheme.dark(
          primary: AppColors.accentDark,
          onPrimary: AppColors.greenDeep,
          secondary: AppColors.emeraldBright,
          onSecondary: AppColors.greenDeep,
          surface: AppColors.greenDeep,
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
        backgroundColor: AppColors.greenDeep,
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
