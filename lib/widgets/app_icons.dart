import 'package:flutter/material.dart';

import '../theme.dart';

/// Минималистичные line-art иконки для режима бюджета и быстрых тайлов.
class AppIconMark extends StatelessWidget {
  final double size;
  final Color? color;

  const AppIconMark({super.key, this.size = 22, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? palOf(context).accent;
    return CustomPaint(
      size: Size(size, size),
      painter: _MarkPainter(c),
    );
  }
}

class AppIconSolo extends StatelessWidget {
  final double size;
  final Color? color;

  const AppIconSolo({super.key, this.size = 22, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? palOf(context).accent;
    return CustomPaint(
      size: Size(size, size),
      painter: _SoloPainter(c),
    );
  }
}

class AppIconPair extends StatelessWidget {
  final double size;
  final Color? color;

  const AppIconPair({super.key, this.size = 22, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? palOf(context).accent;
    return CustomPaint(
      size: Size(size, size),
      painter: _PairPainter(c),
    );
  }
}

class AppIconMeals extends StatelessWidget {
  final double size;
  final Color? color;

  const AppIconMeals({super.key, this.size = 22, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? palOf(context).accent;
    return CustomPaint(
      size: Size(size, size),
      painter: _MealsPainter(c),
    );
  }
}

class AppIconShopping extends StatelessWidget {
  final double size;
  final Color? color;

  const AppIconShopping({super.key, this.size = 22, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? palOf(context).accent;
    return CustomPaint(
      size: Size(size, size),
      painter: _ShoppingPainter(c),
    );
  }
}

class AppIconEntertainment extends StatelessWidget {
  final double size;
  final Color? color;

  const AppIconEntertainment({super.key, this.size = 22, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? palOf(context).accent;
    return CustomPaint(
      size: Size(size, size),
      painter: _EntertainmentPainter(c),
    );
  }
}

class AppIconGoals extends StatelessWidget {
  final double size;
  final Color? color;

  const AppIconGoals({super.key, this.size = 22, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? palOf(context).accent;
    return CustomPaint(
      size: Size(size, size),
      painter: _GoalsPainter(c),
    );
  }
}

class AppIconTip extends StatelessWidget {
  final double size;
  final Color? color;

  const AppIconTip({super.key, this.size = 22, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? palOf(context).accent;
    return CustomPaint(
      size: Size(size, size),
      painter: _TipPainter(c),
    );
  }
}

Paint _stroke(Color color, double width) => Paint()
  ..color = color
  ..style = PaintingStyle.stroke
  ..strokeWidth = width
  ..strokeCap = StrokeCap.round
  ..strokeJoin = StrokeJoin.round
  ..isAntiAlias = true;

Paint _fill(Color color) => Paint()
  ..color = color
  ..style = PaintingStyle.fill
  ..isAntiAlias = true;

class _MarkPainter extends CustomPainter {
  final Color color;
  _MarkPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = s * 0.32;
    canvas.drawCircle(Offset(cx, cy), r, _stroke(color, s * 0.08));
    canvas.drawCircle(Offset(cx, cy), r * 0.35, _fill(color));
  }

  @override
  bool shouldRepaint(covariant _MarkPainter old) => old.color != color;
}

class _SoloPainter extends CustomPainter {
  final Color color;
  _SoloPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final sw = s * 0.09;
    final cx = size.width / 2;
    // head
    canvas.drawCircle(Offset(cx, s * 0.28), s * 0.16, _stroke(color, sw));
    // shoulders
    final path = Path()
      ..moveTo(s * 0.22, s * 0.88)
      ..quadraticBezierTo(s * 0.22, s * 0.55, cx, s * 0.52)
      ..quadraticBezierTo(s * 0.78, s * 0.55, s * 0.78, s * 0.88);
    canvas.drawPath(path, _stroke(color, sw));
  }

  @override
  bool shouldRepaint(covariant _SoloPainter old) => old.color != color;
}

class _PairPainter extends CustomPainter {
  final Color color;
  _PairPainter(this.color);

  void _person(Canvas canvas, double ox, double s, double sw, double scale) {
    final cx = ox + s * 0.22 * scale;
    final headY = s * 0.30;
    canvas.drawCircle(
      Offset(cx, headY),
      s * 0.12 * scale,
      _stroke(color, sw),
    );
    final path = Path()
      ..moveTo(ox + s * 0.06 * scale, s * 0.88)
      ..quadraticBezierTo(
        ox + s * 0.06 * scale,
        s * 0.58,
        cx,
        s * 0.52,
      )
      ..quadraticBezierTo(
        ox + s * 0.38 * scale,
        s * 0.58,
        ox + s * 0.38 * scale,
        s * 0.88,
      );
    canvas.drawPath(path, _stroke(color, sw));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final sw = s * 0.08;
    _person(canvas, s * 0.05, s, sw, 1.0);
    _person(canvas, s * 0.42, s, sw, 1.0);
  }

  @override
  bool shouldRepaint(covariant _PairPainter old) => old.color != color;
}

class _MealsPainter extends CustomPainter {
  final Color color;
  _MealsPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final sw = s * 0.09;
    final cx = size.width / 2;
    final cy = size.height / 2;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + s * 0.06), width: s * 0.72, height: s * 0.42),
      _stroke(color, sw),
    );
    canvas.drawLine(
      Offset(cx, cy - s * 0.28),
      Offset(cx, cy - s * 0.08),
      _stroke(color, sw),
    );
    canvas.drawCircle(Offset(cx, cy + s * 0.04), s * 0.08, _fill(color.withValues(alpha: 0.35)));
  }

  @override
  bool shouldRepaint(covariant _MealsPainter old) => old.color != color;
}

class _ShoppingPainter extends CustomPainter {
  final Color color;
  _ShoppingPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final sw = s * 0.09;
    final path = Path()
      ..moveTo(s * 0.22, s * 0.32)
      ..lineTo(s * 0.30, s * 0.82)
      ..lineTo(s * 0.70, s * 0.82)
      ..lineTo(s * 0.78, s * 0.32)
      ..close();
    canvas.drawPath(path, _stroke(color, sw));
    canvas.drawLine(
      Offset(s * 0.34, s * 0.32),
      Offset(s * 0.34, s * 0.22),
      _stroke(color, sw),
    );
    canvas.drawLine(
      Offset(s * 0.66, s * 0.32),
      Offset(s * 0.66, s * 0.22),
      _stroke(color, sw),
    );
    canvas.drawArc(
      Rect.fromLTRB(s * 0.34, s * 0.10, s * 0.66, s * 0.34),
      3.14,
      3.14,
      false,
      _stroke(color, sw),
    );
  }

  @override
  bool shouldRepaint(covariant _ShoppingPainter old) => old.color != color;
}

class _EntertainmentPainter extends CustomPainter {
  final Color color;
  _EntertainmentPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final sw = s * 0.09;
    final r = RRect.fromRectAndRadius(
      Rect.fromLTWH(s * 0.14, s * 0.28, s * 0.72, s * 0.48),
      Radius.circular(s * 0.08),
    );
    canvas.drawRRect(r, _stroke(color, sw));
    canvas.drawLine(
      Offset(s * 0.28, s * 0.22),
      Offset(s * 0.38, s * 0.28),
      _stroke(color, sw),
    );
    canvas.drawLine(
      Offset(s * 0.72, s * 0.22),
      Offset(s * 0.62, s * 0.28),
      _stroke(color, sw),
    );
    canvas.drawCircle(Offset(s * 0.38, s * 0.52), s * 0.05, _fill(color));
    canvas.drawCircle(Offset(s * 0.62, s * 0.52), s * 0.05, _fill(color));
  }

  @override
  bool shouldRepaint(covariant _EntertainmentPainter old) => old.color != color;
}

class _GoalsPainter extends CustomPainter {
  final Color color;
  _GoalsPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final sw = s * 0.09;
    final cx = size.width / 2;
    canvas.drawCircle(Offset(cx, s * 0.42), s * 0.28, _stroke(color, sw));
    canvas.drawCircle(Offset(cx, s * 0.42), s * 0.12, _stroke(color, sw));
    canvas.drawCircle(Offset(cx, s * 0.42), s * 0.04, _fill(color));
    canvas.drawLine(
      Offset(cx, s * 0.70),
      Offset(cx, s * 0.88),
      _stroke(color, sw),
    );
  }

  @override
  bool shouldRepaint(covariant _GoalsPainter old) => old.color != color;
}

class _TipPainter extends CustomPainter {
  final Color color;
  _TipPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final sw = s * 0.09;
    final cx = size.width / 2;
    canvas.drawCircle(Offset(cx, s * 0.38), s * 0.26, _stroke(color, sw));
    canvas.drawLine(
      Offset(cx, s * 0.66),
      Offset(cx, s * 0.74),
      _stroke(color, sw),
    );
    canvas.drawLine(
      Offset(s * 0.38, s * 0.82),
      Offset(s * 0.62, s * 0.82),
      _stroke(color, sw),
    );
    canvas.drawLine(
      Offset(cx, s * 0.22),
      Offset(cx, s * 0.30),
      _stroke(color, sw),
    );
  }

  @override
  bool shouldRepaint(covariant _TipPainter old) => old.color != color;
}
