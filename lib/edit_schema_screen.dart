import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'capture/steps.dart';
import 'db.dart';
import 'models.dart';
import 'painters.dart';
import 'platform/files.dart';

const fieldTypeLabels = <String, String>{
  'vslider': 'Vertikaler Slider (1–100)',
  'hslider': 'Horizontaler Slider (0–10, 5 in der Mitte)',
  'blocks': 'Anwählbare Blöcke (1–10)',
  'halfblocks': 'Halbierbare Blöcke (Stunden)',
  'choice': 'Auswahl-Chips',
  'time': 'Uhrzeit',
  'text': 'Freitext',
};

const _numericTypes = {'vslider', 'hslider', 'blocks', 'halfblocks'};

/// Schnappschuss des kompletten Anpassen-Zustands (Punkt 4.2).
typedef _Snap = ({
  Map<int, List<String>> ids,
  Map<String, FieldDef> defs,
  Map<int, Set<String>> hidden,
  Map<int, Map<String, String>> labels,
  Map<int, Map<String, String>> themes,
  Set<String> quick,
  Set<String> unlocked,
  Map<int, Set<String>> deleted,
});

class _InputDraft {
  final labelC = TextEditingController();
  final optionsC = TextEditingController();
  final blocksC = TextEditingController(text: '12');
  String type = 'hslider';
  bool quick = false;

  _InputDraft();

  factory _InputDraft.from(FieldInput i, [bool quick = false]) {
    final d = _InputDraft();
    d.labelC.text = i.label;
    d.optionsC.text = i.options.join(', ');
    d.blocksC.text = '${i.maxBlocks}';
    d.type = i.type;
    d.quick = quick;
    return d;
  }

  void dispose() {
    labelC.dispose();
    optionsC.dispose();
    blocksC.dispose();
  }
}

class EditSchemaScreen extends StatefulWidget {
  const EditSchemaScreen({super.key});

  @override
  State<EditSchemaScreen> createState() => _EditSchemaScreenState();
}

class _EditSchemaScreenState extends State<EditSchemaScreen> {
  Map<int, List<String>> _ids = {1: const [], 2: const []};
  Map<String, FieldDef> _defs = {};
  Map<int, Set<String>> _hidden = {1: {}, 2: {}};
  Map<int, Map<String, String>> _labels = {1: {}, 2: {}};
  Map<int, Map<String, String>> _themes = {1: {}, 2: {}};
  Set<String> _quick = {};

  /// Punkt 4.1: Lösch-Freigaben (alles andere gilt als gesperrt).
  Set<String> _unlocked = {};

  /// Punkt 4.3: gelöschte Standard-Datenpunkte (wiederherstellbar).
  Map<int, Set<String>> _deleted = {1: {}, 2: {}};

  /// Punkt 4.2: Undo-Stack.
  final List<_Snap> _undo = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final defs = await PhaskaDb.instance.fieldDefs();
    final del = <int, Set<String>>{
      1: await PhaskaDb.instance.deletedBuiltins(1),
      2: await PhaskaDb.instance.deletedBuiltins(2),
    };
    final ids = <int, List<String>>{
      1: [for (final id in await orderedStepIds(1)) if (!del[1]!.contains(id)) id],
      2: [for (final id in await orderedStepIds(2)) if (!del[2]!.contains(id)) id],
    };
    _hidden = {
      1: await PhaskaDb.instance.hiddenBuiltins(1),
      2: await PhaskaDb.instance.hiddenBuiltins(2),
    };
    _labels = {
      1: await PhaskaDb.instance.builtinLabels(1),
      2: await PhaskaDb.instance.builtinLabels(2),
    };
    _themes = {
      1: await PhaskaDb.instance.builtinThemes(1),
      2: await PhaskaDb.instance.builtinThemes(2),
    };
    _quick = (await PhaskaDb.instance.quickKeys()).toSet();
    _unlocked = await PhaskaDb.instance.unlockedPoints();
    _deleted = del;
    if (mounted) {
      setState(() {
        _defs = {for (final d in defs) d.id: d};
        _ids = ids;
      });
    }
  }

  // ---------- Punkt 4.2: Undo ----------

  void _pushUndo() {
    _undo.add((
      ids: {for (final e in _ids.entries) e.key: List<String>.from(e.value)},
      defs: Map<String, FieldDef>.from(_defs),
      hidden: {for (final e in _hidden.entries) e.key: Set<String>.from(e.value)},
      labels: {
        for (final e in _labels.entries) e.key: Map<String, String>.from(e.value)
      },
      themes: {
        for (final e in _themes.entries) e.key: Map<String, String>.from(e.value)
      },
      quick: Set<String>.from(_quick),
      unlocked: Set<String>.from(_unlocked),
      deleted: {
        for (final e in _deleted.entries) e.key: Set<String>.from(e.value)
      },
    ));
    if (_undo.length > 60) _undo.removeAt(0);
    setState(() {});
  }

  Future<void> _undoLast() async {
    if (_undo.isEmpty) return;
    final s = _undo.removeLast();
    for (final g in [1, 2]) {
      await PhaskaDb.instance.saveStepOrder(g, s.ids[g] ?? const []);
      await PhaskaDb.instance.saveHiddenBuiltins(g, s.hidden[g] ?? const {});
      await PhaskaDb.instance.saveBuiltinLabels(g, s.labels[g] ?? const {});
      await PhaskaDb.instance.saveBuiltinThemes(g, s.themes[g] ?? const {});
      await PhaskaDb.instance.saveDeletedBuiltins(g, s.deleted[g] ?? const {});
    }
    final current = await PhaskaDb.instance.fieldDefs();
    for (final d in current) {
      if (!s.defs.containsKey(d.id)) {
        await PhaskaDb.instance.deleteFieldDef(d.id);
      }
    }
    for (final d in s.defs.values) {
      await PhaskaDb.instance.saveFieldDef(d);
    }
    await PhaskaDb.instance.saveQuickKeys(s.quick.toList());
    await PhaskaDb.instance.saveUnlockedPoints(s.unlocked);
    await _load();
  }

  // ---------- Punkt 4.3: Konfiguration speichern / laden ----------

  void _configSheet() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            leading: const Icon(Icons.save_alt_rounded),
            title: const Text('Konfiguration speichern'),
            subtitle:
                const Text('„fasyconfig.json“ (Download- bzw. Dokumente-Ordner)'),
            onTap: () {
              Navigator.pop(ctx);
              _saveConfig();
            },
          ),
          ListTile(
            leading: const Icon(Icons.file_upload_outlined),
            title: const Text('Konfiguration laden'),
            subtitle: const Text('fasyconfig-Datei auswählen und übernehmen'),
            onTap: () {
              Navigator.pop(ctx);
              _loadConfig();
            },
          ),
        ]),
      ),
    );
  }

  Future<void> _saveConfig() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final json = await PhaskaDb.instance
          .exportConfigJson(_ids[1] ?? const [], _ids[2] ?? const []);
      final result = await filesGateway.saveLocally(
          'fasyconfig.json', utf8.encode(json), 'application/json');
      messenger.showSnackBar(
          SnackBar(content: Text('Konfiguration gespeichert:\n$result')));
    } catch (e) {
      messenger.showSnackBar(
          SnackBar(content: Text('Speichern fehlgeschlagen: $e')));
    }
  }

  Future<void> _loadConfig() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final file = await FilePicker.pickFile(
          type: FileType.custom, allowedExtensions: ['json']);
      if (file == null || !mounted) return;
      final text =
          utf8.decode(await file.readAsBytes(), allowMalformed: true);
      if (!mounted) return;
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          icon: const Icon(Icons.settings_backup_restore_rounded),
          title: const Text('Konfiguration laden?'),
          content: const Text(
              'Farben, Datenpunkte, Reihenfolge, Graphen und Deko werden '
              'durch die Datei ersetzt.\n\nDeine erfassten Daten bleiben '
              'unberührt. Anschließend baut sich die App einmal neu auf, '
              'damit alles fehlerfrei übernommen wird.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Abbrechen')),
            FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Laden')),
          ],
        ),
      );
      if (ok != true || !mounted) return;

      await PhaskaDb.instance.importConfigJson(text);
      // Notifier aktualisieren → die App baut sich selbst neu auf.
      final (c1, c2) = await PhaskaDb.instance.loadColors();
      AppColors.group1.value = Color(c1);
      AppColors.group2.value = Color(c2);
      AppColors.quick.value = Color(await PhaskaDb.instance.loadQuickColor());
      AppColors.themeMode.value = await PhaskaDb.instance.loadThemeMode();
      AppDeco.items.value = await PhaskaDb.instance.loadHomeDecos();
      Repo.bump();
      _undo.clear();
      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          icon: const Icon(Icons.check_circle_outline),
          title: const Text('Konfiguration übernommen'),
          content: const Text('Die Ansicht wird jetzt neu aufgebaut.'),
          actions: [
            FilledButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('OK')),
          ],
        ),
      );
      if (mounted) Navigator.of(context).pop(); // zurück zum Startscreen
    } catch (e) {
      messenger.showSnackBar(
          SnackBar(content: Text('Konfiguration konnte nicht geladen werden: $e')));
    }
  }

  // ---------- Anzeigehelfer ----------

  String _labelOf(int group, String id) {
    if (_defs.containsKey(id)) return _defs[id]!.label;
    return _labels[group]?[id] ?? builtinLabel(group, id);
  }

  String _themeOf(int group, String id) =>
      _defs[id]?.plantTheme ?? _themes[group]?[id] ?? 'none';

  Future<void> _reorder(int group, int oldIndex, int newIndex) async {
    _pushUndo();
    final list = List<String>.from(_ids[group]!);
    list.insert(newIndex, list.removeAt(oldIndex));
    setState(() => _ids[group] = list);
    await PhaskaDb.instance.saveStepOrder(group, list);
  }

  // ---------- Punkt 4.1: Lösch-Sperre ----------

  Future<void> _toggleLock(String id, bool locked) async {
    _pushUndo();
    setState(() {
      if (locked) {
        _unlocked.add(id);
      } else {
        _unlocked.remove(id);
      }
    });
    await PhaskaDb.instance.saveUnlockedPoints(_unlocked);
  }

  // ---------- Standard-Datenpunkte bearbeiten ----------

  Future<void> _builtinDialog(int group, String id) async {
    final canonical = builtinLabel(group, id);
    final labelC = TextEditingController(text: _labelOf(group, id));
    final quickKey = quickKeyForStep(id);
    var theme = _themeOf(group, id);
    var hidden = _hidden[group]!.contains(id);
    var quickOn = quickKey != null && _quick.contains(quickKey);

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          title: const Text('Datenpunkt anpassen'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(
                controller: labelC,
                decoration: InputDecoration(
                    labelText: 'Anzeigename (leer = „$canonical")'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: theme,
                decoration: const InputDecoration(labelText: 'Pflanzen-Deko'),
                items: [
                  for (final e in plantThemes.entries)
                    DropdownMenuItem(value: e.key, child: Text(e.value)),
                ],
                onChanged: (v) => setD(() => theme = v!),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                value: hidden,
                title: const Text('In der Erfassung ausblenden'),
                subtitle:
                    const Text('Werte und Tabellenspalte bleiben erhalten.'),
                onChanged: (v) => setD(() => hidden = v),
              ),
              if (quickKey != null)
                SwitchListTile(
                  value: quickOn,
                  title: const Text('Einzelerfassung erlauben'),
                  subtitle: const Text(
                      'Mehrmals täglich direkt vom Startscreen aus erfassbar; '
                      'Tages-Ø, Min und Max landen in der Tabelle.'),
                  onChanged: (v) => setD(() => quickOn = v),
                ),
            ]),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Abbrechen')),
            FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Speichern')),
          ],
        ),
      ),
    );
    if (saved != true) return;

    _pushUndo();
    final labels = Map<String, String>.from(_labels[group]!);
    final themes = Map<String, String>.from(_themes[group]!);
    final newLabel = labelC.text.trim();
    if (newLabel.isEmpty || newLabel == canonical) {
      labels.remove(id);
    } else {
      labels[id] = newLabel;
    }
    if (theme == 'none') { themes.remove(id); } else { themes[id] = theme; }
    final hide = Set<String>.from(_hidden[group]!);
    if (hidden) { hide.add(id); } else { hide.remove(id); }
    if (quickKey != null) {
      if (quickOn) { _quick.add(quickKey); } else { _quick.remove(quickKey); }
      await PhaskaDb.instance.saveQuickKeys(_quick.toList());
    }

    await PhaskaDb.instance.saveBuiltinLabels(group, labels);
    await PhaskaDb.instance.saveBuiltinThemes(group, themes);
    await PhaskaDb.instance.saveHiddenBuiltins(group, hide);
    await _load();
  }

  // ---------- Eigene Datenpunkte (mehrere Eingaben) ----------

  Future<void> _fieldDialog(int group, {FieldDef? existing}) async {
    final labelC = TextEditingController(text: existing?.label ?? '');
    var theme = existing?.plantTheme ?? 'none';
    final drafts = <_InputDraft>[
      if (existing != null)
        for (final i in existing.inputs)
          _InputDraft.from(i, _quick.contains('${existing.id}::${i.subkey}'))
      else
        _InputDraft(),
    ];

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          title: Text(existing == null
              ? 'Neuer Datenpunkt'
              : '"${existing.label}" bearbeiten'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                TextField(
                  controller: labelC,
                  autofocus: existing == null,
                  decoration: const InputDecoration(
                      labelText: 'Name des Datenpunkts',
                      hintText: 'z. B. Konzentration'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: theme,
                  decoration:
                      const InputDecoration(labelText: 'Pflanzen-Deko'),
                  items: [
                    for (final e in plantThemes.entries)
                      DropdownMenuItem(value: e.key, child: Text(e.value)),
                  ],
                  onChanged: (v) => setD(() => theme = v!),
                ),
                const SizedBox(height: 20),
                for (var i = 0; i < drafts.length; i++) ...[
                  Row(children: [
                    Expanded(
                      child: TextField(
                        controller: drafts[i].labelC,
                        decoration: InputDecoration(
                          labelText: 'Eingabe ${i + 1} (Name)',
                          hintText: drafts.length > 1
                              ? 'z. B. Lesevermögen'
                              : '(optional)',
                        ),
                      ),
                    ),
                    if (drafts.length > 1)
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        tooltip: 'Eingabe entfernen',
                        onPressed: () => setD(() => drafts.removeAt(i)),
                      ),
                  ]),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: drafts[i].type,
                    decoration:
                        const InputDecoration(labelText: 'Erfassungsmethode'),
                    isExpanded: true,
                    items: [
                      for (final e in fieldTypeLabels.entries)
                        DropdownMenuItem(value: e.key, child: Text(e.value)),
                    ],
                    onChanged: (v) => setD(() => drafts[i].type = v!),
                  ),
                  if (drafts[i].type == 'choice')
                    TextField(
                      controller: drafts[i].optionsC,
                      decoration: const InputDecoration(
                          labelText: 'Optionen',
                          hintText: 'mit Komma getrennt'),
                    ),
                  if (drafts[i].type == 'halfblocks')
                    TextField(
                      controller: drafts[i].blocksC,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: 'Anzahl Blöcke (Stunden)'),
                    ),
                  if (_numericTypes.contains(drafts[i].type))
                    CheckboxListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      value: drafts[i].quick,
                      title: const Text('Einzelerfassung erlauben',
                          style: TextStyle(fontSize: 13)),
                      subtitle: const Text(
                          'Mehrmals täglich direkt erfassbar',
                          style: TextStyle(fontSize: 11)),
                      onChanged: (v) =>
                          setD(() => drafts[i].quick = v ?? false),
                    ),
                  const SizedBox(height: 12),
                  const Divider(),
                ],
                TextButton.icon(
                  onPressed: () => setD(() => drafts.add(_InputDraft())),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Weitere Eingabe hinzufügen'),
                ),
              ]),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Abbrechen')),
            FilledButton(
                onPressed: labelC.text.trim().isEmpty
                    ? null
                    : () => Navigator.pop(ctx, true),
                child: const Text('Speichern')),
          ],
        ),
      ),
    );
    if (saved != true || labelC.text.trim().isEmpty) return;

    _pushUndo();
    // Eindeutige Unter-Schlüssel erzeugen
    final used = <String>{};
    final defLabel = labelC.text.trim();
    final inputs = [
      for (final d in drafts)
        () {
          var key = inputSlug(d.labelC.text.trim().isEmpty
              ? (drafts.length == 1 ? defLabel : 'eingabe')
              : d.labelC.text.trim());
          var k = key;
          var n = 2;
          while (!used.add(k)) { k = '${key}_$n'; n++; }
          return FieldInput(
            subkey: k,
            label: d.labelC.text.trim().isEmpty
                ? defLabel
                : d.labelC.text.trim(),
            type: d.type,
            options: d.type == 'choice'
                ? d.optionsC.text
                    .split(',')
                    .map((e) => e.trim())
                    .where((e) => e.isNotEmpty)
                    .toList()
                : const [],
            maxBlocks: int.tryParse(d.blocksC.text) ?? 12,
          );
        }(),
    ];

    final def = FieldDef(
      id: existing?.id ?? 'c_${DateTime.now().millisecondsSinceEpoch}',
      group: existing?.group ?? group,
      label: defLabel,
      inputs: inputs,
      plantTheme: theme,
      position: existing?.position ?? 999,
    );
    await PhaskaDb.instance.saveFieldDef(def);

    // Einzelerfassung-Schlüssel dieses Datenpunkts neu setzen
    final quick = await PhaskaDb.instance.quickKeys();
    quick.removeWhere((k) => k.startsWith('${def.id}::'));
    for (var i = 0; i < inputs.length; i++) {
      if (drafts[i].quick && inputs[i].numeric) {
        quick.add('${def.id}::${inputs[i].subkey}');
      }
    }
    await PhaskaDb.instance.saveQuickKeys(quick);

    final ids = await orderedStepIds(def.group);
    await PhaskaDb.instance.saveStepOrder(def.group, ids);
    await _load();
  }

  // ---------- Löschen (mit Sicherheitsschirm, Punkt 4) ----------

  Future<void> _deleteField(FieldDef d) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('„${d.label}" entfernen?'),
        content: const Text(
            'Der Datenpunkt verschwindet aus der Erfassung. Bereits gespeicherte Werte bleiben in der Datenbank und im CSV-Export erhalten. Über „Rückgängig" oben bekommst du ihn zurück.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Abbrechen')),
          FilledButton(
              style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(ctx).colorScheme.error,
                  foregroundColor: Theme.of(ctx).colorScheme.onError),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Entfernen')),
        ],
      ),
    );
    if (ok == true) {
      _pushUndo();
      await PhaskaDb.instance.deleteFieldDef(d.id);
      await _load();
    }
  }

  Future<void> _deleteBuiltin(int group, String id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('„${_labelOf(group, id)}" entfernen?'),
        content: const Text(
            'Der Datenpunkt verschwindet aus der Erfassung. Gespeicherte Werte '
            'bleiben in der Datenbank und im CSV-Export erhalten. Unten in der '
            '„Gelöscht"-Liste (oder über „Rückgängig") bekommst du ihn zurück.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Abbrechen')),
          FilledButton(
              style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(ctx).colorScheme.error,
                  foregroundColor: Theme.of(ctx).colorScheme.onError),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Entfernen')),
        ],
      ),
    );
    if (ok == true) {
      _pushUndo();
      setState(() => _deleted[group]!.add(id));
      await PhaskaDb.instance.saveDeletedBuiltins(group, _deleted[group]!);
      await _load();
    }
  }

  Future<void> _restoreBuiltin(int group, String id) async {
    _pushUndo();
    setState(() => _deleted[group]!.remove(id));
    await PhaskaDb.instance.saveDeletedBuiltins(group, _deleted[group]!);
    await _load();
  }

  // ---------- Aufbau ----------

  Widget _section(int group, String title, Color color) {
    final ids = _ids[group]!;
    final deleted = _deleted[group] ?? const <String>{};
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 8, 4),
        child: Row(children: [
          Text(title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold, color: color)),
          const Spacer(),
          TextButton.icon(
              onPressed: () => _fieldDialog(group),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Neuer Datenpunkt')),
        ]),
      ),
      ReorderableListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        buildDefaultDragHandles: false,
        itemCount: ids.length,
        onReorderItem: (o, n) => _reorder(group, o, n),
        itemBuilder: (context, i) {
          final id = ids[i];
          final def = _defs[id];
          final hidden = _hidden[group]!.contains(id);
          final plant = plantThemes[_themeOf(group, id)];
          final quickKey = def == null ? quickKeyForStep(id) : null;
          final locked = !_unlocked.contains(id);
          final subtitle = def != null
              ? [
                  def.inputs.length == 1
                      ? (fieldTypeLabels[def.inputs.first.type] ??
                          def.inputs.first.type)
                      : '${def.inputs.length} Eingaben',
                  if (def.inputs.any((inp) =>
                      _quick.contains('${def.id}::${inp.subkey}')))
                    'Einzelerfassung',
                  if (plant != null && plant != 'Keine') plant,
                ].join(' · ')
              : 'Standard'
                  '${hidden ? ' · ausgeblendet' : ''}'
                  '${quickKey != null && _quick.contains(quickKey) ? ' · Einzelerfassung' : ''}'
                  '${plant != null && plant != 'Keine' ? ' · $plant' : ''}';
          return ListTile(
            key: ValueKey('g$group-$id'),
            leading: ReorderableDragStartListener(
              index: i,
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.drag_indicator_rounded),
              ),
            ),
            title: Text(_labelOf(group, id),
                style: hidden
                    ? const TextStyle(decoration: TextDecoration.lineThrough)
                    : null),
            subtitle: Text(subtitle),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              // Punkt 4.1: Schloss vor dem Mülleimer
              IconButton(
                tooltip: locked
                    ? 'Löschen gesperrt – tippen zum Entsperren'
                    : 'Löschen freigegeben – tippen zum Sperren',
                icon: Icon(
                    locked
                        ? Icons.lock_outline_rounded
                        : Icons.lock_open_rounded,
                    size: 20,
                    color:
                        locked ? null : Theme.of(context).colorScheme.error),
                onPressed: () => _toggleLock(id, locked),
              ),
              IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  onPressed: () => def == null
                      ? _builtinDialog(group, id)
                      : _fieldDialog(group, existing: def)),
              IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  tooltip: locked ? 'Gesperrt' : 'Entfernen',
                  onPressed: locked
                      ? null
                      : () => def == null
                          ? _deleteBuiltin(group, id)
                          : _deleteField(def)),
            ]),
          );
        },
      ),
      if (deleted.isNotEmpty) ...[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Text('Gelöscht – tippen zum Wiederherstellen',
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(
                      color:
                          Theme.of(context).colorScheme.onSurfaceVariant)),
        ),
        for (final id in deleted.toList()..sort())
          ListTile(
            leading: const Icon(Icons.restore_rounded),
            title: Text(_labelOf(group, id),
                style:
                    const TextStyle(decoration: TextDecoration.lineThrough)),
            subtitle: const Text('Standard · gelöscht'),
            onTap: () => _restoreBuiltin(group, id),
          ),
      ],
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Anpassen'), actions: [
        // Punkt 4.2: Rückgängig
        IconButton(
            tooltip: 'Rückgängig',
            icon: const Icon(Icons.undo_rounded),
            onPressed: _undo.isEmpty ? null : _undoLast),
        // Punkt 4.3: Konfiguration speichern / laden
        IconButton(
            tooltip: 'Konfiguration speichern / laden',
            icon: const Icon(Icons.save_outlined),
            onPressed: _configSheet),
        const SizedBox(width: 4),
      ]),
      body: ListView(padding: const EdgeInsets.only(bottom: 32), children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Text(
              'Mit dem ⁝⁝-Griff links sofort verschieben. Der 🗑-Mülleimer ist '
              'pro Datenpunkt gesperrt – erst das Schloss daneben öffnen. '
              'Oben rechts: Änderungen rückgängig machen und die komplette '
              'Konfiguration sichern oder laden.',
              style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant)),
        ),
        _section(1, 'Tag', groupColor(1)),
        const Divider(height: 24),
        _section(2, 'Migräne', groupColor(2)),
      ]),
    );
  }
}