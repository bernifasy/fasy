import 'package:flutter/material.dart';

import '../db.dart';
import '../models.dart';

/// Feste IDs der eingebauten Datenpunkte.
const builtinMeta = <int, List<(String, String)>>{
  1: [
    ('wohlbefinden', 'Wohlbefinden'),
    ('schlaf', 'Schlaf'),
    ('elvanse', 'Elvanse'),
    ('unruhe', 'Innere Unruhe'),
    ('medikinet', 'Medikinet'),
  ],
  2: [
    ('intensitaet', 'Migräne-Intensität'),
    ('start', 'Migräne Beginn'),
    ('ende', 'Migräne Ende'),
    ('ausloeser', 'Auslöser'),
    ('symptome', 'Begleitsymptome'),
    ('notizen', 'Notizen'),
  ],
};

String builtinLabel(int group, String id) => builtinMeta[group]!
    .firstWhere((e) => e.$1 == id, orElse: () => (id, id))
    .$2;

class CaptureStep {
  final String id;
  final int group;
  final String title;
  final String? subtitle;
  final String plantTheme;
  final bool Function(PhaskaEntry) hasValue;
  final Widget Function(
          BuildContext context, PhaskaEntry entry, void Function() changed)
      build;

  /// NEU (Punkt 2): setzt den Voreinstellwert, wenn nichts angefasst wurde.
  final void Function(PhaskaEntry e)? applyDefault;

  const CaptureStep({
    required this.id,
    required this.group,
    required this.title,
    required this.hasValue,
    required this.build,
    this.subtitle,
    this.plantTheme = 'none',
    this.applyDefault,
  });
}

// ---------------- Schritt-Aufbau ----------------

Future<List<String>> orderedStepIds(int group,
    {Set<String> hidden = const {}}) async {
  final defs = await PhaskaDb.instance.fieldDefs(group: group);
  final order = await PhaskaDb.instance.stepOrder(group);
  final existing = [
    ...builtinMeta[group]!.map((e) => e.$1),
    ...defs.map((d) => d.id),
  ].where((id) => !hidden.contains(id)).toList();
  final result = <String>[
    if (order != null) ...order.where(existing.contains),
  ];
  result.addAll(existing.where((id) => !result.contains(id)));
  return result;
}

Future<List<CaptureStep>> stepsForGroup(int group) async {
  final defs = await PhaskaDb.instance.fieldDefs(group: group);
  final defsById = {for (final d in defs) d.id: d};
  final hidden = await PhaskaDb.instance.hiddenBuiltins(group);
  final deleted = await PhaskaDb.instance.deletedBuiltins(group); // Punkt 4.3
  final labels = await PhaskaDb.instance.builtinLabels(group);
  final themes = await PhaskaDb.instance.builtinThemes(group);
  final custom = {for (final d in defs) d.id: _customStep(d)};
  final base = [
    for (final id
        in await orderedStepIds(group, hidden: {...hidden, ...deleted}))
      custom[id] ??
          _builtinStep(id, label: labels[id], theme: themes[id] ?? 'none')
  ];
  // Punkt 2: Standardwerte anhängen.
  return [
    for (final s in base)
      CaptureStep(
        id: s.id,
        group: s.group,
        title: s.title,
        subtitle: s.subtitle,
        plantTheme: s.plantTheme,
        hasValue: s.hasValue,
        build: s.build,
        applyDefault: _defaultForStep(s.id, defsById[s.id]),
      )
  ];
}

/// Punkt 2: Was gilt, wenn der Nutzer nichts anfasst?
/// Slider → sichtbarer Voreinstellwert; Blöcke/Medikamente → 0.
void _applyCustomDefaults(PhaskaEntry e, FieldDef def) {
  for (final inp in def.inputs) {
    if (customSubValue(e, def, inp) != null) continue;
    switch (inp.type) {
      case 'vslider':
        setCustomSubValue(e, def, inp, 50);
        break;
      case 'hslider':
        setCustomSubValue(e, def, inp, 5.0);
        break;
      case 'blocks':
        setCustomSubValue(e, def, inp, 0);
        break;
      case 'halfblocks':
        setCustomSubValue(e, def, inp, 0.0);
        break;
    }
  }
}

void Function(PhaskaEntry e)? _defaultForStep(String id, FieldDef? def) {
  if (def != null) return (e) => _applyCustomDefaults(e, def);
  switch (id) {
    case 'wohlbefinden':
      return (e) => e.wohlbefinden ??= 50;
    case 'schlaf':
      return (e) => e.schlafStunden ??= 0.0;
    case 'elvanse':
      return (e) => e.elvanseMg ??= 0;
    case 'unruhe':
      return (e) => e.innereUnruhe ??= 5.0;
    case 'medikinet':
      return (e) => e.medikinetMg ??= 0;
    case 'intensitaet':
      return (e) => e.migraeneIntensitaet ??= 0;
  }
  return null; // Text/Zeit/Auswahl: kein sinnvoller Standard
}

Future<List<CaptureStep>> stepsForAll() async =>
    [...await stepsForGroup(1), ...await stepsForGroup(2)];

CaptureStep _builtinStep(String id, {String? label, String theme = 'none'}) {
  switch (id) {
    case 'wohlbefinden':
      return CaptureStep(
        id: id, group: 1, title: label ?? 'Wohlbefinden',
        subtitle: 'Wie geht es dir gerade? (1–100)', plantTheme: theme,
        hasValue: (e) => e.wohlbefinden != null,
        build: (context, e, changed) {
          e.wohlbefinden ??= 50;
          return VerticalSliderInput(
              value: e.wohlbefinden!,
              hint: '1 = sehr schlecht · 100 = ausgezeichnet',
              onChanged: (v) { e.wohlbefinden = v; changed(); });
        },
      );
    case 'schlaf':
      return CaptureStep(
        id: id, group: 1, title: label ?? 'Schlaf', plantTheme: theme,
        subtitle: 'Tippen = volle Stunde · Gedrückt halten = halbe Stunde · '
            'Drüberstreichen = mehrere Blöcke an/abwählen',
        hasValue: (e) => e.schlafStunden != null,
        build: (context, e, changed) {
          e.schlafStunden ??= 0.0; // Punkt 2
          return HalfBlocksInput(
            initial: e.schlafStunden,
            onChanged: (v) { e.schlafStunden = v; changed(); },
          );
        },
        
      );
    case 'elvanse':
      return CaptureStep(
        id: id, group: 1, title: label ?? 'Elvanse', plantTheme: theme,
        subtitle: 'Einnahmemenge in mg',
        hasValue: (e) => e.elvanseMg != null,
        build: (context, e, changed) {
          e.elvanseMg ??= 0; // Punkt 2: „keine" ist vorausgewählt
          return MgChoiceInput(
            options: const [20, 30, 40, 50],
            value: e.elvanseMg,
            onChanged: (v) { e.elvanseMg = v; changed(); },
          );
        },
        
      );
    case 'unruhe':
      return CaptureStep(
        id: id, group: 1, title: label ?? 'Innere Unruhe', plantTheme: theme,
        subtitle: '0 = gar nicht · 5 = mittel · 10 = sehr stark',
        hasValue: (e) => e.innereUnruhe != null,
        build: (context, e, changed) {
          e.innereUnruhe ??= 5.0;
          return HorizontalSliderInput(
              value: e.innereUnruhe!,
              onChanged: (v) { e.innereUnruhe = v; changed(); });
        },
      );
    case 'medikinet':
      return CaptureStep(
        id: id, group: 1, title: label ?? 'Medikinet', plantTheme: theme,
        subtitle: 'Menge, Zeitpunkt und Magen',
        hasValue: (e) => e.medikinetMg != null,
        build: (context, e, changed) {
          e.medikinetMg ??= 0; // Punkt 2: „keine" ist vorausgewählt
          return MedikinetInput(entry: e, onChanged: changed);
        },
      );
    case 'intensitaet':
      return CaptureStep(
        id: id, group: 2, title: label ?? 'Migräne-Intensität',
        plantTheme: theme,
        subtitle: 'Blöcke von 1 bis 10 antippen oder drüberstreichen',
        hasValue: (e) => e.migraeneIntensitaet != null,
        build: (context, e, changed) {
          e.migraeneIntensitaet ??= 0; // Punkt 2
          return IntensityBlocksInput(
            value: e.migraeneIntensitaet,
            onChanged: (v) { e.migraeneIntensitaet = v; changed(); },
          );
        },
        
      );
    case 'start':
    case 'ende':
      return CaptureStep(
        id: id, group: 2, plantTheme: theme,
        title: label ??
            (id == 'start' ? 'Beginn der Migräne' : 'Ende der Migräne'),
        hasValue: (e) =>
            id == 'start' ? e.migraeneStart != null : e.migraeneEnde != null,
        build: (context, e, changed) => TimeStepInput(
          value: id == 'start' ? e.migraeneStart : e.migraeneEnde,
          onChanged: (v) {
            if (id == 'start') { e.migraeneStart = v; } else { e.migraeneEnde = v; }
            changed();
          },
        ),
      );
    case 'ausloeser':
    case 'symptome':
      final isA = id == 'ausloeser';
      return CaptureStep(
        id: id, group: 2, plantTheme: theme,
        title: label ?? (isA ? 'Auslöser' : 'Begleitsymptome'),
        subtitle: 'Freitext – bisherige Einträge erscheinen als Vorschlag',
        hasValue: (e) {
          final v = isA ? e.ausloeser : e.begleitsymptome;
          return v != null && v.isNotEmpty;
        },
        build: (context, e, changed) => TagsInput(
          initial: isA ? e.ausloeser : e.begleitsymptome,
          hint: isA
              ? 'z. B. Stress, Wetter, Bildschirm …'
              : 'z. B. Übelkeit, Lichtempfindlichkeit …',
          suggestions: PhaskaDb.instance
              .pastValues(isA ? 'ausloeser' : 'begleitsymptome'),
          onChanged: (v) {
            if (isA) { e.ausloeser = v; } else { e.begleitsymptome = v; }
            changed();
          },
        ),
      );
    case 'notizen':
      return CaptureStep(
        id: id, group: 2, title: label ?? 'Notizen', plantTheme: theme,
        hasValue: (e) => e.notizen != null && e.notizen!.isNotEmpty,
        build: (context, e, changed) => NotesInput(
          initial: e.notizen,
          onChanged: (v) { e.notizen = v; changed(); },
        ),
      );
    default:
      throw ArgumentError('Unbekannte Schritt-ID: $id');
  }
}

CaptureStep _customStep(FieldDef d) => CaptureStep(
      id: d.id,
      group: d.group,
      title: d.label,
      plantTheme: d.plantTheme,
      hasValue: (e) => d.inputs.any((inp) {
        final v = customSubValue(e, d, inp);
        return v != null && (v is! String || v.isNotEmpty);
      }),
      build: (context, e, changed) {
        _applyCustomDefaults(e, d); // Punkt 2
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final inp in d.inputs) ...[
              if (d.inputs.length > 1)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(inp.label,
                      style: Theme.of(context).textTheme.titleSmall),
                ),
              _customInput(inp, customSubValue(e, d, inp), (v) {
                setCustomSubValue(e, d, inp, v);
                changed();
              }),
              const SizedBox(height: 28),
            ],
          ],
        );
      },
      
    );

Widget _customInput(
    FieldInput inp, Object? value, ValueChanged<Object?> onChanged) {
  switch (inp.type) {
    case 'vslider':
      return VerticalSliderInput(
          value: (value as num?)?.toInt() ?? 50, onChanged: onChanged);
    case 'hslider':
      return HorizontalSliderInput(
          value: (value as num?)?.toDouble() ?? 5.0,
          onChanged: (v) => onChanged(v));
    case 'blocks':
      return IntensityBlocksInput(
          value: (value as num?)?.toInt(), onChanged: onChanged);
    case 'halfblocks':
      return HalfBlocksInput(
          initial: (value as num?)?.toDouble(),
          maxBlocks: inp.maxBlocks,
          onChanged: onChanged);
    case 'choice':
      return ChoiceChipsInput(
          options: inp.options,
          value: value as String?,
          onChanged: onChanged);
    case 'time':
      return TimeStepInput(value: value as String?, onChanged: onChanged);
    default:
      return NotesInput(initial: value as String?, onChanged: onChanged);
  }
}

/// Öffentliche Hülle um [_customInput] – damit auch Einzelerfassung
/// und Einzeltabelle dieselben Eingabe-Widgets nutzen können.
Widget customInputWidget(
        FieldInput inp, Object? value, ValueChanged<Object?> onChanged) =>
    _customInput(inp, value, onChanged);

// ---------------- Zeit-Helfer & Rad-Picker ----------------

String formatClock(TimeOfDay t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

TimeOfDay? parseClock(String? v) {
  if (v == null) return null;
  final p = v.split(':');
  if (p.length != 2) return null;
  return TimeOfDay(
      hour: int.tryParse(p[0]) ?? 0, minute: int.tryParse(p[1]) ?? 0);
}

/// Stunden/Minuten-Trommeln wie in der Android-Wecker-App.
Future<String?> pickWheelTime(BuildContext context, String? current) async {
  final init = parseClock(current) ?? TimeOfDay.now();
  var hour = init.hour;
  var minute = init.minute;
  return showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    builder: (ctx) {
      final theme = Theme.of(ctx);
      Widget wheel(int count, int initial, ValueChanged<int> onSel) =>
          Expanded(
            child: ListWheelScrollView.useDelegate(
              controller: FixedExtentScrollController(initialItem: initial),
              itemExtent: 44,
              perspective: .002,
              diameterRatio: 1.6,
              physics: const FixedExtentScrollPhysics(),
              onSelectedItemChanged: onSel,
              childDelegate: ListWheelChildBuilderDelegate(
                childCount: count,
                builder: (c, i) => Center(
                    child: Text(i.toString().padLeft(2, '0'),
                        style: theme.textTheme.headlineSmall)),
              ),
            ),
          );
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            SizedBox(
              height: 200,
              child: Row(children: [
                wheel(24, hour, (v) => hour = v),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(':', style: theme.textTheme.headlineMedium)),
                wheel(60, minute, (v) => minute = v),
              ]),
            ),
            const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Std.'), SizedBox(width: 150), Text('Min.'),
                ]),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(
                  child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Abbrechen'))),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: FilledButton(
                  onPressed: () => Navigator.pop(
                      ctx,
                      '${hour.toString().padLeft(2, '0')}:'
                      '${minute.toString().padLeft(2, '0')}'),
                  child: const Text('Übernehmen'),
                ),
              ),
            ]),
          ]),
        ),
      );
    },
  );
}

// ---------------- Eingabe-Widgets ----------------

/// Die Slider/Blöcke halten ihren Wert selbst und reagieren dadurch
/// sofort auf den Finger – ohne auf einen Eltern-Rebuild zu warten.
class VerticalSliderInput extends StatefulWidget {
  final int value;
  final int min;
  final int max;
  final String hint;
  final ValueChanged<int> onChanged;
  const VerticalSliderInput(
      {super.key,
      required this.value,
      this.min = 1,
      this.max = 100,
      this.hint = '',
      required this.onChanged});

  @override
  State<VerticalSliderInput> createState() => _VerticalSliderInputState();
}

class _VerticalSliderInputState extends State<VerticalSliderInput> {
  late int _v = widget.value;

  @override
  void didUpdateWidget(VerticalSliderInput old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) _v = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mid = ((widget.max - widget.min) / 2 + widget.min).round();
    return Column(children: [
      Text('$_v',
          style: theme.textTheme.displayLarge?.copyWith(
              fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
      if (widget.hint.isNotEmpty)
        Text(widget.hint, style: theme.textTheme.bodyMedium),
      const SizedBox(height: 24),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        SizedBox(
          height: 320,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${widget.max}', style: theme.textTheme.labelLarge),
                Text('$mid', style: theme.textTheme.labelLarge),
                Text('${widget.min}', style: theme.textTheme.labelLarge),
              ]),
        ),
        const SizedBox(width: 16),
        SizedBox(
          height: 320,
          child: RotatedBox(
            quarterTurns: 3,
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 18,
                thumbShape:
                    const RoundSliderThumbShape(enabledThumbRadius: 15),
                overlayShape:
                    const RoundSliderOverlayShape(overlayRadius: 26),
              ),
              child: Slider(
                value: _v.toDouble(),
                min: widget.min.toDouble(),
                max: widget.max.toDouble(),
                divisions: widget.max - widget.min,
                onChanged: (v) {
                  setState(() => _v = v.round());
                  widget.onChanged(_v);
                },
              ),
            ),
          ),
        ),
      ]),
    ]);
  }
}

/// 0–10: 5 liegt genau in der Mitte.
class HorizontalSliderInput extends StatefulWidget {
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;
  const HorizontalSliderInput(
      {super.key,
      required this.value,
      this.min = 0,
      this.max = 10,
      this.divisions = 20,
      required this.onChanged});

  @override
  State<HorizontalSliderInput> createState() => _HorizontalSliderInputState();
}

class _HorizontalSliderInputState extends State<HorizontalSliderInput> {
  late double _v = widget.value;

  @override
  void didUpdateWidget(HorizontalSliderInput old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) _v = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(children: [
      Text(fmtDe(_v),
          style: theme.textTheme.displayLarge?.copyWith(
              fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
      const SizedBox(height: 24),
      Slider(
          value: _v,
          min: widget.min,
          max: widget.max,
          divisions: widget.divisions,
          label: fmtDe(_v),
          onChanged: (v) {
            setState(() => _v = v);
            widget.onChanged(v);
          }),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(fmtDe(widget.min)),
              Text(fmtDe((widget.max - widget.min) / 2 + widget.min)),
              Text(fmtDe(widget.max)),
            ]),
      ),
    ]);
  }
}

/// Blöcke mit Halbierung + Streich-Geste (an/abwählen).
class HalfBlocksInput extends StatefulWidget {
  final double? initial;
  final int maxBlocks;
  final ValueChanged<double?> onChanged;
  const HalfBlocksInput(
      {super.key, this.initial, this.maxBlocks = 12, required this.onChanged});

  @override
  State<HalfBlocksInput> createState() => _HalfBlocksInputState();
}

class _HalfBlocksInputState extends State<HalfBlocksInput> {
  static const _cross = 6;
  static const _spacing = 8.0;
  static const _ratio = .95;
  final _gridKey = GlobalKey();
  late final List<double> _blocks = List.filled(widget.maxBlocks, 0.0);
  double? _paintTarget;

  @override
  void initState() {
    super.initState();
    var rest = widget.initial ?? 0.0;
    for (var i = 0; i < _blocks.length; i++) {
      if (rest >= 1) { _blocks[i] = 1; rest -= 1; }
      else if (rest >= .5) { _blocks[i] = .5; rest -= .5; }
    }
  }

  double get _total => _blocks.fold(0.0, (a, b) => a + b);
  void _notify() => widget.onChanged(_total == 0 ? null : _total);

  int? _indexAt(Offset global) {
    final box = _gridKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return null;
    final local = box.globalToLocal(global);
    final cellW = (box.size.width - (_cross - 1) * _spacing) / _cross;
    final cellH = cellW / _ratio;
    final col = (local.dx / (cellW + _spacing)).floor();
    final row = (local.dy / (cellH + _spacing)).floor();
    final i = row * _cross + col;
    return (i >= 0 && i < _blocks.length) ? i : null;
  }

  void _tap(int i) {
    setState(() => _blocks[i] = _blocks[i] == 1 ? 0 : 1);
    _notify();
  }

  void _longPress(int i) {
    setState(() => _blocks[i] = _blocks[i] == .5 ? 1 : .5);
    _notify();
  }

  void _paintStart(int i) {
    _paintTarget = _blocks[i] == 0 ? 1.0 : 0.0;
    _paintMove(i);
  }

  void _paintMove(int i) {
    if (_paintTarget != null && _blocks[i] != _paintTarget) {
      setState(() => _blocks[i] = _paintTarget!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(children: [
      Text('${fmtDe(_total)} h',
          style: theme.textTheme.displayMedium?.copyWith(
              fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
      const SizedBox(height: 24),
      GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapUp: (d) {
          final i = _indexAt(d.globalPosition);
          if (i != null) _tap(i);
        },
        onLongPressStart: (d) {
          final i = _indexAt(d.globalPosition);
          if (i != null) _longPress(i);
        },
        onPanStart: (d) {
          final i = _indexAt(d.globalPosition);
          if (i != null) _paintStart(i);
        },
        onPanUpdate: (d) {
          final i = _indexAt(d.globalPosition);
          if (i != null) _paintMove(i);
        },
        onPanEnd: (_) {
          _paintTarget = null;
          _notify();
        },
        child: GridView.builder(
          key: _gridKey,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _cross,
              mainAxisSpacing: _spacing,
              crossAxisSpacing: _spacing,
              childAspectRatio: _ratio),
          itemCount: _blocks.length,
          itemBuilder: (context, i) {
            final v = _blocks[i];
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: theme.colorScheme.outlineVariant),
                color: theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: .35),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: Stack(children: [
                  if (v > 0)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: v,
                        heightFactor: 1,
                        child: Container(color: theme.colorScheme.primary),
                      ),
                    ),
                  Center(
                      child: Text('${i + 1}',
                          style: theme.textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600))),
                ]),
              ),
            );
          },
        ),
      ),
      const SizedBox(height: 16),
      Text('Tippen: 1 h an/aus · Halten: ½ h an/aus\nStreichen: mehrere an/ab',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
    ]);
  }
}

/// 1..N Blöcke in einer Reihe – tippen oder drüberstreichen.
class IntensityBlocksInput extends StatefulWidget {
  final int? value;
  final int max;
  final ValueChanged<int?> onChanged;
  const IntensityBlocksInput(
      {super.key, required this.value, required this.onChanged, this.max = 10});

  @override
  State<IntensityBlocksInput> createState() => _IntensityBlocksInputState();
}

class _IntensityBlocksInputState extends State<IntensityBlocksInput> {
  final _key = GlobalKey();
  late int? _cur = widget.value;

  @override
  void didUpdateWidget(IntensityBlocksInput old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) _cur = widget.value;
  }

  void _set(int? v) {
    setState(() => _cur = v);
    widget.onChanged(v);
  }

  int? _indexAt(Offset global) {
    final box = _key.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return null;
    final local = box.globalToLocal(global);
    final i = (local.dx / (box.size.width / widget.max)).floor();
    return i.clamp(0, widget.max - 1);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final value = _cur;
    return Column(children: [
      Text(value?.toString() ?? '—',
          style: theme.textTheme.displayLarge?.copyWith(
              fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
      const SizedBox(height: 24),
      GestureDetector(
        key: _key,
        behavior: HitTestBehavior.opaque,
        onTapUp: (d) {
          final i = _indexAt(d.globalPosition);
          if (i != null) _set(value == i + 1 ? null : i + 1);
        },
        onPanStart: (d) {
          final i = _indexAt(d.globalPosition);
          if (i != null) _set(i + 1);
        },
        onPanUpdate: (d) {
          final i = _indexAt(d.globalPosition);
          if (i != null && value != i + 1) _set(i + 1);
        },
        child: Row(
          children: List.generate(widget.max, (i) {
            final filled = value != null && i < value;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: filled
                        ? theme.colorScheme.primary
                        : theme.colorScheme.surfaceContainerHighest
                            .withValues(alpha: .35),
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: theme.colorScheme.outlineVariant),
                  ),
                  child: Center(
                      child: Text('${i + 1}',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: filled ? Colors.white : null))),
                ),
              ),
            );
          }),
        ),
      ),
      const SizedBox(height: 8),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('1 = leicht', style: theme.textTheme.bodySmall),
        Text('${widget.max} = unerträglich', style: theme.textTheme.bodySmall),
      ]),
    ]);
  }
}

class MgChoiceInput extends StatelessWidget {
  final List<int> options;
  final int? value; // 0 = „keine“
  final ValueChanged<int?> onChanged;
  final WrapAlignment alignment;
  const MgChoiceInput(
      {super.key,
      required this.options,
      required this.value,
      required this.onChanged,
      this.alignment = WrapAlignment.center});

  @override
  Widget build(BuildContext context) => Wrap(
        spacing: 10,
        runSpacing: 10,
        alignment: alignment,
        children: [
          for (final mg in options)
            ChoiceChip(
                label: Text('$mg mg'),
                selected: value == mg,
                onSelected: (sel) => onChanged(sel ? mg : null)),
          ChoiceChip(
              label: const Text('keine'),
              selected: value == 0,
              onSelected: (sel) => onChanged(sel ? 0 : null)),
        ],
      );
}

class ChoiceChipsInput extends StatelessWidget {
  final List<String> options;
  final String? value;
  final ValueChanged<String?> onChanged;
  const ChoiceChipsInput(
      {super.key,
      required this.options,
      required this.value,
      required this.onChanged});

  @override
  Widget build(BuildContext context) => Wrap(
        spacing: 10,
        runSpacing: 10,
        alignment: WrapAlignment.center,
        children: [
          for (final o in options)
            ChoiceChip(
                label: Text(o),
                selected: value == o,
                onSelected: (sel) => onChanged(sel ? o : null)),
        ],
      );
}

class MedikinetInput extends StatelessWidget {
  final PhaskaEntry entry;
  final VoidCallback onChanged;
  const MedikinetInput({super.key, required this.entry, required this.onChanged});

  static const abstaende = [
    'direkt danach', '< 30 Min.', '30–60 Min.', '> 1 Std.'
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final e = entry;
    final taken = e.medikinetMg != null && e.medikinetMg != 0;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Menge', style: theme.textTheme.titleSmall),
      const SizedBox(height: 8),
      MgChoiceInput(
        alignment: WrapAlignment.start,
        options: const [5, 10, 15, 20],
        value: e.medikinetMg,
        onChanged: (v) {
          e.medikinetMg = v;
          if (v == null || v == 0) {
            e.medikinetZeit = null;
            e.medikinetMagen = null;
            e.medikinetEssenAbstand = null;
          }
          onChanged();
        },
      ),
      if (taken) ...[
        const SizedBox(height: 28),
        Text('Zeitpunkt', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () async {
            final t = await pickWheelTime(context, e.medikinetZeit);
            if (t != null) { e.medikinetZeit = t; onChanged(); }
          },
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.outlineVariant),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(children: [
              const Icon(Icons.schedule),
              const SizedBox(width: 12),
              Text(e.medikinetZeit ?? 'Zeit wählen',
                  style: theme.textTheme.titleMedium),
              const Spacer(),
              if (e.medikinetZeit != null)
                GestureDetector(
                  onTap: () { e.medikinetZeit = null; onChanged(); },
                  child: const Icon(Icons.close, size: 20),
                ),
            ]),
          ),
        ),
        const SizedBox(height: 28),
        Text('Magen', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'nüchtern', label: Text('nüchtern')),
            ButtonSegment(
                value: 'nach dem Essen', label: Text('nach dem Essen')),
          ],
          selected: e.medikinetMagen == null
              ? const <String>{}
              : {e.medikinetMagen!},
          emptySelectionAllowed: true,
          onSelectionChanged: (s) {
            e.medikinetMagen = s.isEmpty ? null : s.first;
            if (e.medikinetMagen != 'nach dem Essen') {
              e.medikinetEssenAbstand = null;
            }
            onChanged();
          },
        ),
        if (e.medikinetMagen == 'nach dem Essen') ...[
          const SizedBox(height: 16),
          Text('Wie lange nach dem Essen?', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final a in abstaende)
              ChoiceChip(
                label: Text(a),
                selected: e.medikinetEssenAbstand == a,
                onSelected: (sel) {
                  e.medikinetEssenAbstand = sel ? a : null;
                  onChanged();
                },
              ),
          ]),
        ],
      ],
    ]);
  }
}

class TimeStepInput extends StatelessWidget {
  final String? value;
  final ValueChanged<String?> onChanged;
  const TimeStepInput({super.key, this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(children: [
      Text(value ?? '—',
          style: theme.textTheme.displayLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: value == null
                  ? theme.colorScheme.outline
                  : theme.colorScheme.primary)),
      if (value != null) Text('Uhr', style: theme.textTheme.bodyMedium),
      const SizedBox(height: 28),
      FilledButton.tonalIcon(
        onPressed: () async {
          final t = await pickWheelTime(context, value);
          if (t != null) onChanged(t);
        },
        icon: const Icon(Icons.schedule),
        label: Text(value == null ? 'Zeit wählen' : 'Zeit ändern'),
      ),
      const SizedBox(height: 12),
      Wrap(alignment: WrapAlignment.center, spacing: 8, children: [
        ActionChip(
          avatar: const Icon(Icons.update, size: 18),
          label: const Text('Jetzt'),
          onPressed: () => onChanged(formatClock(TimeOfDay.now())),
        ),
        if (value != null)
          ActionChip(
            avatar: const Icon(Icons.clear, size: 18),
            label: const Text('Zurücksetzen'),
            onPressed: () => onChanged(null),
          ),
      ]),
    ]);
  }
}

class TagsInput extends StatefulWidget {
  final String? initial;
  final String hint;
  final Future<List<String>> suggestions;
  final ValueChanged<String?> onChanged;

  const TagsInput({
    super.key,
    this.initial,
    required this.hint,
    required this.suggestions,
    required this.onChanged,
  });

  @override
  State<TagsInput> createState() => _TagsInputState();
}

class _TagsInputState extends State<TagsInput> {
  late final TextEditingController _c = TextEditingController();
  late final List<String> _tags = (widget.initial ?? '')
      .split(';')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _emit() => widget.onChanged(_tags.isEmpty ? null : _tags.join('; '));

  void _add(String raw) {
    final t = raw.trim();
    _c.clear();
    if (t.isEmpty ||
        _tags.any((x) => x.toLowerCase() == t.toLowerCase())) {
      return;
    }
    setState(() => _tags.add(t));
    _emit();
  }

  void _toggle(String t) {
    setState(() => _tags.contains(t) ? _tags.remove(t) : _tags.add(t));
    _emit();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      TextField(
        controller: _c,
        textInputAction: TextInputAction.done,
        onSubmitted: _add,
        decoration: InputDecoration(
          hintText: widget.hint,
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          suffixIcon: IconButton(
              icon: const Icon(Icons.add), onPressed: () => _add(_c.text)),
        ),
      ),
      if (_tags.isNotEmpty) ...[
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final t in _tags)
            InputChip(
                label: Text(t),
                onDeleted: () {
                  setState(() => _tags.remove(t));
                  _emit();
                }),
        ]),
      ],
      const SizedBox(height: 24),
      Text('Bisher verwendet', style: theme.textTheme.titleSmall),
      const SizedBox(height: 8),
      FutureBuilder<List<String>>(
        future: widget.suggestions,
        builder: (context, snap) {
          final s = snap.data ?? const <String>[];
          if (s.isEmpty) {
            return Text('Noch keine Einträge vorhanden',
                style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant));
          }
          return Wrap(spacing: 8, runSpacing: 8, children: [
            for (final t in s)
              FilterChip(
                  label: Text(t),
                  selected: _tags.contains(t),
                  onSelected: (_) => _toggle(t)),
          ]);
        },
      ),
    ]);
  }
}

class NotesInput extends StatefulWidget {
  final String? initial;
  final ValueChanged<String?> onChanged;
  const NotesInput({super.key, this.initial, required this.onChanged});

  @override
  State<NotesInput> createState() => _NotesInputState();
}

class _NotesInputState extends State<NotesInput> {
  late final TextEditingController _c =
      TextEditingController(text: widget.initial ?? '');

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextField(
        controller: _c,
        minLines: 4,
        maxLines: 8,
        decoration: InputDecoration(
          hintText: 'Weitere Anmerkungen …',
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onChanged: (t) =>
            widget.onChanged(t.trim().isEmpty ? null : t.trim()),
      );
}