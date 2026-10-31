import 'dart:convert';

import 'db.dart';
import 'l10n.dart';
import 'notifications_stub.dart'
    if (dart.library.io) 'notifications_native.dart';

export 'notifications_stub.dart' show NotifGateway, notifGateway;

/// Eine Erinnerung aus dem Einstellungsmenü (Punkt 8.5).
class NotifCfg {
  int id; // stabil, eindeutig
  String type; // 'standard' | 'med' | 'custom'
  String target; // standard: 'g1'/'g2' · med: Medikamentenname · custom: ''
  String time; // 'HH:mm'
  String text; // nur custom
  bool skipIfDone; // nur standard/g1: auslassen, wenn heute schon erfasst
  bool enabled;

  NotifCfg({
    required this.id,
    required this.type,
    this.target = 'g1',
    required this.time,
    this.text = '',
    this.skipIfDone = true,
    this.enabled = true,
  });

  Map<String, Object?> toJson() => {
        'id': id, 'type': type, 'target': target, 'time': time,
        'text': text, 'skip': skipIfDone, 'enabled': enabled,
      };

  factory NotifCfg.fromJson(Map<String, dynamic> m) => NotifCfg(
        id: (m['id'] as num).toInt(),
        type: '${m['type']}',
        target: '${m['target'] ?? 'g1'}',
        time: '${m['time'] ?? '20:00'}',
        text: '${m['text'] ?? ''}',
        skipIfDone: m['skip'] != false,
        enabled: m['enabled'] != false,
      );
}

class Notifications {
  Notifications._();

  /// Auf dieser Plattform vom System unterstützt?
  static bool get supported => notifGateway.supported;

  static Future<List<NotifCfg>> load() async {
    final raw = await PhaskaDb.instance.getMeta('notifications');
    if (raw == null) return [];
    return [
      for (final e in jsonDecode(raw) as List)
        NotifCfg.fromJson((e as Map).cast<String, dynamic>())
    ];
  }

  static Future<void> saveAll(List<NotifCfg> list) async {
    await PhaskaDb.instance
        .setMeta('notifications', jsonEncode([for (final c in list) c.toJson()]));
    await rescheduleAll();
  }

  static String bodyFor(NotifCfg c) => switch (c.type) {
        'standard' => S
            .t('notif_body_capture')
            .replaceAll('{x}', c.target == 'g2' ? S.t('cap_group_mig') : ''),
        'med' => S.t('notif_body_med').replaceAll('{x}', c.target),
        _ => c.text,
      };

  /// Plant die nächsten 7 Tage neu (läuft nach jeder Datenänderung).
  /// Punkt 8.5.I: Tage mit Tageserfassung nach 04:00 werden übersprungen,
  /// solange skipIfDone aktiv ist.
  static Future<void> rescheduleAll() async {
    if (!supported) return;
    await notifGateway.init();
    await notifGateway.cancelAll();
    final list = (await load()).where((c) => c.enabled).toList();
    if (list.isEmpty) return;
    final now = DateTime.now();
    for (final c in list) {
      final parts = c.time.split(':');
      final h = int.tryParse(parts[0]) ?? 20;
      final m = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
      for (var d = 0; d < 7; d++) {
        final day = DateTime(now.year, now.month, now.day + d, h, m);
        if (day.isBefore(now)) continue;
        if (c.type == 'standard' && c.target == 'g1' && c.skipIfDone) {
          if (await PhaskaDb.instance.hasDayCaptureAfter4(day)) continue;
        }
        await notifGateway.schedule(
          id: c.id * 10 + d,
          when: day,
          title: 'fasy',
          body: bodyFor(c),
          payload: c.type == 'standard' ? 'capture:${c.target}' : '',
        );
      }
    }
  }

  /// Wird beim Antippen einer Benachrichtigung aufgerufen (Deep-Link in die
  /// Erfassung). main.dart registriert den Callback.
  static void Function(String payload)? onTap;
}