import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'capture/capture_flow.dart';
import 'db.dart';
import 'l10n.dart';
import 'models.dart';
import 'onboarding.dart' show kKeyExportFab;
import 'widgets.dart';

class TableScreen extends StatefulWidget {
  const TableScreen({super.key});

  @override
  State<TableScreen> createState() => _TableScreenState();
}

class _TableScreenState extends State<TableScreen> {
  List<PhaskaEntry>? _entries;
  List<FieldDef> _defs = const [];
  List<String> _quickKeys = const [];
  Map<String, Map<String, QuickAgg>> _agg = const {};
  bool _busy = false;

  /// Punkt 3: nur diese Leiste scrollt die Tabelle horizontal.
  final _hCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    Repo.changes.addListener(_load);
    _load();
  }

  @override
  void dispose() {
    Repo.changes.removeListener(_load);
    _hCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final e = await PhaskaDb.instance.all();
    final d = await PhaskaDb.instance.fieldDefs();
    final k = await PhaskaDb.instance.quickKeys();
    final a = k.isEmpty
        ? const <String, Map<String, QuickAgg>>{}
        : await PhaskaDb.instance.quickDayAgg();
    if (mounted) {
      setState(() {
        _entries = e;
        _defs = d;
        _quickKeys = k;
        _agg = a;
      });
    }
  }

  List<String> _displayRow(PhaskaEntry e) {
    String aggCell(String k, double Function(QuickAgg a) pick) {
      final a = _agg[dayKeyOf(e.createdAt)]?[k];
      return a == null ? '—' : fmtDe(pick(a));
    }

    return [
      DateFormat('dd.MM.yy\nHH:mm').format(e.createdAt),
      e.wohlbefinden?.toString() ?? '—',
      e.schlafStunden == null ? '—' : fmtDe(e.schlafStunden!),
      e.elvanseMg == null
          ? '—'
          : (e.elvanseMg == 0 ? 'keine' : '${e.elvanseMg}'),
      e.elvanseZeit ?? '—', // Punkt 5
      e.innereUnruhe == null ? '—' : fmtDe(e.innereUnruhe!),
      e.medikinetMg == null
          ? '—'
          : (e.medikinetMg == 0 ? 'keine' : '${e.medikinetMg}'),
      e.medikinetZeit ?? '—',
      e.medikinetMagen ?? '—',
      e.medikinetEssenAbstand ?? '—',
      e.migraeneIntensitaet?.toString() ?? '—',
      e.migraeneStart ?? '—',
      e.migraeneEnde ?? '—',
      e.ausloeser ?? '—',
      e.begleitsymptome ?? '—',
      e.notizen ?? '—',
      e.migraeneTag,
      for (final d in _defs)
        for (final inp in d.inputs) fmtOne(customSubValue(e, d, inp)),
      // Punkt 2: Durchschnitt bleibt eigener Tabellenpunkt.
      for (final k in _quickKeys) ...[
        aggCell(k, (a) => a.avg),
        aggCell(k, (a) => a.min),
        aggCell(k, (a) => a.max),
      ],
    ];
  }

  Future<void> _run(Future<dynamic> Function() action,
      String Function(dynamic result) doneMessage) async {
    if ((_entries ?? []).isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Noch keine Daten zum Exportieren.')));
      return;
    }
    setState(() => _busy = true);
    try {
      final result = await action();
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(doneMessage(result))));
      }
    } catch (err) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Export fehlgeschlagen: $err')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _importCsv() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final file = await FilePicker.pickFile(
          type: FileType.custom, allowedExtensions: ['csv']);
      if (file == null || !mounted) return;
      final bytes = await file.readAsBytes();
      final text = utf8.decode(bytes, allowMalformed: true);
      if (!mounted) return;
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          icon: const Icon(Icons.file_upload_outlined),
          title: const Text('CSV importieren?'),
          content: const Text(
              'Es werden nur neue Einträge ergänzt – vorhandene bleiben '
              'unverändert. Duplikate werden über den Zeitstempel erkannt.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Abbrechen')),
            FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Importieren')),
          ],
        ),
      );
      if (ok != true || !mounted) return;
      final (n, s, unknown) = await importCsv(text, _defs);
      messenger.showSnackBar(SnackBar(
          content: Text(
              'Import fertig: $n neu, $s übersprungen'
              '${unknown.isEmpty ? '' : '\nUnbekannte Spalten: ${unknown.join(', ')}'}'),
          duration: const Duration(seconds: 6)));
    } catch (err) {
      messenger.showSnackBar(
          SnackBar(content: Text('Import fehlgeschlagen: $err')));
    }
  }

  Future<void> _rowOptions(PhaskaEntry e) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: const Text('Eintrag bearbeiten'),
            subtitle:
                const Text('Erfassung mit den vorhandenen Werten öffnen'),
            onTap: () => Navigator.pop(ctx, 'edit'),
          ),
          ListTile(
            leading: Icon(Icons.delete_outline,
                color: Theme.of(ctx).colorScheme.error),
            title: const Text('Eintrag löschen'),
            onTap: () => Navigator.pop(ctx, 'delete'),
          ),
        ]),
      ),
    );
    if (action == 'edit' && mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              CaptureFlowScreen(editMode: true, entry: e, editOpensReview: true),
        ),
      );
    } else if (action == 'delete' && mounted) {
      await _confirmDelete(e);
    }
  }

  Future<void> _confirmDelete(PhaskaEntry e) async {
    if (e.id == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Zeile löschen?'),
        content: Text(
            'Eintrag vom ${DateFormat('dd.MM.yyyy HH:mm').format(e.createdAt)} endgültig löschen?'),
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
    if (ok == true) await PhaskaDb.instance.delete(e.id!);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entries = _entries;
    final stripe =
        theme.colorScheme.surfaceContainerHighest.withValues(alpha: .45);
    final cols = csvColumnDefs(_defs, _quickKeys);
    return Scaffold(
      body: SafeArea(
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(children: [
              Text(S.t('screen_table'),
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const Spacer(),
              if (entries != null)
                Text('${entries.length} Zeilen',
                    style: theme.textTheme.labelLarge),
            ]),
          ),
          if (entries != null && entries.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text(
                  'Lange auf eine Zeile drücken: bearbeiten oder löschen. '
                  'Die Leiste ganz unten verschiebt die Tabelle seitlich.',
                  style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant)),
            ),
          Expanded(
            child: entries == null
                ? const Center(child: CircularProgressIndicator())
                : entries.isEmpty
                    ? Center(
                        child: Text('Noch keine Daten erfasst.',
                            style: theme.textTheme.bodyLarge))
                    : Column(children: [
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              controller: _hCtrl,
                              // Punkt 3: Tabelle reagiert NICHT auf Wischen –
                              // horizontale Gesten gehen ans PageView.
                              physics:
                                  const NeverScrollableScrollPhysics(),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: DataTable(
                                columnSpacing: 14,
                                horizontalMargin: 8,
                                headingRowHeight: 44,
                                dataRowMinHeight: 40,
                                dataRowMaxHeight: 64,
                                columns: [
                                  for (final (i, c) in cols.indexed)
                                    DataColumn(
                                      label: Container(
                                        color: i.isOdd
                                            ? stripe
                                            : Colors.transparent,
                                        padding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 4, vertical: 4),
                                        child: Text(c.label,
                                            style: theme
                                                .textTheme.labelSmall
                                                ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: c.group == null
                                                  ? null
                                                  : c.group == 3
                                                      ? AppColors
                                                          .quick.value
                                                      : groupColor(c.group!),
                                            )),
                                      ),
                                    ),
                                ],
                                rows: [
                                  for (final e in entries)
                                    DataRow(
                                      onLongPress: () => _rowOptions(e),
                                      cells: [
                                        for (final (i, cell)
                                            in _displayRow(e).indexed)
                                          DataCell(
                                            Container(
                                              constraints:
                                                  const BoxConstraints(
                                                      maxWidth: 170,
                                                      minHeight: 40),
                                              alignment:
                                                  Alignment.centerLeft,
                                              color: i.isOdd
                                                  ? stripe
                                                  : Colors.transparent,
                                              padding: const EdgeInsets
                                                  .symmetric(horizontal: 4),
                                              child: Text(
                                                cell,
                                                maxLines: 2,
                                                overflow:
                                                    TextOverflow.ellipsis,
                                                style: i == 16 &&
                                                        cell == 'ja'
                                                    ? theme
                                                        .textTheme.bodySmall
                                                        ?.copyWith(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold,
                                                            color: theme
                                                                .colorScheme
                                                                .error)
                                                    : theme.textTheme
                                                        .bodySmall,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ]),
          ),
          // Punkt 3: horizontale Scroll-Leiste am unteren Bildschirmrand
          // (ggf. leer, wenn Tabelle schmal/schmal genug ist).
          if (entries != null && entries.length > 1)
            Padding(
              padding: const EdgeInsets.only(bottom: 96),
              child: HorizontalScroller(controller: _hCtrl),
            ),
        ]),
      ),
      floatingActionButton: Row(mainAxisSize: MainAxisSize.min, children: [
        FloatingActionButton.small(
          heroTag: 'import',
          tooltip: 'CSV importieren',
          onPressed: _busy ? null : _importCsv,
          child: const Icon(Icons.file_upload_outlined),
        ),
        const SizedBox(width: 12),
        FloatingActionButton.small(
          heroTag: 'save_local',
          tooltip: 'Lokal speichern (Download-Ordner)',
          onPressed: _busy
              ? null
              : () => _run(
                    () => saveCsvLocally(_entries!, _defs),
                    (path) => 'Gespeichert:\n$path',
                  ),
          child: const Icon(Icons.save_alt_rounded),
        ),
        const SizedBox(width: 12),
        FloatingActionButton.extended(
          key: kKeyExportFab,
          heroTag: 'share',
          // Punkt 2: teilt große Tabelle UND Einzelerfassungstabelle.
          onPressed: _busy
              ? null
              : () => _run(
                    () => shareCsvBundle(_entries!, _defs),
                    (n) => n == 2
                        ? 'Beide Tabellen geteilt (Erfassungen + Einzelwerte).'
                        : 'Export geteilt.',
                  ),
          icon: _busy
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.ios_share_rounded),
          label: Text(_busy ? 'Exportiere …' : 'Teilen'),
        ),
      ]),
    );
  }
}