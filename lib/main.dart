import 'dart:async';

import 'package:flutter/material.dart';

import 'capture/capture_flow.dart';
import 'db.dart';
import 'edit_schema_screen.dart';
import 'graphs.dart';
import 'models.dart';
import 'onboarding.dart'; // NEU (Punkt 7)
import 'painters.dart';
import 'quick_capture.dart';
import 'quick_table.dart';
import 'table_screen.dart';
import 'widget_bridge.dart';

final navKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final (c1, c2) = await PhaskaDb.instance.loadColors();
  AppColors.group1.value = Color(c1);
  AppColors.group2.value = Color(c2);
  AppColors.quick.value =
      Color(await PhaskaDb.instance.loadQuickColor()); // NEU (Punkt 1)
  AppColors.themeMode.value = await PhaskaDb.instance.loadThemeMode();
  AppDeco.items.value = await PhaskaDb.instance.loadHomeDecos();
  runApp(const FasyApp());
}

class FasyApp extends StatelessWidget {
  const FasyApp({super.key});

  ThemeData _theme(Brightness b) => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.group1.value, brightness: b),
      );

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        AppColors.group1,
        AppColors.group2,
        AppColors.quick, // NEU (Punkt 1)
        AppColors.themeMode,
      ]),
      builder: (context, _) => MaterialApp(
        title: 'fasy',
        debugShowCheckedModeBanner: false,
        navigatorKey: navKey,
        theme: _theme(Brightness.light),
        darkTheme: _theme(Brightness.dark),
        themeMode: switch (AppColors.themeMode.value) {
          'light' => ThemeMode.light,
          'dark' => ThemeMode.dark,
          _ => ThemeMode.system,
        },
        home: const HomePager(),
      ),
    );
  }
}

class HomePager extends StatefulWidget {
  const HomePager({super.key});

  @override
  State<HomePager> createState() => _HomePagerState();
}

class _HomePagerState extends State<HomePager> with WidgetsBindingObserver {
  final _controller = PageController();
  int _page = 0;
  Timer? _midnight; // NEU (Punkt 3)

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // NEU (Punkt 3)
    Repo.changes.addListener(_pushWidgets);
    updateHomeWidgets();
    initWidgetLinks(_onWidgetUri);
    _scheduleMidnightRefresh(); // NEU (Punkt 3)
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _maybeWelcome()); // NEU (Punkt 7)
  }

  void _pushWidgets() => updateHomeWidgets();

  // ---------- NEU: Mitternachts-Refresh der Widgets (Punkt 3) ----------

  /// Timer auf 00:01 Uhr des nächsten Tages; danach neu geplant.
  /// Repo.bump() frischt dabei sowohl die App (Kalender!) als auch –
  /// über den Listener oben – die Homescreen-Widgets auf.
  void _scheduleMidnightRefresh() {
    _midnight?.cancel();
    final now = DateTime.now();
    final next = DateTime(now.year, now.month, now.day + 1, 0, 1);
    _midnight = Timer(next.difference(now), () {
      Repo.bump();
      _scheduleMidnightRefresh();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Datum könnte im Hintergrund gewechselt haben.
      Repo.bump();
      _scheduleMidnightRefresh();
    }
  }

  // ---------- NEU: Willkommensdialog beim ersten Start (Punkt 7) ----------

  Future<void> _maybeWelcome() async {
    if (await PhaskaDb.instance.isOnboarded()) return;
    final ctx = navKey.currentContext;
    if (ctx == null || !mounted || !ctx.mounted) return;
    // ignore: use_build_context_synchronously
    final intro = await showDialog<bool>(
        context: ctx,
        barrierDismissible: false,
        builder: (_) => const WelcomeDialog());
    await PhaskaDb.instance.markOnboarded();
    if (intro == true) {
      await navKey.currentState
          ?.push(MaterialPageRoute(builder: (_) => const IntroScreen()));
    }
  }

  Future<void> _onWidgetUri(Uri? uri) async {
    if (uri == null) return;
    final nav = navKey.currentState;
    if (nav == null) return;
    if (uri.host == 'g1') {
      nav.push(MaterialPageRoute(
          builder: (_) => const CaptureFlowScreen(startGroup: 1)));
    } else if (uri.host == 'g2') {
      nav.push(MaterialPageRoute(
          builder: (_) => const CaptureFlowScreen(startGroup: 2)));
    } else if (uri.host == 'quick') {
      await _openQuickPicker(nav.context);
    }
  }

  @override
  void dispose() {
    _midnight?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    Repo.changes.removeListener(_pushWidgets);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _page == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _controller.animateToPage(0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic);
        }
      },
      child: PageView(
        controller: _controller,
        onPageChanged: (i) => setState(() => _page = i),
        children: const [
          HomeScreen(),
          GraphsScreen(),
          QuickTableScreen(),
          TableScreen(),
        ],
      ),
    );
  }
}

// ---------------- Homescreen ----------------

const presetColors = <int>{
  0xFF3A8330, 0xFF43A047, 0xFF00897B, 0xFF1E88E5, 0xFF4FC3F7,
  0xFF5C6BC0, 0xFF7E57C2, 0xFF9575CD, 0xFFAB47BC, 0xFFEC407A,
  0xFFEF5350, 0xFFFB8C00,
};

/// Auswahl der freigegebenen Einzelerfassungs-Werte (Punkt 2).
Future<void> _openQuickPicker(BuildContext context) async {
  final defs = await PhaskaDb.instance.fieldDefs();
  final defsById = {for (final d in defs) d.id: d};
  final available = {for (final s in availableGraphSources(defs)) s.key};
  final keys =
      (await PhaskaDb.instance.quickKeys()).where(available.contains).toList();
  if (!context.mounted) return;
  if (keys.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
            'Noch keine Werte für die Einzelerfassung freigegeben – im Menü '
            '„Anpassen" (Stift-Symbol) pro Datenpunkt „Einzelerfassung '
            'erlauben" aktivieren.')));
    return;
  }
  final agg = await PhaskaDb.instance.quickDayAgg();
  final today = dayKeyOf(DateTime.now());
  if (!context.mounted) return;
  final quickColor = AppColors.quick.value; // NEU (Punkt 1)
  final key = await showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    builder: (ctx) => SafeArea(
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text('Welchen Wert erfassen?',
                style: Theme.of(ctx).textTheme.titleMedium),
          ),
          for (final k in keys)
            ListTile(
              leading: CircleAvatar(
                  backgroundColor: quickColor, // NEU (Punkt 1)
                  child: const Icon(Icons.speed_rounded,
                      color: Colors.white, size: 20)),
              title: Text(keyLabel(k, defsById)),
              subtitle: agg[today]?[k] == null
                  ? null
                  : Text(
                      'Heute: ${agg[today]![k]!.n}× · Ø ${fmtDe(agg[today]![k]!.avg)}'),
              onTap: () => Navigator.pop(ctx, k),
            ),
          const SizedBox(height: 8),
        ]),
      ),
    ),
  );
  if (key != null && context.mounted) {
    await Navigator.push(context,
        MaterialPageRoute(builder: (_) => QuickCaptureScreen(sourceKey: key)));
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _start(BuildContext context, int group) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => CaptureFlowScreen(startGroup: group)));
  }

  Future<void> _cycleThemeMode() async {
    final next = switch (AppColors.themeMode.value) {
      'system' => 'light',
      'light' => 'dark',
      _ => 'system',
    };
    AppColors.themeMode.value = next;
    await PhaskaDb.instance.saveThemeMode(next);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
      child: Stack(children: [
        // Konfigurierbare Deko-Pflanzen
        const _DecoLayer(),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(children: [
                  GestureDetector(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const AboutScreen())),
                    child: const _Wordmark(),
                  ),
                  const Spacer(),
                  IconButton(
                      tooltip: 'Darstellung (System/Hell/Dunkel)',
                      icon: ValueListenableBuilder(
                        valueListenable: AppColors.themeMode,
                        builder: (_, mode, _) => Icon(switch (mode) {
                          'light' => Icons.light_mode_outlined,
                          'dark' => Icons.dark_mode_outlined,
                          _ => Icons.brightness_auto_outlined,
                        }),
                      ),
                      onPressed: _cycleThemeMode),
                  IconButton(
                      tooltip: 'Farbschema & Deko',
                      icon: const Icon(Icons.palette_outlined),
                      onPressed: () => _openColorSheet(context)),
                  IconButton(
                      tooltip: 'Datenpunkte anpassen',
                      icon: const Icon(Icons.tune_rounded),
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const EditSchemaScreen()))),
                ]),
                const SizedBox(height: 12),
                const MiniCalendar(),
                const Spacer(),
                _HomeButton(
                  color: groupColor(1),
                  icon: Icons.wb_sunny_rounded,
                  title: 'Tag erfassen',
                  subtitle: 'Wohlbefinden, Schlaf, Medikation',
                  onTap: () => _start(context, 1),
                ),
                const SizedBox(height: 16),
                _HomeButton(
                  color: groupColor(2),
                  icon: Icons.bolt_rounded,
                  title: 'Migräne erfassen',
                  subtitle: 'Intensität, Zeiten, Auslöser',
                  onTap: () => _start(context, 2),
                ),
                const SizedBox(height: 16),
                _HomeButton(
                  color: AppColors.quick.value, // NEU (Punkt 1)
                  icon: Icons.speed_rounded,
                  title: 'Einzelwert erfassen',
                  subtitle: 'Schnellmessung ohne Tageserfassung',
                  onTap: () => _openQuickPicker(context),
                ),
                const Spacer(),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.swipe_left_alt,
                      size: 18, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Text('Nach links wischen: Verlauf, Einzelwerte & Tabelle',
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant)),
                ]),
              ]),
        ),
      ]),
    ));
  }
}

/// Kleine Wortmarke oben links.
class _Wordmark extends StatelessWidget {
  const _Wordmark();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: groupColor(1), width: 2),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text('fasy',
            style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800, letterSpacing: 1.5)),
        const SizedBox(width: 8),
        Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
                color: groupColor(2), shape: BoxShape.circle)),
      ]),
    );
  }
}

// ---------------- Über-Screen (Punkt 4) ----------------

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Über fasy')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child:
              Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const _Wordmark(),
            const SizedBox(height: 32),
            Text(
                'vibecoded by kimi k3 inside tinfoil.sh\n'
                'with instructions by Bernhard Haska.',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            SelectableText(
                'visit www.platzhalter.com to see the source code, changes and releases',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.primary)),
          ]),
        ),
      ),
    );
  }
}

// ---------------- Homescreen-Deko (Punkt 3) ----------------

class _DecoLayer extends StatelessWidget {
  const _DecoLayer();

  static const _sizes = {
    's': Size(100, 155),
    'm': Size(150, 230),
    'l': Size(200, 300),
  };

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<HomeDeco>>(
      valueListenable: AppDeco.items,
      builder: (_, decos, _) => Stack(children: [
        for (var i = 0; i < decos.length; i++) _place(decos[i], i),
      ]),
    );
  }

  Widget _place(HomeDeco d, int i) {
    final size = _sizes[d.size] ?? _sizes['m']!;
    final color = i.isEven ? groupColor(1) : groupColor(2);
    final isBottom = d.position.startsWith('bottom');
    final paint = IgnorePointer(
      child: Opacity(
        opacity: .14,
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.rotationZ(isBottom ? 3.6 : 0),
          child: CustomPaint(
              size: size,
              painter: PlantPainter(theme: d.theme, color: color)),
        ),
      ),
    );
    return switch (d.position) {
      'topLeft' => Positioned(top: 70, left: -30, child: paint),
      'topCenter' =>
        Positioned(top: 60, left: 0, right: 0, child: Center(child: paint)),
      'topRight' => Positioned(top: 70, right: -30, child: paint),
      'bottomLeft' => Positioned(bottom: -10, left: -40, child: paint),
      'bottomCenter' => Positioned(
          bottom: -10, left: 0, right: 0, child: Center(child: paint)),
      _ => Positioned(bottom: -10, right: -40, child: paint),
    };
  }
}

const decoPositionLabels = {
  'topLeft': 'Oben links',
  'topCenter': 'Oben Mitte',
  'topRight': 'Oben rechts',
  'bottomLeft': 'Unten links',
  'bottomCenter': 'Unten Mitte',
  'bottomRight': 'Unten rechts',
};
const decoSizeLabels = {'s': 'klein', 'm': 'mittel', 'l': 'groß'};

Future<void> saveDecos() =>
    PhaskaDb.instance.saveHomeDecos(AppDeco.items.value);

Future<void> decoAddDialog(BuildContext context) async {
  var decoTheme = 'urwald';
  var pos = 'topRight';
  var size = 'm';
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setD) => AlertDialog(
        title: const Text('Deko hinzufügen'),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            DropdownButtonFormField<String>(
              initialValue: decoTheme,
              decoration: const InputDecoration(labelText: 'Pflanze'),
              items: [
                for (final e in plantThemes.entries)
                  if (e.key != 'none')
                    DropdownMenuItem(value: e.key, child: Text(e.value)),
              ],
              onChanged: (v) => setD(() => decoTheme = v!),
            ),
            const SizedBox(height: 16),
            Align(
                alignment: Alignment.centerLeft,
                child: Text('Position',
                    style: Theme.of(ctx).textTheme.labelLarge)),
            const SizedBox(height: 6),
            Wrap(spacing: 6, runSpacing: 6, children: [
              for (final e in decoPositionLabels.entries)
                ChoiceChip(
                    label: Text(e.value),
                    selected: pos == e.key,
                    onSelected: (_) => setD(() => pos = e.key)),
            ]),
            const SizedBox(height: 16),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 's', label: Text('klein')),
                ButtonSegment(value: 'm', label: Text('mittel')),
                ButtonSegment(value: 'l', label: Text('groß')),
              ],
              selected: {size},
              onSelectionChanged: (s) => setD(() => size = s.first),
            ),
          ]),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Abbrechen')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Hinzufügen')),
        ],
      ),
    ),
  );
  if (ok == true) {
    AppDeco.items.value = [
      ...AppDeco.items.value,
      HomeDeco(theme: decoTheme, position: pos, size: size)
    ];
    await saveDecos();
  }
}

/// NEU async (Punkt 1): lädt vorher das Einzelerfassungs-Deko-Thema.
Future<void> _openColorSheet(BuildContext context) async {
  var quickTheme = await PhaskaDb.instance.loadQuickTheme();
  if (!context.mounted) return;
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setD) {
        Widget section(
                String label, int group, ValueNotifier<Color> current) =>
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: Theme.of(ctx).textTheme.titleSmall),
              const SizedBox(height: 10),
              Wrap(spacing: 10, runSpacing: 10, children: [
                for (final c in presetColors)
                  GestureDetector(
                    onTap: () async {
                      current.value = Color(c);
                      setD(() {});
                      await PhaskaDb.instance.saveColor(group, c);
                      await updateHomeWidgets(); // NEU (Punkt 6)
                    },
                    child: CircleAvatar(
                      backgroundColor: Color(c),
                      radius: 20,
                      child: current.value.toARGB32() == c
                          ? const Icon(Icons.check, color: Colors.white)
                          : null,
                    ),
                  ),
              ]),
            ]);
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  section('Tag', 1, AppColors.group1),
                  const SizedBox(height: 20),
                  section('Migräne', 2, AppColors.group2),
                  const SizedBox(height: 20),
                  // NEU (Punkt 1)
                  section('Einzelerfassung', 3, AppColors.quick),
                  const SizedBox(height: 16),
                  TextButton.icon(
                    icon: const Icon(Icons.restart_alt, size: 18),
                    label: const Text('Farben zurücksetzen'),
                    onPressed: () async {
                      AppColors.group1.value =
                          const Color(kDefaultGroup1Color);
                      AppColors.group2.value =
                          const Color(kDefaultGroup2Color);
                      AppColors.quick.value =
                          const Color(kDefaultQuickColor); // NEU
                      setD(() {});
                      await PhaskaDb.instance.saveColor(1, kDefaultGroup1Color);
                      await PhaskaDb.instance.saveColor(2, kDefaultGroup2Color);
                      await PhaskaDb.instance.saveColor(3, kDefaultQuickColor);
                      await updateHomeWidgets();
                    },
                  ),
                  const Divider(height: 28),
                  Row(children: [
                    Text('Deko', style: Theme.of(ctx).textTheme.titleSmall),
                    const Spacer(),
                    TextButton.icon(
                        onPressed: () => decoAddDialog(ctx),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Pflanze')),
                  ]),
                  const SizedBox(height: 6),
                  ValueListenableBuilder<List<HomeDeco>>(
                    valueListenable: AppDeco.items,
                    builder: (_, decos, _) => Column(children: [
                      if (decos.isEmpty)
                        Text('Keine Deko aktiv.',
                            style: Theme.of(ctx).textTheme.bodySmall),
                      for (var i = 0; i < decos.length; i++)
                        ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading:
                              const Icon(Icons.eco_outlined, size: 20),
                          title: Text(
                              plantThemes[decos[i].theme] ?? decos[i].theme),
                          subtitle: Text(
                              '${decoPositionLabels[decos[i].position]} · '
                              '${decoSizeLabels[decos[i].size]}'),
                          trailing: IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  size: 20),
                              tooltip: 'Deko entfernen',
                              onPressed: () async {
                                AppDeco.items.value =
                                    List<HomeDeco>.from(AppDeco.items.value)
                                      ..removeAt(i);
                                await saveDecos();
                              }),
                        ),
                    ]),
                  ),
                  // NEU (Punkt 1): Deko der Einzelerfassungs-Slides
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: quickTheme,
                    decoration: const InputDecoration(
                        labelText: 'Deko der Einzelerfassungs-Slides'),
                    items: [
                      for (final e in plantThemes.entries)
                        DropdownMenuItem(
                            value: e.key, child: Text(e.value)),
                    ],
                    onChanged: (v) async {
                      setD(() => quickTheme = v!);
                      await PhaskaDb.instance.saveQuickTheme(v!);
                    },
                  ),
                ]),
          ),
        );
      },
    ),
  );
}

// ---------------- Mini-Kalender ----------------

const _monthNames = [
  'Januar', 'Februar', 'März', 'April', 'Mai', 'Juni', 'Juli',
  'August', 'September', 'Oktober', 'November', 'Dezember',
];

class MiniCalendar extends StatefulWidget {
  const MiniCalendar({super.key});

  @override
  State<MiniCalendar> createState() => _MiniCalendarState();
}

class _MiniCalendarState extends State<MiniCalendar> {
  late DateTime _shown = DateTime.now();
  Map<int, int> _mask = {}; // Tag -> Bitmaske (1=Tag, 2=Migränetag)

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
    final entries = await PhaskaDb.instance.all();
    final defs = await PhaskaDb.instance.fieldDefs();
    final mask = <int, int>{};
    for (final e in entries) {
      if (e.createdAt.year != _shown.year ||
          e.createdAt.month != _shown.month) {
        continue;
      }
      var m2 = 0;
      var g1 = e.hasG1;
      for (final d in defs) {
        final v = e.custom[d.id];
        final filled = v != null && (v is! String || v.isNotEmpty);
        if (filled && d.group == 1) g1 = true;
      }
      // Migräne nur markieren, wenn es ein Migränetag ist (Intensität > 2).
      if (g1) m2 |= 1;
      if (e.migraeneTag == 'ja') m2 |= 2;
      if (m2 > 0) mask[e.createdAt.day] = (mask[e.createdAt.day] ?? 0) | m2;
    }
    if (mounted) setState(() => _mask = mask);
  }

  void _shift(int delta) {
    setState(() => _shown = DateTime(_shown.year, _shown.month + delta, 1));
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final first = DateTime(_shown.year, _shown.month, 1);
    final offset = first.weekday - 1; // Montag = 0
    final days = DateTime(_shown.year, _shown.month + 1, 0).day;
    final today = DateTime.now();
    final g1 = groupColor(1), g2 = groupColor(2);

    return Card(
      elevation: 0,
      color:
          theme.colorScheme.surfaceContainerHighest.withValues(alpha: .4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          Row(children: [
            IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.chevron_left),
                onPressed: () => _shift(-1)),
            Expanded(
                child: Text(
                    '${_monthNames[_shown.month - 1]} ${_shown.year}',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold))),
            IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.chevron_right),
                onPressed: () => _shift(1)),
          ]),
          Row(children: [
            for (final w in ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'])
              Expanded(
                  child: Text(w,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant))),
          ]),
          const SizedBox(height: 4),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7, childAspectRatio: 1),
            itemCount: offset + days,
            itemBuilder: (context, i) {
              if (i < offset) return const SizedBox.shrink();
              final day = i - offset + 1;
              final m = _mask[day] ?? 0;
              final isToday = today.year == _shown.year &&
                  today.month == _shown.month &&
                  today.day == day;
              BoxDecoration? deco;
              TextStyle? style;
              if (m == 3) {
                deco = BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        stops: const [.5, .5],
                        colors: [g1, g2]));
                style =
                    const TextStyle(color: Colors.white, fontSize: 12);
              } else if (m != 0) {
                deco = BoxDecoration(
                    shape: BoxShape.circle,
                    color: m == 1 ? g1 : g2);
                style =
                    const TextStyle(color: Colors.white, fontSize: 12);
              }
              if (isToday) {
                deco = (deco ??
                        const BoxDecoration(shape: BoxShape.circle))
                    .copyWith(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: theme.colorScheme.primary, width: 2));
              }
              return Center(
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: deco,
                  alignment: Alignment.center,
                  child: Text('$day',
                      style: style ??
                          theme.textTheme.bodySmall
                              ?.copyWith(fontSize: 12)),
                ),
              );
            },
          ),
        ]),
      ),
    );
  }
}

// ---------------- Buttons ----------------

class _HomeButton extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _HomeButton({
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: color.withValues(alpha: .14),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(children: [
            CircleAvatar(
                radius: 26,
                backgroundColor: color,
                child: Icon(icon, color: Colors.white)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: theme.textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    Text(subtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant)),
                  ]),
            ),
            const Icon(Icons.chevron_right),
          ]),
        ),
      ),
    );
  }
}