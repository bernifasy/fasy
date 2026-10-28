import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';

import 'db.dart';
import 'graphs.dart';
import 'models.dart';

/// Deep-Links aus den Button-Widgets: 'fasy://g1', 'fasy://g2', 'fasy://quick'
Future<void> initWidgetLinks(ValueChanged<Uri?> onLink) async {
  HomeWidget.widgetClicked.listen(onLink);
  try {
    onLink(await HomeWidget.initiallyLaunchedFromHomeWidget());
  } catch (_) {}
}

/// Nach jeder Datenänderung aufrufen (Listener auf Repo.changes).
Future<void> updateHomeWidgets() async {
  try { await updateStatusWidget(); } catch (_) {}
  try { await updateButtonWidgets(); } catch (_) {} // NEU (Punkt 6)
  try { await updateGraphWidget(); } catch (_) {}
  try { await updateCalendarWidget(); } catch (_) {}
}

// ---------------- Widget 1: Status-Kreis (1x1) ----------------

/// 0 = keine Erfassung heute · 1 = Erfassung · 3 = Migränetag
Future<int> todayMask() async {
  final entries = await PhaskaDb.instance.all();
  final defs = await PhaskaDb.instance.fieldDefs();
  final now = DateTime.now();
  var mask = 0;
  for (final e in entries) {
    if (e.createdAt.year != now.year ||
        e.createdAt.month != now.month ||
        e.createdAt.day != now.day) {
      continue;
    }
    var g1 = e.hasG1;
    for (final d in defs) {
      final v = e.custom[d.id];
      if (v != null && (v is! String || v.isNotEmpty) && d.group == 1) {
        g1 = true;
      }
    }
    if (g1 || e.hasG2) mask |= 1;
    if (e.migraeneTag == 'ja') mask = 3;
  }
  return mask;
}

class _StatusCircle extends StatelessWidget {
  final int mask;
  const _StatusCircle({required this.mask});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(120, 120),
      painter: _CirclePainter(mask, groupColor(1), groupColor(2)),
    );
  }
}

class _CirclePainter extends CustomPainter {
  final int mask;
  final Color g1, g2;
  _CirclePainter(this.mask, this.g1, this.g2);

  @override
  void paint(Canvas canvas, Size size) {
    final r = (Offset.zero & size).deflate(10);
    if (mask == 3) {
      canvas.drawArc(r, -math.pi / 2, math.pi, true, Paint()..color = g1);
      canvas.drawArc(r, math.pi / 2, math.pi, true, Paint()..color = g2);
    } else if (mask == 1) {
      canvas.drawOval(r, Paint()..color = g1);
    }
    canvas.drawOval(
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5
          ..color = mask == 0 ? const Color(0x669E9E9E) : g1);
    final tp = TextPainter(
        text: TextSpan(
            text: 'f',
            style: TextStyle(
                fontSize: 52,
                fontWeight: FontWeight.w800,
                color: mask == 0 ? const Color(0x669E9E9E) : Colors.white)),
        textDirection: TextDirection.ltr)
      ..layout();
    tp.paint(
        canvas,
        Offset(size.width / 2 - tp.width / 2,
            size.height / 2 - tp.height / 2));
  }

  @override
  bool shouldRepaint(_CirclePainter old) => old.mask != mask;
}

Future<void> updateStatusWidget() async {
  final mask = await todayMask();
  final path = await HomeWidget.renderFlutterWidget(
      _StatusCircle(mask: mask),
      key: 'fasy_status',
      logicalSize: const Size(120, 120),
      pixelRatio: 2);
  await HomeWidget.saveWidgetData<String>('status_image', path);
  await HomeWidget.updateWidget(androidName: 'FasyStatusWidget');
}

// ---------------- Widget 4: Graph ----------------

Future<void> setGraphWidgetId(String id) async {
  await HomeWidget.saveWidgetData<String>('graph_widget_id', id);
  await updateGraphWidget();
}

Widget _plainText(String s,
        {double size = 16,
        Color color = const Color(0xFF222222),
        FontWeight weight = FontWeight.normal}) =>
    Text(s,
        textDirection: TextDirection.ltr,
        style: TextStyle(fontSize: size, color: color, fontWeight: weight));

Future<void> updateGraphWidget() async {
  final graphs = await PhaskaDb.instance.graphDefs();
  if (graphs.isEmpty) return;
  final chosenId =
      await HomeWidget.getWidgetData<String>('graph_widget_id');
  final g = graphs.where((x) => x.id == chosenId).firstOrNull ?? graphs.first;

  final entries = await PhaskaDb.instance.all();
  final defs = await PhaskaDb.instance.fieldDefs();
  final defsById = {for (final d in defs) d.id: d};

  final days = g.rangeDays;
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final xLabels = [
    for (var i = 0; i < days; i++)
      () {
        final d = today.subtract(Duration(days: days - 1 - i));
        return '${d.day}.${d.month}.';
      }(),
  ];
  final sums = [
    for (var s = 0; s < g.series.length; s++) List<double>.filled(days, 0)
  ];
  final counts = [
    for (var s = 0; s < g.series.length; s++) List<int>.filled(days, 0)
  ];
  for (final e in entries) {
    final day =
        DateTime(e.createdAt.year, e.createdAt.month, e.createdAt.day);
    final idx = day.difference(today).inDays + (days - 1);
    if (idx < 0 || idx >= days) continue;
    for (var s = 0; s < g.series.length; s++) {
      final v = entryValueFor(e, g.series[s].key, defsById);
      if (v != null) {
        sums[s][idx] += v;
        counts[s][idx]++;
      }
    }
  }
  final maxVals = [for (final s in g.series) keyMax(s.key, defsById)];
  final values = [
    for (var s = 0; s < g.series.length; s++)
      [
        for (var i = 0; i < days; i++)
          counts[s][i] > 0
              ? () {
                  final nv = sums[s][i] / counts[s][i] / maxVals[s];
                  return nv < 0 ? 0.0 : (nv > 1 ? 1.0 : nv);
                }()
              : null
      ]
  ];

  final widget2 = Container(
    width: 620,
    height: 340,
    padding: const EdgeInsets.all(14),
    color: const Color(0xFFF6F6F1),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _plainText(g.title, size: 20, weight: FontWeight.bold),
      const SizedBox(height: 4),
      Expanded(
        child: CustomPaint(
          size: const Size(592, 272),
          painter: ChartPainter(
            xLabels: xLabels,
            series: values,
            maxValues: maxVals,
            colors: [for (final s in g.series) Color(s.color)],
            type: g.type,
            labelStyle:
                const TextStyle(fontSize: 12, color: Color(0xFF666666)),
            gridColor: const Color(0x33666666),
          ),
        ),
      ),
    ]),
  );

  final path = await HomeWidget.renderFlutterWidget(widget2,
      key: 'fasy_graph',
      logicalSize: const Size(620, 340),
      pixelRatio: 2);
  await HomeWidget.saveWidgetData<String>('graph_image', path);
  await HomeWidget.updateWidget(androidName: 'FasyGraphWidget');
}

// ---------------- Widget 5: Kalender ----------------

const _monthNamesDe = [
  'Januar', 'Februar', 'März', 'April', 'Mai', 'Juni', 'Juli',
  'August', 'September', 'Oktober', 'November', 'Dezember',
];

class _MonthPainter extends CustomPainter {
  final int year, month;
  final Map<int, int> mask;
  final Color g1, g2, fg;
  _MonthPainter(this.year, this.month, this.mask, this.g1, this.g2, this.fg);

  @override
  void paint(Canvas canvas, Size size) {
    final first = DateTime(year, month, 1);
    final offset = first.weekday - 1;
    final days = DateTime(year, month + 1, 0).day;
    final rows = ((offset + days) / 7).ceil();
    final cellW = size.width / 7;
    final cellH = size.height / (rows + 1);
    final tp = TextPainter(textDirection: TextDirection.ltr);

    void text(String s, Offset c,
        {Color color = const Color(0xFF666666),
        double size = 16,
        FontWeight w = FontWeight.normal}) {
      tp.text = TextSpan(
          text: s,
          style: TextStyle(color: color, fontSize: size, fontWeight: w));
      tp.layout();
      tp.paint(canvas, c - Offset(tp.width / 2, tp.height / 2));
    }

    for (var c = 0; c < 7; c++) {
      text(['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'][c],
          Offset((c + .5) * cellW, cellH / 2),
          size: 14, w: FontWeight.w600);
    }
    for (var d = 1; d <= days; d++) {
      final idx = offset + d - 1;
      final c = Offset((idx % 7 + .5) * cellW, ((idx ~/ 7) + 1.5) * cellH);
      final r = math.min(cellW, cellH) * .34;
      final m = mask[d] ?? 0;
      if (m == 3) {
        final rr = Rect.fromCircle(center: c, radius: r);
        canvas.drawArc(rr, -math.pi / 2, math.pi, true, Paint()..color = g1);
        canvas.drawArc(rr, math.pi / 2, math.pi, true, Paint()..color = g2);
      } else if (m != 0) {
        canvas.drawCircle(c, r, Paint()..color = m == 1 ? g1 : g2);
      }
      text('$d', c,
          color: m != 0 ? Colors.white : fg, size: 15);
    }
  }

  @override
  bool shouldRepaint(_MonthPainter old) => true;
}

Future<void> updateCalendarWidget() async {
  final entries = await PhaskaDb.instance.all();
  final defs = await PhaskaDb.instance.fieldDefs();
  final now = DateTime.now();
  final mask = <int, int>{};
  for (final e in entries) {
    if (e.createdAt.year != now.year || e.createdAt.month != now.month) {
      continue;
    }
    var m2 = 0;
    var g1 = e.hasG1;
    for (final d in defs) {
      final v = e.custom[d.id];
      if (v != null && (v is! String || v.isNotEmpty) && d.group == 1) {
        g1 = true;
      }
    }
    if (g1) m2 |= 1;
    if (e.migraeneTag == 'ja') m2 |= 2;
    if (m2 > 0) mask[e.createdAt.day] = (mask[e.createdAt.day] ?? 0) | m2;
  }

  final widget2 = Container(
    width: 620,
    height: 400,
    padding: const EdgeInsets.all(14),
    color: const Color(0xFFF6F6F1),
    child: Column(children: [
      _plainText('${_monthNamesDe[now.month - 1]} ${now.year}',
          size: 20, weight: FontWeight.bold),
      const SizedBox(height: 6),
      Expanded(
        child: CustomPaint(
          size: const Size(592, 340),
          painter: _MonthPainter(now.year, now.month, mask, groupColor(1),
              groupColor(2), const Color(0xFF444444)),
        ),
      ),
    ]),
  );

  final path = await HomeWidget.renderFlutterWidget(widget2,
      key: 'fasy_calendar',
      logicalSize: const Size(620, 400),
      pixelRatio: 2);
  await HomeWidget.saveWidgetData<String>('calendar_image', path);
  await HomeWidget.updateWidget(androidName: 'FasyCalendarWidget');
}

// ---------------- Widgets 2–4: Die drei Homescreen-Buttons (Punkt 6) ----------------

/// Rendert die drei Buttons haargenau wie in der App (Farbe, Icon, Text,
/// abgerundete Ecken) als Bilder. Die nativen Widgets zeigen sie als
/// ImageView an – dadurch sind sie nie wieder „unsichtbar".
Future<void> updateButtonWidgets() async {
  final specs = <(String, Color, String, String, String)>[
    ('g1', groupColor(1), 'sun', 'Tag erfassen',
        'Wohlbefinden, Schlaf, Medikation'),
    ('g2', groupColor(2), 'bolt', 'Migräne erfassen',
        'Intensität, Zeiten, Auslöser'),
    ('quick', AppColors.quick.value, 'gauge', 'Einzelwert erfassen',
        'Schnellmessung ohne Tageserfassung'),
  ];
  for (final (id, color, kind, title, sub) in specs) {
    final path = await HomeWidget.renderFlutterWidget(
      _WidgetButton(color: color, kind: kind, title: title, subtitle: sub),
      key: 'fasy_btn_$id',
      logicalSize: const Size(620, 190),
      pixelRatio: 2,
    );
    await HomeWidget.saveWidgetData<String>('btn_${id}_image', path);
  }
  // ⚠️ Die androidName-Strings müssen zu deinen Receivern in
  // android/app/src/main/AndroidManifest.xml passen – ggf. anpassen.
  await HomeWidget.updateWidget(androidName: 'FasyButtonG1Widget');
  await HomeWidget.updateWidget(androidName: 'FasyButtonG2Widget');
  await HomeWidget.updateWidget(androidName: 'FasyButtonQuickWidget');
}

class _WidgetButton extends StatelessWidget {
  final Color color;
  final String kind; // sun | bolt | gauge
  final String title;
  final String subtitle;
  const _WidgetButton(
      {required this.color,
      required this.kind,
      required this.title,
      required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 620,
      height: 190,
      padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 28),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .22),
        borderRadius: BorderRadius.circular(46),
      ),
      child: Row(children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: CustomPaint(painter: _MiniIcon(kind, Colors.white)),
        ),
        const SizedBox(width: 30),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title,
                textDirection: TextDirection.ltr,
                style: const TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B1B1B))),
            const SizedBox(height: 6),
            Text(subtitle,
                textDirection: TextDirection.ltr,
                style: const TextStyle(
                    fontSize: 24, color: Color(0xFF5A5A5A))),
          ],
        ),
      ]),
    );
  }
}

/// Icons als Vektor-Painter (sicherer als Fonts beim Offscreen-Rendern).
class _MiniIcon extends CustomPainter {
  final String kind;
  final Color color;
  const _MiniIcon(this.kind, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * .085
      ..strokeCap = StrokeCap.round;
    final fill = Paint()..color = color;
    switch (kind) {
      case 'sun':
        for (var i = 0; i < 8; i++) {
          final a = i * math.pi / 4;
          canvas.drawLine(
              c + Offset(math.cos(a), math.sin(a)) * size.width * .30,
              c + Offset(math.cos(a), math.sin(a)) * size.width * .44,
              stroke);
        }
        canvas.drawCircle(c, size.width * .21, stroke);
        break;
      case 'bolt':
        final p = Path()
          ..moveTo(size.width * .58, size.height * .10)
          ..lineTo(size.width * .30, size.height * .58)
          ..lineTo(size.width * .48, size.height * .58)
          ..lineTo(size.width * .40, size.height * .92)
          ..lineTo(size.width * .72, size.height * .42)
          ..lineTo(size.width * .54, size.height * .42)
          ..close();
        canvas.drawPath(p, fill);
        break;
      default: // gauge
        canvas.drawArc(Rect.fromCircle(center: c, radius: size.width * .34),
            math.pi * .75, math.pi * 1.5, false, stroke);
        canvas.drawLine(
            c,
            c + Offset(math.cos(-.6), math.sin(-.6)) * size.width * .26,
            stroke);
        canvas.drawCircle(c, size.width * .055, fill);
    }
  }

  @override
  bool shouldRepaint(_MiniIcon old) =>
      old.kind != kind || old.color != color;
}