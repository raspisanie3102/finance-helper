import 'package:flutter/material.dart';

import '../theme.dart';

/// Пошаговая инструкция при первом запуске: подсвечивает элементы
/// главного экрана и объясняет короткой подсказкой. Пролистывается
/// тапом по экрану или кнопкой «Далее», пропускается ссылкой.
class TourOverlay extends StatefulWidget {
  final List<TourStep> steps;
  final VoidCallback onFinish;

  const TourOverlay({super.key, required this.steps, required this.onFinish});

  @override
  State<TourOverlay> createState() => _TourOverlayState();
}

class TourStep {
  final GlobalKey key;
  final String emoji;
  final String title;
  final String text;

  const TourStep({
    required this.key,
    required this.emoji,
    required this.title,
    required this.text,
  });
}

class _TourOverlayState extends State<TourOverlay> {
  int step = 0;
  bool closing = false;

  @override
  void initState() {
    super.initState();
    // Первый кадр: ждём завершения layout, чтобы вычислить позиции целей.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  Rect? _rectOf(GlobalKey key) {
    final box = key.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.attached || !box.hasSize) return null;
    return box.localToGlobal(Offset.zero) & box.size;
  }

  void _next() {
    if (step < widget.steps.length - 1) {
      setState(() => step++);
    } else {
      setState(() => closing = true);
      Future.delayed(const Duration(milliseconds: 350), widget.onFinish);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final current = widget.steps[step];
    final target = _rectOf(current.key);
    final isLast = step == widget.steps.length - 1;

    // Карточку ставим под цель, если есть место, иначе — над ней.
    final tooltipTop = target != null && target.bottom < size.height * 0.55
        ? target.bottom + 16
        : (target?.top ?? size.height * 0.4) - 200;

    return AnimatedOpacity(
      opacity: closing ? 0 : 1,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            // затемнение с «окном» вокруг подсвеченного элемента
            GestureDetector(
              onTap: _next,
              behavior: HitTestBehavior.opaque,
              child: TweenAnimationBuilder<Rect?>(
                // Пока цель не найдена (первый кадр), окно нулевого размера.
                tween: RectTween(
                  begin: Rect.zero,
                  end: target?.inflate(10) ?? Rect.zero,
                ),
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutCubic,
                builder: (context, holeRect, _) => CustomPaint(
                  size: size,
                  painter: _SpotlightPainter(
                    hole: holeRect,
                    barrier: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xCC060B07)
                        : const Color(0xB30F1A13),
                  ),
                ),
              ),
            ),
            // подпись «шаг x из n» и «Пропустить»
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Text(
                      'Шаг ${step + 1} из ${widget.steps.length}',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFBFD8C9),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() => closing = true);
                      Future.delayed(
                          const Duration(milliseconds: 350), widget.onFinish);
                    },
                    child: const Text(
                      'Пропустить',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFBFD8C9),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // карточка-подсказка
            AnimatedPositioned(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              left: 20,
              right: 20,
              top: tooltipTop.clamp(
                  MediaQuery.of(context).padding.top + 48, size.height - 260),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.12),
                      end: Offset.zero,
                    ).animate(anim),
                    child: child,
                  ),
                ),
                child: _TourCard(
                  key: ValueKey(step),
                  emoji: current.emoji,
                  title: current.title,
                  text: current.text,
                  isLast: isLast,
                  step: step,
                  total: widget.steps.length,
                  onNext: _next,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TourCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String text;
  final bool isLast;
  final int step;
  final int total;
  final VoidCallback onNext;

  const _TourCard({
    super.key,
    required this.emoji,
    required this.title,
    required this.text,
    required this.isLast,
    required this.step,
    required this.total,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final pal = palOf(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: pal.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: pal.sageBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: pal.sage,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                    child: Text(emoji, style: const TextStyle(fontSize: 22))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                    color: pal.text,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              height: 1.45,
              color: pal.sub,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              for (var i = 0; i < total; i++)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 5),
                  width: i == step ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: i == step ? AppColors.green : pal.divider,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              const Spacer(),
              GestureDetector(
                onTap: onNext,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.green,
                    borderRadius: BorderRadius.circular(13),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.green.withValues(alpha: 0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Text(
                    isLast ? 'Понятно, поехали 🌿' : 'Далее',
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
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

class _SpotlightPainter extends CustomPainter {
  final Rect? hole;
  final Color barrier;

  _SpotlightPainter({required this.hole, required this.barrier});

  @override
  void paint(Canvas canvas, Size size) {
    Path overlay = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    if (hole != null) {
      final holePath = Path()
        ..addRRect(
            RRect.fromRectAndRadius(hole!, const Radius.circular(24)));
      overlay = Path.combine(
        PathOperation.difference,
        overlay,
        holePath,
      );
    }

    canvas.drawPath(overlay, Paint()..color = barrier);

    // мягкая светлая обводка вокруг подсвеченного элемента
    if (hole != null && hole!.width > 0 && hole!.height > 0) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(hole!, const Radius.circular(24)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = const Color(0x66FFFFFF),
      );
    }
  }

  @override
  bool shouldRepaint(_SpotlightPainter old) =>
      old.hole != hole || old.barrier != barrier;
}
