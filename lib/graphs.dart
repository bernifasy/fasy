import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'db.dart';
import 'models.dart';
import 'l10n.dart';
import 'widget_bridge.dart';

/// Farbpalette für Linien/Balken im Verlauf.
const graphPalette = <int>[
  0xFFEF5350, 0xFF1E88E5, 0xFFFB8C00, 0xFF43A047, 0xFF7E57C2,
  0xFFEC407A, 0xFF00897B, 0xFF5C6BC0, 0xFFAB47BC, 0xFFAB47BC,
];

class GraphSource {
  final String key;
  final String label;
  final int group;
  const GraphSource(
      {required this.key, required this.label, required this.group});
}

List<GraphSource> availableGraphSources(List<FieldDef> defs) => [
      const GraphSource(
          key: 'wohlbefinden', label: 'Wohlbefinden', group: 1),
      const GraphSource(key: 'schlaf', label: 'Schlaf (h)', group: 1),
      const GraphSource(key: 'elvanse', label: 'Elvanse (mg)', group: 1),
      const GraphSource(key: 'innere_unruhe', label: 'Innere Unruhe', group: 1),
      const GraphSource(key: 'medikinet', label: 'Medikinet (mg)', group: 1),
      const GraphSource(
          key: 'intensitaet', label: 'Migräne-Intensität', group: 2),
      for (final d in defs)
        for (final inp in d.inputs)
          if (inp.numeric)
            GraphSource(
                key: '${d.id}::${inp.subkey}',
                label: d.inputs.length == 1
                    ? d.label
                    : '${d.label} ${inp.label}',
                group: d.group),
    ];

double? entryValueFor(
    PhaskaEntry e, String key, Map<String, FieldDef> defsById) {
  switch (key) {
    case 'wohlbefinden':
      return e.wohlbefinden?.toDouble();
    case 'schlaf':
      return e.schlafStunden;
    case 'elvanse':
      return e.elvanseMg?.toDouble();
    case 'innere_unruhe':
      return e.innereUnruhe;
    case 'medikinet':
      return e.medikinetMg?.toDouble();
    case 'intensitaet':
      return e.migraeneIntensitaet?.toDouble();
  }
  final parts = key.split('::');
  if (parts.length == 2) {
    final d = defsById[parts[0]];
    if (d == null) return null;
    for (final inp in d.inputs) {
      if (inp.subkey == parts[1]) {
        final v = customSubValue(e, d, inp);
        if (v is num) return v.toDouble();
      }
    }
  }
  return null;
}

// ---------------- Painter ----------------

/// Zeichnet die Serien normalisiert (0–100 % des jeweiligen Skalenmaximums).
/// series enthält bereits normalisierte Werte (0..1); maxValues ist das
/// Skalenmaximum je Serie (für Achsenbeschriftung).
class ChartPainter extends CustomPainter {
  final List<String> xLabels;
  final List<List<double?>> series;
  final List<double> maxValues;
  final List<Color> colors;
  final String type; // line | bar | points
  final TextStyle labelStyle;
  final Color gridColor;

  ChartPainter({
    required this.xLabels,
    required this.series,
    required this.maxValues,
    required this.colors,
    required this.type,
    required this.labelStyle,
    required this.gridColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const leftPad = 40.0, rightPad = 10.0, topPad = 12.0, bottomPad = 26.0;
    final w = size.width - leftPad - rightPad;
    final h = size.height - topPad - bottomPad;
    if (w <= 0 || h <= 0 || xLabels.isEmpty || maxValues.isEmpty) return;

    // Haben alle Serien dieselbe Skala? Dann Achse in echten Werten,
    // sonst 0–100 % + farbcodierte Maxima rechts oben.
    final single = maxValues.every((m) => (m - maxValues[0]).abs() < 1e-9);

    double px(int i) => xLabels.length == 1
        ? leftPad + w / 2
        : leftPad + w * i / (xLabels.length - 1);
    double py(double v) => topPad + h * (1 - v.clamp(0.0, 1.0));

    final tp = TextPainter(textDirection: TextDirection.ltr);
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;

    // Y-Achse: 5 Linien + Beschriftung
    for (var k = 0; k <= 4; k++) {
      final frac = k / 4;
      final y = topPad + h * (1 - frac);
      canvas.drawLine(
          Offset(leftPad, y),
          Offset(size.width - rightPad, y),
          k == 0
              ? (Paint()
                ..color = labelStyle.color ?? const Color(0xFF888888)
                ..strokeWidth = 1.2)
              : gridPaint);
      tp.text = TextSpan(
          text: single
              ? fmtDe(maxValues[0] * frac)
              : '${(frac * 100).round()} %',
          style: labelStyle);
      tp.layout();
      tp.paint(canvas, Offset(leftPad - tp.width - 5, y - 6));
    }

    // Rechts oben: reale Maxima je Serie in Serienfarbe (nur bei Mischskalen)
    if (!single) {
      var ry = topPad;
      final seen = <double>{};
      for (var s = 0; s < series.length; s++) {
        if (!seen.add(maxValues[s])) continue;
        tp.text = TextSpan(
            text: '❯ ${fmtDe(maxValues[s])}',
            style: labelStyle.copyWith(color: colors[s]));
        tp.layout();
        tp.paint(canvas, Offset(size.width - tp.width - rightPad, ry));
        ry += tp.height + 2;
      }
    }

    // X-Achse: Datum in maximal ~6 Abständen
    final step = math.max(1, (xLabels.length / 6).ceil());
    for (var i = 0; i < xLabels.length; i += step) {
      tp.text = TextSpan(text: xLabels[i], style: labelStyle);
      tp.layout();
      final x =
          (px(i) - tp.width / 2).clamp(0.0, size.width - tp.width);
      tp.paint(canvas, Offset(x, size.height - bottomPad + 8));
    }

    // Serien
    final n = series.length;
    for (var s = 0; s < n; s++) {
      final paint = Paint()
        ..color = colors[s]
        ..strokeWidth = 2.4
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      final dotPaint = Paint()..color = colors[s];

      if (type == 'bar') {
        final colW = xLabels.length > 1 ? w / (xLabels.length - 1) : w;
        final barW = math.min(8.0, math.max(2.5, colW * .2));
        for (var i = 0; i < xLabels.length; i++) {
          final v = series[s][i];
          if (v == null) continue;
          final cx = px(i) + (s - (n - 1) / 2) * (barW + 2);
          canvas.drawRRect(
              RRect.fromRectAndRadius(
                  Rect.fromLTRB(
                      cx - barW / 2, py(v), cx + barW / 2, topPad + h),
                  const Radius.circular(2)),
              dotPaint);
        }
        continue;
      }

      // Linie: nur vorhandene Tage verbinden (Lücken werden übersprungen)
      final pts = <Offset>[];
      for (var i = 0; i < xLabels.length; i++) {
        final v = series[s][i];
        if (v != null) pts.add(Offset(px(i), py(v)));
      }
      if (type == 'line' && pts.length > 1) {
        final path = Path()..moveTo(pts[0].dx, pts[0].dy);
        for (var i = 1; i < pts.length; i++) {
          path.lineTo(pts[i].dx, pts[i].dy);
        }
        canvas.drawPath(path, paint);
      }
      for (final p in pts) {
        canvas.drawCircle(p, type == 'points' ? 3.5 : 2.6, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(ChartPainter old) => true;
}

// ---------------- Karte ----------------

const _typeLabels = {'line': 'Linien', 'bar': 'Balken', 'points': 'Punkte'};

class _GraphCard extends StatelessWidget {
  final GraphDef graph;
  final List<PhaskaEntry> entries;
  final List<FieldDef> defs;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSetWidget;

  const _GraphCard({
    required this.graph,
    required this.entries,
    required this.defs,
    required this.onEdit,
    required this.onDelete,
    required this.onSetWidget,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defsById = {for (final d in defs) d.id: d};
    final days = graph.rangeDays;
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
      for (var s = 0; s < graph.series.length; s++)
        List<double>.filled(days, 0)
    ];
    final counts = [
      for (var s = 0; s < graph.series.length; s++) List<int>.filled(days, 0)
    ];
    for (final e in entries) {
      final day =
          DateTime(e.createdAt.year, e.createdAt.month, e.createdAt.day);
      final idx = day.difference(today).inDays + (days - 1);
      if (idx < 0 || idx >= days) continue;
      for (var s = 0; s < graph.series.length; s++) {
        final v = entryValueFor(e, graph.series[s].key, defsById);
        if (v != null) {
          sums[s][idx] += v;
          counts[s][idx]++;
        }
      }
    }
    // Skalenmaximum je Serie + Normalisierung auf 0–100 %
    final maxVals = [for (final s in graph.series) keyMax(s.key, defsById)];
    final values = [
      for (var s = 0; s < graph.series.length; s++)
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
    final mixed = maxVals.any((m) => (m - maxVals[0]).abs() > 1e-9);
    final hasData = values.any((s) => s.any((v) => v != null));

    return Card(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 4, 12),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(graph.title,
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    Text(
                        'Letzte ${graph.rangeDays} Tage · '
                        '${_typeLabels[graph.type] ?? 'Linien'}'
                        '${mixed ? ' · Skala 0–100 % je Wert' : ''}',
                        style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant)),
                  ]),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 20),
              onSelected: (v) {
                if (v == 'edit') onEdit();
                if (v == 'delete') onDelete();
                if (v == 'widget') onSetWidget();
              },
              itemBuilder: (ctx) => const [
                PopupMenuItem(value: 'edit', child: Text('Bearbeiten')),
                PopupMenuItem(
                    value: 'widget', child: Text('Im Widget anzeigen')),
                PopupMenuItem(value: 'delete', child: Text('Löschen')),
              ],
            ),
          ]),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: hasData
                ? SizedBox(
                    height: 200,
                    width: double.infinity,
                    child: CustomPaint(
                      painter: ChartPainter(
                        xLabels: xLabels,
                        series: values,
                        maxValues: maxVals,
                        colors: [for (final s in graph.series) Color(s.color)],
                        type: graph.type,
                        labelStyle: TextStyle(
                            fontSize: 10,
                            color: theme.colorScheme.onSurfaceVariant),
                        gridColor: theme.colorScheme.outlineVariant
                            .withValues(alpha: .5),
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(vertical: 36),
                    child: Center(
                      child: Text('Noch keine Daten im Zeitraum.',
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant)),
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8, top: 6),
            child: Wrap(spacing: 14, runSpacing: 4, children: [
              for (final (i, s) in graph.series.indexed)
                Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                          color: Color(s.color), shape: BoxShape.circle)),
                  const SizedBox(width: 5),
                  Text(
                      mixed
                          ? '${s.label} (0–${fmtDe(maxVals[i])})'
                          : s.label,
                      style: theme.textTheme.labelSmall),
                ]),
            ]),
          ),
        ]),
      ),
    );
  }
}

// ---------------- Screen ----------------

class GraphsScreen extends StatefulWidget {
  const GraphsScreen({super.key});

  @override
  State<GraphsScreen> createState() => _GraphsScreenState();
}

class _GraphsScreenState extends State<GraphsScreen> {
  List<PhaskaEntry> _entries = const [];
  List<FieldDef> _defs = const [];
  List<GraphDef>? _graphs;
  int _migraeneDays30 = 0;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    Repo.changes.addListener(_load);
    _load();
  }

  @override
  void dispose() {
    Repo.changes.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    if (_loading) return;
    _loading = true;
    try {
      final e = await PhaskaDb.instance.all();
      final d = await PhaskaDb.instance.fieldDefs();
      var g = await PhaskaDb.instance.graphDefs();
      if (g.isEmpty && !await PhaskaDb.instance.graphsSeeded()) {
        await _seedDefaults();
        g = await PhaskaDb.instance.graphDefs();
      }
      final cutoff = DateTime.now().subtract(const Duration(days: 30));
      final days = <String>{};
      for (final en in e) {
        if (en.createdAt.isAfter(cutoff) && en.migraeneTag == 'ja') {
          days.add(
              '${en.createdAt.year}-${en.createdAt.month}-${en.createdAt.day}');
        }
      }
      if (mounted) {
        setState(() {
          _entries = e;
          _defs = d;
          _graphs = g;
          _migraeneDays30 = days.length;
        });
      }
    } finally {
      _loading = false;
    }
  }

  Future<void> _seedDefaults() async {
    GraphSource? konzentr;
    for (final s in availableGraphSources(_defs)) {
      if (s.label.toLowerCase().contains('konzentr')) { konzentr = s; break; }
    }
    final ms = DateTime.now().millisecondsSinceEpoch;
    final seeds = [
      GraphDef(
        id: 'g_${ms}_1',
        title: 'Wohlbefinden & Medikation',
        rangeDays: 30,
        position: 0,
        series: [
          GraphSeries(
              key: 'wohlbefinden',
              label: 'Wohlbefinden',
              color: kDefaultGroup1Color),
          GraphSeries(
              key: 'elvanse', label: 'Elvanse (mg)', color: 0xFFFB8C00),
          GraphSeries(
              key: 'medikinet',
              label: 'Medikinet (mg)',
              color: 0xFF1E88E5),
        ],
      ),
      GraphDef(
        id: 'g_${ms}_2',
        title:
            'Innere Unruhe${konzentr != null ? ' & ${konzentr.label}' : ''}',
        rangeDays: 30,
        position: 1,
        series: [
          GraphSeries(
              key: 'innere_unruhe',
              label: 'Innere Unruhe',
              color: 0xFFEF5350),
          if (konzentr != null)
            GraphSeries(
                key: konzentr.key,
                label: konzentr.label,
                color: 0xFF5C6BC0),
        ],
      ),
    ];
    for (final g in seeds) {
      await PhaskaDb.instance.saveGraphDef(g, notify: false);
    }
    await PhaskaDb.instance.markGraphsSeeded();
  }

  Future<void> _setAsWidget(GraphDef g) async {
    await setGraphWidgetId(g.id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Dieser Graph wird im Homescreen-Widget angezeigt.')));
    }
  }

  Future<void> _graphDialog({GraphDef? existing}) async {
    final sources = availableGraphSources(_defs);
    final titleC = TextEditingController(text: existing?.title ?? '');
    var type = existing?.type ?? 'line';
    var rangeDays = existing?.rangeDays ?? 30;
    final series = [
      for (final s in (existing?.series ?? const <GraphSeries>[]))
        GraphSeries(key: s.key, label: s.label, color: s.color),
    ];

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          title: Text(
              existing == null ? 'Neuer Graph' : '„${existing.title}" bearbeiten'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleC,
                      decoration: const InputDecoration(
                          labelText: 'Titel',
                          hintText: 'z. B. Schlaf & Unruhe'),
                    ),
                    const SizedBox(height: 16),
                    Text('Diagrammart',
                        style: Theme.of(ctx).textTheme.labelLarge),
                    const SizedBox(height: 6),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'line', label: Text('Linien')),
                        ButtonSegment(value: 'bar', label: Text('Balken')),
                        ButtonSegment(value: 'points', label: Text('Punkte')),
                      ],
                      selected: {type},
                      onSelectionChanged: (s) => setD(() => type = s.first),
                    ),
                    const SizedBox(height: 16),
                    Text('Zeitraum',
                        style: Theme.of(ctx).textTheme.labelLarge),
                    const SizedBox(height: 6),
                    Wrap(spacing: 8, children: [
                      for (final d in [7, 14, 30, 60, 90, 180, 365])
                        ChoiceChip(
                          label: Text('$d Tage'),
                          selected: rangeDays == d,
                          onSelected: (_) => setD(() => rangeDays = d),
                        ),
                    ]),
                    const SizedBox(height: 16),
                    Text('Werte', style: Theme.of(ctx).textTheme.labelLarge),
                    const SizedBox(height: 6),
                    Wrap(spacing: 8, runSpacing: 8, children: [
                      for (final s in sources)
                        FilterChip(
                          label: Text(s.label),
                          selected: series.any((x) => x.key == s.key),
                          onSelected: (sel) => setD(() {
                            final idx =
                                series.indexWhere((x) => x.key == s.key);
                            if (sel && idx < 0) {
                              series.add(GraphSeries(
                                  key: s.key,
                                  label: s.label,
                                  color: graphPalette[
                                      series.length % graphPalette.length]));
                            } else if (!sel && idx >= 0) {
                              series.removeAt(idx);
                            }
                          }),
                        ),
                    ]),
                    for (final s in series) ...[
                      const SizedBox(height: 10),
                      Row(children: [
                        Expanded(
                            child: Text(s.label,
                                style: Theme.of(ctx).textTheme.bodySmall)),
                      ]),
                      Wrap(spacing: 6, runSpacing: 6, children: [
                        for (final c in graphPalette.take(9))
                          GestureDetector(
                            onTap: () => setD(() => s.color = c),
                            child: CircleAvatar(
                              radius: 11,
                              backgroundColor: Color(c),
                              child: s.color == c
                                  ? const Icon(Icons.check,
                                      size: 12, color: Colors.white)
                                  : null,
                            ),
                          ),
                      ]),
                    ],
                  ]),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Abbrechen')),
            FilledButton(
                onPressed: (titleC.text.trim().isEmpty || series.isEmpty)
                    ? null
                    : () => Navigator.pop(ctx, true),
                child: const Text('Speichern')),
          ],
        ),
      ),
    );
    if (saved != true) return;

    final def = GraphDef(
      id: existing?.id ?? 'g_${DateTime.now().millisecondsSinceEpoch}',
      title: titleC.text.trim(),
      type: type,
      rangeDays: rangeDays,
      series: series,
      position: existing?.position ?? (_graphs?.length ?? 0),
    );
    await PhaskaDb.instance.saveGraphDef(def, notify: false);
    await _load();
  }

  Future<void> _deleteGraph(GraphDef g) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('„${g.title}" löschen?'),
        content: const Text(
            'Der Graph wird entfernt. Deine Erfassungen bleiben unberührt.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Abbrechen')),
          FilledButton(
              style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(ctx).colorScheme.error,
                  foregroundColor: Theme.of(ctx).colorScheme.onError),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Löschen')),
        ],
      ),
    );
    if (ok == true) await PhaskaDb.instance.deleteGraphDef(g.id);
  }

  Future<void> _onReorder(int oldIndex, int newIndex) async {
    final graphs = List<GraphDef>.from(_graphs!);
    graphs.insert(newIndex, graphs.removeAt(oldIndex));
    setState(() => _graphs = graphs);
    for (var i = 0; i < graphs.length; i++) {
      graphs[i].position = i;
      await PhaskaDb.instance.saveGraphDef(graphs[i], notify: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final graphs = _graphs;
    return Scaffold(
      body: SafeArea(
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
            child: Text(S.t('screen_graphs'),
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
          ),
          if (graphs != null && graphs.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text(
                  'Lange auf einen Graphen drücken, um ihn zu verschieben.',
                  style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant)),
            ),
          Expanded(
            child: graphs == null
                ? const Center(child: CircularProgressIndicator())
                : graphs.isEmpty
                    ? Center(
                        child: Text(
                            'Noch keine Graphen.\nTippe unten auf „Neuer Graph".',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant)))
                    : SingleChildScrollView(
                        padding: const EdgeInsets.only(top: 4, bottom: 120),
                        child: Column(children: [
                          ReorderableListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: graphs.length,
                            onReorderItem: _onReorder,
                            itemBuilder: (context, i) {
                              final g = graphs[i];
                              return Container(
                                key: ValueKey(g.id),
                                child: _GraphCard(
                                  graph: g,
                                  entries: _entries,
                                  defs: _defs,
                                  onEdit: () => _graphDialog(existing: g),
                                  onDelete: () => _deleteGraph(g),
                                  onSetWidget: () => _setAsWidget(g),
                                ),
                              );
                            },
                          ),
                          // Migränetage-Counter (letzte 30 Tage)
                          Card(
                            margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              child: Row(children: [
                                CircleAvatar(
                                  backgroundColor: groupColor(2),
                                  child: const Icon(
                                      Icons.monitor_heart_outlined,
                                      color: Colors.white),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Migränetage',
                                            style: theme.textTheme.titleSmall
                                                ?.copyWith(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                        Text('letzte 30 Tage',
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                                    color: theme.colorScheme
                                                        .onSurfaceVariant)),
                                      ]),
                                ),
                                Text('$_migraeneDays30',
                                    style: theme.textTheme.headlineMedium
                                        ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: groupColor(2))),
                              ]),
                            ),
                          ),
                        ]),
                      ),
          ),
        ]),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'graphs_add',
        onPressed: () => _graphDialog(),
        icon: const Icon(Icons.add_chart),
        label: const Text('Neuer Graph'),
      ),
    );
  }
}