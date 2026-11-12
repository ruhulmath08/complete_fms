import 'package:flutter/material.dart';
import '../../../domain/entities/poultry.dart';
import '../../../domain/failures.dart';
import '../../../domain/usecases/poultry_usecases.dart';
import '../../../infrastructure/di/injection.dart';
import '../../../infrastructure/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../shared/widgets/form_field_column.dart';
import '../widgets/poultry_group_form_fields.dart';

String _rowTotal(String quantity, String unitPrice) {
  final qty = double.tryParse(quantity);
  final price = double.tryParse(unitPrice);
  if (qty == null || price == null) return '—';
  return (qty * price).toStringAsFixed(2);
}

String _formatHistoryDate(String iso) {
  final parsed = DateTime.tryParse(iso);
  if (parsed == null) return iso;
  final local = parsed.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${local.year}-${two(local.month)}-${two(local.day)} '
      '${two(local.hour)}:${two(local.minute)}';
}

String _nowIso() => DateTime.now().toUtc().toIso8601String();

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
  String? _editingEggId;
  String? _editingFeedingId;
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

  final _eggProducedAt = TextEditingController();
  final _eggQty = TextEditingController();
  final _eggUnit = TextEditingController(text: 'pcs');
  final _eggPrice = TextEditingController(text: '0');
  final _eggNote = TextEditingController();
  final _feedFedAt = TextEditingController();
  final _feedName = TextEditingController();
  final _feedQty = TextEditingController();
  final _feedUnit = TextEditingController(text: 'kg');
  final _feedNote = TextEditingController();

  @override
  void initState() {
    super.initState();
    _resetEggForm();
    _resetFeedingForm();
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
      _eggProducedAt,
      _eggQty,
      _eggUnit,
      _eggPrice,
      _eggNote,
      _feedFedAt,
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

  void _resetEggForm() {
    _editingEggId = null;
    _eggProducedAt.text = _nowIso();
    _eggQty.clear();
    _eggUnit.text = 'pcs';
    _eggPrice.text = '0';
    _eggNote.clear();
  }

  void _resetFeedingForm() {
    _editingFeedingId = null;
    _feedFedAt.text = _nowIso();
    _feedName.clear();
    _feedQty.clear();
    _feedUnit.text = 'kg';
    _feedNote.clear();
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

  void _startEditEgg(EggProduction row) {
    setState(() {
      _editingEggId = row.id;
      _eggProducedAt.text = row.producedAt;
      _eggQty.text = row.quantity;
      _eggUnit.text = row.unit;
      _eggPrice.text = row.pricePerUnit;
      _eggNote.text = row.note ?? '';
      _error = null;
    });
  }

  void _startEditFeeding(PoultryFeeding row) {
    setState(() {
      _editingFeedingId = row.id;
      _feedFedAt.text = row.fedAt;
      _feedName.text = row.feedName;
      _feedQty.text = row.quantity;
      _feedUnit.text = row.unit;
      _feedNote.text = row.note ?? '';
      _error = null;
    });
  }

  Future<void> _saveEgg() async {
    setState(() => _error = null);
    final note = _eggNote.text.trim();
    try {
      if (_editingEggId != null) {
        await getIt<UpdateEggProduction>()(
          groupId: widget.groupId,
          eggId: _editingEggId!,
          producedAt: _eggProducedAt.text.trim(),
          quantity: _eggQty.text.trim(),
          unit: _eggUnit.text.trim(),
          pricePerUnit: _eggPrice.text.trim(),
          note: note.isEmpty ? null : note,
        );
      } else {
        await getIt<AddEggProduction>()(
          groupId: widget.groupId,
          producedAt: _eggProducedAt.text.trim(),
          quantity: _eggQty.text.trim(),
          unit: _eggUnit.text.trim(),
          pricePerUnit: _eggPrice.text.trim(),
          note: note.isEmpty ? null : note,
        );
      }
      setState(_resetEggForm);
      await _load();
    } on AppFailure catch (e) {
      setState(() => _error = e.message);
    }
  }

  Future<void> _deleteEgg(EggProduction row) async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(l10n.deleteEggConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await getIt<DeleteEggProduction>()(widget.groupId, row.id);
      if (_editingEggId == row.id) _resetEggForm();
      await _load();
    } on AppFailure catch (e) {
      setState(() => _error = e.message);
    }
  }

  Future<void> _saveFeeding() async {
    setState(() => _error = null);
    final note = _feedNote.text.trim();
    try {
      if (_editingFeedingId != null) {
        await getIt<UpdatePoultryFeeding>()(
          groupId: widget.groupId,
          feedingId: _editingFeedingId!,
          fedAt: _feedFedAt.text.trim(),
          feedName: _feedName.text.trim(),
          quantity: _feedQty.text.trim(),
          unit: _feedUnit.text.trim(),
          note: note.isEmpty ? null : note,
        );
      } else {
        await getIt<AddPoultryFeeding>()(
          groupId: widget.groupId,
          fedAt: _feedFedAt.text.trim(),
          feedName: _feedName.text.trim(),
          quantity: _feedQty.text.trim(),
          unit: _feedUnit.text.trim(),
          note: note.isEmpty ? null : note,
        );
      }
      setState(_resetFeedingForm);
      await _load();
    } on AppFailure catch (e) {
      setState(() => _error = e.message);
    }
  }

  Future<void> _deleteFeeding(PoultryFeeding row) async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(l10n.deleteFeedingConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await getIt<DeletePoultryFeeding>()(widget.groupId, row.id);
      if (_editingFeedingId == row.id) _resetFeedingForm();
      await _load();
    } on AppFailure catch (e) {
      setState(() => _error = e.message);
    }
  }

  DataRow _eggRow(
    EggProduction row,
    int index,
    bool canWrite,
    AppLocalizations l10n,
  ) {
    final tokens = AppTokens.of(context);
    return DataRow(
      cells: [
        DataCell(Text('$index')),
        DataCell(Text(_formatHistoryDate(row.producedAt))),
        DataCell(Text('${row.quantity} ${row.unit}')),
        DataCell(Text(row.pricePerUnit)),
        DataCell(Text(_rowTotal(row.quantity, row.pricePerUnit))),
        DataCell(Text(row.note ?? '—')),
        if (canWrite)
          DataCell(
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: l10n.editEntry,
                  onPressed: () => _startEditEgg(row),
                  color: tokens.primary,
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  tooltip: l10n.delete,
                  onPressed: () => _deleteEgg(row),
                  color: tokens.danger,
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
          ),
      ],
    );
  }

  DataRow _feedingRow(
    PoultryFeeding row,
    int index,
    bool canWrite,
    AppLocalizations l10n,
  ) {
    final tokens = AppTokens.of(context);
    return DataRow(
      cells: [
        DataCell(Text('$index')),
        DataCell(Text(_formatHistoryDate(row.fedAt))),
        DataCell(Text(row.feedName)),
        DataCell(Text('${row.quantity} ${row.unit}')),
        DataCell(Text(row.note ?? '—')),
        if (canWrite)
          DataCell(
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: l10n.editEntry,
                  onPressed: () => _startEditFeeding(row),
                  color: tokens.primary,
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  tooltip: l10n.delete,
                  onPressed: () => _deleteFeeding(row),
                  color: tokens.danger,
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
          ),
      ],
    );
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
          if (_eggs.isEmpty)
            Text(l10n.noEggEntries)
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: [
                  DataColumn(label: Text(l10n.rowNumber)),
                  DataColumn(label: Text(l10n.dateTime)),
                  DataColumn(label: Text(l10n.quantity)),
                  DataColumn(label: Text(l10n.pricePerUnit)),
                  DataColumn(label: Text(l10n.total)),
                  DataColumn(label: Text(l10n.note)),
                  if (canWrite) DataColumn(label: Text(l10n.actions)),
                ],
                rows: [
                  for (var i = 0; i < _eggs.length; i++)
                    _eggRow(_eggs[i], i + 1, canWrite, l10n),
                ],
              ),
            ),
          if (canWrite) ...[
            FormFieldColumn(
              children: [
                TextField(
                  controller: _eggProducedAt,
                  decoration: InputDecoration(labelText: l10n.producedAtHint),
                ),
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
              ],
            ),
            const SizedBox(height: FormFieldColumn.gap),
            FilledButton(
              onPressed: _saveEgg,
              child: Text(
                _editingEggId != null ? l10n.updateEggEntry : l10n.addEgg,
              ),
            ),
            if (_editingEggId != null)
              TextButton(
                onPressed: () => setState(_resetEggForm),
                child: Text(l10n.cancelEdit),
              ),
          ],
        ],
        const Divider(height: 32),
        Text(l10n.feeding, style: Theme.of(context).textTheme.titleLarge),
        if (_feedings.isEmpty)
          Text(l10n.noFeedingEntries)
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: [
                DataColumn(label: Text(l10n.rowNumber)),
                DataColumn(label: Text(l10n.dateTime)),
                DataColumn(label: Text(l10n.feedName)),
                DataColumn(label: Text(l10n.quantity)),
                DataColumn(label: Text(l10n.note)),
                if (canWrite) DataColumn(label: Text(l10n.actions)),
              ],
              rows: [
                for (var i = 0; i < _feedings.length; i++)
                  _feedingRow(_feedings[i], i + 1, canWrite, l10n),
              ],
            ),
          ),
        if (canWrite) ...[
          FormFieldColumn(
            children: [
              TextField(
                controller: _feedFedAt,
                decoration: InputDecoration(labelText: l10n.fedAtHint),
              ),
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
            ],
          ),
          const SizedBox(height: FormFieldColumn.gap),
          FilledButton(
            onPressed: _saveFeeding,
            child: Text(
              _editingFeedingId != null
                  ? l10n.updateFeedingEntry
                  : l10n.addFeeding,
            ),
          ),
          if (_editingFeedingId != null)
            TextButton(
              onPressed: () => setState(_resetFeedingForm),
              child: Text(l10n.cancelEdit),
            ),
        ] else
          Text(l10n.poultryArchivedReadOnly),
      ],
    );
  }
}
