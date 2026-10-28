import 'package:flutter/material.dart';

import 'capture/steps.dart';
import 'db.dart';
import 'models.dart';

/// Beim allerersten Start: Willkommens-Dialog (Punkt 7).
class WelcomeDialog extends StatelessWidget {
  const WelcomeDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Text('🌱', style: TextStyle(fontSize: 44)),
      title: const Text('Willkommen bei fasy! 🎉', textAlign: TextAlign.center),
      content: const Text(
          'Lass dir die App erklären oder lege selbst drauf los.',
          textAlign: TextAlign.center),
      actionsAlignment: MainAxisAlignment.center,
      actionsOverflowDirection: VerticalDirection.down,
      actions: [
        FilledButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.school_outlined),
            label: const Text('Einführung')),
        TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Direkt loslegen')),
      ],
    );
  }
}

/// Interaktive Einführung: E1 Text → E2 Werteauswahl → E3 Funktionsüberblick.
class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final _page = PageController();
  int _index = 0;

  /// E2: alle Standardwerte sind erstmal angewählt.
  final Set<String> _selected = {
    for (final g in builtinMeta.keys)
      for (final (id, _) in builtinMeta[g]!) id,
  };

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  void _go(int i) => _page.animateToPage(i,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubicEmphasized);

  Future<void> _next() async {
    if (_index == 0) {
      _go(1);
    } else if (_index == 1) {
      await _applySelection();
      _go(2);
    } else if (mounted) {
      Navigator.pop(context);
    }
  }

  /// E2 → nicht angewählte Standardwerte werden ausgeblendet.
  Future<void> _applySelection() async {
    for (final g in [1, 2]) {
      final hidden = {
        for (final (id, _) in builtinMeta[g]!)
          if (!_selected.contains(id)) id,
      };
      await PhaskaDb.instance.saveHiddenBuiltins(g, hidden);
    }
    Repo.bump();
  }

  Widget _e1(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 48, 28, 24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Schön, dass du da bist 🌿',
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        Text(
            'fasy ist eine App, die dir helfen soll, dich und, was dir gut '
            'tut, besser zu verstehen. Hier kannst du Werte wie Wohlbefinden, '
            'Konzentration, Medikamente, Schlaf und vieles mehr tracken.\n\n'
            'Die Kontrolle hast dabei nur du:\n'
            'Du entscheidest, welche Werte dir wichtig sind – und all deine '
            'Daten bleiben auf deinem Gerät. Nur du kannst sie sehen.\n\n'
            'Beginne damit, auszuwählen, welche Werte du erfassen willst.',
            style: theme.textTheme.bodyLarge?.copyWith(height: 1.5)),
      ]),
    );
  }

  Widget _e2(BuildContext context) {
    final theme = Theme.of(context);
    Widget groupBlock(int g, String title) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: Text(title,
                  style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold, color: groupColor(g))),
            ),
            for (final (id, label) in builtinMeta[g]!)
              CheckboxListTile(
                controlAffinity: ListTileControlAffinity.leading,
                secondary: CircleAvatar(
                    radius: 6, backgroundColor: groupColor(g)),
                title: Text(label),
                value: _selected.contains(id),
                onChanged: (v) => setState(() =>
                    v == true ? _selected.add(id) : _selected.remove(id)),
              ),
          ],
        );
    return ListView(padding: const EdgeInsets.only(top: 24), children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        child: Text('Welche Werte willst du erfassen?',
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold)),
      ),
      groupBlock(1, 'Tag'),
      groupBlock(2, 'Migräne'),
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Text('Später kannst du noch eigene Werte hinzufügen.',
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      ),
    ]);
  }

  Widget _e3(BuildContext context) {
    final theme = Theme.of(context);
    const items = <(IconData, String, String)>[
      (Icons.wb_sunny_rounded, 'Tag & Migräne erfassen',
          'Die zwei großen Buttons auf dem Startscreen führen dich Schritt für Schritt durch die Erfassung.'),
      (Icons.speed_rounded, 'Einzelwert erfassen',
          'Schnellmessungen mehrmals täglich – Tages-Ø, Min & Max landen automatisch in der Tabelle.'),
      (Icons.swipe_left_alt, 'Wischen',
          'Nach links wischen: Verlauf, Einzelwerte & Tabelle.'),
      (Icons.tune_rounded, 'Anpassen',
          'Oben rechts: Datenpunkte umbenennen, ausblenden, löschen, verschieben und eigene hinzufügen.'),
      (Icons.palette_outlined, 'Farben & Deko',
          'Gruppenfarben, Einzelerfassungs-Farbe, Pflanzen und Dark Mode.'),
      (Icons.touch_app_outlined, 'Lange drücken',
          'In den Tabellen Zeilen lange drücken, um sie zu bearbeiten oder zu löschen.'),
      (Icons.widgets_outlined, 'Homescreen-Widgets',
          'Halte den Homescreen gedrückt → Widgets → fasy: Buttons, Status, Verlauf & Kalender.'),
    ];
    return ListView(padding: const EdgeInsets.only(top: 24), children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
        child: Text('So findest du dich zurecht',
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold)),
      ),
      for (final (icon, title, sub) in items)
        ListTile(
          leading: CircleAvatar(
              backgroundColor:
                  theme.colorScheme.primary.withValues(alpha: .12),
              child: Icon(icon, color: theme.colorScheme.primary)),
          title: Text(title,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(sub),
        ),
      const SizedBox(height: 24),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _index == 2;
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Align(
            alignment: Alignment.topRight,
            child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Überspringen')),
          ),
          Expanded(
            child: PageView(
              controller: _page,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (i) => setState(() => _index = i),
              children: [_e1(context), _e2(context), _e3(context)],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child:
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              for (var i = 0; i < 3; i++) ...[
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: _index == i ? 22 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _index == i
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 6),
              ],
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Row(children: [
              TextButton(
                  onPressed: _index > 0 ? () => _go(_index - 1) : null,
                  child: const Text('Zurück')),
              const Spacer(),
              FilledButton(
                onPressed: _next,
                child: Text(isLast ? "Los geht's 🎉" : 'Weiter'),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}