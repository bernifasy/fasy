import 'dart:async';

import 'package:flutter/material.dart';

import 'capture/capture_flow.dart';
import 'capture/steps.dart';
import 'db.dart';
import 'graphs.dart';
import 'l10n.dart';
import 'models.dart';
import 'notifications.dart';
import 'onboarding.dart';
import 'painters.dart';
import 'quick_capture.dart';
import 'quick_table.dart';
import 'settings_screen.dart';
import 'table_screen.dart';
import 'widget_bridge.dart';
import 'widgets.dart';

final navKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final (c1, c2) = await PhaskaDb.instance.loadColors();
  AppColors.group1.value = Color(c1);
  AppColors.group2.value = Color(c2);
  AppColors.quick.value = Color(await PhaskaDb.instance.loadQuickColor());
  AppColors.attackEnd.value =
      Color(await PhaskaDb.instance.loadAttackEndColor()); // Punkt 7
  AppColors.themeMode.value = await PhaskaDb.instance.loadThemeMode();
  S.code.value = await PhaskaDb.instance.loadLanguage(); // Punkt 8.4
  AppDeco.items.value = await PhaskaDb.instance.loadHomeDecos();
  await PhaskaDb.instance.clearDemoData(); // Tutorial-Reste (Sicherheitsnetz)
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
        AppColors.quick,
        AppColors.attackEnd,
        AppColors.themeMode,
        S.code, // Sprachwechsel → kompletter Neuaufbau (Punkt 8.4)
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
  PageController? _controller;
  int _page = 0;
  int _cols = 1;
  List<String> _ids = const ['home', 'graphs', 'quick', 'table'];
  Timer? _midnight;

  int get _homeIndex {
    final i = _ids.indexOf('home');
    return i < 0 ? 0 : i;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Repo.changes.addListener(_onRepoChange);
    updateHomeWidgets();
    initWidgetLinks(_onWidgetUri);
    _scheduleMidnightRefresh();
    _loadSlides();
    Notifications.onTap = _onNotificationTap; // Punkt 8.5
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _maybeWelcome()); // Punkt 6/10
  }

  void _onRepoChange() {
    updateHomeWidgets();
    unawaited(Notifications.rescheduleAll());
    _loadSlides();
  }

  Future<void> _loadSlides() async {
    final cfgs = await PhaskaDb.instance.loadSlides();
    if (!mounted) return;
    setState(() {
      // Punkt 8.3: nur SICHTBARE Slides anzeigen (Fehler 5: sofort wirksam,
      // weil saveSlides() Repo.bump() → _onRepoChange() → _loadSlides()).
      _ids = [for (final c in cfgs) if (c.visible) c.id];
      if (_ids.isEmpty) _ids = const ['home']; // home ist nie versteckt
      if (_page >= _ids.length) _page = _ids.length - 1;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final c = homePagerController;
      if (c != null && c.hasClients && c.page?.round() != _page) {
        c.jumpToPage(_page);
      }
    });
  }

  /// Fehler 2: [force] = der Schulungs-Knopf startet IMMER beim
  /// Willkommensdialog (sonst nur beim allerersten App-Start).
  Future<void> _maybeWelcome({bool force = false}) async {
    if (!force && await PhaskaDb.instance.isOnboarded()) return;
    if (!mounted) return;
    final intro = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => const WelcomeDialog());
    await PhaskaDb.instance.markOnboarded();
    if (!mounted) return;
    if (intro == true) {
      await _startOnboarding();
    } else {
      // Punkt 10.1: Pfeil-Highlight – Context des Pagers (Overlay ist Ahn!).
      unawaited(showOnboardingPointer(context));
    }
  }

  // ---------- Punkt 8.5: Tap auf Benachrichtigung → Erfassung ----------

  void _onNotificationTap(String payload) {
    if (!payload.startsWith('capture:')) return;
    final g = payload.endsWith('g2') ? 2 : 1;
    navKey.currentState?.push(MaterialPageRoute(
        builder: (_) => CaptureFlowScreen(startGroup: g)));
  }

  // ---------- Mitternachts-Refresh ----------

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
      Repo.bump();
      _scheduleMidnightRefresh();
    }
  }

  // ---------- Onboarding (Punkt 6 & 10) ----------

  Future<void> _startOnboarding() async {
    final result = await navKey.currentState?.push<Object?>(
        MaterialPageRoute(builder: (_) => const OnboardingScreen()));
    if (result != true || !mounted) return;
    final g1 = await PhaskaDb.instance.groupEnabled(1);
    final g2 = await PhaskaDb.instance.groupEnabled(2);
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // FIX: State-Context statt Navigator-Context (vorher: Overlay.of crashte).
      TutorialController.instance.start(context, _ids, g1: g1, g2: g2,
          onDone: () {
        navKey.currentState?.push(
            MaterialPageRoute(builder: (_) => const FinishScreen()));
      });
    });
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
    Repo.changes.removeListener(_onRepoChange);
    _controller?.dispose();
    super.dispose();
  }

  // ---------- Punkt 12: mehrere Slides nebeneinander ----------

  void _ensureController(int cols) {
    if (_cols == cols && _controller != null) return;
    final old = _controller;
    _controller = PageController(
      viewportFraction: 1 / cols,
      initialPage: _page.clamp(0, _ids.length - 1),
    );
    homePagerController = _controller;
    _cols = cols;
    old?.dispose();
  }

  Widget _screenFor(String id) => switch (id) {
        'graphs' => const GraphsScreen(),
        'quick' => const QuickTableScreen(),
        'table' => const TableScreen(),
        _ => const HomeScreen(),
      };

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, bc) {
      // Portrait → 1 Slide; breite Bildschirme → mehrere nebeneinander.
      final cols = R.columnsFor(bc.maxWidth);
      _ensureController(cols);
      return PopScope(
        canPop: _page == _homeIndex,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) {
            _controller!.animateToPage(_homeIndex,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic);
          }
        },
        child: PageView.builder(
          controller: _controller,
          itemCount: _ids.length,
          onPageChanged: (i) => setState(() => _page = i),
          itemBuilder: (context, i) => _screenFor(_ids[i]),
        ),
      );
    });
  }
}

// ---------------- Homescreen ----------------

Future<void> _openQuickPicker(BuildContext context) async {
  final defs = await PhaskaDb.instance.fieldDefs();
  final defsById = {for (final d in defs) d.id: d};
  final available = {for (final s in availableGraphSources(defs)) s.key};
  final keys =
      (await PhaskaDb.instance.quickKeys()).where(available.contains).toList();
  if (!context.mounted) return;
  if (keys.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.t('quick_none_hint'))));
    return;
  }
  final agg = await PhaskaDb.instance.quickDayAgg();
  final today = dayKeyOf(DateTime.now());
  if (!context.mounted) return;
  final quickColor = AppColors.quick.value;
  final key = await showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    builder: (ctx) => SafeArea(
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(S.t('quick_picker_title'),
                style: Theme.of(ctx).textTheme.titleMedium),
          ),
          for (final k in keys)
            ListTile(
              leading: CircleAvatar(
                  backgroundColor: quickColor,
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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _g1On = true;
  bool _g2On = true;
  PhaskaEntry? _runningMigraine; // Punkt 7

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
    final g1 = await PhaskaDb.instance.groupEnabled(1);
    final g2 = await PhaskaDb.instance.groupEnabled(2);
    final running = g2 ? await PhaskaDb.instance.runningMigraine() : null;
    if (mounted) {
      setState(() {
        _g1On = g1;
        _g2On = g2;
        _runningMigraine = running;
      });
    }
  }

  Future<void> _start(int group) async {
    TutorialController.instance.notifyRoute('capture_open');
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => CaptureFlowScreen(startGroup: group)));
    TutorialController.instance.notifyRoute('capture_done');
  }

  /// Punkt 7: offene Attacke beenden → Flow ab „Ende der Migräne", Rest
  /// durchlaufbar, danach Übersicht.
  Future<void> _endAttack(PhaskaEntry e) async {
    final steps = await stepsForAll();
    final idx = steps.indexWhere((s) => s.id == 'ende');
    if (!mounted) return;
    // Fehler 7: „jetzt" vorbelegen – NUR hier. Im normalen Migräne-Flow
    // bleibt das Ende leer (Vorbelegung in steps.dart wurde entfernt).
    e.migraeneEnde ??= formatClock(TimeOfDay.now());
    TutorialController.instance.notifyRoute('capture_open');
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => CaptureFlowScreen(
                editMode: true,
                entry: e,
                startIndex: idx < 0 ? 0 : idx,
                editOpensReview: true)));
    TutorialController.instance.notifyRoute('capture_done');
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

  Future<void> _openSettings() async {
    TutorialController.instance.notifyRoute('settings_open');
    await Navigator.push(context,
        MaterialPageRoute(builder: (_) => const SettingsScreen()));
    TutorialController.instance.notifyRoute('settings_done');
  }

  Future<void> _openOnboarding() async {
    // Fehler 2: Tutorial-Knopf → komplette Einführung AB Willkommensdialog.
    final pager = context.findAncestorStateOfType<_HomePagerState>();
    await pager?._maybeWelcome(force: true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final running = _runningMigraine;

    final header = Row(children: [
      GestureDetector(
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AboutScreen())),
        child: const _Wordmark(),
      ),
      const Spacer(),
      IconButton(
          key: kKeyOnboardingBtn, // Punkt 6 (und Pfeil-Highlight 10.1)
          tooltip: S.t('tooltip_onboarding'),
          icon: const Icon(Icons.school_outlined),
          onPressed: _openOnboarding),
      IconButton(
          tooltip: S.t('tooltip_theme'),
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
          key: kKeySettingsBtn, // Punkt 8: der eine Einstellungs-Knopf
          tooltip: S.t('tooltip_settings'),
          icon: const Icon(Icons.settings_rounded),
          onPressed: _openSettings),
    ]);

    final buttons = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!_g1On && !_g2On)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(S.t('home_no_groups'),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant)),
            ),
          if (_g1On) ...[
            _HomeButton(
              key: kKeyTagBtn,
              color: groupColor(1),
              icon: Icons.wb_sunny_rounded,
              title: S.t('home_tag'),
              subtitle: S.t('home_tag_sub'),
              onTap: () => _start(1),
            ),
            const SizedBox(height: 16),
          ],
          if (_g2On) ...[
            if (running != null)
              _HomeButton(
                // Punkt 7: „Attacke beendet" in eigener Farbe
                color: AppColors.attackEnd.value,
                icon: Icons.flag_rounded,
                title: S.t('home_attack_end'),
                subtitle: S.t('home_attack_end_sub'),
                onTap: () => _endAttack(running),
              )
            else
              _HomeButton(
                key: kKeyMigBtn,
                color: groupColor(2),
                icon: Icons.bolt_rounded,
                title: S.t('home_mig'),
                subtitle: S.t('home_mig_sub'),
                onTap: () => _start(2),
              ),
            const SizedBox(height: 16),
          ],
          _HomeButton(
            key: kKeyQuickBtn,
            color: AppColors.quick.value,
            icon: Icons.speed_rounded,
            title: S.t('home_quick'),
            subtitle: S.t('home_quick_sub'),
            onTap: () => _openQuickPicker(context),
          ),
        ]);

    final hint = Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.swipe_left_alt,
          size: 18, color: theme.colorScheme.onSurfaceVariant),
      const SizedBox(width: 6),
      Text(S.t('home_swipe_hint'),
          style: theme.textTheme.bodySmall
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
    ]);

    return Scaffold(
      body: SafeArea(
        child: Stack(children: [
          const _DecoLayer(),
          // Punkt 12: Inhalt scrollt, wenn der Platz knapp wird – sonst
          // verteilt spaceBetween wie bisher.
          LayoutBuilder(builder: (context, bc) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              child: ConstrainedBox(
                constraints:
                    BoxConstraints(minHeight: bc.maxHeight - 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(children: [
                      header,
                      const SizedBox(height: 12),
                      const MiniCalendar(),
                    ]),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: buttons,
                    ),
                    hint,
                  ],
                ),
              ),
            );
          }),
        ]),
      ),
    );
  }
}

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
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w800, letterSpacing: 1.5)),
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

// ---------------- Homescreen-Deko ----------------

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
  Map<int, int> _mask = {};

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
    final offset = first.weekday - 1;
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
                style = const TextStyle(color: Colors.white, fontSize: 12);
              } else if (m != 0) {
                deco = BoxDecoration(
                    shape: BoxShape.circle, color: m == 1 ? g1 : g2);
                style = const TextStyle(color: Colors.white, fontSize: 12);
              }
              if (isToday) {
                deco = (deco ?? const BoxDecoration(shape: BoxShape.circle))
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
                          theme.textTheme.bodySmall?.copyWith(fontSize: 12)),
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
    super.key,
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