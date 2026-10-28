import 'package:flutter/material.dart';

/// Verfügbare Pflanzenthemen für Erfassungs-Slides und den Homescreen.
const plantThemes = <String, String>{
  'none': 'Keine',
  'urwald': 'Urwald',
  'euphorbia': 'Euphorbia trigona',
  'lavendel': 'Lavendel',
  'thymian': 'Thymian',
  'forellen': 'Forellenbegonie',
};

/// Minimalistische, automatisch eingefärbte Pflanzen-Illustrationen.
class PlantPainter extends CustomPainter {
  final String theme;
  final Color color;
  const PlantPainter({required this.theme, required this.color});

  void _leaf(Canvas canvas, Offset c, double angle, double len, double w,
      Paint paint) {
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(angle);
    final path = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(len * .5, -w, len, 0)
      ..quadraticBezierTo(len * .5, w, 0, 0);
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  Paint _stem(double width) => Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..strokeCap = StrokeCap.round;

  @override
  void paint(Canvas canvas, Size size) {
    switch (theme) {
      case 'euphorbia':
        _euphorbia(canvas, size);
        break;
      case 'lavendel':
        _lavender(canvas, size);
        break;
      case 'thymian':
        _thyme(canvas, size);
        break;
      case 'forellen':
        _begonia(canvas, size);
        break;
      default:
        _jungle(canvas, size);
    }
  }

  /// Urwald: zwei geschwungene Zweige mit Blättern (bisheriges Design).
  void _jungle(Canvas canvas, Size size) {
    final stem = _stem(3);
    final leaf = Paint()..color = color;
    canvas.drawPath(
        Path()
          ..moveTo(size.width * .2, size.height)
          ..quadraticBezierTo(size.width * .05, size.height * .45,
              size.width * .45, size.height * .05),
        stem);
    canvas.drawPath(
        Path()
          ..moveTo(size.width * .2, size.height * .9)
          ..quadraticBezierTo(size.width * .55, size.height * .6,
              size.width * .7, size.height * .35),
        stem);
    _leaf(canvas, Offset(size.width * .16, size.height * .72), -.9, 34, 14, leaf);
    _leaf(canvas, Offset(size.width * .12, size.height * .50), -.5, 30, 13, leaf);
    _leaf(canvas, Offset(size.width * .28, size.height * .28), -1.9, 30, 13, leaf);
    _leaf(canvas, Offset(size.width * .42, size.height * .13), -2.4, 26, 12, leaf);
    _leaf(canvas, Offset(size.width * .40, size.height * .75), .6, 30, 13, leaf);
    _leaf(canvas, Offset(size.width * .58, size.height * .52), .2, 28, 12, leaf);
    _leaf(canvas, Offset(size.width * .68, size.height * .38), -.4, 24, 11, leaf);
  }

  /// Euphorbia trigona: aufrechte gerippte Säulen mit kleinen Blättchen.
  void _euphorbia(Canvas canvas, Size size) {
    final stalks = <(double, double)>[(.30, 1.0), (.52, .84), (.75, .64)];
    for (final (fx, fh) in stalks) {
      final x = size.width * fx;
      final top = size.height * (1 - fh) + size.height * .05;
      final base = size.height;
      final path = Path()
        ..moveTo(x, base)
        ..quadraticBezierTo(x + 6, size.height * .55, x, top);
      canvas.drawPath(path, _stem(7));
      // dünne Seitenrippen
      canvas.drawPath(path.shift(const Offset(4.5, 0)), _stem(2));
      canvas.drawPath(path.shift(const Offset(-4.5, 0)), _stem(2));
      // kleine Blättchen entlang der Ränder
      final small = _stem(2.2);
      for (double y = base - 18; y > top + 8; y -= 26) {
        canvas.drawLine(Offset(x + 5, y), Offset(x + 14, y - 6), small);
        canvas.drawLine(Offset(x - 5, y - 9), Offset(x - 14, y - 15), small);
      }
    }
  }

  /// Lavendel: schlanke Stiele mit Ähren aus ovalen Knospen.
  void _lavender(Canvas canvas, Size size) {
    final stem = Paint()
      ..color = color.withValues(alpha: .55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final bud = Paint()..color = color;
    for (var k = 0; k < 4; k++) {
      final x = size.width * (.24 + k * .17);
      final top = size.height * (.18 + (k.isOdd ? .07 : 0));
      canvas.drawLine(Offset(x + 5, size.height), Offset(x, top + 26), stem);
      for (var i = 0; i < 5; i++) {
        canvas.save();
        canvas.translate(x + i * 1.2 - 3, top + 20 - i * 6.5);
        canvas.rotate(-.25);
        canvas.drawOval(
            Rect.fromCenter(center: Offset.zero, width: 12, height: 17), bud);
        canvas.restore();
      }
    }
  }

  /// Thymian: feine Stiele mit gepaarten Mini-Blättchen.
  void _thyme(Canvas canvas, Size size) {
    final leaf = Paint()..color = color;
    for (var k = 0; k < 3; k++) {
      final x0 = size.width * (.30 + k * .2);
      final a = Offset(x0, size.height);
      final b = Offset(x0 - 14, size.height * .55);
      final c = Offset(x0 + 4, size.height * (.16 + k * .1));
      canvas.drawPath(
          Path()
            ..moveTo(a.dx, a.dy)
            ..quadraticBezierTo(b.dx, b.dy, c.dx, c.dy),
          _stem(2.4));
      // Mini-Blättchen-Paare entlang des Stiels
      for (double t = .12; t < .95; t += .16) {
        final pos = _bezier(a, b, c, t);
        canvas.drawCircle(pos + const Offset(5, -4), 3.6, leaf);
        canvas.drawCircle(pos + const Offset(-5, -6), 3.6, leaf);
      }
    }
  }

  /// Punkt auf einer quadratischen Bézier-Kurve (0 = Start, 1 = Ende).
  Offset _bezier(Offset a, Offset b, Offset c, double t) {
    final u = 1 - t;
    return Offset(
      u * u * a.dx + 2 * u * t * b.dx + t * t * c.dx,
      u * u * a.dy + 2 * u * t * b.dy + t * t * c.dy,
    );
  }

  /// Forellenbegonie (Begonia maculata): geflügelte Blätter mit Punkten.
  void _begonia(Canvas canvas, Size size) {
    final leafPaint = Paint()..color = color;
    final spot = Paint()..color = Colors.white.withValues(alpha: .85);
    final stems = <(double, double, double)>[
      (.30, .30, -1), (.56, .14, 1), (.80, .44, -1)
    ];
    for (final (fx, fy, dir) in stems) {
      final x = size.width * fx;
      final tip = Offset(x + 14 * dir, size.height * fy);
      canvas.drawPath(
          Path()
            ..moveTo(x, size.height)
            ..quadraticBezierTo(
                x - 10 * dir, size.height * .6, tip.dx, tip.dy),
          _stem(2.6));
      canvas.save();
      canvas.translate(tip.dx, tip.dy);
      canvas.rotate(.5 * dir);
      final leaf = Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(10, -26, 30, -30)
        ..quadraticBezierTo(40, -12, 14, 10)
        ..quadraticBezierTo(4, 8, 0, 0);
      canvas.drawPath(leaf, leafPaint);
      canvas.clipPath(leaf);
      for (final p in [
        const Offset(10, -14), const Offset(18, -21), const Offset(24, -10),
        const Offset(12, -25), const Offset(20, 0), const Offset(28, -22),
      ]) {
        canvas.drawCircle(p, 2.2, spot);
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(PlantPainter old) =>
      old.color != color || old.theme != theme;
}