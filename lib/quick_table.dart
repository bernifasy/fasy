import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'capture/steps.dart';
import 'onboarding.dart';
import 'db.dart';
import 'l10n.dart';
import 'models.dart';
import 'quick_capture.dart';

/// Tabelle aller Einzelerfassungen (editierbar: Wert, Zeitpunkt, Löschen).
class QuickTableScreen extends StatefulWidget {
  const QuickTableScreen({super.key});

  @override
  State<QuickTableScreen> createState() => _QuickTableScreenState();
}

class _QuickTableScreenState extends State<QuickTableScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  List<QuickValue>? _values;
  Map<String, FieldDef> _defs = {};

  @override
  void initState() {
    super.initState();
    Repo.changes.addListener(_load);
    _load();
  }

  @override
  void dispose() {
    Repo.changes.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    final v = await PhaskaDb.instance.allQuick();
    final d = await PhaskaDb.instance.fieldDefs();
    if (mounted) {
      setState(() {
        _values = v;
        _defs = {for (final x in d) x.id: x};
      });
    }
  }

  Future<void> _editValue(QuickValue q) async {
    double? v = q.value;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          title: Text(q.label),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: quickValueInput(
                  q.defKey, customInputFor(q.defKey, _defs), v,
                  (nv) => setD(() => v = nv)),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Abbrechen')),
            FilledButton(
                onPressed:
                    v == null ? null : () => Navigator.pop(ctx, true),
                child: const Text('Übernehmen')),
          ],
        ),
      ),
    );
    if (ok == true && v != null) {
      await PhaskaDb.instance.updateQuick(QuickValue(
          id: q.id,
          defKey: q.defKey,
          label: q.label,
          value: v!,
          createdAt: q.createdAt));
    }
  }

  Future<void> _editTime(QuickValue q) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
        context: context,
        initialDate: q.createdAt,
        firstDate: DateTime(2015),
        lastDate: now);
    if (picked == null || !mounted) return;
    final prev = TimeOfDay.fromDateTime(q.createdAt);
    final t = await pickWheelTime(context, formatClock(prev));
    final time = t == null ? prev : parseClock(t)!;
    if (!mounted) return;
    await PhaskaDb.instance.updateQuick(QuickValue(
        id: q.id,
        defKey: q.defKey,
        label: q.label,
        value: q.value,
        createdAt: DateTime(
            picked.year, picked.month, picked.day, time.hour, time.minute)));
  }

  Future<void> _delete(QuickValue q) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Messwert löschen?'),
        content: const Text(
            'Der einzelne Messwert wird entfernt. Tages-Ø, Min und Max werden neu berechnet.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Abbrechen')),
          FilledButton(
              style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(ctx).colorScheme.error,
                  foregroundColor: Theme.of(ctx).colorScheme.onError),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Löschen')),
        ],
      ),
    );
    if (ok == true) await PhaskaDb.instance.deleteQuick(q);
  }

  Future<void> _options(QuickValue q) async {
    final a = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Wert ändern'),
              onTap: () => Navigator.pop(ctx, 'value')),
          ListTile(
              leading: const Icon(Icons.schedule_outlined),
              title: const Text('Zeitpunkt ändern'),
              onTap: () => Navigator.pop(ctx, 'time')),
          ListTile(
              leading: Icon(Icons.delete_outline,
                  color: Theme.of(ctx).colorScheme.error),
              title: const Text('Löschen'),
              onTap: () => Navigator.pop(ctx, 'delete')),
        ]),
      ),
    );
    if (a == 'value') _editValue(q);
    if (a == 'time') _editTime(q);
    if (a == 'delete') _delete(q);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // KeepAlive
    final theme = Theme.of(context);
    final values = _values;
    return Scaffold(
      body: SafeArea(
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(children: [
              Text(S.t('screen_quick'),
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const Spacer(),
              if (values != null)
                Text('${values.length} Messungen',
                    style: theme.textTheme.labelLarge),
            ]),
          ),
          if (values != null && values.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text('Lange auf eine Zeile: bearbeiten oder löschen.',
                  style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant)),
            ),
          Expanded(
            child: values == null
                ? const Center(child: CircularProgressIndicator())
                : values.isEmpty
                    ? Center(
                        child: Text(
                            'Noch keine Einzelmessungen.\nÜber „Einzelwert erfassen" auf dem Startscreen starten.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant)))
                    : ListView.separated(
                        padding: const EdgeInsets.only(bottom: 24),
                        itemCount: values.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, i) {
                          final q = values[i];
                          return ListTile(
                            key: i == 0 ? kKeyQuickFirstRow : null,
                            onLongPress: () => _options(q),
                            leading: CircleAvatar(
                                radius: 6,
                                backgroundColor: AppColors.quick.value),
                            title: Text(q.label),
                            subtitle: Text(
                                DateFormat('dd.MM.yyyy · HH:mm')
                                    .format(q.createdAt)),
                            trailing: Text(fmtDe(q.value),
                                style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold)),
                          );
                        },
                      ),
          ),
        ]),
      ),
    );
  }
}