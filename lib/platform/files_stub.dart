/// Schnittstelle für alles, was „eine Datei rausschreibt".
abstract class FilesGateway {
  /// „Teilen": nativ Sharesheet, Web Browser-Download.
  Future<void> share(String fileName, List<int> bytes,
      {required String mime, required String text});

  /// Dauerhaft speichern: nativ via file_saver (Download-/Dokumente-Ordner),
  /// Web Browser-Download. Rückgabe = Text für die Snackbar (Pfad/Dateiname).
  Future<String?> saveLocally(String fileName, List<int> bytes, String mime);

  /// Autosave in den app-internen Ordner. Web: bewusst ohne Wirkung –
  /// die PWA-Persistenz liegt in der Browser-Datenbank (IndexedDB/OPFS).
  Future<void> autosave(String fileName, List<int> bytes);
  /// Mehrere Dateien gleichzeitig teilen (Punkt 2: Export-Bundle).
  Future<void> shareMany(List<(String, List<int>, String)> files,
      {required String text});
}

FilesGateway get filesGateway =>
    throw UnsupportedError('Kein Datei-Gateway für diese Plattform.');