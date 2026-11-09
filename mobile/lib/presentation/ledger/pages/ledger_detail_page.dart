import 'package:flutter/material.dart';
import '../../../domain/entities/ledger.dart';
import '../../../domain/failures.dart';
import '../../../domain/usecases/ledger_usecases.dart';
import '../../../infrastructure/di/injection.dart';
import '../../../l10n/app_localizations.dart';
import '../widgets/ledger_entry_form_fields.dart';

class LedgerDetailPage extends StatefulWidget {
  const LedgerDetailPage({super.key, required this.entryId});

  final String entryId;

  @override
  State<LedgerDetailPage> createState() => _LedgerDetailPageState();
}

class _LedgerDetailPageState extends State<LedgerDetailPage> {
  LedgerEntry? _entry;
  bool _loading = true;
  bool _editing = false;
  bool _saving = false;
  String? _error;

  final _occurredAt = TextEditingController();
  final _amount = TextEditingController();
  final _unit = TextEditingController();
  final _note = TextEditingController();
  LedgerEntryType _entryType = LedgerEntryType.expense;
  LedgerEntryCategory _category = LedgerEntryCategory.other;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _occurredAt.dispose();
    _amount.dispose();
    _unit.dispose();
    _note.dispose();
    super.dispose();
  }

  void _hydrate(LedgerEntry entry) {
    _occurredAt.text = entry.occurredAt;
    _amount.text = entry.amount;
    _unit.text = entry.unit ?? '';
    _note.text = entry.note ?? '';
    _entryType = entry.entryType;
    _category = entry.category;
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final entry = await getIt<GetLedgerEntry>()(widget.entryId);
      if (!mounted) return;
      _hydrate(entry);
      setState(() {
        _entry = entry;
        _loading = false;
      });
    } on AppFailure catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    }
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await getIt<UpdateLedgerEntry>()(
        widget.entryId,
        buildLedgerEntryWriteParams(
          occurredAt: _occurredAt,
          amount: _amount,
          unit: _unit,
          note: _note,
          entryType: _entryType,
          category: _category,
        ),
      );
      if (!mounted) return;
      setState(() => _editing = false);
      await _load();
    } on AppFailure catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _archive() async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.archiveLedgerEntry),
        content: Text(l10n.archiveLedgerEntryConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.archiveLedgerEntry),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await getIt<ArchiveLedgerEntry>()(widget.entryId);
      await _load();
    } on AppFailure catch (e) {
      setState(() => _error = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_loading) return const Center(child: CircularProgressIndicator());
    final entry = _entry;
    if (entry == null) {
      return Center(child: Text(_error ?? l10n.genericError));
    }
    final canWrite = !entry.isArchived;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          '${ledgerEntryTypeLabel(l10n, entry.entryType)} · ${entry.amount}',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        Text(
          '${entry.occurredAt} · ${ledgerCategoryLabel(l10n, entry.category)}'
          '${entry.isArchived ? ' · ${l10n.archived}' : ''}',
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        const SizedBox(height: 12),
        if (canWrite)
          Row(
            children: [
              OutlinedButton(
                onPressed: () => setState(() => _editing = !_editing),
                child: Text(_editing ? l10n.cancel : l10n.edit),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: _archive,
                child: Text(l10n.archiveLedgerEntry),
              ),
            ],
          )
        else
          Text(l10n.ledgerArchivedReadOnly),
        const SizedBox(height: 12),
        if (_editing && canWrite) ...[
          LedgerEntryFormFields(
            occurredAt: _occurredAt,
            amount: _amount,
            unit: _unit,
            note: _note,
            entryType: _entryType,
            category: _category,
            onEntryTypeChanged: (v) => setState(() => _entryType = v),
            onCategoryChanged: (v) => setState(() => _category = v),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: Text(_saving ? l10n.saving : l10n.save),
          ),
        ] else ...[
          Text('${l10n.ledgerEntryType}: ${ledgerEntryTypeLabel(l10n, entry.entryType)}'),
          Text('${l10n.amount}: ${entry.amount}'),
          Text('${l10n.totalPrice}: ${entry.totalPrice}'),
          Text('${l10n.unit}: ${entry.unit ?? '—'}'),
          Text('${l10n.note}: ${entry.note ?? '—'}'),
        ],
      ],
    );
  }
}
