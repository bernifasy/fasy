import 'package:flutter/foundation.dart';

abstract class NotifGateway {
  bool get supported;
  Future<void> init();
  Future<bool> requestPermission();
  Future<void> cancelAll();
  Future<void> schedule(
      {required int id,
      required DateTime when,
      required String title,
      required String body,
      required String payload});
}

class StubNotifGateway extends NotifGateway {
  @override
  bool get supported => false;
  @override
  Future<void> init() async {}
  @override
  Future<bool> requestPermission() async {
    debugPrint('Benachrichtigungen: auf dieser Plattform nicht verfügbar.');
    return false;
  }

  @override
  Future<void> cancelAll() async {}
  @override
  Future<void> schedule(
      {required int id,
      required DateTime when,
      required String title,
      required String body,
      required String payload}) async {}
}

NotifGateway get notifGateway => StubNotifGateway();