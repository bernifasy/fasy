import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_saver/file_saver.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqflite/sqflite.dart';

import 'models.dart';

/// Tages-Aggregat einer Einzelerfassung (Ø, Min, Max, Anzahl).
typedef QuickAgg = ({double avg, double min, double max, int n});

/// 'yyyy-MM-dd'-Schlüssel eines Datums (für Tages-Gruppierungen).
String dayKeyOf(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
// -------- Schnellmessung ↔ Tageseintrag (Punkt 5) --------

/// Marker-Map eines Eintrags: defKey → zuletzt aus Schnellmessungen
/// zurückgeschriebener Ø-Wert. Dadurch erkennen wir, ob der Wert am
/// Tageseintrag "von Hand" stammt oder nur das Aggregat widerspiegelt.
Map<String, double> quickWritten(PhaskaEntry e) {
  final raw = e.custom['_qw'];
  if (raw is! Map) return {};
  return {
    for (final en in raw.entries) '${en.key}': (en.value as num).toDouble()
  };
}

/// Aktueller Wert eines Mess-Schlüssels am Tageseintrag.
double? entryValueForKey(
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
  final p = key.split('::');
  if (p.length == 2) {
    final d = defsById[p[0]];
    if (d != null) {
      for (final inp in d.inputs) {
        if (inp.subkey == p[1]) {
          final v = customSubValue(e, d, inp);
          if (v is num) return v.toDouble();
        }
      }
    }
  }
  return null;
}

/// Tageswert, der ins Aggregat einfließen darf: null, wenn es nur der
/// zuvor zurückgeschriebene Durchschnitt ist (sonst Doppelzählung!).
double? entryBaseValue(
    PhaskaEntry e, String key, Map<String, FieldDef> defsById) {
  final v = entryValueForKey(e, key, defsById);
  if (v == null) return null;
  final written = quickWritten(e)[key];
  if (written != null && written == v) return null; // nur der alte Ø
  return v;
}

class PhaskaDb {
  PhaskaDb._();
  static final PhaskaDb instance = PhaskaDb._();
  static const table = 'entries';
  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    final path = p.join(await getDatabasesPath(), 'phaska.db');
    _db = await openDatabase(path, version: 4, onCreate: (db, v) async {
      await _createEntries(db);
      await _createExtras(db);
      await _createQuick(db);
    }, onUpgrade: (db, oldV, newV) async {
      if (oldV < 2) {
        await db.execute(
            'ALTER TABLE $table ADD COLUMN medikinet_essen_abstand TEXT');
        await db
            .execute('ALTER TABLE $table ADD COLUMN custom_values TEXT');
        await _createExtras(db);
      }
      if (oldV < 3) {
        await _createGraphen(db);
      }
      if (oldV < 4) {
        await _createQuick(db);
      }
    });
    return _db!;
  }

  Future<void> _createEntries(Database db) => db.execute('''
      CREATE TABLE $table (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        created_at TEXT NOT NULL,
        wohlbefinden INTEGER,
        schlaf_stunden REAL,
        elvanse_mg INTEGER,
        innere_unruhe REAL,
        medikinet_mg INTEGER,
        medikinet_zeit TEXT,
        medikinet_magen TEXT,
        medikinet_essen_abstand TEXT,
        migraene_intensitaet INTEGER,
        migraene_start TEXT,
        migraene_ende TEXT,
        ausloeser TEXT,
        begleitsymptome TEXT,
        notizen TEXT,
        migraene_tag TEXT NOT NULL DEFAULT 'nein',
        custom_values TEXT
      )''');

  Future<void> _createExtras(Database db) async {
    await db.execute(
        'CREATE TABLE IF NOT EXISTS field_defs (id TEXT PRIMARY KEY, grp INTEGER NOT NULL, label TEXT NOT NULL, type TEXT NOT NULL, config TEXT, position INTEGER)');
    await db.execute(
        'CREATE TABLE IF NOT EXISTS meta (key TEXT PRIMARY KEY, value TEXT)');
    await _createGraphen(db);
  }

  Future<void> _createGraphen(Database db) => db.execute(
      'CREATE TABLE IF NOT EXISTS graph_defs (id TEXT PRIMARY KEY, title TEXT NOT NULL, cfg TEXT NOT NULL, position INTEGER)');

  Future<void> _createQuick(Database db) => db.execute('''
      CREATE TABLE IF NOT EXISTS quick_values (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        def_key TEXT NOT NULL,
        label TEXT NOT NULL,
        value REAL NOT NULL,
        created_at TEXT NOT NULL
      )''');

  // ---------- Einträge ----------

  Future<int> insert(PhaskaEntry e) async {
    final id = await (await database).insert(table, e.toMap());
    Repo.bump();
    unawaited(autosave());
    return id;
  }

  Future<void> update(PhaskaEntry e) async {
    await (await database)
        .update(table, e.toMap(), where: 'id = ?', whereArgs: [e.id]);
    Repo.bump();
    unawaited(autosave());
  }

  Future<void> delete(int id) async {
    await (await database).delete(table, where: 'id = ?', whereArgs: [id]);
    Repo.bump();
    unawaited(autosave());
  }

  Future<List<PhaskaEntry>> all() async {
    final rows =
        await (await database).query(table, orderBy: 'created_at DESC');
    return rows.map(PhaskaEntry.fromMap).toList();
  }

  Future<List<String>> pastValues(String column) async {
    assert(column == 'ausloeser' || column == 'begleitsymptome');
    final rows = await (await database).query(table,
        columns: [column], where: "$column IS NOT NULL AND $column != ''");
    final found = <String>{};
    for (final r in rows) {
      for (final part in (r[column] as String).split(';')) {
        final t = part.trim();
        if (t.isNotEmpty) found.add(t);
      }
    }
    return found.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
  }

  // ---------- Eigene Datenpunkte & Reihenfolge ----------

  Future<List<FieldDef>> fieldDefs({int? group}) async {
    final rows = await (await database).query('field_defs',
        where: group == null ? null : 'grp = ?',
        whereArgs: group == null ? null : [group],
        orderBy: 'position');
    return rows.map(FieldDef.fromMap).toList();
  }

  Future<void> saveFieldDef(FieldDef d) async {
    await (await database).insert('field_defs', d.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    Repo.bump();
  }

  Future<void> deleteFieldDef(String id) async {
    await (await database)
        .delete('field_defs', where: 'id = ?', whereArgs: [id]);
    Repo.bump();
  }

  // ---------- Meta ----------

  Future<String?> _meta(String key) async {
    final r = await (await database)
        .query('meta', where: 'key = ?', whereArgs: [key]);
    return r.isEmpty ? null : r.first['value'] as String?;
  }

  Future<void> _setMeta(String key, String value) async =>
      (await database).insert('meta', {'key': key, 'value': value},
          conflictAlgorithm: ConflictAlgorithm.replace);

  Future<List<String>?> stepOrder(int group) async {
    final v = await _meta('order_g$group');
    return v == null ? null : [for (final e in jsonDecode(v) as List) '$e'];
  }

  Future<void> saveStepOrder(int group, List<String> ids) =>
      _setMeta('order_g$group', jsonEncode(ids));

  Future<Set<String>> hiddenBuiltins(int group) async {
    final v = await _meta('hidden_g$group');
    return v == null ? {} : {for (final e in jsonDecode(v) as List) '$e'};
  }

  Future<void> saveHiddenBuiltins(int group, Set<String> ids) =>
      _setMeta('hidden_g$group', jsonEncode(ids.toList()));

  Future<Map<String, String>> builtinLabels(int group) async {
    final v = await _meta('labels_g$group');
    if (v == null) return {};
    return {
      for (final e in (jsonDecode(v) as Map).entries) '${e.key}': '${e.value}'
    };
  }

  Future<void> saveBuiltinLabels(int group, Map<String, String> m) =>
      _setMeta('labels_g$group', jsonEncode(m));

  Future<Map<String, String>> builtinThemes(int group) async {
    final v = await _meta('themes_g$group');
    if (v == null) return {};
    return {
      for (final e in (jsonDecode(v) as Map).entries) '${e.key}': '${e.value}'
    };
  }

  Future<void> saveBuiltinThemes(int group, Map<String, String> m) =>
      _setMeta('themes_g$group', jsonEncode(m));

  // ---------- Farben & Theme ----------

  Future<(int, int)> loadColors() async => (
        int.tryParse(await _meta('color_g1') ?? '') ?? kDefaultGroup1Color,
        int.tryParse(await _meta('color_g2') ?? '') ?? kDefaultGroup2Color,
      );

  Future<void> saveColor(int group, int argb) =>
      _setMeta('color_g$group', '$argb');

  Future<String> loadThemeMode() async => await _meta('theme_mode') ?? 'system';

  Future<void> saveThemeMode(String mode) => _setMeta('theme_mode', mode);

  // ---------- Graphen ----------

  Future<List<GraphDef>> graphDefs() async {
    final rows =
        await (await database).query('graph_defs', orderBy: 'position');
    return rows.map(GraphDef.fromMap).toList();
  }

  Future<void> saveGraphDef(GraphDef g, {bool notify = true}) async {
    await (await database).insert('graph_defs', g.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    if (notify) Repo.bump();
  }

  Future<void> deleteGraphDef(String id) async {
    await (await database)
        .delete('graph_defs', where: 'id = ?', whereArgs: [id]);
    Repo.bump();
  }

  Future<bool> graphsSeeded() async => await _meta('graphs_seeded') == '1';

  Future<void> markGraphsSeeded() => _setMeta('graphs_seeded', '1');

  // ---------- Einzelerfassung (Schnellmessungen) ----------

  Future<int> insertQuick(QuickValue q) async {
    final id = await (await database).insert('quick_values', q.toMap());
    await applyQuickAggregate(q.defKey, q.createdAt);
    Repo.bump();
    unawaited(autosave());
    return id;
  }

  Future<void> updateQuick(QuickValue q) async {
    await (await database).update('quick_values', q.toMap(),
        where: 'id = ?', whereArgs: [q.id]);
    await applyQuickAggregate(q.defKey, q.createdAt);
    Repo.bump();
    unawaited(autosave());
  }

  Future<void> deleteQuick(QuickValue q) async {
    await (await database)
        .delete('quick_values', where: 'id = ?', whereArgs: [q.id]);
    await applyQuickAggregate(q.defKey, q.createdAt);
    Repo.bump();
    unawaited(autosave());
  }

  Future<List<QuickValue>> allQuick() async {
    final rows = await (await database)
        .query('quick_values', orderBy: 'created_at DESC');
    return rows.map(QuickValue.fromMap).toList();
  }

  Future<List<String>> quickKeys() async {
    final v = await _meta('quick_keys');
    return v == null
        ? const []
        : [for (final e in jsonDecode(v) as List) '$e'];
  }

  Future<void> saveQuickKeys(List<String> keys) =>
      _setMeta('quick_keys', jsonEncode(keys));

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;


  /// Rechnet Schnellmessungen + den händisch erfassten Tageswert (falls
  /// vorhanden) zu einem gemeinsamen Durchschnitt und schreibt ihn in den
  /// Tageseintrag zurück – inkl. Marker, damit er beim nächsten Mal nicht
  /// doppelt zählt (Punkt 5).
  Future<void> applyQuickAggregate(String defKey, DateTime day) async {
    final qs = await allQuick();
    final vals = qs
        .where((v) => v.defKey == defKey && _sameDay(v.createdAt, day))
        .map((v) => v.value)
        .toList();
    final defsById = {for (final d in await fieldDefs()) d.id: d};
    final e =
        (await all()).where((x) => _sameDay(x.createdAt, day)).firstOrNull;
    if (e == null) return; // kein Tageseintrag → nur Einzeltabelle
    final base = entryBaseValue(e, defKey, defsById);
    final combined = [...vals, if (base != null) base];
    if (combined.isEmpty) return;
    final avg = combined.reduce((a, b) => a + b) / combined.length;
    setEntryValueForKey(e, defKey, avg, defsById);
    // Marker merken: Dieser Wert stammt jetzt aus dem Aggregat.
    final written = entryValueForKey(e, defKey, defsById);
    final qw = quickWritten(e);
    if (written != null) qw[defKey] = written;
    e.custom['_qw'] = qw;
    await update(e);
  }

  /// Tages-Aggregate aller Schnellmessungen: dayKey -> defKey -> QuickAgg.
  /// NEU (Punkt 5): Handelt es sich am Tageseintrag um einen eigenständig
  /// erfassten Wert (kein zurückgeschriebener Ø), zählt er als zusätzliche
  /// Messung mit in Ø, Min, Max und Anzahl.
  Future<Map<String, Map<String, QuickAgg>>> quickDayAgg() async {
    final qs = await allQuick();
    if (qs.isEmpty) return const {};
    final out = <String, Map<String, QuickAgg>>{};
    for (final q in qs) {
      final m = out.putIfAbsent(dayKeyOf(q.createdAt), () => {});
      final cur = m[q.defKey];
      if (cur == null) {
        m[q.defKey] = (avg: q.value, min: q.value, max: q.value, n: 1);
      } else {
        final sum = cur.avg * cur.n + q.value;
        m[q.defKey] = (
          avg: sum / (cur.n + 1),
          min: q.value < cur.min ? q.value : cur.min,
          max: q.value > cur.max ? q.value : cur.max,
          n: cur.n + 1
        );
      }
    }
    // Tageswerte einrechnen.
    final defsById = {for (final d in await fieldDefs()) d.id: d};
    for (final e in await all()) {
      final m = out[dayKeyOf(e.createdAt)];
      if (m == null) continue;
      for (final k in m.keys.toList()) {
        final base = entryBaseValue(e, k, defsById);
        if (base == null) continue;
        final cur = m[k]!;
        final n = cur.n + 1;
        m[k] = (
          avg: (cur.avg * cur.n + base) / n,
          min: base < cur.min ? base : cur.min,
          max: base > cur.max ? base : cur.max,
          n: n
        );
      }
    }
    return out;
  }

  // ---------- Einzelerfassung: Farbe & Deko (Punkt 1) ----------

  Future<int> loadQuickColor() async =>
      int.tryParse(await _meta('color_g3') ?? '') ?? kDefaultQuickColor;

  Future<String> loadQuickTheme() async => await _meta('quick_theme') ?? 'urwald';

  Future<void> saveQuickTheme(String t) => _setMeta('quick_theme', t);

  // ---------- Lösch-Sperre & gelöschte Standards (Punkte 4.1/4.3) ----------

  /// IDs, deren Mülleimer freigeschaltet ist. Alles andere gilt als gesperrt.
  Future<Set<String>> unlockedPoints() async {
    final v = await _meta('unlocked_points');
    return v == null ? {} : {for (final e in jsonDecode(v) as List) '$e'};
  }

  Future<void> saveUnlockedPoints(Set<String> ids) =>
      _setMeta('unlocked_points', jsonEncode(ids.toList()));

  Future<Set<String>> deletedBuiltins(int group) async {
    final v = await _meta('deleted_g$group');
    return v == null ? {} : {for (final e in jsonDecode(v) as List) '$e'};
  }

  Future<void> saveDeletedBuiltins(int group, Set<String> ids) =>
      _setMeta('deleted_g$group', jsonEncode(ids.toList()));

  // ---------- Onboarding (Punkt 7) ----------

  Future<bool> isOnboarded() async => await _meta('onboarded') == '1';

  Future<void> markOnboarded() => _setMeta('onboarded', '1');

  // ---------- Konfiguration exportieren/importieren (Punkt 4.3) ----------

  Future<String> exportConfigJson(
      List<String> orderG1, List<String> orderG2) async {
    final (c1, c2) = await loadColors();
    final groups = <String, Object?>{};
    for (final g in [1, 2]) {
      groups['$g'] = {
        'order': g == 1 ? orderG1 : orderG2,
        'hidden': (await hiddenBuiltins(g)).toList(),
        'deleted': (await deletedBuiltins(g)).toList(),
        'labels': await builtinLabels(g),
        'themes': await builtinThemes(g),
      };
    }
    final cfg = <String, Object?>{
      'app': 'fasy',
      'kind': 'config',
      'version': 5,
      'colors': {'g1': c1, 'g2': c2, 'g3': await loadQuickColor()},
      'themeMode': await loadThemeMode(),
      'quickTheme': await loadQuickTheme(),
      'homeDecos': [for (final d in await loadHomeDecos()) d.toJson()],
      'fieldDefs': [for (final d in await fieldDefs()) d.toMap()],
      'graphDefs': [for (final g in await graphDefs()) g.toMap()],
      'groups': groups,
      'quickKeys': await quickKeys(),
      'unlocked': (await unlockedPoints()).toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(cfg);
  }

  /// Übernimmt eine fasyconfig-Datei. Erfasste Daten bleiben unberührt.
  Future<void> importConfigJson(String text) async {
    final m = (jsonDecode(text) as Map).cast<String, dynamic>();
    List<String> strList(Object? v) =>
        v is List ? [for (final e in v) '$e'] : const [];
    Map<String, String> strMap(Object? v) => v is Map
        ? {for (final e in v.entries) '${e.key}': '${e.value}'}
        : const {};

    final colors = (m['colors'] as Map?)?.cast<String, dynamic>();
    if (colors != null) {
      if (colors['g1'] is num) await saveColor(1, (colors['g1'] as num).toInt());
      if (colors['g2'] is num) await saveColor(2, (colors['g2'] as num).toInt());
      if (colors['g3'] is num) await saveColor(3, (colors['g3'] as num).toInt());
    }
    if (m['themeMode'] is String) await saveThemeMode(m['themeMode'] as String);
    if (m['quickTheme'] is String) {
      await saveQuickTheme(m['quickTheme'] as String);
    }
    if (m['homeDecos'] is List) {
      await saveHomeDecos([
        for (final e in m['homeDecos'] as List)
          HomeDeco.fromJson((e as Map).cast<String, dynamic>())
      ]);
    }
    if (m['fieldDefs'] is List) {
      final incoming = [
        for (final e in m['fieldDefs'] as List)
          FieldDef.fromMap((e as Map).cast<String, Object?>())
      ];
      for (final d in await fieldDefs()) {
        if (incoming.every((x) => x.id != d.id)) await deleteFieldDef(d.id);
      }
      for (final d in incoming) {
        await saveFieldDef(d);
      }
    }
    if (m['graphDefs'] is List) {
      final incoming = [
        for (final e in m['graphDefs'] as List)
          GraphDef.fromMap((e as Map).cast<String, Object?>())
      ];
      for (final g in await graphDefs()) {
        if (incoming.every((x) => x.id != g.id)) await deleteGraphDef(g.id);
      }
      for (final g in incoming) {
        await saveGraphDef(g, notify: false);
      }
      await markGraphsSeeded(); // nicht erneut seeden
    }
    final groups = (m['groups'] as Map?)?.cast<String, dynamic>();
    if (groups != null) {
      for (final gs in ['1', '2']) {
        final g = int.parse(gs);
        final gm = (groups[gs] as Map?)?.cast<String, dynamic>();
        if (gm == null) continue;
        if (gm['order'] is List) await saveStepOrder(g, strList(gm['order']));
        if (gm['hidden'] is List) {
          await saveHiddenBuiltins(g, strList(gm['hidden']).toSet());
        }
        if (gm['deleted'] is List) {
          await saveDeletedBuiltins(g, strList(gm['deleted']).toSet());
        }
        if (gm['labels'] is Map) await saveBuiltinLabels(g, strMap(gm['labels']));
        if (gm['themes'] is Map) await saveBuiltinThemes(g, strMap(gm['themes']));
      }
    }
    if (m['quickKeys'] is List) await saveQuickKeys(strList(m['quickKeys']));
    if (m['unlocked'] is List) {
      await saveUnlockedPoints(strList(m['unlocked']).toSet());
    }
  }

  // ---------- Homescreen-Deko ----------

  Future<List<HomeDeco>> loadHomeDecos() async {
    final v = await _meta('home_decos');
    if (v == null) {
      // Werkszustand = bisheriges Design
      return [
        HomeDeco(theme: 'urwald', position: 'topRight'),
        HomeDeco(theme: 'urwald', position: 'bottomLeft'),
      ];
    }
    return [
      for (final e in jsonDecode(v) as List)
        HomeDeco.fromJson((e as Map).cast<String, dynamic>())
    ];
  }

  Future<void> saveHomeDecos(List<HomeDeco> d) =>
      _setMeta('home_decos', jsonEncode([for (final x in d) x.toJson()]));
}

// ---------------- CSV-Export (jamovi) ----------------

/// Spalten-Definitionen inkl. Gruppenzugehörigkeit (null = neutral).
List<({String label, int? group})> csvColumnDefs(List<FieldDef> defs,
    [List<String> quickKeys = const []]) {
  final defsById = {for (final d in defs) d.id: d};
  return [
    (label: 'Erfasst am', group: null),
    (label: 'Wohlbefinden (1-100) (T)', group: 1),
    (label: 'Schlaf (h) (T)', group: 1),
    (label: 'Elvanse (mg) (T)', group: 1),
    (label: 'Innere Unruhe (0-10) (T)', group: 1),
    (label: 'Medikinet (mg) (T)', group: 1),
    (label: 'Medikinet Uhrzeit (T)', group: 1),
    (label: 'Medikinet Magen (T)', group: 1),
    (label: 'Medikinet Abstand zum Essen (T)', group: 1),
    (label: 'Migraene-Intensitaet (1-10) (M)', group: 2),
    (label: 'Migraene Beginn (M)', group: 2),
    (label: 'Migraene Ende (M)', group: 2),
    (label: 'Ausloeser (M)', group: 2),
    (label: 'Begleitsymptome (M)', group: 2),
    (label: 'Notizen (M)', group: 2),
    (label: 'Migraenetag', group: null),
    for (final d in defs)
      for (final inp in d.inputs)
        (
          label: d.inputs.length == 1
              ? '${d.label}${d.group == 1 ? ' (T)' : ' (M)'}'
              : '${d.label} ${inp.label}${d.group == 1 ? ' (T)' : ' (M)'}',
          group: d.group
        ),
    for (final k in quickKeys) ...[
      (label: '${keyLabel(k, defsById)} Tages-Ø', group: 3),
      (label: '${keyLabel(k, defsById)} Tages-Min', group: 3),
      (label: '${keyLabel(k, defsById)} Tages-Max', group: 3),
    ],
  ];
}

List<String> csvHeaders(List<FieldDef> defs,
        [List<String> quickKeys = const []]) =>
    [for (final c in csvColumnDefs(defs, quickKeys)) c.label];

String _csvCell(Object? v) {
  if (v == null) return '';
  var s = v.toString();
  if (s.contains(';') || s.contains('"') || s.contains('\n')) {
    s = '"${s.replaceAll('"', '""')}"';
  }
  return s;
}

List<String> csvRow(PhaskaEntry e, List<FieldDef> defs,
        [List<String> quickKeys = const [],
        Map<String, Map<String, QuickAgg>> agg = const {}]) =>
    [
      _csvCell(DateFormat('dd.MM.yyyy HH:mm').format(e.createdAt)),
      _csvCell(e.wohlbefinden),
      _csvCell(e.schlafStunden?.toStringAsFixed(1)),
      _csvCell(e.elvanseMg == null
          ? null
          : (e.elvanseMg == 0 ? 'keine' : e.elvanseMg)),
      _csvCell(e.innereUnruhe?.toStringAsFixed(1)),
      _csvCell(e.medikinetMg == null
          ? null
          : (e.medikinetMg == 0 ? 'keine' : e.medikinetMg)),
      _csvCell(e.medikinetZeit),
      _csvCell(e.medikinetMagen),
      _csvCell(e.medikinetEssenAbstand),
      _csvCell(e.migraeneIntensitaet),
      _csvCell(e.migraeneStart),
      _csvCell(e.migraeneEnde),
      _csvCell(e.ausloeser),
      _csvCell(e.begleitsymptome),
      _csvCell(e.notizen),
      _csvCell(e.migraeneTag),
      for (final d in defs)
        for (final inp in d.inputs)
          _csvCell(_customCsv(customSubValue(e, d, inp))),
      for (final k in quickKeys) ...[
        _csvCell(agg[dayKeyOf(e.createdAt)]?[k]?.avg.toStringAsFixed(1)),
        _csvCell(agg[dayKeyOf(e.createdAt)]?[k]?.min.toStringAsFixed(1)),
        _csvCell(agg[dayKeyOf(e.createdAt)]?[k]?.max.toStringAsFixed(1)),
      ],
    ];

String _customCsv(Object? v) =>
    v == null ? '' : (v is double ? v.toStringAsFixed(1) : '$v');

Future<File> buildCsvFile(
    List<PhaskaEntry> entries, List<FieldDef> defs) async {
  final keys = await PhaskaDb.instance.quickKeys();
  final agg = keys.isEmpty
      ? const <String, Map<String, QuickAgg>>{}
      : await PhaskaDb.instance.quickDayAgg();
  final b = StringBuffer()..writeln(csvHeaders(defs, keys).join(';'));
  for (final e in entries) {
    b.writeln(csvRow(e, defs, keys, agg).join(';'));
  }
  final dir = await getApplicationDocumentsDirectory();
  final stamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
  final file = File(p.join(dir.path, 'fasy_export_$stamp.csv'));
  await file.writeAsString(b.toString());
  return file;
}

Future<void> shareCsv(List<PhaskaEntry> entries, List<FieldDef> defs) async {
  final file = await buildCsvFile(entries, defs);
  await SharePlus.instance.share(
    ShareParams(
      files: [XFile(file.path)],
      text: 'fasy Export (CSV für jamovi)',
    ),
  );
}

/// Speichert die CSV direkt im Download-Ordner des Telefons.
Future<String?> saveCsvLocally(
    List<PhaskaEntry> entries, List<FieldDef> defs) async {
  final file = await buildCsvFile(entries, defs);
  final bytes = await file.readAsBytes();
  final stamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
  return FileSaver.instance.saveFile(
    name: 'fasy_export_$stamp',
    bytes: bytes,
    fileExtension: 'csv',
    mimeType: MimeType.other,
    customMimeType: 'text/csv',
  );
}

// ---------------- Autosave (Punkt 6) ----------------

bool _autosaveRunning = false;

/// Schreibt nach jeder Änderung zeitgestempelte Exporte in den
/// App-internen Ordner „autosave". Alte Dateien bleiben erhalten.
Future<void> autosave() async {
  if (_autosaveRunning) return;
  _autosaveRunning = true;
  try {
    final entries = await PhaskaDb.instance.all();
    if (entries.isEmpty) return;
    final defs = await PhaskaDb.instance.fieldDefs();
    final keys = await PhaskaDb.instance.quickKeys();
    final agg = keys.isEmpty
        ? const <String, Map<String, QuickAgg>>{}
        : await PhaskaDb.instance.quickDayAgg();
    final stamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final dir = Directory(p.join(
        (await getApplicationDocumentsDirectory()).path, 'autosave'));
    await dir.create(recursive: true);

    final b = StringBuffer()..writeln(csvHeaders(defs, keys).join(';'));
    for (final e in entries) {
      b.writeln(csvRow(e, defs, keys, agg).join(';'));
    }
    await File(p.join(dir.path, 'fasy_autosave_$stamp.csv'))
        .writeAsString(b.toString());

    final qs = await PhaskaDb.instance.allQuick();
    if (qs.isNotEmpty) {
      final qb = StringBuffer()..writeln('Zeit;Schluessel;Wert');
      for (final q in qs.reversed) {
        qb.writeln(
            '${DateFormat('dd.MM.yyyy HH:mm').format(q.createdAt)};'
            '${_csvCell(q.label)};${q.value.toStringAsFixed(1)}');
      }
      await File(p.join(dir.path, 'fasy_einzel_$stamp.csv'))
          .writeAsString(qb.toString());
    }
  } catch (_) {
    // Autosave darf die App nie abstürzen lassen.
  } finally {
    _autosaveRunning = false;
  }
}

// ---------------- CSV-Import ----------------

/// Zerlegt CSV-Text (Semikolon) in Zeilen/Zellen; respektiert "..."-Zitate.
List<List<String>> _parseCsv(String text) {
  if (text.startsWith('﻿')) text = text.substring(1); // BOM weg
  final rows = <List<String>>[];
  var row = <String>[];
  final cell = StringBuffer();
  var inQuotes = false;
  for (var i = 0; i < text.length; i++) {
    final ch = text[i];
    if (inQuotes) {
      if (ch == '"') {
        if (i + 1 < text.length && text[i + 1] == '"') {
          cell.write('"');
          i++;
        } else {
          inQuotes = false;
        }
      } else {
        cell.write(ch);
      }
    } else if (ch == '"') {
      inQuotes = true;
    } else if (ch == ';') {
      row.add(cell.toString());
      cell.clear();
    } else if (ch == '\n') {
      row.add(cell.toString());
      cell.clear();
      rows.add(row);
      row = <String>[];
    } else if (ch != '\r') {
      cell.write(ch);
    }
  }
  if (cell.isNotEmpty || row.isNotEmpty) {
    row.add(cell.toString());
    rows.add(row);
  }
  return rows;
}

/// Entfernt das (T)/(M)-Gruppensuffix am Ende (erkennt alte phaska- und
/// neue fasy-Header gleichermaßen).
String _stripGroupSuffix(String h) =>
    h.trim().replaceAll(RegExp(r'\s*\((T|M)\)\s*$'), '').trim();

/// Spaltenname -> interner Schlüssel:
/// 'created', 'ignore', Basis-Schlüssel ('wohlbefinden' …),
/// 'c::<defId>::<subkey>' für eigene Datenpunkte, null = unbekannt.
String? _baseKeyForColumn(String column, List<FieldDef> defs) {
  final low = _stripGroupSuffix(column).toLowerCase();
  const base = <String, String>{
    'erfasst am': 'created',
    'wohlbefinden (1-100)': 'wohlbefinden',
    'schlaf (h)': 'schlaf_stunden',
    'elvanse (mg)': 'elvanse_mg',
    'innere unruhe (0-10)': 'innere_unruhe',
    'medikinet (mg)': 'medikinet_mg',
    'medikinet uhrzeit': 'medikinet_zeit',
    'medikinet magen': 'medikinet_magen',
    'medikinet abstand zum essen': 'medikinet_essen_abstand',
    'migraene-intensitaet (1-10)': 'migraene_intensitaet',
    'migraene beginn': 'migraene_start',
    'migraene ende': 'migraene_ende',
    'ausloeser': 'ausloeser',
    'begleitsymptome': 'begleitsymptome',
    'notizen': 'notizen',
    'migraenetag': 'ignore', // wird beim Import neu aus Intensität abgeleitet
  };
  final direct = base[low];
  if (direct != null) return direct;
  // Aggregate der Einzelerfassung: beim Import ignorieren (werden gerechnet)
  if (low.endsWith(' tages-ø') ||
      low.endsWith(' tages-min') ||
      low.endsWith(' tages-max')) {
    return 'ignore';
  }
  // Eigene Datenpunkte: '<DefLabel>' bzw. '<DefLabel> <InputLabel>'
  for (final d in defs) {
    final dl = d.label.toLowerCase();
    if (!low.startsWith(dl)) continue;
    if (d.inputs.length == 1 && low == dl) {
      return 'c::${d.id}::${d.inputs.first.subkey}';
    }
    if (low == dl) continue;
    final rest = low.substring(dl.length).trim();
    for (final inp in d.inputs) {
      if (rest == inp.label.toLowerCase()) {
        return 'c::${d.id}::${inp.subkey}';
      }
    }
  }
  return null;
}

double? _csvToDouble(String s) {
  final t = s.trim().replaceAll(',', '.');
  if (t.isEmpty) return null;
  return double.tryParse(t);
}

int? _csvToInt(String s) => _csvToDouble(s)?.round();

/// 'dd.MM.yyyy HH:mm' (Exportformat) oder ISO – sonst null.
DateTime? _parseEntryDate(String s) {
  final t = s.trim();
  if (t.isEmpty) return null;
  final iso = DateTime.tryParse(t);
  if (iso != null) return iso;
  final m = RegExp(r'^(\d{1,2})\.(\d{1,2})\.(\d{4})\s+(\d{1,2}):(\d{2})')
      .firstMatch(t);
  if (m == null) return null;
  return DateTime(int.parse(m[3]!), int.parse(m[2]!), int.parse(m[1]!),
      int.parse(m[4]!), int.parse(m[5]!));
}

void _applyBaseValue(
    PhaskaEntry e, String key, String cell, List<FieldDef> defs) {
  if (key == 'created' || key == 'ignore') return;
  if (cell.trim().isEmpty) return;
  switch (key) {
    case 'wohlbefinden':
      e.wohlbefinden = _csvToInt(cell);
      break;
    case 'schlaf_stunden':
      e.schlafStunden = _csvToDouble(cell);
      break;
    case 'elvanse_mg':
      e.elvanseMg =
          cell.trim().toLowerCase() == 'keine' ? 0 : _csvToInt(cell);
      break;
    case 'innere_unruhe':
      e.innereUnruhe = _csvToDouble(cell);
      break;
    case 'medikinet_mg':
      e.medikinetMg =
          cell.trim().toLowerCase() == 'keine' ? 0 : _csvToInt(cell);
      break;
    case 'medikinet_zeit':
      e.medikinetZeit = cell.trim();
      break;
    case 'medikinet_magen':
      e.medikinetMagen = cell.trim();
      break;
    case 'medikinet_essen_abstand':
      e.medikinetEssenAbstand = cell.trim();
      break;
    case 'migraene_intensitaet':
      e.migraeneIntensitaet = _csvToInt(cell);
      break;
    case 'migraene_start':
      e.migraeneStart = cell.trim();
      break;
    case 'migraene_ende':
      e.migraeneEnde = cell.trim();
      break;
    case 'ausloeser':
      e.ausloeser = cell.trim();
      break;
    case 'begleitsymptome':
      e.begleitsymptome = cell.trim();
      break;
    case 'notizen':
      e.notizen = cell.trim();
      break;
    default:
      if (key.startsWith('c::')) {
        final p = key.split('::'); // c :: defId :: subkey
        final d = defs.where((x) => x.id == p[1]).firstOrNull;
        final inp = d?.inputs.where((i) => i.subkey == p[2]).firstOrNull;
        if (d != null && inp != null) {
          final Object? v = switch (inp.type) {
            'vslider' || 'blocks' => _csvToInt(cell),
            'hslider' || 'halfblocks' => _csvToDouble(cell),
            _ => cell.trim(),
          };
          if (v != null) setCustomSubValue(e, d, inp, v);
        }
      }
  }
}

/// Importiert Semikolon-CSV (fasy-/phaska-Exportformat).
/// Rückgabe: (neu importiert, übersprungen, unbekannte Spalten).
Future<(int, int, List<String>)> importCsv(
    String csvText, List<FieldDef> defs) async {
  final rows = _parseCsv(csvText);
  if (rows.length < 2) return (0, 0, const <String>[]);
  final headers = rows.first;
  final keys = [for (final h in headers) _baseKeyForColumn(h, defs)];

  final existing = await PhaskaDb.instance.all();
  final stamps = {
    for (final e in existing) e.createdAt.toIso8601String().substring(0, 16)
  };

  final unknown = <String>[];
  for (var i = 0; i < headers.length; i++) {
    if (keys[i] == null && headers[i].trim().isNotEmpty) {
      unknown.add(headers[i].trim());
    }
  }

  var imported = 0, skipped = 0;
  final db = await PhaskaDb.instance.database;
  for (var r = 1; r < rows.length; r++) {
    final row = rows[r];
    if (row.every((c) => c.trim().isEmpty)) continue;
    final e = PhaskaEntry.empty();
    var dateOk = false;
    for (var c = 0; c < keys.length; c++) {
      final k = keys[c];
      if (k == null || k == 'ignore') continue;
      final cell = c < row.length ? row[c] : '';
      if (k == 'created') {
        final d = _parseEntryDate(cell);
        if (d != null) {
          e.createdAt = d;
          dateOk = true;
        }
        continue;
      }
      _applyBaseValue(e, k, cell, defs);
    }
    if (!dateOk) {
      skipped++;
      continue;
    }
    final stamp = e.createdAt.toIso8601String().substring(0, 16);
    if (stamps.contains(stamp)) {
      skipped++;
      continue;
    }
    stamps.add(stamp);
    await db.insert(PhaskaDb.table, e.toMap());
    imported++;
  }
  if (imported > 0) {
    Repo.bump();
    unawaited(autosave());
  }
  return (imported, skipped, unknown);
}