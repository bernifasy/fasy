import 'dart:async';

import 'package:flutter/material.dart';

import '../models.dart';
import '../painters.dart';
import '../review_screen.dart';
import 'steps.dart';

class CaptureFlowScreen extends StatefulWidget {
  final int startGroup; // 1 oder 2
  final bool editMode;
  final PhaskaEntry? entry;
  final int startIndex;

  /// true = nach dem letzten Schritt zur Übersicht (z. B. Bearbeiten aus der Tabelle)
  final bool editOpensReview;

  const CaptureFlowScreen({
    super.key,
    this.startGroup = 1,
    this.editMode = false,
    this.entry,
    this.startIndex = 0,
    this.editOpensReview = false,
  });

  @override
  State<CaptureFlowScreen> createState() => _CaptureFlowScreenState();
}

class _CaptureFlowScreenState extends State<CaptureFlowScreen> {
  late final PhaskaEntry _entry = widget.entry ?? PhaskaEntry.empty();
  List<CaptureStep>? _steps;
  bool _group2Appended = false;
  PageController? _page;
  int _index = 0;

  bool get _isLast => _index == _steps!.length - 1;
  Color get _accent => groupColor(_steps![_index].group);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final s = widget.editMode
        ? await stepsForAll()
        : await stepsForGroup(widget.startGroup);
    if (!mounted) return;
    setState(() {
      _steps = s;
      _index = widget.startIndex.clamp(0, s.length - 1);
      _page = PageController(initialPage: _index);
    });
  }

  @override
  void dispose() {
    _page?.dispose();
    super.dispose();
  }

  void _go(int i) {
    FocusScope.of(context).unfocus();
    _page!.animateToPage(i,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeInOutCubicEmphasized);
  }

  String get _primaryLabel {
    if (_isLast) return widget.editMode ? 'Fertig' : 'Abschließen';
    if (widget.editMode) return 'Weiter';
    return _steps![_index].hasValue(_entry) ? 'Weiter' : 'Überspringen';
  }

  Future<void> _onPrimary() async {
    if (!_isLast) {
      _go(_index + 1);
      return;
    }
    if (widget.editMode) {
      if (widget.editOpensReview) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => ReviewScreen(entry: _entry)));
      } else {
        Navigator.pop(context, true);
      }
      return;
    }
    if (widget.startGroup == 1 && !_group2Appended) {
      final weiter = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          icon: const Icon(Icons.check_circle_outline),
          title: const Text('Tag fertig erfasst'),
          content: const Text(
              'Erfassung beenden oder direkt mit der Migräne-Erfassung (Gruppe 2) weitermachen?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Beenden')),
            FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Weiter mit Gruppe 2')),
          ],
        ),
      );
      if (weiter == true) {
        final g2 = await stepsForGroup(2);
        setState(() {
          _steps!.addAll(g2);
          _group2Appended = true;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) => _go(_index + 1));
        return;
      }
    }
    await _finish();
  }

  Future<void> _finish() async {
    // Punkt 2: unberührte Werte bekommen ihren Voreinstellwert.
    for (final s in _steps!) {
      s.applyDefault?.call(_entry);
    }
    await showSuccessCheck(context);
    if (!mounted) return;
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => ReviewScreen(entry: _entry)));
  }

  Future<void> _onClose() async {
    if (widget.editMode) {
      Navigator.pop(context, true);
      return;
    }
    final hasData = _steps!.any((s) => s.hasValue(_entry));
    if (!hasData) {
      Navigator.pop(context);
      return;
    }
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Erfassung abbrechen?'),
        content: const Text('Die bisher eingegebenen Daten gehen verloren.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Weiter erfassen')),
          FilledButton(
              style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(ctx).colorScheme.error,
                  foregroundColor: Theme.of(ctx).colorScheme.onError),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Abbrechen')),
        ],
      ),
    );
    if (ok == true && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_steps == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final step = _steps![_index];
    final onAccent =
        ThemeData.estimateBrightnessForColor(_accent) == Brightness.light
            ? Colors.black87
            : Colors.white;

    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 4, 16, 0),
            child: Row(children: [
              IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: 'Abbrechen',
                  onPressed: _onClose),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('fasy', style: theme.textTheme.labelMedium),
                      Text(step.group == 1 ? 'Tag' : 'Migräne',
                          style: theme.textTheme.titleSmall),
                    ]),
              ),
              Text('${_index + 1} / ${_steps!.length}',
                  style: theme.textTheme.labelLarge),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                minHeight: 6,
                value: (_index + 1) / _steps!.length,
                color: _accent,
                backgroundColor: _accent.withValues(alpha: .15),
              ),
            ),
          ),
          Expanded(
            child: PageView(
              controller: _page,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (i) => setState(() => _index = i),
              children: [
                for (final s in _steps!)
                  _StepShell(
                    key: ValueKey(s.id),
                    step: s,
                    entry: _entry,
                    // Der Eltern-Rebuild ist bewusst zurück – so wie in
                    // der Version, in der die Eingaben perfekt liefen.
                    onChanged: () => setState(() {}),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              TextButton.icon(
                onPressed: _index > 0 ? () => _go(_index - 1) : null,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Zurück'),
              ),
              const Spacer(),
              FilledButton(
                style: FilledButton.styleFrom(
                    backgroundColor: _accent, foregroundColor: onAccent),
                onPressed: _onPrimary,
                child: Text(_primaryLabel),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _StepShell extends StatelessWidget {
  final CaptureStep step;
  final PhaskaEntry entry;
  final VoidCallback onChanged;
  const _StepShell(
      {super.key,
      required this.step,
      required this.entry,
      required this.onChanged});

  /// Große Deko-Pflanze; IgnorePointer, damit sie nie Eingaben abfängt.
  Widget _deco(
    Color color, {
    double? top,
    double? bottom,
    double? left,
    double? right,
    required double w,
    required double h,
    required double opacity,
    double rotate = 0,
    bool flip = false,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: IgnorePointer(
        child: Opacity(
          opacity: opacity,
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.rotationZ(rotate),
            child: Transform.flip(
              flipX: flip,
              child: CustomPaint(
                size: Size(w, h),
                painter: PlantPainter(theme: step.plantTheme, color: color),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = groupColor(step.group);
    final theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(
          colorScheme: theme.colorScheme.copyWith(primary: accent)),
      child: Builder(
        builder: (context) => Stack(children: [
          if (step.plantTheme != 'none') ...[
            _deco(accent, top: 20, right: -45, w: 220, h: 310, opacity: .16),
            _deco(accent,
                bottom: 70, left: -55, w: 210, h: 300, opacity: .12, rotate: .3),
            _deco(accent,
                bottom: -25, right: 25, w: 150, h: 220, opacity: .12, flip: true),
          ],
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(step.title,
                      style: theme.textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  if (step.subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(step.subtitle!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant)),
                    ),
                  const SizedBox(height: 28),
                  step.build(context, entry, onChanged),
                ]),
          ),
        ]),
      ),
    );
  }
}

/// Kleiner Erfolgs-Dialog – öffentlich, wird auch von der Einzelerfassung genutzt.
class SuccessDialog extends StatefulWidget {
  const SuccessDialog({super.key});

  @override
  State<SuccessDialog> createState() => _SuccessDialogState();
}

class _SuccessDialogState extends State<SuccessDialog> {
  Timer? _t;

  @override
  void initState() {
    super.initState();
    _t = Timer(const Duration(milliseconds: 1400), () {
      if (mounted) Navigator.pop(context);
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 600),
            curve: Curves.elasticOut,
            builder: (context, v, child) =>
                Transform.scale(scale: v, child: child),
            child: CircleAvatar(
              radius: 40,
              backgroundColor: Colors.green.shade400,
              child: const Icon(Icons.check_rounded,
                  size: 48, color: Colors.white),
            ),
          ),
          const SizedBox(height: 16),
          Text('Erfolgreich erfasst!',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Gleich geht’s weiter.', style: theme.textTheme.bodyMedium),
        ]),
      ),
    );
  }
}

/// Zeigt den Erfolgs-Dialog an und schließt ihn automatisch wieder.
Future<void> showSuccessCheck(BuildContext context) => showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const SuccessDialog());