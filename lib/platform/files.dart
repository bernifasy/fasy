/// Plattform-Abstraktion für Datei-Ausgänge:
/// nativ → echte Dateien/Sharesheet, Web → Browser-Download.
library;
export 'files_stub.dart'
    if (dart.library.io) 'files_native.dart'
    if (dart.library.js_interop) 'files_web.dart';