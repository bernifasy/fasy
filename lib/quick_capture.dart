import 'package:flutter/material.dart';

import 'capture/capture_flow.dart';
import 'capture/steps.dart';
import 'db.dart';
import 'models.dart';
import 'painters.dart';

/// Findet die FieldInput eines eigenen Datenpunkts zu einem Mess-Schlüssel.
FieldInput? customInputFor(String key, Map<String, FieldDef> defsById) {
  final p = key.split('::');
  if (p.length != 2) return null;
  final d = defsById[p[0]];
  if (d == null) return null;
  for (final i in d.inputs) {
    if (i.subkey == p[1]) return i;
  }
  return null;
}

/// Punkt 2: Voreinstellung = der Wert, der ohne Berühren gespeichert wird.
double? defaultQuickValue(String key, FieldInput? custom) {
  switch (key) {
    case 'wohlbefinden':
      return 50;
    case 'innere_unruhe':
      return 5;
    case 'intensitaet':
      return 0;
    case 'schlaf':
      return 0;
    case 'elvanse':
      return 0;
    case 'medikinet':
      return 0;
  }
  if (custom != null) {
    switch (custom.type) {
      case 'vslider':
        return 50;
      case 'hslider':
        return 5.0;
      case 'blocks':
        return 0.0;
      case 'halfblocks':
        return 0.0;
    }
  }
  return null;
}

/// Eingabe-Widget für einen Schnell-Wert (builtins + eigene Datenpunkte).
Widget quickValueInput(String key, FieldInput? custom, double? value,
    ValueChanged<double?> onChanged) {
  switch (key) {
    case 'wohlbefinden':
      return VerticalSliderInput(
          value: (value ?? 50).round(),
          hint: 'Schnellerfassung für heute',
          onChanged: (v) => onChanged(v.toDouble()));
    case 'innere_unruhe':
      return HorizontalSliderInput(value: value ?? 5, onChanged: onChanged);
    case 'intensitaet':
      return IntensityBlocksInput(
          value: value?.round(), onChanged: (v) => onChanged(v?.toDouble()));
    case 'schlaf':
      return HalfBlocksInput(initial: value, onChanged: onChanged);
    case 'elvanse':
      return MgChoiceInput(
          options: const [20, 30, 40, 50],
          value: value?.round(),
          onChanged: (v) => onChanged(v?.toDouble()));
    case 'medikinet':
      return MgChoiceInput(
          options: const [5, 10, 15, 20],
          value: value?.round(),
          onChanged: (v) => onChanged(v?.toDouble()));
  }
  if (custom != null) {
    return customInputWidget(custom, value, (v) {
      if (v is num) onChanged(v.toDouble());
    });
  }
  return const SizedBox.shrink();
}

/// Einzelne Schnellerfassung eines freigegebenen Werts.
/// Punkt 1: eigene Farbe (AppColors.quick) + eigene Pflanzen-Deko.
class QuickCaptureScreen extends StatefulWidget {
  final String sourceKey;
  const QuickCaptureScreen({super.key, required this.sourceKey});

  @override
  State<QuickCaptureScreen> createState() => _QuickCaptureScreenState();
}

class _QuickCaptureScreenState extends State<QuickCaptureScreen> {
  Map<String, FieldDef> _defs = {};
  String _plantTheme = 'none';
  double? _value;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final d = await PhaskaDb.instance.fieldDefs();
    final defs = {for (final x in d) x.id: x};
    final theme = await PhaskaDb.instance.loadQuickTheme();
    if (!mounted) return;
    setState(() {
      _defs = defs;
      _plantTheme = theme;
      // Punkt 2: Voreinstellwert direkt anzeigen (und speicherbar machen).
      _value ??= defaultQuickValue(
          widget.sourceKey, customInputFor(widget.sourceKey, defs));
    });
  }

  Future<void> _save() async {
    await PhaskaDb.instance.insertQuick(QuickValue(
        defKey: widget.sourceKey,
        label: keyLabel(widget.sourceKey, _defs),
        value: _value!,
        createdAt: DateTime.now()));
    if (!mounted) return;
    await showSuccessCheck(context);
    if (mounted) Navigator.pop(context);
  }

  Widget _deco(Color accent,
      {double? top,
      double? bottom,
      double? left,
      double? right,
      required double w,
      required double h,
      required double opacity}) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: IgnorePointer(
        child: Opacity(
          opacity: opacity,
          child: CustomPaint(
              size: Size(w, h),
              painter: PlantPainter(theme: _plantTheme, color: accent)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = AppColors.quick.value; // Punkt 1
    return Theme(
      data:
          theme.copyWith(colorScheme: theme.colorScheme.copyWith(primary: accent)),
      child: Builder(
        builder: (context) => Scaffold(
          body: SafeArea(
            child: Stack(children: [
              if (_plantTheme != 'none') ...[
                _deco(accent, top: 30, right: -40, w: 200, h: 280, opacity: .14),
                _deco(accent,
                    bottom: 70, left: -50, w: 180, h: 260, opacity: .10),
              ],
              Column(children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context)),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(keyLabel(widget.sourceKey, _defs),
                              style: theme.textTheme.headlineMedium
                                  ?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Text('Einzelerfassung · zählt in Tages-Ø, Min & Max',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant)),
                          const SizedBox(height: 28),
                          quickValueInput(
                              widget.sourceKey,
                              customInputFor(widget.sourceKey, _defs),
                              _value,
                              (v) => setState(() => _value = v)),
                        ]),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                        backgroundColor: accent,
                        minimumSize: const Size.fromHeight(48)),
                    onPressed: _value == null ? null : _save,
                    child: const Text('Speichern'),
                  ),
                ),
              ]),
            ]),
          ),
        ),
      ),
    );
  }
}