import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'notifications.dart';

class NativeNotifGateway extends NotifGateway {
  final _fln = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  /// Volle Planung nur auf Mobil; Desktop-io bleibt Stub (siehe supported).
  static bool get _mobile => Platform.isAndroid || Platform.isIOS;

  @override
  bool get supported => _mobile;

  @override
  Future<void> init() async {
    if (_ready || !_mobile) return;
    _ready = true;
    tzdata.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation(DateTime.now().timeZoneName));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('Europe/Berlin'));
    }
    await _fln.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: (r) {
        final p = r.payload ?? '';
        if (p.isNotEmpty) Notifications.onTap?.call(p);
      },
    );
  }

  @override
  Future<bool> requestPermission() async {
    if (!_mobile) return false;
    await init();
    if (Platform.isAndroid) {
      final android = _fln.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      return await android?.requestNotificationsPermission() ?? false;
    }
    final ios = _fln.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    return await ios?.requestPermissions(alert: true, badge: true, sound: true) ??
        false;
  }

  @override
  Future<void> cancelAll() async {
    if (_mobile) await _fln.cancelAll();
  }

  @override
  Future<void> schedule(
      {required int id,
      required DateTime when,
      required String title,
      required String body,
      required String payload}) async {
    if (!_mobile || !_ready) return;
    await _fln.zonedSchedule(
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      id,
      title,
      body,
      tz.TZDateTime.from(when, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails('fasy_reminders', 'Erinnerungen',
            importance: Importance.high, priority: Priority.high),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: payload,
    );
  }
}

NotifGateway get notifGateway => NativeNotifGateway();