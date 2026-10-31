import 'package:flutter/material.dart';

import 'capture/steps.dart';
import 'db.dart';
import 'l10n.dart';
import 'models.dart';

/// Globale Keys für die Spotlight-Führung (in main.dart / table_screen.dart
/// an die Ziel-Widgets gehängt).
final kKeyTagBtn = GlobalKey();
final kKeyMigBtn = GlobalKey();
final kKeyQuickBtn = GlobalKey();
final kKeySettingsBtn = GlobalKey();
final kKeyOnboardingBtn = GlobalKey();
final kKeyExportFab = GlobalKey();

/// Der PageController des HomePagers (Tutorial wertet Seitenwechsel aus).
PageController? homePagerController;

// ============================================================================
// Willkommens-Dialog (Punkt 10.1)
// ============================================================================

class WelcomeDialog extends StatelessWidget {
  const WelcomeDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Text('🌱🎉', style: TextStyle(fontSize: 44)),
      title: Text(S.t('ob_welcome_title'), textAlign: TextAlign.center),
      content: Text(S.t('ob_welcome_body'), textAlign: TextAlign.center),
      actionsAlignment: MainAxisAlignment.center,
      actionsOverflowDirection: VerticalDirection.down,
      actions: [
        FilledButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.school_outlined),
            label: Text(S.t('ob_welcome_intro'))),
        TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(S.t('ob_welcome_direct'))),
      ],
    );
  }
}

/// Punkt 10.1: Nach „Direkt loslegen" ein Pfeil-Highlight auf den
/// Einführung-nachholen-Knopf oben im Homescreen.
/// WICHTIG: context muss aus einer Route stammen (z. B. HomePager-State),
/// sonst findet Overlay.of nichts.
Future<void> showOnboardingPointer(BuildContext context) async {
  final overlay = Overlay.of(context);
  late OverlayEntry entry;
  Rect? target() {
    final box =
        kKeyOnboardingBtn.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return null;
    return box.localToGlobal(Offset.zero) & box.size;
  }

  entry = OverlayEntry(builder: (_) {
    final r = target();
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (entry.mounted) entry.remove();
      },
      child: Stack(children: [
        Positioned.fill(
            child: CustomPaint(painter: _HolePainter(r, Colors.black45))),
        if (r != null)
          Positioned(
            top: r.bottom + 10,
            right: 12,
            width: 260,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Text('⬆️', style: TextStyle(fontSize: 30)),
                  Text(
                    S.code.value == 'en'
                        ? 'You can restart the tour here anytime.'
                        : 'Die Einführung kannst du hier jederzeit nachholen.',
                    textAlign: TextAlign.center,
                  ),
                ]),
              ),
            ),
          ),
      ]),
    );
  });
  overlay.insert(entry);
  await Future.delayed(const Duration(seconds: 9));
  if (entry.mounted) entry.remove();
}

// ============================================================================
// Auswahl + Medikamenten-Setup (Punkt 10.2 / 2.1)
// ============================================================================

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _page = PageController();
  int _index = 0;

  bool _g1On = true;
  final Set<String> _g1Sel = {
    'wohlbefinden', 'schlaf', 'medication', 'konzentration', 'unruhe'
  };
  bool _g2On = true;
  final Set<String> _g2Sel = {
    'intensitaet', 'start', 'ende', 'ausloeser', 'symptome', 'notizen'
  };
  bool _elvanse = true;
  bool _medikinet = true;
  final List<FieldDef> _newMeds = [];

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  bool get _medsOn => _g1Sel.contains('medication');
  int get _pageCount => _medsOn ? 2 : 1;

  void _go(int i) => _page.animateToPage(i,
      duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);

  Future<void> _addMedDialog() async {
    final nameC = TextEditingController();
    final dosesC = TextEditingController(text: '5, 10, 20, 40');
    var withTime = true;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          title: Text(S.t('ob_med_add')),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(
                controller: nameC,
                autofocus: true,
                decoration: InputDecoration(labelText: S.t('ob_med_name'))),
            const SizedBox(height: 12),
            TextField(
                controller: dosesC,
                decoration: InputDecoration(labelText: S.t('ob_med_doses'))),
            SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: withTime,
                title: Text(S.t('ob_med_time')),
                onChanged: (v) => setD(() => withTime = v)),
          ]),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(S.t('cancel'))),
            FilledButton(
                onPressed: nameC.text.trim().isEmpty
                    ? null
                    : () => Navigator.pop(ctx, true),
                child: Text(S.t('add'))),
          ],
        ),
      ),
    );
    if (ok != true || nameC.text.trim().isEmpty) return;
    final name = nameC.text.trim();
    final doses = dosesC.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    setState(() {
      _newMeds.add(FieldDef(
        id: 'c_med_${name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_')}',
        group: 1,
        label: name,
        inputs: [
          FieldInput(
              subkey: 'dosis',
              label: name,
              type: 'choice',
              options: [for (final d in doses) '$d mg']),
          if (withTime)
            FieldInput(subkey: 'zeit', label: 'Uhrzeit', type: 'time'),
        ],
      ));
    });
  }

  Future<void> _apply() async {
    await PhaskaDb.instance.saveGroupEnabled(1, _g1On);
    await PhaskaDb.instance.saveGroupEnabled(2, _g2On);

    final h1 = <String>{};
    if (!_g1Sel.contains('wohlbefinden')) h1.add('wohlbefinden');
    if (!_g1Sel.contains('schlaf')) h1.add('schlaf');
    if (!_g1Sel.contains('unruhe')) h1.add('unruhe');
    if (!_medsOn || !_elvanse) h1.add('elvanse');
    if (!_medsOn || !_medikinet) h1.add('medikinet');
    await PhaskaDb.instance.saveHiddenBuiltins(1, h1);

    final h2 = <String>{};
    for (final id
        in ['intensitaet', 'start', 'ende', 'ausloeser', 'symptome', 'notizen']) {
      if (!_g2Sel.contains(id)) h2.add(id);
    }
    await PhaskaDb.instance.saveHiddenBuiltins(2, h2);

    final defs = await PhaskaDb.instance.fieldDefs(group: 1);
    if (_g1Sel.contains('konzentration') &&
        defs.every((d) => d.id != 'c_konzentration')) {
      await PhaskaDb.instance.saveFieldDef(FieldDef(
          id: 'c_konzentration',
          group: 1,
          label: S.t('ob_konzentration'),
          inputs: [
            FieldInput(
                subkey: 'wert',
                label: S.t('ob_konzentration'),
                type: 'hslider')
          ]));
    }
    for (final d in _newMeds) {
      await PhaskaDb.instance.saveFieldDef(d);
    }
    for (final g in [1, 2]) {
      await PhaskaDb.instance.saveStepOrder(g, await orderedStepIds(g));
    }
  }

  Future<void> _finishSelection() async {
    await _apply();
    // Beispielwerte fürs Tutorial (verschwinden danach wieder – Pkt. 10.4–6).
    await PhaskaDb.instance.insertDemoData();
    if (mounted) Navigator.pop(context, true); // true = Tutorial starten
  }

  Widget _checkCol(
    String title,
    Color color,
    bool colOn,
    ValueChanged<bool> onCol,
    List<(String, String)> items,
    Set<String> sel,
  ) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        CheckboxListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          title: Text(title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold, color: color)),
          value: colOn && items.every((e) => sel.contains(e.$1)),
          tristate: true,
          onChanged: (_) {
            final allOn = colOn && items.every((e) => sel.contains(e.$1));
            onCol(!allOn);
            if (!allOn) {
              sel.addAll(items.map((e) => e.$1));
            } else {
              sel.removeAll(items.map((e) => e.$1));
            }
          },
        ),
        for (final item in items)
          CheckboxListTile(
            dense: true,
            visualDensity: VisualDensity.compact,
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            title: Text(item.$2, style: const TextStyle(fontSize: 13)),
            value: colOn && sel.contains(item.$1),
            onChanged: !colOn
                ? null
                : (v) {
                    if (v == true) {
                      sel.add(item.$1);
                    } else {
                      sel.remove(item.$1);
                    }
                  },
          ),
      ]);

  Widget _selectionPage(BuildContext context) {
    final theme = Theme.of(context);
    return StatefulBuilder(builder: (context, setD) {
      return ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Text(S.t('ob_pick_title'),
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(S.t('ob_pick_sub'),
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 12),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                child: _checkCol(
                    S.t('ob_col_day'), groupColor(1), _g1On, (v) {
                  _g1On = v;
                  setD(() {});
                }, [
                  ('wohlbefinden', S.t('b_wohlbefinden')),
                  ('schlaf', S.t('b_schlaf')),
                  ('medication', S.t('ob_medications')),
                  ('konzentration', S.t('ob_konzentration')),
                  ('unruhe', S.t('ob_innere_ruhe')),
                ], _g1Sel),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _checkCol(S.t('ob_col_mig'), groupColor(2), _g2On, (v) {
                  _g2On = v;
                  setD(() {});
                }, [
                  ('intensitaet', S.t('b_intensitaet')),
                  ('start', S.t('b_start')),
                  ('ende', S.t('b_ende')),
                  ('ausloeser', S.t('b_ausloeser')),
                  ('symptome', S.t('b_symptome')),
                  ('notizen', S.t('b_notizen')),
                ], _g2Sel),
              ),
            ]),
          ]);
    });
  }

  Widget _medPage(BuildContext context) {
    final theme = Theme.of(context);
    return StatefulBuilder(builder: (context, setD) {
      return ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Text(S.t('ob_med_setup_title'),
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(S.t('ob_med_setup_sub'),
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 12),
            CheckboxListTile(
                title: const Text('Elvanse'),
                subtitle: const Text('20–70 mg · mit Uhrzeit'),
                value: _elvanse,
                onChanged: (v) => setD(() => _elvanse = v ?? true)),
            CheckboxListTile(
                title: const Text('Medikinet'),
                subtitle: const Text('5–80 mg · mit Uhrzeit & Magen'),
                value: _medikinet,
                onChanged: (v) => setD(() => _medikinet = v ?? true)),
            for (final d in _newMeds)
              ListTile(
                leading: const Icon(Icons.medication_rounded),
                title: Text(d.label),
                subtitle: Text(d.inputs
                    .map((i) => i.type == 'choice'
                        ? i.options.join(' / ')
                        : S.t('notif_time'))
                    .join(' · ')),
                trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => setD(() => _newMeds.remove(d))),
              ),
            TextButton.icon(
                onPressed: () async {
                  await _addMedDialog();
                  setD(() {});
                },
                icon: const Icon(Icons.add),
                label: Text(S.t('ob_med_add'))),
          ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    final last = _index == _pageCount - 1;
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Align(
            alignment: Alignment.topRight,
            child: TextButton(
                onPressed: () => Navigator.pop(context, 'skip'),
                child: Text(S.t('ob_skip'))),
          ),
          Expanded(
            child: PageView(
              controller: _page,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (i) => setState(() => _index = i),
              children: [
                _selectionPage(context),
                if (_medsOn) _medPage(context),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Row(children: [
              TextButton(
                  onPressed: _index > 0 ? () => _go(_index - 1) : null,
                  child: Text(S.t('back'))),
              const Spacer(),
              FilledButton(
                onPressed: last ? _finishSelection : () => _go(_index + 1),
                child: Text(last ? S.t('ob_tutorial_go') : S.t('next')),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

// ============================================================================
// Spotlight-Tutorial (Punkt 10.3–10.7)
// ============================================================================

class _TutStep {
  final String title;
  final String body;
  final GlobalKey? target;

  /// 'manual' = Weiter-Knopf in der Karte · sonst Ereignis aus main.dart /
  /// review_screen.dart ('capture_open', 'review_open', 'capture_done',
  /// 'settings_open', 'settings_done', 'page:<slideId>').
  final String wait;

  /// 0 = kein Wisch-Hinweis · 1 = nach links (vorwärts) · -1 = nach rechts.
  final int swipe;

  /// Karte oben statt unten zeigen.
  final bool cardTop;

  /// false = Bildschirm NICHT abdunkeln (Arbeitsschritte wie Erfassung,
  /// Übersicht, Einstellungen – da soll man ungehindert weiterarbeiten).
  final bool dim;

  /// Karte bei der ersten Eingabe in der Erfassung selbst ausblenden.
  final bool hideOnInput;

  /// Karte per Wischen weglegen, ohne das Tutorial zu beenden.
  final bool dismissable;

  /// Wird die Erfassung ABGEBROCHEN (kein review_open), wird dieser
  /// Schritt übersprungen (Review-Karte auf dem Homescreen wäre falsch).
  final bool skipOnAbort;

  const _TutStep(this.title, this.body,
      {this.target,
      this.wait = 'manual',
      this.swipe = 0,
      this.cardTop = false,
      this.dim = true,
      this.hideOnInput = false,
      this.dismissable = false,
      this.skipOnAbort = false});
}

class TutorialController {
  TutorialController._();
  static final TutorialController instance = TutorialController._();

  OverlayEntry? _entry;
  List<_TutStep> _steps = const [];
  int _index = 0;
  bool active = false;
  BuildContext? _appContext;
  VoidCallback? _onDone;
  List<String> _slideIds = const ['home', 'graphs', 'quick', 'table'];

  List<_TutStep> _makeSteps(bool g1, bool g2) {
    // Nur Schritte für Slides, die es auch wirklich gibt – sonst wartet
    // das Tutorial ewig auf eine Seite, die ausgeblendet ist.
    final slides = _slideIds;
    return [
      if (g1 || g2) ...[
        _TutStep(
            S.t('ob_tut_capture'),
            g1
                ? S.t('ob_tut_capture_body')
                : S.t('ob_tut_capture_body_mig'),
            target: g1 ? kKeyTagBtn : kKeyMigBtn,
            wait: 'capture_open'),
        _TutStep(S.t('ob_tut_flow'), S.t('ob_tut_flow_body'),
            wait: 'review_open',
            cardTop: true,
            dim: false,
            hideOnInput: true,
            dismissable: true),
        _TutStep(S.t('ob_tut_review'), S.t('ob_tut_review_body'),
            wait: 'capture_done',
            cardTop: true,
            dim: false,
            dismissable: true,
            skipOnAbort: true),
      ],
      if (slides.contains('graphs')) ...[
        _TutStep(S.t('ob_tut_swipe_right'), '',
            wait: 'page:graphs', swipe: 1),
        _TutStep(S.t('ob_tut_graphs'), S.t('ob_tut_graphs_body')),
      ],
      if (slides.contains('quick')) ...[
        _TutStep(S.t('ob_tut_swipe_right2'), '',
            wait: 'page:quick', swipe: 1),
        _TutStep(S.t('ob_tut_quick'), S.t('ob_tut_quick_body')),
      ],
      if (slides.contains('table')) ...[
        _TutStep(S.t('ob_tut_swipe_right3'), '',
            wait: 'page:table', swipe: 1),
        _TutStep(S.t('ob_tut_table'), S.t('ob_tut_table_body'),
            target: kKeyExportFab),
      ],
      if (slides.length > 1)
        _TutStep(S.t('ob_tut_swipe_back'), '',
            wait: 'page:home', swipe: -1),
      _TutStep(S.t('ob_tut_settings'), S.t('ob_tut_settings_body'),
          target: kKeySettingsBtn, wait: 'settings_open'),
      _TutStep(S.t('ob_tut_settings'), S.t('ob_tut_settings_open'),
          wait: 'settings_done', cardTop: true, dim: false),
    ];
  }

  _TutStep get _step => _steps[_index];

  void start(BuildContext context, List<String> slideIds,
      {required bool g1, required bool g2, VoidCallback? onDone}) {
    if (active) return;
    active = true;
    _index = 0;
    _appContext = context; // Route-Context! (nie navKey.currentContext)
    _slideIds = List.of(slideIds);
    _steps = _makeSteps(g1, g2);
    _onDone = onDone;
    homePagerController?.addListener(_onPager);
    _show();
  }

  void next() => _advance();

  void _advance({bool silent = false}) {
    _entry?.remove();
    _entry = null;
    if (_index >= _steps.length - 1) {
      _finish();
      return;
    }
    _index++;
    if (!silent) _show();
    // Steht der neue Schritt auf eine Seite, die längst sichtbar ist
    // (schnell weitergewischt), sofort auswerten statt zu hängen:
    if (active && _step.wait.startsWith('page:')) _onPager();
  }

  /// Karte ausblenden, ohne den Schritt abzuschließen (wegwischbar /
  /// automatisch bei erster Eingabe).
  void hideCard() {
    _entry?.remove();
    _entry = null;
  }

  /// Feuert bei jeder Eingabe in der Erfassung (capture_flow.dart).
  void notifyInput() {
    if (!active || _entry == null) return;
    if (_step.hideOnInput) hideCard();
  }

  /// Verzögerter Schrittwechsel, der NUR feuert, wenn bis dahin noch
  /// derselbe Schritt aktiv ist. WICHTIG: Der PageController feuert
  /// während einer Wisch-Animation viele Male – ohne diese Bindung
  /// lief das Tutorial mehrere Schritte auf einmal weiter (darum
  /// „endete" es für dich stets am Verlauf).
  void _scheduleAdvance() {
    final forIndex = _index;
    Future.delayed(const Duration(milliseconds: 350), () {
      if (!active || _index != forIndex) return;
      _advance();
    });
  }

  void _onPager() {
    if (!active) return;
    final step = _step;
    if (!step.wait.startsWith('page:')) return;
    final want = step.wait.split(':')[1];
    final page = homePagerController?.page?.round() ?? 0;
    if (page < _slideIds.length && _slideIds[page] == want) {
      _scheduleAdvance();
    }
  }

  /// Wird aus main.dart / review_screen.dart aufgerufen.
  void notifyRoute(String event) {
    if (!active) return;
    final w = _step.wait;
    // Erfassung wurde ABGEBROCHEN, bevor die Übersicht kam: Flow-Schritt
    // stil beenden, Review-Schritt (skipOnAbort) ebenfalls überspringen.
    if (w == 'review_open' && event == 'capture_done') {
      _advance(silent: true);
      if (active && _step.skipOnAbort) _advance();
      return;
    }
    if (event != w) return;
    if (event == 'capture_open' || event == 'settings_open') {
      _advance();
    } else {
      _scheduleAdvance();
    }
  }

  Rect? _targetRect() {
    final key = _step.target;
    if (key == null) return null;
    final box = key.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return null;
    return box.localToGlobal(Offset.zero) & box.size;
  }

  void _show() {
    final ctx = _appContext;
    if (ctx == null) return;
    _entry = OverlayEntry(builder: (context) {
      return _SpotlightOverlay(
        rect: _targetRect(),
        title: _step.title,
        body: _step.body,
        manual: _step.wait == 'manual',
        swipe: _step.swipe,
        cardTop: _step.cardTop,
        dim: _step.dim,
        dismissable: _step.dismissable,
        onNext: next,
        onSkip: skip,
        onDismiss: hideCard,
      );
    });
    Overlay.of(ctx).insert(_entry!);
  }

  Future<void> skip() async {
    _entry?.remove();
    _entry = null;
    await _cleanup();
  }

  Future<void> _finish() async {
    await _cleanup();
    _onDone?.call();
  }

  Future<void> _cleanup() async {
    active = false;
    homePagerController?.removeListener(_onPager);
    _appContext = null;
    await PhaskaDb.instance.clearDemoData(); // Beispielwerte entfernen
  }
}
/// Abschluss-Screen (Punkt 10.8).
class FinishScreen extends StatelessWidget {
  const FinishScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(children: [
            const Spacer(),
            const Text('🎉🥳', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            Text(S.t('ob_finish_title'),
                style: theme.textTheme.headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Text(S.t('ob_finish_body'),
                style: theme.textTheme.bodyLarge?.copyWith(height: 1.5)),
            const SizedBox(height: 16),
            SelectableText('https://github.com/bernifasy/fasy',
                style: theme.textTheme.titleMedium
                    ?.copyWith(color: theme.colorScheme.primary)),
            const SizedBox(height: 4),
            SelectableText('bernhard.kiew@hotmail.de',
                style: theme.textTheme.titleMedium
                    ?.copyWith(color: theme.colorScheme.primary)),
            const SizedBox(height: 24),
            Text(S.t('ob_finish_tinfoil'),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant, height: 1.4)),
            const Spacer(),
            FilledButton(
                onPressed: () => Navigator.pop(context),
                child: Text(S.t('ob_finish_go'))),
            const SizedBox(height: 16),
          ]),
        ),
      ),
    );
  }
}

// ---------------- Overlay mit Loch ----------------

class _SpotlightOverlay extends StatelessWidget {
  final Rect? rect;
  final String title, body;
  final bool manual, cardTop, dim, dismissable;
  final int swipe;
  final VoidCallback onNext, onSkip, onDismiss;

  const _SpotlightOverlay({
    required this.rect,
    required this.title,
    required this.body,
    required this.manual,
    required this.cardTop,
    required this.dim,
    required this.dismissable,
    required this.swipe,
    required this.onNext,
    required this.onSkip,
    required this.onDismiss,
  });

  /// Diese Flächen fangen Taps AUSserhalb des Lochs ab.
  Widget _blocker(Rect r) => Positioned.fromRect(
      rect: r,
      child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {},
          child: Container()));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);
    final r = rect; // lokale Kopie → Promotion funktioniert

    Widget card = Card(
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(
                    child: Text(title,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold))),
                TextButton(onPressed: onSkip, child: Text(S.t('ob_skip'))),
              ]),
              if (swipe != 0)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: _SwipeHint(left: swipe == 1),
                ),
              if (body.isNotEmpty)
                Text(body, style: theme.textTheme.bodyMedium),
              if (manual) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton(
                      onPressed: onNext, child: Text(S.t('next'))),
                ),
              ],
              if (dismissable)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Center(
                    child: Text('zum Ausblenden wegwischen',
                        style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.outline)),
                  ),
                ),
            ]),
      ),
    );
    if (dismissable) {
      // Wegwischbar: Tutorial läuft im Hintergrund weiter (onDismiss),
      // es wird NICHT beendet (das wäre onSkip).
      card = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanEnd: (_) => onDismiss(),
        child: card,
      );
    }

    return Material(
      type: MaterialType.transparency,
      child: Stack(children: [
        // 1) Abdunklung nur, wenn der Schritt es will – UND als reine Deko
        //    (IgnorePointer!), sonst schluckt sie alle Touches.
        if (dim)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                  painter:
                      _HolePainter(r, Colors.black.withValues(alpha: .55))),
            ),
          ),
        // 2) Touch-Sperre nur RUND UM das Loch (und UNTER der Karte).
        if (r != null) ...[
          _blocker(Rect.fromLTWH(
              0, 0, size.width, (r.top - 6).clamp(0.0, size.height))),
          _blocker(Rect.fromLTWH(0, r.bottom + 6, size.width,
              (size.height - r.bottom - 6).clamp(0.0, size.height))),
          _blocker(Rect.fromLTWH(0, r.top - 6,
              (r.left - 6).clamp(0.0, size.width), r.height + 12)),
          _blocker(Rect.fromLTWH(r.right + 6, r.top - 6,
              (size.width - r.right - 6).clamp(0.0, size.width),
              r.height + 12)),
        ],
        // 3) Rahmen um das Ziel (Deko).
        if (r != null)
          Positioned.fromRect(
            rect: r.inflate(6),
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  border:
                      Border.all(color: theme.colorScheme.primary, width: 3),
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ),
        // 4) Karte ganz OBEN → immer erreichbar.
        Positioned(
          left: 16,
          right: 16,
          top: cardTop ? MediaQuery.paddingOf(context).top + 24 : null,
          bottom: cardTop ? null : 24,
          child: card,
        ),
      ]),
    );
  }
}

class _HolePainter extends CustomPainter {
  final Rect? hole;
  final Color color;
  _HolePainter(this.hole, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()..addRect(Offset.zero & size);
    final h = hole;
    if (h != null) {
      path.addRRect(
          RRect.fromRectAndRadius(h.inflate(6), const Radius.circular(24)));
      path.fillType = PathFillType.evenOdd;
    }
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_HolePainter old) =>
      old.hole != hole || old.color != color;
}

/// Finger, der den Wisch in die gewünschte Richtung demonstriert.
class _SwipeHint extends StatefulWidget {
  final bool left;
  const _SwipeHint({required this.left});

  @override
  State<_SwipeHint> createState() => _SwipeHintState();
}

class _SwipeHintState extends State<_SwipeHint>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1400))
    ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final fade = _c.value < .15
            ? _c.value / .15
            : (_c.value > .8 ? (1 - _c.value) / .2 : 1.0);
        final t = Curves.easeInOut.transform(_c.value);
        final dir = widget.left ? -1.0 : 1.0;
        return SizedBox(
          height: 84,
          child: Stack(alignment: Alignment.center, children: [
            // dezente Spur, auf der der Finger entlangfährt
            Container(
              width: 190,
              height: 44,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: .55),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    for (var i = 0; i < 3; i++)
                      Icon(Icons.circle,
                          size: 6,
                          color: theme.colorScheme.outline
                              .withValues(alpha: .5)),
                  ]),
            ),
            Transform.translate(
              offset: Offset(dir * t * 80, 0),
              child: Opacity(
                opacity: fade.clamp(0.0, 1.0),
                child: Text(widget.left ? '👈' : '👉',
                    style: const TextStyle(fontSize: 38)),
              ),
            ),
          ]),
        );
      },
    );
  }
}