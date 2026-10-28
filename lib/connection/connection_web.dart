import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

/// Web: sqlite3 als WASM-Modul + drift-Worker (liegen beide in web/).
/// Persistenz wählt drift automatisch (OPFS, sonst IndexedDB-Fallback).
QueryExecutor openConnection() => LazyDatabase(() async {
      final result = await WasmDatabase.open(
        databaseName: 'phaska',
        sqlite3Uri: Uri.parse('sqlite3.wasm'),
        driftWorkerUri: Uri.parse('drift_worker.dart.js'),
      );
      if (result.missingFeatures.isNotEmpty) {
        // Hinweis im Browser-Log, falls z. B. private Fenster die
        // persistente Speicherung verhindern.
        // ignore: avoid_print
        print('fasy/web Storage: ${result.chosenImplementation} '
            '(fehlend: ${result.missingFeatures})');
      }
      return result.resolvedExecutor;
    });