import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';

/// Looping demonstration of the hand measurement: a ruler slides under the
/// knuckles, then the span from the index to the little-finger knuckle is marked.
/// Shows the finished frame, without motion, when the device has animations off.
class HandSpanAnimation extends StatefulWidget {
  const HandSpanAnimation({super.key});

  @override
  State<HandSpanAnimation> createState() => _HandSpanAnimationState();
}

class _HandSpanAnimationState extends State<HandSpanAnimation>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3600),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations) {
      _controller.stop();
      _controller.value = 1;
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) => CustomPaint(
        painter: _HandSpanPainter(_controller.value),
        size: Size.infinite,
      ),
    );
  }
}

class _HandSpanPainter extends CustomPainter {
  _HandSpanPainter(this.t);

  /// 0..1 through one loop: ruler in, index knuckle, span grows, little-finger knuckle, hold.
  final double t;

  static const _accent = Color(0xFFF59E0B);
  // Finger lengths as a share of the tallest, index → little finger.
  static const _fingerLengths = [0.86, 1.0, 0.90, 0.68];

  double _phase(double start, double end) =>
      Curves.easeInOut.transform(((t - start) / (end - start)).clamp(0.0, 1.0));

  @override
  void paint(Canvas canvas, Size size) {
    final handW = math.min(size.width * 0.46, size.height * 0.62);
    final fingerW = handW / 4;
    final left = (size.width - handW) / 2;
    final palmTop = size.height * 0.50;
    final palmBottom = size.height * 0.98;
    final maxFinger = palmTop - 4;

    final skin = Paint()..color = kGreenLight;
    final outline = Paint()
      ..color = kGreenMid
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Thumb, on the index-finger side.
    canvas.save();
    canvas.translate(left + 2, palmTop + (palmBottom - palmTop) * 0.45);
    canvas.rotate(-0.6);
    final thumb = RRect.fromRectAndRadius(
      Rect.fromLTWH(-fingerW * 0.95, -fingerW * 1.5, fingerW * 0.95, fingerW * 1.9),
      Radius.circular(fingerW * 0.45),
    );
    canvas.drawRRect(thumb, skin);
    canvas.drawRRect(thumb, outline);
    canvas.restore();

    // Fingers.
    final knuckles = <Offset>[];
    for (var i = 0; i < 4; i++) {
      final x = left + fingerW * i;
      final top = palmTop - maxFinger * _fingerLengths[i];
      final finger = RRect.fromRectAndRadius(
        Rect.fromLTRB(x + 2, top, x + fingerW - 2, palmTop + fingerW * 0.5),
        Radius.circular(fingerW * 0.45),
      );
      canvas.drawRRect(finger, skin);
      canvas.drawRRect(finger, outline);
      knuckles.add(Offset(x + fingerW / 2, palmTop + 4));
    }

    // Palm (back of the hand), drawn over the finger bases.
    final palm = RRect.fromRectAndCorners(
      Rect.fromLTRB(left, palmTop, left + handW, palmBottom),
      topLeft: Radius.circular(fingerW * 0.4),
      topRight: Radius.circular(fingerW * 0.4),
      bottomLeft: Radius.circular(handW * 0.3),
      bottomRight: Radius.circular(handW * 0.3),
    );
    canvas.drawRRect(palm, skin);
    canvas.drawRRect(palm, outline);

    for (final k in knuckles) {
      canvas.drawCircle(k, 4, Paint()..color = kGreenMid);
    }

    // Ruler slides in from the right and rests just below the knuckles.
    final rulerIn = _phase(0.0, 0.25);
    final rulerTop = knuckles.first.dy + 12;
    final rulerH = math.max(18.0, fingerW * 0.55);
    final rulerLeft = left - fingerW * 0.5 + (1 - rulerIn) * size.width * 0.5;
    final rulerRect = Rect.fromLTWH(rulerLeft, rulerTop, handW + fingerW, rulerH);
    final rulerAlpha = rulerIn;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rulerRect, const Radius.circular(3)),
      Paint()..color = Colors.white.withValues(alpha: rulerAlpha),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rulerRect, const Radius.circular(3)),
      Paint()
        ..color = kText2.withValues(alpha: rulerAlpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    final tick = Paint()
      ..color = kText2.withValues(alpha: rulerAlpha)
      ..strokeWidth = 1;
    const ticks = 24;
    for (var i = 1; i < ticks; i++) {
      final x = rulerRect.left + rulerRect.width * i / ticks;
      final len = i % 4 == 0 ? rulerH * 0.55 : rulerH * 0.3;
      canvas.drawLine(Offset(x, rulerTop), Offset(x, rulerTop + len), tick);
    }

    // The span: index knuckle lights up, the line grows, the little-finger knuckle lights up.
    final startOn = _phase(0.28, 0.40);
    final grow = _phase(0.40, 0.68);
    final endOn = _phase(0.66, 0.78);
    final a = knuckles.first;
    final b = knuckles.last;
    final mark = Paint()
      ..color = _accent
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    void endpoint(Offset p, double on) {
      if (on <= 0) return;
      canvas.drawCircle(p, 4 + 8 * on, Paint()..color = _accent.withValues(alpha: 0.25 * on));
      canvas.drawCircle(p, 5, Paint()..color = _accent.withValues(alpha: on));
      canvas.drawLine(
        Offset(p.dx, p.dy + 6),
        Offset(p.dx, p.dy + 6 + (rulerTop + rulerH - p.dy - 6) * on),
        Paint()
          ..color = _accent.withValues(alpha: on)
          ..strokeWidth = 2,
      );
    }

    endpoint(a, startOn);
    if (grow > 0) {
      final y = rulerTop + rulerH + 8;
      final end = Offset(a.dx + (b.dx - a.dx) * grow, y);
      canvas.drawLine(Offset(a.dx, y), end, mark);
      canvas.drawLine(Offset(a.dx, y - 5), Offset(a.dx, y + 5), mark);
      if (grow >= 1) canvas.drawLine(Offset(b.dx, y - 5), Offset(b.dx, y + 5), mark);
    }
    endpoint(b, endOn);
  }

  @override
  bool shouldRepaint(covariant _HandSpanPainter oldDelegate) => oldDelegate.t != t;
}
