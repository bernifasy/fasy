import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Nativ (Android): die Datei liegt exakt dort, wo sie sqflite angelegt hat –
/// <AppData>/databases/phaska.db. Die S23-Bestandsdaten bleiben liegen.
QueryExecutor openConnection() => LazyDatabase(() async {
      final dir = await _databaseDir();
      return NativeDatabase.createInBackground(
          File(p.join(dir.path, 'phaska.db')));
    });

Future<Directory> _databaseDir() async {
  final support = await getApplicationSupportDirectory();
  if (Platform.isAndroid) {
    // sqflite nutzt <AppData>/databases – getApplicationSupportDirectory()
    // liefert <AppData>/files, also eine Ebene hoch und in "databases".
    final dir = Directory(p.join(support.parent.path, 'databases'));
    await dir.create(recursive: true);
    return dir;
  }
  // Desktop/iOS: keine Bestandsinstallationen → eigener Ordner reicht.
  return support;
}