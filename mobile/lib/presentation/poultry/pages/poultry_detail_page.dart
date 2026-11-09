import 'package:flutter/material.dart';
import '../../../domain/entities/poultry.dart';
import '../../../domain/failures.dart';
import '../../../domain/usecases/poultry_usecases.dart';
import '../../../infrastructure/di/injection.dart';
import '../../../l10n/app_localizations.dart';
import '../widgets/poultry_group_form_fields.dart';

class PoultryDetailPage extends StatefulWidget {
  const PoultryDetailPage({super.key, required this.groupId});

  final String groupId;

  @override
  State<PoultryDetailPage> createState() => _PoultryDetailPageState();
}

class _PoultryDetailPageState extends State<PoultryDetailPage> {
  PoultryGroup? _group;
  List<EggProduction> _eggs = const [];
  List<PoultryFeeding> _feedings = const [];
  bool _loading = true;
  bool _editing = false;
  bool _saving = false;
  String? _error;

  final _name = TextEditingController();
  final _birdCount = TextEditingController();
  final _dateAcquired = TextEditingController();
  final _purchaseDate = TextEditingController();
  final _purchasePrice = TextEditingController();
  final _notes = TextEditingController();
  PoultryType _poultryType = PoultryType.layer;
  AcquisitionSource _acquiredBy = AcquisitionSource.bornOnFarm;

  final _eggQty = TextEditingController();
  final _eggUnit = TextEditingController(text: 'pcs');
  final _eggPrice = TextEditingController(text: '0');
  final _eggNote = TextEditingController();
  final _feedName = TextEditingController();
  final _feedQty = TextEditingController();
  final _feedUnit = TextEditingController(text: 'kg');
  final _feedNote = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final c in [
      _name,
      _birdCount,
      _dateAcquired,
      _purchaseDate,
      _purchasePrice,
      _notes,
      _eggQty,
      _eggUnit,
      _eggPrice,
      _eggNote,
      _feedName,
      _feedQty,
      _feedUnit,
      _feedNote,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _hydrateForm(PoultryGroup group) {
    _name.text = group.name;
    _birdCount.text = group.birdCount.toString();
    _dateAcquired.text = group.dateAcquired ?? '';
    _purchaseDate.text = group.purchaseDate ?? '';
    _purchasePrice.text = group.purchasePrice ?? '';
    _notes.text = group.notes ?? '';
    _poultryType = group.poultryType;
    _acquiredBy = group.acquiredBy;
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final group = await getIt<GetPoultryGroup>()(widget.groupId);
      final eggs = group.eggsEligible
          ? await getIt<ListEggProductions>()(widget.groupId)
          : null;
      final feedings = await getIt<ListPoultryFeedings>()(widget.groupId);
      if (!mounted) return;
      _hydrateForm(group);
      setState(() {
        _group = group;
        _eggs = eggs?.items ?? const [];
        _feedings = feedings.items;
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
      final group = await getIt<UpdatePoultryGroup>()(
        widget.groupId,
        buildPoultryGroupWriteParams(
          name: _name,
          birdCount: _birdCount,
          dateAcquired: _dateAcquired,
          purchaseDate: _purchaseDate,
          purchasePrice: _purchasePrice,
          notes: _notes,
          poultryType: _poultryType,
          acquiredBy: _acquiredBy,
        ),
      );
      if (!mounted) return;
      setState(() {
        _group = group;
        _editing = false;
      });
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
        title: Text(l10n.archivePoultryGroup),
        content: Text(l10n.archivePoultryGroupConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.archivePoultryGroup),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await getIt<ArchivePoultryGroup>()(widget.groupId);
      await _load();
    } on AppFailure catch (e) {
      setState(() => _error = e.message);
    }
  }

  Future<void> _addEgg() async {
    setState(() => _error = null);
    try {
      await getIt<AddEggProduction>()(
        groupId: widget.groupId,
        producedAt: DateTime.now().toUtc().toIso8601String(),
        quantity: _eggQty.text.trim(),
        unit: _eggUnit.text.trim(),
        pricePerUnit: _eggPrice.text.trim(),
        note: _eggNote.text.trim().isEmpty ? null : _eggNote.text.trim(),
      );
      _eggQty.clear();
      _eggNote.clear();
      await _load();
    } on AppFailure catch (e) {
      setState(() => _error = e.message);
    }
  }

  Future<void> _addFeeding() async {
    setState(() => _error = null);
    try {
      await getIt<AddPoultryFeeding>()(
        groupId: widget.groupId,
        fedAt: DateTime.now().toUtc().toIso8601String(),
        feedName: _feedName.text.trim(),
        quantity: _feedQty.text.trim(),
        unit: _feedUnit.text.trim(),
        note: _feedNote.text.trim().isEmpty ? null : _feedNote.text.trim(),
      );
      _feedName.clear();
      _feedQty.clear();
      _feedNote.clear();
      await _load();
    } on AppFailure catch (e) {
      setState(() => _error = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_loading) return const Center(child: CircularProgressIndicator());
    final group = _group;
    if (group == null) {
      return Center(child: Text(_error ?? l10n.genericError));
    }
    final canWrite = !group.isArchived;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(group.name, style: Theme.of(context).textTheme.headlineSmall),
        Text(
          '${group.poultryType.name} · ${group.birdCount} ${l10n.birds}'
          '${group.isArchived ? ' · ${l10n.archived}' : ''}',
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        if (canWrite)
          Row(
            children: [
              TextButton(
                onPressed: () => setState(() => _editing = !_editing),
                child: Text(_editing ? l10n.cancel : l10n.edit),
              ),
              TextButton(
                onPressed: _archive,
                child: Text(l10n.archivePoultryGroup),
              ),
            ],
          ),
        if (_editing && canWrite) ...[
          PoultryGroupFormFields(
            name: _name,
            birdCount: _birdCount,
            dateAcquired: _dateAcquired,
            purchaseDate: _purchaseDate,
            purchasePrice: _purchasePrice,
            notes: _notes,
            poultryType: _poultryType,
            acquiredBy: _acquiredBy,
            onPoultryTypeChanged: (v) => setState(() => _poultryType = v),
            onAcquiredByChanged: (v) => setState(() => _acquiredBy = v),
          ),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: Text(_saving ? l10n.saving : l10n.save),
          ),
        ] else ...[
          ListTile(
            title: Text(l10n.poultryType),
            subtitle: Text(group.poultryType.name),
          ),
          ListTile(
            title: Text(l10n.birdCount),
            subtitle: Text('${group.birdCount}'),
          ),
          ListTile(
            title: Text(l10n.notes),
            subtitle: Text(group.notes ?? '—'),
          ),
        ],
        const Divider(height: 32),
        Text(
          l10n.eggProduction,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        if (!group.eggsEligible)
          Text(l10n.eggsNotForBroiler)
        else ...[
          ..._eggs.map(
            (row) => ListTile(
              title: Text('${row.quantity} ${row.unit}'),
              subtitle: Text(row.producedAt),
            ),
          ),
          if (_eggs.isEmpty) Text(l10n.noEggEntries),
          if (canWrite) ...[
            TextField(
              controller: _eggQty,
              decoration: InputDecoration(labelText: l10n.quantity),
            ),
            TextField(
              controller: _eggUnit,
              decoration: InputDecoration(labelText: l10n.unit),
            ),
            TextField(
              controller: _eggPrice,
              decoration: InputDecoration(labelText: l10n.pricePerUnit),
            ),
            TextField(
              controller: _eggNote,
              decoration: InputDecoration(labelText: l10n.note),
            ),
            FilledButton(onPressed: _addEgg, child: Text(l10n.addEgg)),
          ],
        ],
        const Divider(height: 32),
        Text(l10n.feeding, style: Theme.of(context).textTheme.titleLarge),
        ..._feedings.map(
          (row) => ListTile(
            title: Text('${row.feedName}: ${row.quantity} ${row.unit}'),
            subtitle: Text(row.fedAt),
          ),
        ),
        if (_feedings.isEmpty) Text(l10n.noFeedingEntries),
        if (canWrite) ...[
          TextField(
            controller: _feedName,
            decoration: InputDecoration(labelText: l10n.feedName),
          ),
          TextField(
            controller: _feedQty,
            decoration: InputDecoration(labelText: l10n.quantity),
          ),
          TextField(
            controller: _feedUnit,
            decoration: InputDecoration(labelText: l10n.unit),
          ),
          TextField(
            controller: _feedNote,
            decoration: InputDecoration(labelText: l10n.note),
          ),
          FilledButton(onPressed: _addFeeding, child: Text(l10n.addFeeding)),
        ] else
          Text(l10n.poultryArchivedReadOnly),
      ],
    );
  }
}
