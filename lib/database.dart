import 'package:drift/drift.dart';

import 'connection/connection.dart';

part 'database.g.dart';

// ============================================================================
// drift-Schema – Tabellen-/Spaltennamen byteidentisch zum alten sqflite-Schema.
// onCreate/onUpgrade laufen ABSICHTLICH über rohe SQL-Statements, damit die
// bestehende phaska.db (user_version 4) auf dem Telefon exakt wie bisher
// migriert wird und Neuinstallationen dasselbe sqlite_master-Schema erhalten.
// ============================================================================

@DataClassName('EntryRow')
class Entries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get createdAt => text().named('created_at')();
  IntColumn get wohlbefinden => integer().nullable()();
  RealColumn get schlafStunden => real().nullable().named('schlaf_stunden')();
  IntColumn get elvanseMg => integer().nullable().named('elvanse_mg')();
  RealColumn get innereUnruhe => real().nullable().named('innere_unruhe')();
  IntColumn get medikinetMg => integer().nullable().named('medikinet_mg')();
  TextColumn get medikinetZeit => text().nullable().named('medikinet_zeit')();
  TextColumn get medikinetMagen => text().nullable().named('medikinet_magen')();
  TextColumn get medikinetEssenAbstand =>
      text().nullable().named('medikinet_essen_abstand')();
  IntColumn get migraeneIntensitaet =>
      integer().nullable().named('migraene_intensitaet')();
  TextColumn get migraeneStart => text().nullable().named('migraene_start')();
  TextColumn get migraeneEnde => text().nullable().named('migraene_ende')();
  TextColumn get ausloeser => text().nullable()();
  TextColumn get begleitsymptome => text().nullable()();
  TextColumn get notizen => text().nullable()();
  TextColumn get migraeneTag =>
      text().named('migraene_tag').withDefault(const Constant('nein'))();
  TextColumn get customValues => text().nullable().named('custom_values')();
}

@DataClassName('FieldDefRow')
class FieldDefs extends Table {
  TextColumn get id => text()();
  IntColumn get grp => integer()();
  TextColumn get label => text()();
  TextColumn get type => text()();
  TextColumn get config => text().nullable()();
  IntColumn get position => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('MetaRow')
class Meta extends Table {
  TextColumn get key => text()();
  TextColumn get value => text().nullable()();

  @override
  Set<Column> get primaryKey => {key};
}

@DataClassName('GraphDefRow')
class GraphDefs extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get cfg => text()();
  IntColumn get position => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('QuickValueRow')
class QuickValues extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get defKey => text().named('def_key')();
  TextColumn get label => text()();
  RealColumn get value => real()();
  TextColumn get createdAt => text().named('created_at')();
}

// ----------------------------------------------------------------------------
// SQL wie im alten sqflite-db.dart – identisch, Zeichen für Zeichen.
// ----------------------------------------------------------------------------

const _sqlCreateEntries = '''
      CREATE TABLE entries (
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
      )''';

const _sqlCreateFieldDefs =
    'CREATE TABLE IF NOT EXISTS field_defs (id TEXT PRIMARY KEY, grp INTEGER NOT NULL, label TEXT NOT NULL, type TEXT NOT NULL, config TEXT, position INTEGER)';

const _sqlCreateMeta =
    'CREATE TABLE IF NOT EXISTS meta (key TEXT PRIMARY KEY, value TEXT)';

const _sqlCreateGraphen =
    'CREATE TABLE IF NOT EXISTS graph_defs (id TEXT PRIMARY KEY, title TEXT NOT NULL, cfg TEXT NOT NULL, position INTEGER)';

const _sqlCreateQuick = '''
      CREATE TABLE IF NOT EXISTS quick_values (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        def_key TEXT NOT NULL,
        label TEXT NOT NULL,
        value REAL NOT NULL,
        created_at TEXT NOT NULL
      )''';

@DriftDatabase(tables: [Entries, FieldDefs, Meta, GraphDefs, QuickValues])
class FasyDatabase extends _$FasyDatabase {
  FasyDatabase() : super(openConnection());

  /// Versions-Kontinuität: sqflite endete bei 4 → drift startet bei 5.
  /// Geräte mit v4 laufen durch ein No-Op-Upgrade, Daten bleiben liegen.
  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          // Neugerät / Web: dasselbe Schema wie früher sqflite-onCreate.
          await m.database.customStatement(_sqlCreateEntries);
          // _createExtras(db)
          await m.database.customStatement(_sqlCreateFieldDefs);
          await m.database.customStatement(_sqlCreateMeta);
          await m.database.customStatement(_sqlCreateGraphen);
          // _createQuick(db)
          await m.database.customStatement(_sqlCreateQuick);
        },
        onUpgrade: (m, from, to) async {
          // Spiegelt exakt den alten sqflite-onUpgrade-Pfad.
          if (from < 2) {
            await m.database.customStatement(
                'ALTER TABLE entries ADD COLUMN medikinet_essen_abstand TEXT');
            await m.database
                .customStatement('ALTER TABLE entries ADD COLUMN custom_values TEXT');
            // _createExtras(db)
            await m.database.customStatement(_sqlCreateFieldDefs);
            await m.database.customStatement(_sqlCreateMeta);
            await m.database.customStatement(_sqlCreateGraphen);
          }
          if (from < 3) {
            await m.database.customStatement(_sqlCreateGraphen);
          }
          if (from < 4) {
            await m.database.customStatement(_sqlCreateQuick);
          }
          // 4 → 5: bewusst NICHTS. Reine Versionsanhebung für die
          // drift-Übernahme. Die S23-Bestandsdaten bleiben unangetastet.
        },
      );
}