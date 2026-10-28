/// Android-Homescreen-Widgets; im Web laufen dieselben Signaturen als No-Op.
export 'widget_bridge_stub.dart'
    if (dart.library.io) 'widget_bridge_native.dart';