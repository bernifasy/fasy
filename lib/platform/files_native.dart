import 'dart:io';
import 'dart:typed_data';

import 'package:file_saver/file_saver.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'files_stub.dart';

class NativeFilesGateway extends FilesGateway {
  @override
  Future<void> share(String fileName, List<int> bytes,
      {required String mime, required String text}) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, fileName));
    await file.writeAsBytes(bytes);
    await SharePlus.instance
        .share(ShareParams(files: [XFile(file.path)], text: text));
  }

  @override
  Future<void> shareMany(List<(String, List<int>, String)> files,
      {required String text}) async {
    // Punkt 2: große Tabelle + Einzelerfassungstabelle in einem Sharesheet.
    final dir = await getApplicationDocumentsDirectory();
    final xfiles = <XFile>[];
    for (final (name, bytes, _) in files) {
      final f = File(p.join(dir.path, name));
      await f.writeAsBytes(bytes);
      xfiles.add(XFile(f.path));
    }
    await SharePlus.instance.share(ShareParams(files: xfiles, text: text));
  }

  @override
  Future<String?> saveLocally(
      String fileName, List<int> bytes, String mime) async {
    final dot = fileName.lastIndexOf('.');
    return FileSaver.instance.saveFile(
      name: dot > 0 ? fileName.substring(0, dot) : fileName,
      bytes: Uint8List.fromList(bytes),
      fileExtension: dot > 0 ? fileName.substring(dot + 1) : '',
      mimeType: MimeType.other,
      customMimeType: mime,
    );
  }

  @override
  Future<void> autosave(String fileName, List<int> bytes) async {
    final dir = Directory(p.join(
        (await getApplicationDocumentsDirectory()).path, 'autosave'));
    await dir.create(recursive: true);
    await File(p.join(dir.path, fileName)).writeAsBytes(bytes);
  }
}

FilesGateway get filesGateway => NativeFilesGateway();