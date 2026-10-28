/// Wählt zur Compile-Zeit die passende Datenbank-Verbindung:
/// nativ (ffi) → echte phaska.db-Datei, Web → WASM/sqlite3 (IndexedDB/OPFS).
export 'connection_stub.dart'
    if (dart.library.ffi) 'connection_native.dart'
    if (dart.library.js_interop) 'connection_web.dart';