import 'package:flutter/foundation.dart';

/// Web-Fallback: Homescreen-Widgets gibt es nur unter Android –
/// dieselben Signaturen, überall No-Ops.
Future<void> initWidgetLinks(ValueChanged<Uri?> onLink) async {}

Future<void> updateHomeWidgets() async {}

Future<void> setGraphWidgetId(String id) async {}