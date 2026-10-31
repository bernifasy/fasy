import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Color;

/// Standardfarben (in der App änderbar).
const kDefaultGroup1Color = 0xFF3A8330; // grün – Tag
const kDefaultGroup2Color = 0xFF7E57C2; // violett – Migräne
const kDefaultQuickColor = 0xFF00897B; // türkis – Einzelerfassung
const kDefaultAttackEndColor = 0xFFEF5350; // rot – „Attacke beendet“ (Punkt 7)

class AppColors {
  static final ValueNotifier<Color> group1 =
      ValueNotifier(const Color(kDefaultGroup1Color));
  static final ValueNotifier<Color> group2 =
      ValueNotifier(const Color(kDefaultGroup2Color));
  static final ValueNotifier<Color> quick =
      ValueNotifier(const Color(kDefaultQuickColor));
  static final ValueNotifier<Color> attackEnd =
      ValueNotifier(const Color(kDefaultAttackEndColor)); // Punkt 7

  /// 'system' | 'light' | 'dark'
  static final ValueNotifier<String> themeMode = ValueNotifier('system');
}

Color groupColor(int group) =>
    group == 1 ? AppColors.group1.value : AppColors.group2.value;

class Repo {
  static final ValueNotifier<int> changes = ValueNotifier(0);
  static void bump() => changes.value++;
}

/// Dosis-Optionen (Punkt 10.2.1: Elvanse bis 70, Medikinet bis 80).
const kElvanseOptions = [20, 30, 40, 50, 60, 70];
const kMedikinetOptions = [5, 10, 15, 20, 30, 40, 50, 60, 70, 80];

/// Slides des Home-Pagers (Punkt 8.3).
const kAllSlides = ['home', 'graphs', 'quick', 'table'];

class SlideCfg {
  String id;
  bool visible;
  SlideCfg(this.id, {this.visible = true});

  Map<String, Object?> toJson() => {'id': id, 'visible': visible};
  factory SlideCfg.fromJson(Map<String, dynamic> m) =>
      SlideCfg('${m['id']}', visible: m['visible'] != false);
}

/// Slug für interne Schlüssel (v. a. Unter-Eingaben).
String inputSlug(String raw) {
  var s = raw
      .toLowerCase()
      .replaceAll('ä', 'ae')
      .replaceAll('ö', 'oe')
      .replaceAll('ü', 'ue')
      .replaceAll('ß', 'ss');
  s = s
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_+|_+$'), '');
  return s.isEmpty ? 'wert' : s;
}

/// Eine einzelne Eingabe innerhalb eines eigenen Datenpunkts.
class FieldInput {
  String subkey;
  String label;
  String type; // vslider | hslider | blocks | halfblocks | choice | time | text
  List<String> options; // nur choice
  int maxBlocks; // nur halfblocks

  FieldInput({
    required this.subkey,
    required this.label,
    required this.type,
    this.options = const [],
    this.maxBlocks = 12,
  });

  bool get numeric =>
      type == 'vslider' || type == 'hslider' || type == 'blocks' || type == 'halfblocks';

  Map<String, Object?> toJson() => {
        'subkey': subkey,
        'label': label,
        'type': type,
        'options': options,
        'maxBlocks': maxBlocks,
      };

  factory FieldInput.fromJson(Map<String, dynamic> m) => FieldInput(
        subkey: '${m['subkey'] ?? inputSlug('${m['label'] ?? 'wert'}')}',
        label: '${m['label'] ?? ''}',
        type: '${m['type'] ?? 'hslider'}',
        options: [for (final o in (m['options'] as List? ?? const [])) '$o'],
        maxBlocks: (m['maxBlocks'] as num?)?.toInt() ?? 12,
      );
}

/// Definition eines eigenen Datenpunkts (mit beliebig vielen Eingaben).
class FieldDef {
  final String id;
  final int group; // 1 oder 2
  String label;
  List<FieldInput> inputs;
  String plantTheme;
  int position;

  FieldDef({
    required this.id,
    required this.group,
    required this.label,
    List<FieldInput>? inputs,
    this.plantTheme = 'none',
    this.position = 999,
  }) : inputs = inputs ??
            [FieldInput(subkey: inputSlug(label), label: label, type: 'hslider')];

  String get type => inputs.isEmpty ? 'text' : inputs.first.type;

  Map<String, Object?> toMap() => {
        'id': id,
        'grp': group,
        'label': label,
        'type': type,
        'config': jsonEncode({
          'plantTheme': plantTheme,
          'inputs': [for (final i in inputs) i.toJson()],
        }),
        'position': position,
      };

  factory FieldDef.fromMap(Map<String, Object?> m) {
    final cfg =
        jsonDecode((m['config'] as String?) ?? '{}') as Map<String, dynamic>;
    final label = m['label'] as String;
    final rawInputs = cfg['inputs'] as List?;
    final List<FieldInput> inputs;
    if (rawInputs != null && rawInputs.isNotEmpty) {
      inputs = [
        for (final i in rawInputs)
          FieldInput.fromJson((i as Map).cast<String, dynamic>())
      ];
    } else {
      inputs = [
        FieldInput(
          subkey: inputSlug(label),
          label: label,
          type: '${m['type'] ?? 'hslider'}',
          options: [for (final o in (cfg['options'] as List? ?? const [])) '$o'],
          maxBlocks: (cfg['maxBlocks'] as num?)?.toInt() ?? 12,
        )
      ];
    }
    return FieldDef(
      id: m['id'] as String,
      group: m['grp'] as int,
      label: label,
      inputs: inputs,
      plantTheme: '${cfg['plantTheme'] ?? 'none'}',
      position: (m['position'] as num?)?.toInt() ?? 999,
    );
  }
}

// ---------------- Graphen ----------------

class GraphSeries {
  String key;
  String label;
  int color;
  GraphSeries({required this.key, required this.label, required this.color});

  Map<String, Object?> toJson() => {'key': key, 'label': label, 'color': color};

  factory GraphSeries.fromJson(Map<String, dynamic> m) => GraphSeries(
        key: '${m['key']}',
        label: '${m['label']}',
        color: (m['color'] as num?)?.toInt() ?? 0xFF000000,
      );
}

class GraphDef {
  final String id;
  String title;
  String type;
  int rangeDays;
  List<GraphSeries> series;
  int position;

  GraphDef({
    required this.id,
    required this.title,
    this.type = 'line',
    this.rangeDays = 30,
    this.series = const [],
    this.position = 999,
  });

  Map<String, Object?> toMap() => {
        'id': id,
        'title': title,
        'cfg': jsonEncode({
          'type': type,
          'rangeDays': rangeDays,
          'series': [for (final s in series) s.toJson()],
        }),
        'position': position,
      };

  factory GraphDef.fromMap(Map<String, Object?> m) {
    final cfg = jsonDecode((m['cfg'] as String?) ?? '{}') as Map<String, dynamic>;
    return GraphDef(
      id: m['id'] as String,
      title: m['title'] as String,
      type: '${cfg['type'] ?? 'line'}',
      rangeDays: (cfg['rangeDays'] as num?)?.toInt() ?? 30,
      series: [
        for (final s in (cfg['series'] as List? ?? const []))
          GraphSeries.fromJson((s as Map).cast<String, dynamic>())
      ],
      position: (m['position'] as num?)?.toInt() ?? 999,
    );
  }
}

// ---------------- Eintrag ----------------

class PhaskaEntry {
  int? id;
  DateTime createdAt;

  int? wohlbefinden;
  double? schlafStunden;
  int? elvanseMg;
  String? elvanseZeit; // Punkt 5: Uhrzeit auch für Elvanse
  double? innereUnruhe;
  int? medikinetMg;
  String? medikinetZeit;
  String? medikinetMagen;
  String? medikinetEssenAbstand;

  int? migraeneIntensitaet;
  String? migraeneStart;
  String? migraeneEnde;
  String? ausloeser;
  String? begleitsymptome;
  String? notizen;

  Map<String, Object?> custom;

  PhaskaEntry({
    this.id,
    required this.createdAt,
    this.wohlbefinden,
    this.schlafStunden,
    this.elvanseMg,
    this.elvanseZeit,
    this.innereUnruhe,
    this.medikinetMg,
    this.medikinetZeit,
    this.medikinetMagen,
    this.medikinetEssenAbstand,
    this.migraeneIntensitaet,
    this.migraeneStart,
    this.migraeneEnde,
    this.ausloeser,
    this.begleitsymptome,
    this.notizen,
    Map<String, Object?>? custom,
  }) : custom = custom ?? {};

  factory PhaskaEntry.empty() => PhaskaEntry(createdAt: DateTime.now());

  String get migraeneTag => (migraeneIntensitaet ?? 0) > 2 ? 'ja' : 'nein';

  bool get hasG1 =>
      wohlbefinden != null ||
      schlafStunden != null ||
      elvanseMg != null ||
      elvanseZeit != null ||
      innereUnruhe != null ||
      medikinetMg != null;

  bool get hasG2 =>
      migraeneIntensitaet != null ||
      migraeneStart != null ||
      migraeneEnde != null ||
      (ausloeser?.isNotEmpty ?? false) ||
      (begleitsymptome?.isNotEmpty ?? false) ||
      (notizen?.isNotEmpty ?? false);

  Map<String, Object?> toMap() => {
        'id': id,
        'created_at': createdAt.toIso8601String(),
        'wohlbefinden': wohlbefinden,
        'schlaf_stunden': schlafStunden,
        'elvanse_mg': elvanseMg,
        'elvanse_zeit': elvanseZeit, // Punkt 5
        'innere_unruhe': innereUnruhe,
        'medikinet_mg': medikinetMg,
        'medikinet_zeit': medikinetZeit,
        'medikinet_magen': medikinetMagen,
        'medikinet_essen_abstand': medikinetEssenAbstand,
        'migraene_intensitaet': migraeneIntensitaet,
        'migraene_start': migraeneStart,
        'migraene_ende': migraeneEnde,
        'ausloeser': ausloeser,
        'begleitsymptome': begleitsymptome,
        'notizen': notizen,
        'migraene_tag': migraeneTag,
        'custom_values': jsonEncode(custom),
      };

  factory PhaskaEntry.fromMap(Map<String, Object?> m) => PhaskaEntry(
        id: m['id'] as int?,
        createdAt: DateTime.parse(m['created_at'] as String),
        wohlbefinden: m['wohlbefinden'] as int?,
        schlafStunden: (m['schlaf_stunden'] as num?)?.toDouble(),
        elvanseMg: m['elvanse_mg'] as int?,
        elvanseZeit: m['elvanse_zeit'] as String?, // Punkt 5
        innereUnruhe: (m['innere_unruhe'] as num?)?.toDouble(),
        medikinetMg: m['medikinet_mg'] as int?,
        medikinetZeit: m['medikinet_zeit'] as String?,
        medikinetMagen: m['medikinet_magen'] as String?,
        medikinetEssenAbstand: m['medikinet_essen_abstand'] as String?,
        migraeneIntensitaet: m['migraene_intensitaet'] as int?,
        migraeneStart: m['migraene_start'] as String?,
        migraeneEnde: m['migraene_ende'] as String?,
        ausloeser: m['ausloeser'] as String?,
        begleitsymptome: m['begleitsymptome'] as String?,
        notizen: m['notizen'] as String?,
        custom: (jsonDecode((m['custom_values'] as String?) ?? '{}') as Map)
            .cast<String, Object?>(),
      );
}

// ---------------- Custom-Werte ----------------

Object? customSubValue(PhaskaEntry e, FieldDef d, FieldInput inp) {
  final v = e.custom[d.id];
  if (v is Map) return v[inp.subkey];
  if (v != null && d.inputs.isNotEmpty && inp.subkey == d.inputs.first.subkey) {
    return v;
  }
  return null;
}

void setCustomSubValue(
    PhaskaEntry e, FieldDef d, FieldInput inp, Object? value) {
  final cur = e.custom[d.id];
  final map = <String, Object?>{};
  if (cur is Map) {
    for (final en in cur.entries) {
      map['${en.key}'] = en.value;
    }
  } else if (cur != null && d.inputs.isNotEmpty) {
    map[d.inputs.first.subkey] = cur;
  }
  map[inp.subkey] = value;
  e.custom[d.id] = map;
}

String fmtDe(num v) {
  final d = v.toDouble();
  if (d == d.roundToDouble()) return d.round().toString();
  return d.toStringAsFixed(1).replaceAll('.', ',');
}

String fmtOne(Object? v) {
  if (v == null) return '—';
  if (v is num) return fmtDe(v);
  final s = '$v';
  return s.isEmpty ? '—' : s;
}

String fmtCustomDisplay(Object? v) => fmtOne(v);

// ---------------- Einzelerfassung ----------------

class QuickValue {
  int? id;
  String defKey;
  String label;
  double value;
  DateTime createdAt;

  QuickValue(
      {this.id,
      required this.defKey,
      required this.label,
      required this.value,
      required this.createdAt});

  Map<String, Object?> toMap() => {
        'id': id,
        'def_key': defKey,
        'label': label,
        'value': value,
        'created_at': createdAt.toIso8601String(),
      };

  factory QuickValue.fromMap(Map<String, Object?> m) => QuickValue(
        id: m['id'] as int?,
        defKey: m['def_key'] as String,
        label: m['label'] as String,
        value: (m['value'] as num).toDouble(),
        createdAt: DateTime.parse(m['created_at'] as String),
      );
}

const builtinValueLabels = <String, String>{
  'wohlbefinden': 'Wohlbefinden',
  'schlaf': 'Schlaf (h)',
  'elvanse': 'Elvanse (mg)',
  'innere_unruhe': 'Innere Unruhe',
  'medikinet': 'Medikinet (mg)',
  'intensitaet': 'Migräne-Intensität',
};

String? builtinValueKeyOf(String id) => switch (id) {
      'wohlbefinden' => 'wohlbefinden',
      'schlaf' => 'schlaf',
      'elvanse' => 'elvanse',
      'unruhe' => 'innere_unruhe',
      'medikinet' => 'medikinet',
      'intensitaet' => 'intensitaet',
      _ => null,
    };

// Abwärtskompatibler Name (wird in edit_schema/quick-Capture genutzt).
String? quickKeyForStep(String id) => builtinValueKeyOf(id);

String keyLabel(String key, Map<String, FieldDef> defsById) {
  if (builtinValueLabels.containsKey(key)) return builtinValueLabels[key]!;
  final p = key.split('::');
  if (p.length == 2) {
    final d = defsById[p[0]];
    if (d != null) {
      for (final i in d.inputs) {
        if (i.subkey == p[1]) {
          return d.inputs.length == 1 ? d.label : '${d.label} ${i.label}';
        }
      }
    }
  }
  return key;
}

double keyMax(String key, Map<String, FieldDef> defsById) {
  switch (key) {
    case 'wohlbefinden':
      return 100;
    case 'schlaf':
      return 12;
    case 'elvanse':
      return 70; // Punkt 10.2.1
    case 'innere_unruhe':
      return 10;
    case 'medikinet':
      return 80; // Punkt 10.2.1
    case 'intensitaet':
      return 10;
  }
  final p = key.split('::');
  if (p.length == 2) {
    final d = defsById[p[0]];
    if (d != null) {
      for (final i in d.inputs) {
        if (i.subkey == p[1]) {
          return switch (i.type) {
            'vslider' => 100.0,
            'hslider' => 10.0,
            'blocks' => 10.0,
            'halfblocks' => i.maxBlocks.toDouble(),
            _ => 100.0,
          };
        }
      }
    }
  }
  return 100;
}

bool keyIsInt(String key, Map<String, FieldDef> defsById) {
  if (key == 'innere_unruhe' || key == 'schlaf') return false;
  final p = key.split('::');
  if (p.length == 2) {
    final t = defsById[p[0]]
        ?.inputs
        .where((i) => i.subkey == p[1])
        .firstOrNull
        ?.type;
    return t == 'vslider' || t == 'blocks';
  }
  return false;
}

int keyGroup(String key, Map<String, FieldDef> defsById) {
  if (builtinValueLabels.containsKey(key)) {
    return key == 'intensitaet' ? 2 : 1;
  }
  return defsById[key.split('::').first]?.group ?? 1;
}

int _ci(double v, int min, int max) {
  final r = v.round();
  return r < min ? min : (r > max ? max : r);
}

void setEntryValueForKey(
    PhaskaEntry e, String key, double v, Map<String, FieldDef> defsById) {
  switch (key) {
    case 'wohlbefinden':
      e.wohlbefinden = _ci(v, 1, 100);
      return;
    case 'schlaf':
      final h = (v * 2).round() / 2;
      e.schlafStunden = h < 0 ? 0.0 : (h > 24 ? 24.0 : h);
      return;
    case 'elvanse':
      e.elvanseMg = v.round();
      return;
    case 'innere_unruhe':
      e.innereUnruhe = v < 0 ? 0.0 : (v > 10 ? 10.0 : v);
      return;
    case 'medikinet':
      e.medikinetMg = v.round();
      return;
    case 'intensitaet':
      e.migraeneIntensitaet = _ci(v, 1, 10);
      return;
  }
  final p = key.split('::');
  if (p.length == 2) {
    final d = defsById[p[0]];
    final inp = d?.inputs.where((i) => i.subkey == p[1]).firstOrNull;
    if (d != null && inp != null) {
      setCustomSubValue(e, d, inp, keyIsInt(key, defsById) ? v.round() : v);
    }
  }
}

/// Setzt einen Schlüssel am Tageseintrag auf „nicht erfasst" zurück
/// (Punkt 2: Bereinigung zurückgeschriebener Durchschnitte).
void clearEntryValueForKey(
    PhaskaEntry e, String key, Map<String, FieldDef> defsById) {
  switch (key) {
    case 'wohlbefinden':
      e.wohlbefinden = null;
      return;
    case 'schlaf':
      e.schlafStunden = null;
      return;
    case 'elvanse':
      e.elvanseMg = null;
      return;
    case 'innere_unruhe':
      e.innereUnruhe = null;
      return;
    case 'medikinet':
      e.medikinetMg = null;
      return;
    case 'intensitaet':
      e.migraeneIntensitaet = null;
      return;
  }
  final p = key.split('::');
  if (p.length == 2) {
    final d = defsById[p[0]];
    final inp = d?.inputs.where((i) => i.subkey == p[1]).firstOrNull;
    if (d != null && inp != null) setCustomSubValue(e, d, inp, null);
  }
}

// ---------------- Homescreen-Deko ----------------

class HomeDeco {
  String theme;
  String position;
  String size;

  HomeDeco({required this.theme, this.position = 'topRight', this.size = 'm'});

  Map<String, Object?> toJson() =>
      {'theme': theme, 'position': position, 'size': size};

  factory HomeDeco.fromJson(Map<String, dynamic> m) => HomeDeco(
        theme: '${m['theme'] ?? 'urwald'}',
        position: '${m['position'] ?? 'topRight'}',
        size: '${m['size'] ?? 'm'}',
      );
}

class AppDeco {
  static final ValueNotifier<List<HomeDeco>> items = ValueNotifier(const []);
}