import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

import 'files_stub.dart';

class WebFilesGateway extends FilesGateway {
  void _download(String fileName, List<int> bytes, String mime) {
    final data = bytes is Uint8List ? bytes : Uint8List.fromList(bytes);
    final blob =
        web.Blob([data.toJS].toJS, web.BlobPropertyBag(type: mime));
    final url = web.URL.createObjectURL(blob);
    final anchor = web.document.createElement('a') as web.HTMLAnchorElement
      ..href = url
      ..download = fileName
      ..style.display = 'none';
    web.document.body?.appendChild(anchor);
    anchor.click();
    anchor.remove();
    web.URL.revokeObjectURL(url);
  }

  @override
  Future<void> share(String fileName, List<int> bytes,
          {required String mime, required String text}) async =>
      _download(fileName, bytes, mime);

  @override
  Future<void> shareMany(List<(String, List<int>, String)> files,
      {required String text}) async {
    // Web kennt kein Multi-File-Teilen → zwei Downloads nacheinander.
    for (final (name, bytes, mime) in files) {
      _download(name, bytes, mime);
      await Future.delayed(const Duration(milliseconds: 350));
    }
  }

  @override
  Future<String?> saveLocally(
      String fileName, List<int> bytes, String mime) async {
    _download(fileName, bytes, mime);
    return fileName;
  }

  @override
  Future<void> autosave(String fileName, List<int> bytes) async {
    // Kein Dateisystem im Browser.
  }
}

FilesGateway get filesGateway => WebFilesGateway();