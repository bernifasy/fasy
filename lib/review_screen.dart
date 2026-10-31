import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'capture/capture_flow.dart';
import 'onboarding.dart';
import 'capture/steps.dart';
import 'db.dart';
import 'l10n.dart';
import 'models.dart';

class ReviewScreen extends StatefulWidget {
  final PhaskaEntry entry;
  const ReviewScreen({super.key, required this.entry});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  List<FieldDef> _defs = const [];
  Map<String, String> _labels = {};

  @override
  void initState() {
    super.initState();
    // Tutorial: „Überprüfen & Speichern"-Karte anzeigen.
    TutorialController.instance.notifyRoute('review_open');
    _load();
  }

  Future<void> _load() async {
    final d = await PhaskaDb.instance.fieldDefs();
    final l1 = await PhaskaDb.instance.builtinLabels(1);
    final l2 = await PhaskaDb.instance.builtinLabels(2);
    if (mounted) setState(() { _defs = d; _labels = {...l1, ...l2}; });
  }

  String _or(String? v) => (v == null || v.isEmpty) ? '—' : v;
  String _bLabel(String id) => _labels[id] ?? S.builtin(id);

  String _elvanseText(PhaskaEntry e) {
    if (e.elvanseMg == null) return '—';
    if (e.elvanseMg == 0) return S.t('rev_none');
    final parts = ['${e.elvanseMg} mg'];
    if (e.elvanseZeit != null) parts.add('${e.elvanseZeit} ${S.t('w_uhr')}');
    return parts.join(' · ');
  }

  String _medikinetText(PhaskaEntry e) {
    if (e.medikinetMg == null) return '—';
    if (e.medikinetMg == 0) return S.t('rev_none');
    final parts = ['${e.medikinetMg} mg'];
    if (e.medikinetZeit != null) parts.add('${e.medikinetZeit} ${S.t('w_uhr')}');
    if (e.medikinetMagen != null) {
      var m = e.medikinetMagen!;
      if (e.medikinetEssenAbstand != null) {
        m += ' (${e.medikinetEssenAbstand})';
      }
      parts.add(m);
    }
    return parts.join(' · ');
  }

  List<({String label, String value, String? stepId})> _items(
      PhaskaEntry e) {
    return [
      (
        label: _bLabel('wohlbefinden'),
        value: e.wohlbefinden?.toString() ?? '—',
        stepId: 'wohlbefinden'
      ),
      (
        label: _bLabel('schlaf'),
        value:
            e.schlafStunden == null ? '—' : '${fmtDe(e.schlafStunden!)} h',
        stepId: 'schlaf'
      ),
      (
        label: _bLabel('elvanse'),
        value: _elvanseText(e), // Punkt 5: inkl. Uhrzeit
        stepId: 'elvanse'
      ),
      (
        label: _bLabel('unruhe'),
        value: e.innereUnruhe == null ? '—' : fmtDe(e.innereUnruhe!),
        stepId: 'unruhe'
      ),
      (
        label: _bLabel('medikinet'),
        value: _medikinetText(e),
        stepId: 'medikinet'
      ),
      (
        label: _bLabel('intensitaet'),
        value: e.migraeneIntensitaet?.toString() ?? '—',
        stepId: 'intensitaet'
      ),
      (
        label: _bLabel('start'),
        value: _or(e.migraeneStart),
        stepId: 'start'
      ),
      (
        label: _bLabel('ende'),
        value: _or(e.migraeneEnde),
        stepId: 'ende'
      ),
      (
        label: _bLabel('ausloeser'),
        value: _or(e.ausloeser),
        stepId: 'ausloeser'
      ),
      (
        label: _bLabel('symptome'),
        value: _or(e.begleitsymptome),
        stepId: 'symptome'
      ),
      (
        label: _bLabel('notizen'),
        value: _or(e.notizen),
        stepId: 'notizen'
      ),
      for (final d in _defs)
        for (final inp in d.inputs)
          (
            label: d.inputs.length == 1 ? d.label : '${d.label} ${inp.label}',
            value: fmtOne(customSubValue(e, d, inp)),
            stepId: d.id
          ),
      (
        label: S.t('rev_migday'),
        value: '${e.migraeneTag} (automatisch)',
        stepId: null
      ),
      (
        label: S.t('rev_created'),
        value:
            '${DateFormat('dd.MM.yyyy · HH:mm').format(e.createdAt)} ${S.t('w_uhr')}',
        stepId: '_created'
      ),
    ];
  }

  Future<void> _editCreatedAt() async {
    final e = widget.entry;
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: e.createdAt.isAfter(now) ? now : e.createdAt,
      firstDate: DateTime(2015),
      lastDate: now,
      helpText: S.t('rev_date_help'),
    );
    if (picked == null || !mounted) return;
    final prev = TimeOfDay.fromDateTime(e.createdAt);
    final t = await pickWheelTime(context, formatClock(prev));
    final time = t == null ? prev : parseClock(t)!;
    if (!mounted) return;
    setState(() => e.createdAt =
        DateTime(picked.year, picked.month, picked.day, time.hour, time.minute));
  }

  Future<void> _edit(String stepId) async {
    if (stepId == '_created') {
      await _editCreatedAt();
      return;
    }
    final steps = await stepsForAll();
    final idx = steps.indexWhere((s) => s.id == stepId);
    if (idx < 0 || !mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CaptureFlowScreen(
            editMode: true, entry: widget.entry, startIndex: idx),
      ),
    );
    if (mounted) setState(() {});
  }

  Future<void> _save() async {
    final messenger = ScaffoldMessenger.of(context);
    final isNew = widget.entry.id == null;
    if (isNew) {
      await PhaskaDb.instance.insert(widget.entry);
    } else {
      await PhaskaDb.instance.update(widget.entry);
    }
    if (!mounted) return;
    Navigator.pop(context);
    messenger.showSnackBar(SnackBar(
        content: Text(isNew ? S.t('rev_saved_new') : S.t('rev_saved_edit'))));
  }

  Future<void> _discard() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(S.t('rev_discard_title')),
        content: Text(S.t('rev_discard_body')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(S.t('back'))),
          FilledButton(
              style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(ctx).colorScheme.error,
                  foregroundColor: Theme.of(ctx).colorScheme.onError),
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(S.t('rev_discard'))),
        ],
      ),
    );
    if (ok == true && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = _items(widget.entry);
    return Scaffold(
      appBar: AppBar(
          title: Text(
              widget.entry.id == null ? S.t('rev_title_new') : S.t('rev_title_edit')),
          automaticallyImplyLeading: false),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
        itemCount: items.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final it = items[i];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 4, vertical: 2),
            title: Text(it.label,
                style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant)),
            subtitle:
                Text(it.value, style: theme.textTheme.titleMedium),
            trailing: it.stepId != null
                ? Icon(
                    it.stepId == '_created'
                        ? Icons.edit_calendar_outlined
                        : Icons.edit_outlined,
                    size: 20)
                : null,
            onTap: it.stepId != null ? () => _edit(it.stepId!) : null,
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Expanded(
              child: OutlinedButton(
                  onPressed: _discard,
                  child: Text(S.t('rev_discard'))),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: FilledButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save_outlined),
                  label: Text(widget.entry.id == null
                      ? S.t('save')
                      : S.t('rev_save_changes'))),
            ),
          ]),
        ),
      ),
    );
  }
}