import 'package:flutter/material.dart';

import 'capture/steps.dart';
import 'db.dart';
import 'edit_schema_screen.dart';
import 'l10n.dart';
import 'models.dart';
import 'notifications.dart';
import 'painters.dart';
import 'widget_bridge.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Widget tile(IconData icon, String title, String sub, Widget dest) => Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          child: ListTile(
            leading: CircleAvatar(
                backgroundColor:
                    theme.colorScheme.primary.withValues(alpha: .12),
                child: Icon(icon, color: theme.colorScheme.primary)),
            title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(sub),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => dest)),
          ),
        );
    return Scaffold(
      appBar: AppBar(title: Text(S.t('tooltip_settings'))),
      body: ListView(padding: const EdgeInsets.symmetric(vertical: 12), children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
          child: Text(S.t('set_section_customize'),
              style: theme.textTheme.labelLarge
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ),
        tile(Icons.tune_rounded, S.t('set_captures'), S.t('set_captures_sub'),
            const EditSchemaScreen()),
        tile(Icons.palette_outlined, S.t('set_colors'), S.t('set_colors_sub'),
            const ColorSettingsScreen()),
        tile(Icons.view_carousel_outlined, S.t('set_slides'),
            S.t('set_slides_sub'), const SlidesSettingsScreen()),
        tile(Icons.language_rounded, S.t('set_language'),
            S.t('set_language_sub'), const LanguageSettingsScreen()),
        tile(Icons.notifications_outlined, S.t('set_notifications'),
            S.t('set_notifications_sub'), const NotificationsSettingsScreen()),
      ]),
    );
  }
}

// ---------------- Punkt 1 + 8.2: Farben (Fullscreen beim Hochziehen) ----------------

class ColorSettingsScreen extends StatelessWidget {
  const ColorSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(S.t('set_colors'))),
        body: const SafeArea(child: _ColorBody()),
      );
}

/// Inhalt des Farbmenüs – als Sheet ODER Vollbild, mit Griff und X-Button.
/// Nach oben ziehen öffnet Vollbild; Exit-Button immer sichtbar (Punkt 1).
Future<void> openColorSheet(BuildContext context) async {
  var quickTheme = await PhaskaDb.instance.loadQuickTheme();
  if (!context.mounted) return;
  final themeC = ValueNotifier<String>(quickTheme);
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: false,
    builder: (ctx) => DraggableScrollableSheet(
      initialChildSize: .72,
      minChildSize: .45,
      maxChildSize: 1,
      snap: true,
      snapSizes: const [.72, 1],
      expand: false,
      builder: (ctx, ctrl) => Column(children: [
        // Griff + Exit-Button (Punkt 1)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
          child: Row(children: [
            Expanded(
              child: Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                      color: Theme.of(ctx).colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(3)),
                ),
              ),
            ),
            IconButton(
                tooltip: S.t('close'),
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(ctx)),
          ]),
        ),
        Expanded(
          child: _ColorBody(scroll: ctrl, quickTheme: themeC),
        ),
      ]),
    ),
  );
  quickTheme = themeC.value;
}

class _ColorBody extends StatelessWidget {
  final ScrollController? scroll;
  final ValueNotifier<String>? quickTheme;
  const _ColorBody({this.scroll, this.quickTheme});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return StatefulBuilder(builder: (context, setD) {
      Widget section(String label, int group, ValueNotifier<Color> current) =>
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: theme.textTheme.titleSmall),
            const SizedBox(height: 10),
            Wrap(spacing: 10, runSpacing: 10, children: [
              for (final c in presetColors)
                GestureDetector(
                  onTap: () async {
                    current.value = Color(c);
                    setD(() {});
                    await PhaskaDb.instance.saveColor(group, c);
                    await updateHomeWidgets();
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
      return ListView(
        controller: scroll,
        padding: const EdgeInsets.fromLTRB(24, 4, 24, 32),
        children: [
          section(S.t('col_tag'), 1, AppColors.group1),
          const SizedBox(height: 20),
          section(S.t('col_mig'), 2, AppColors.group2),
          const SizedBox(height: 20),
          section(S.t('col_quick'), 3, AppColors.quick),
          const SizedBox(height: 20),
          // Punkt 7: Farbe des „Attacke beendet"-Knopfes
          section(S.t('col_attack_end'), 4, AppColors.attackEnd),
          const SizedBox(height: 12),
          TextButton.icon(
            icon: const Icon(Icons.restart_alt, size: 18),
            label: Text(S.t('col_reset')),
            onPressed: () async {
              AppColors.group1.value = const Color(kDefaultGroup1Color);
              AppColors.group2.value = const Color(kDefaultGroup2Color);
              AppColors.quick.value = const Color(kDefaultQuickColor);
              AppColors.attackEnd.value = const Color(kDefaultAttackEndColor);
              setD(() {});
              for (final (g, c) in [
                (1, kDefaultGroup1Color),
                (2, kDefaultGroup2Color),
                (3, kDefaultQuickColor),
                (4, kDefaultAttackEndColor),
              ]) {
                await PhaskaDb.instance.saveColor(g, c);
              }
              await updateHomeWidgets();
            },
          ),
          const Divider(height: 28),
          Row(children: [
            Text(S.t('col_deco'), style: theme.textTheme.titleSmall),
            const Spacer(),
            TextButton.icon(
                onPressed: () => decoAddDialog(context),
                icon: const Icon(Icons.add, size: 18),
                label: Text(S.t('col_deco_add'))),
          ]),
          const SizedBox(height: 6),
          ValueListenableBuilder<List<HomeDeco>>(
            valueListenable: AppDeco.items,
            builder: (_, decos, _) => Column(children: [
              if (decos.isEmpty)
                Text(S.t('col_deco_none'), style: theme.textTheme.bodySmall),
              for (var i = 0; i < decos.length; i++)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.eco_outlined, size: 20),
                  title: Text(plantThemes[decos[i].theme] ?? decos[i].theme),
                  subtitle: Text(
                      '${decoPositionLabels[decos[i].position]} · ${decoSizeLabels[decos[i].size]}'),
                  trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      onPressed: () async {
                        AppDeco.items.value =
                            List<HomeDeco>.from(AppDeco.items.value)..removeAt(i);
                        await PhaskaDb.instance.saveHomeDecos(AppDeco.items.value);
                      }),
                ),
            ]),
          ),
          const SizedBox(height: 16),
          FutureBuilder<String>(
            future: PhaskaDb.instance.loadQuickTheme(),
            builder: (context, snap) {
              final v = quickTheme?.value ?? snap.data ?? 'urwald';
              return DropdownButtonFormField<String>(
                initialValue: v,
                decoration: InputDecoration(labelText: S.t('col_deco_quick_slides')),
                items: [
                  for (final e in plantThemes.entries)
                    DropdownMenuItem(value: e.key, child: Text(e.value)),
                ],
                onChanged: (nv) async {
                  quickTheme?.value = nv!;
                  await PhaskaDb.instance.saveQuickTheme(nv!);
                },
              );
            },
          ),
        ],
      );
    });
  }
}

const presetColors = <int>{
  0xFF3A8330, 0xFF43A047, 0xFF00897B, 0xFF1E88E5, 0xFF4FC3F7,
  0xFF5C6BC0, 0xFF7E57C2, 0xFF9575CD, 0xFFAB47BC, 0xFFEC407A,
  0xFFEF5350, 0xFFFB8C00,
};

const decoPositionLabels = {
  'topLeft': 'Oben links',
  'topCenter': 'Oben Mitte',
  'topRight': 'Oben rechts',
  'bottomLeft': 'Unten links',
  'bottomCenter': 'Unten Mitte',
  'bottomRight': 'Unten rechts',
};
const decoSizeLabels = {'s': 'klein', 'm': 'mittel', 'l': 'groß'};

Future<void> decoAddDialog(BuildContext context) async {
  var decoTheme = 'urwald';
  var pos = 'topRight';
  var size = 'm';
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setD) => AlertDialog(
        title: Text('${S.t('col_deco_add')} 🌿'),
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
              child: Text(S.t('cancel'))),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(S.t('add'))),
        ],
      ),
    ),
  );
  if (ok == true) {
    AppDeco.items.value = [
      ...AppDeco.items.value,
      HomeDeco(theme: decoTheme, position: pos, size: size)
    ];
    await PhaskaDb.instance.saveHomeDecos(AppDeco.items.value);
  }
}

// ---------------- Punkt 8.3: Slides anpassen ----------------

class SlidesSettingsScreen extends StatefulWidget {
  const SlidesSettingsScreen({super.key});

  @override
  State<SlidesSettingsScreen> createState() => _SlidesSettingsScreenState();
}

class _SlidesSettingsScreenState extends State<SlidesSettingsScreen> {
  List<SlideCfg>? _slides;

  @override
  void initState() {
    super.initState();
    PhaskaDb.instance.loadSlides().then((s) {
      if (mounted) setState(() => _slides = s);
    });
  }

  Future<void> _save() async {
    await PhaskaDb.instance.saveSlides(_slides!);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final slides = _slides;
    return Scaffold(
      appBar: AppBar(title: Text(S.t('set_slides'))),
      body: slides == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(padding: const EdgeInsets.only(bottom: 32), children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Text(S.t('slides_hint'),
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant)),
              ),
              ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                buildDefaultDragHandles: false,
                itemCount: slides.length,
                onReorderItem: (o, n) async {
                  final list = List<SlideCfg>.from(slides);
                  list.insert(n, list.removeAt(o));
                  setState(() => _slides = list);
                  await _save();
                },
                itemBuilder: (context, i) {
                  final s = slides[i];
                  final isHome = s.id == 'home';
                  return CheckboxListTile(
                    key: ValueKey(s.id),
                    secondary: ReorderableDragStartListener(
                      index: i,
                      child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: Icon(Icons.drag_indicator_rounded),
                      ),
                    ),
                    title: Text(S.t('slide_${s.id}')),
                    subtitle: isHome ? Text(S.t('slide_home')) : null,
                    value: s.visible,
                    onChanged: isHome
                        ? null // Startscreen bleibt immer sichtbar
                        : (v) async {
                            setState(() => s.visible = v ?? true);
                            await _save();
                          },
                  );
                },
              ),
            ]),
    );
  }
}

// ---------------- Punkt 8.4: Sprache ----------------

class LanguageSettingsScreen extends StatelessWidget {
  const LanguageSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(S.t('set_language'))),
        body: ValueListenableBuilder<String>(
          valueListenable: S.code,
          builder: (_, code, _) => Padding(
            padding: const EdgeInsets.all(24),
            child: SegmentedButton<String>(
              segments: [
                ButtonSegment(
                    value: 'de',
                    label: Text(S.t('lang_de')),
                    icon: const Icon(Icons.summarize_outlined)),
                ButtonSegment(
                    value: 'en',
                    label: Text(S.t('lang_en')),
                    icon: const Icon(Icons.translate)),
              ],
              selected: {code},
              onSelectionChanged: (sel) async {
                S.code.value = sel.first;
                await PhaskaDb.instance.saveLanguage(sel.first);
              },
            ),
          ),
        ),
      );
}

// ---------------- Punkt 8.5: Benachrichtigungen ----------------

class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  State<NotificationsSettingsScreen> createState() =>
      _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState
    extends State<NotificationsSettingsScreen> {
  List<NotifCfg>? _list;

  @override
  void initState() {
    super.initState();
    Notifications.load().then((l) {
      if (mounted) setState(() => _list = l);
    });
  }

  Future<void> _save() => Notifications.saveAll(_list!);

  String _title(NotifCfg c) => switch (c.type) {
        'standard' => c.target == 'g2'
            ? S.t('notif_target_g2')
            : S.t('notif_target_g1'),
        'med' => c.target,
        _ => S.t('notif_type_custom'),
      };

  Future<void> _add() async {
    if (!Notifications.supported) return;
    // Messenger VOR dem Async-Gap holen; mounted-Guard für alle
    // context-Benutzungen danach (behebt den Lint use_build_context_synchronously).
    final messenger = ScaffoldMessenger.of(context);
    final okPerm = await notifGateway.requestPermission();
    if (!mounted) return;
    if (!okPerm) {
      messenger.showSnackBar(SnackBar(content: Text(S.t('notif_perm_denied'))));
      return;
    }
    final type = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          for (final (t, icon) in [
            ('standard', Icons.wb_sunny_rounded),
            ('med', Icons.medication_rounded),
            ('custom', Icons.edit_notifications_rounded),
          ])
            ListTile(
              leading: Icon(icon),
              title: Text(S.t('notif_type_$t')),
              subtitle: Text(S.t('notif_type_${t}_sub')),
              onTap: () => Navigator.pop(ctx, t),
            ),
          const SizedBox(height: 8),
        ]),
      ),
    );
    if (type == null || !mounted) return;

    // Variablen je Typ
    var cfg = NotifCfg(
        id: DateTime.now().millisecondsSinceEpoch % 100000,
        type: type,
        time: '20:00',
        target: type == 'med' ? 'Elvanse' : 'g1');
    var disclaimerAccepted = type != 'med';
    final textC = TextEditingController();

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          title: Text(S.t('notif_type_$type')),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              if (type == 'standard') ...[
                Align(
                    alignment: Alignment.centerLeft,
                    child: Text(S.t('notif_target'),
                        style: Theme.of(ctx).textTheme.labelLarge)),
                const SizedBox(height: 6),
                SegmentedButton<String>(
                  segments: [
                    ButtonSegment(
                        value: 'g1', label: Text(S.t('notif_target_g1'))),
                    ButtonSegment(
                        value: 'g2', label: Text(S.t('notif_target_g2'))),
                  ],
                  selected: {cfg.target},
                  onSelectionChanged: (s) => setD(() => cfg.target = s.first),
                ),
                const SizedBox(height: 12),
              ],
              if (type == 'med') ...[
                TextFormField(
                  initialValue: cfg.target,
                  decoration: InputDecoration(labelText: S.t('notif_med_name')),
                  onChanged: (v) => cfg.target = v,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(ctx).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.alarm_add_rounded,
                            color: Theme.of(ctx).colorScheme.onErrorContainer),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(S.t('notif_med_disclaimer'),
                              style: TextStyle(
                                  color: Theme.of(ctx)
                                      .colorScheme
                                      .onErrorContainer)),
                        ),
                      ]),
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  value: disclaimerAccepted,
                  title: Text(S.t('understood')),
                  onChanged: (v) =>
                      setD(() => disclaimerAccepted = v ?? false),
                ),
              ],
              if (type == 'custom')
                TextField(
                  controller: textC,
                  maxLines: 2,
                  decoration:
                      InputDecoration(labelText: S.t('notif_med_text')),
                ),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.schedule),
                title: Text(S.t('notif_time')),
                trailing: Text(cfg.time,
                    style: Theme.of(ctx).textTheme.titleMedium),
                onTap: () async {
                  final t = await pickWheelTime(ctx, cfg.time);
                  if (t != null) setD(() => cfg.time = t);
                },
              ),
              if (type == 'standard' && cfg.target == 'g1')
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: cfg.skipIfDone,
                  title: Text(S.t('notif_skip_done')),
                  subtitle: Text(S.t('notif_skip_done_sub')),
                  onChanged: (v) => setD(() => cfg.skipIfDone = v),
                ),
            ]),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(S.t('cancel'))),
            FilledButton(
                onPressed: !disclaimerAccepted ||
                        (type == 'custom' && textC.text.trim().isEmpty)
                    ? null
                    : () => Navigator.pop(ctx, true),
                child: Text(S.t('save'))),
          ],
        ),
      ),
    );
    if (saved != true) return;
    if (type == 'custom') cfg.text = textC.text.trim();
    setState(() => _list = [...?_list, cfg]);
    await _save();
    messenger.showSnackBar(SnackBar(content: Text(S.t('notif_saved'))));
  }

  @override
  Widget build(BuildContext context) {
    final list = _list;
    return Scaffold(
      appBar: AppBar(title: Text(S.t('set_notifications'))),
      body: !Notifications.supported
          ? Center(
              child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(S.t('notif_unsupported'),
                  textAlign: TextAlign.center),
            ))
          : list == null
              ? const Center(child: CircularProgressIndicator())
              : list.isEmpty
                  ? Center(child: Text(S.t('notif_none')))
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 100),
                      itemCount: list.length,
                      itemBuilder: (context, i) {
                        final c = list[i];
                        return ListTile(
                          leading: Icon(switch (c.type) {
                            'standard' => Icons.wb_sunny_rounded,
                            'med' => Icons.medication_rounded,
                            _ => Icons.edit_notifications_rounded,
                          }),
                          title: Text(c.type == 'custom' ? c.text : _title(c),
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                          subtitle: Text(
                              '${c.time}${c.type == 'standard' && c.target == 'g1' && c.skipIfDone ? ' · ${S.t('notif_skip_done')}' : ''}'),
                          trailing: Row(mainAxisSize: MainAxisSize.min,
                              children: [
                                Switch(
                                    value: c.enabled,
                                    onChanged: (v) async {
                                      setState(() => c.enabled = v);
                                      await _save();
                                    }),
                                IconButton(
                                    icon: const Icon(Icons.delete_outline),
                                    onPressed: () async {
                                      setState(() => _list = List.of(list)
                                        ..removeAt(i));
                                      await _save();
                                    }),
                              ]),
                        );
                      }),
      floatingActionButton: Notifications.supported
          ? FloatingActionButton.extended(
              onPressed: _add,
              icon: const Icon(Icons.add_alarm_rounded),
              label: Text(S.t('notif_add')),
            )
          : null,
    );
  }
}