import 'package:flutter/material.dart';
import '../../../domain/entities/crop.dart';
import '../../../domain/failures.dart';
import '../../../domain/usecases/crops_usecases.dart';
import '../../../infrastructure/di/injection.dart';
import '../../../infrastructure/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../shared/widgets/form_field_column.dart';
import '../widgets/crop_cycle_form_fields.dart';

String _todayDate() {
  final now = DateTime.now();
  final m = now.month.toString().padLeft(2, '0');
  final d = now.day.toString().padLeft(2, '0');
  return '${now.year}-$m-$d';
}

String _categoryLabel(AppLocalizations l10n, ExpenseCategory category) {
  return switch (category) {
    ExpenseCategory.labour => l10n.expenseLabour,
    ExpenseCategory.fertilizers => l10n.expenseFertilizers,
    ExpenseCategory.pesticidesAndChemicals => l10n.expensePesticides,
    ExpenseCategory.seeds => l10n.expenseSeeds,
    ExpenseCategory.irrigation => l10n.expenseIrrigation,
    ExpenseCategory.equipment => l10n.expenseEquipment,
    ExpenseCategory.other => l10n.expenseOther,
  };
}

class CropCycleDetailPage extends StatefulWidget {
  const CropCycleDetailPage({super.key, required this.cycleId});

  final String cycleId;

  @override
  State<CropCycleDetailPage> createState() => _CropCycleDetailPageState();
}

class _CropCycleDetailPageState extends State<CropCycleDetailPage> {
  CropCycle? _cycle;
  CycleSummary? _summary;
  List<CropExpense> _expenses = const [];
  List<Harvest> _harvests = const [];
  List<CropName> _cropNames = const [];
  String? _cropLabel;
  bool _loading = true;
  bool _editing = false;
  bool _saving = false;
  String? _error;

  String? _cropNameId;
  final _plantedAt = TextEditingController();
  final _expectedHarvestAt = TextEditingController();
  final _plotName = TextEditingController();
  final _area = TextEditingController();
  final _location = TextEditingController();
  final _notes = TextEditingController();

  final _spentAt = TextEditingController(text: _todayDate());
  final _expenseAmount = TextEditingController();
  final _expenseNote = TextEditingController();
  ExpenseCategory _expenseCategory = ExpenseCategory.labour;
  String? _editingExpenseId;
  String? _editingHarvestId;

  final _harvestedAt = TextEditingController(text: _todayDate());
  final _harvestQty = TextEditingController();
  final _harvestUnit = TextEditingController(text: 'kg');
  final _saleAmount = TextEditingController();
  final _harvestNote = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final c in [
      _plantedAt,
      _expectedHarvestAt,
      _plotName,
      _area,
      _location,
      _notes,
      _spentAt,
      _expenseAmount,
      _expenseNote,
      _harvestedAt,
      _harvestQty,
      _harvestUnit,
      _saleAmount,
      _harvestNote,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _hydrate(CropCycle cycle) {
    _cropNameId = cycle.cropNameId;
    _plantedAt.text = cycle.plantedAt;
    _expectedHarvestAt.text = cycle.expectedHarvestAt ?? '';
    _plotName.text = cycle.plotName ?? '';
    _area.text = cycle.area ?? '';
    _location.text = cycle.location ?? '';
    _notes.text = cycle.notes ?? '';
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final cycle = await getIt<GetCropCycle>()(widget.cycleId);
      final names = await getIt<ListCropNames>()(includeArchived: true);
      final summary = await getIt<GetCropCycleSummary>()(widget.cycleId);
      final expenses = await getIt<ListCropExpenses>()(widget.cycleId);
      final harvests = await getIt<ListHarvests>()(widget.cycleId);
      if (!mounted) return;
      _hydrate(cycle);
      final active = names.items.where((n) => !n.isArchived).toList();
      final editNames = active.isNotEmpty
          ? active
          : names.items.where((n) => n.id == cycle.cropNameId).toList();
      String? cropLabel;
      for (final name in names.items) {
        if (name.id == cycle.cropNameId) {
          cropLabel = name.name;
          break;
        }
      }
      setState(() {
        _cycle = cycle;
        _summary = summary;
        _expenses = expenses.items;
        _harvests = harvests.items;
        _cropNames = editNames;
        _cropLabel = cropLabel;
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
    final cropNameId = _cropNameId;
    if (cropNameId == null) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await getIt<UpdateCropCycle>()(
        widget.cycleId,
        buildCropCycleWriteParams(
          cropNameId: cropNameId,
          plantedAt: _plantedAt,
          expectedHarvestAt: _expectedHarvestAt,
          plotName: _plotName,
          area: _area,
          location: _location,
          notes: _notes,
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
        title: Text(l10n.archiveCropCycle),
        content: Text(l10n.archiveCropCycleConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.archiveCropCycle),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await getIt<ArchiveCropCycle>()(widget.cycleId);
      await _load();
    } on AppFailure catch (e) {
      setState(() => _error = e.message);
    }
  }

  void _resetExpenseForm() {
    _editingExpenseId = null;
    _spentAt.text = _todayDate();
    _expenseAmount.clear();
    _expenseNote.clear();
    _expenseCategory = ExpenseCategory.labour;
  }

  void _resetHarvestForm() {
    _editingHarvestId = null;
    _harvestedAt.text = _todayDate();
    _harvestQty.clear();
    _harvestUnit.text = 'kg';
    _saleAmount.clear();
    _harvestNote.clear();
  }

  void _startEditExpense(CropExpense row) {
    setState(() {
      _editingExpenseId = row.id;
      _spentAt.text = row.spentAt;
      _expenseCategory = row.category;
      _expenseAmount.text = row.amount;
      _expenseNote.text = row.note ?? '';
      _error = null;
    });
  }

  void _startEditHarvest(Harvest row) {
    setState(() {
      _editingHarvestId = row.id;
      _harvestedAt.text = row.harvestedAt;
      _harvestQty.text = row.quantity;
      _harvestUnit.text = row.unit;
      _saleAmount.text = row.saleAmount ?? '';
      _harvestNote.text = row.note ?? '';
      _error = null;
    });
  }

  Future<void> _saveExpense() async {
    setState(() => _error = null);
    final note = _expenseNote.text.trim();
    try {
      if (_editingExpenseId != null) {
        await getIt<UpdateCropExpense>()(
          cycleId: widget.cycleId,
          expenseId: _editingExpenseId!,
          spentAt: _spentAt.text.trim(),
          category: _expenseCategory,
          amount: _expenseAmount.text.trim(),
          note: note.isEmpty ? null : note,
        );
      } else {
        await getIt<AddCropExpense>()(
          cycleId: widget.cycleId,
          spentAt: _spentAt.text.trim(),
          category: _expenseCategory,
          amount: _expenseAmount.text.trim(),
          note: note.isEmpty ? null : note,
        );
      }
      if (!mounted) return;
      setState(_resetExpenseForm);
      await _load();
    } on AppFailure catch (e) {
      setState(() => _error = e.message);
    }
  }

  Future<bool> _confirmDelete(String message) async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(message),
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
    return ok == true;
  }

  Future<void> _deleteExpense(CropExpense row) async {
    final l10n = AppLocalizations.of(context)!;
    if (!await _confirmDelete(l10n.deleteExpenseConfirm)) return;
    try {
      await getIt<DeleteCropExpense>()(widget.cycleId, row.id);
      if (!mounted) return;
      if (_editingExpenseId == row.id) setState(_resetExpenseForm);
      await _load();
    } on AppFailure catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
  }

  Future<void> _saveHarvest() async {
    setState(() => _error = null);
    final sale = _saleAmount.text.trim();
    final note = _harvestNote.text.trim();
    try {
      if (_editingHarvestId != null) {
        await getIt<UpdateHarvest>()(
          cycleId: widget.cycleId,
          harvestId: _editingHarvestId!,
          harvestedAt: _harvestedAt.text.trim(),
          quantity: _harvestQty.text.trim(),
          unit: _harvestUnit.text.trim(),
          saleAmount: sale.isEmpty ? null : sale,
          note: note.isEmpty ? null : note,
        );
      } else {
        await getIt<AddHarvest>()(
          cycleId: widget.cycleId,
          harvestedAt: _harvestedAt.text.trim(),
          quantity: _harvestQty.text.trim(),
          unit: _harvestUnit.text.trim(),
          saleAmount: sale.isEmpty ? null : sale,
          note: note.isEmpty ? null : note,
        );
      }
      if (!mounted) return;
      setState(_resetHarvestForm);
      await _load();
    } on AppFailure catch (e) {
      setState(() => _error = e.message);
    }
  }

  Future<void> _deleteHarvest(Harvest row) async {
    final l10n = AppLocalizations.of(context)!;
    if (!await _confirmDelete(l10n.deleteHarvestConfirm)) return;
    try {
      await getIt<DeleteHarvest>()(widget.cycleId, row.id);
      if (!mounted) return;
      if (_editingHarvestId == row.id) setState(_resetHarvestForm);
      await _load();
    } on AppFailure catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
  }

  Widget _actionCell({
    required AppLocalizations l10n,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
    required Key editKey,
    required Key deleteKey,
  }) {
    final tokens = AppTokens.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          key: editKey,
          tooltip: l10n.editEntry,
          onPressed: onEdit,
          color: tokens.primary,
          icon: const Icon(Icons.edit_outlined),
        ),
        IconButton(
          key: deleteKey,
          tooltip: l10n.delete,
          onPressed: onDelete,
          color: tokens.danger,
          icon: const Icon(Icons.delete_outline),
        ),
      ],
    );
  }

  DataRow _expenseRow(
    CropExpense row,
    int index,
    bool canWrite,
    AppLocalizations l10n,
  ) {
    return DataRow(
      cells: [
        DataCell(Text('$index')),
        DataCell(Text(row.spentAt)),
        DataCell(Text(_categoryLabel(l10n, row.category))),
        DataCell(Text(row.amount)),
        DataCell(Text(row.note ?? '—')),
        if (canWrite)
          DataCell(
            _actionCell(
              l10n: l10n,
              onEdit: () => _startEditExpense(row),
              onDelete: () => _deleteExpense(row),
              editKey: ValueKey('expense-edit-${row.id}'),
              deleteKey: ValueKey('expense-delete-${row.id}'),
            ),
          ),
      ],
    );
  }

  DataRow _harvestRow(
    Harvest row,
    int index,
    bool canWrite,
    AppLocalizations l10n,
  ) {
    return DataRow(
      cells: [
        DataCell(Text('$index')),
        DataCell(Text(row.harvestedAt)),
        DataCell(Text('${row.quantity} ${row.unit}')),
        DataCell(Text(row.saleAmount ?? '—')),
        DataCell(Text(row.note ?? '—')),
        if (canWrite)
          DataCell(
            _actionCell(
              l10n: l10n,
              onEdit: () => _startEditHarvest(row),
              onDelete: () => _deleteHarvest(row),
              editKey: ValueKey('harvest-edit-${row.id}'),
              deleteKey: ValueKey('harvest-delete-${row.id}'),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_loading) return const Center(child: CircularProgressIndicator());
    final cycle = _cycle;
    if (cycle == null) {
      return Center(child: Text(_error ?? l10n.genericError));
    }
    final canWrite = !cycle.isArchived;
    final title = [
      _cropLabel ?? l10n.cropLabel,
      if (cycle.plotName != null && cycle.plotName!.isNotEmpty) cycle.plotName!,
    ].join(' · ');

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        Text(
          '${l10n.plantedPrefix} ${cycle.plantedAt}'
          '${cycle.isArchived ? ' · ${l10n.archived}' : ''}',
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
                child: Text(l10n.archiveCropCycle),
              ),
            ],
          ),
        if (_editing && canWrite) ...[
          CropCycleFormFields(
            cropNames: _cropNames,
            cropNameId: _cropNameId,
            onCropNameChanged: (value) => setState(() => _cropNameId = value),
            plantedAt: _plantedAt,
            expectedHarvestAt: _expectedHarvestAt,
            plotName: _plotName,
            area: _area,
            location: _location,
            notes: _notes,
          ),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: Text(_saving ? l10n.saving : l10n.save),
          ),
        ] else ...[
          ListTile(
            title: Text(l10n.cropLabel),
            subtitle: Text(_cropLabel ?? '—'),
          ),
          ListTile(
            title: Text(l10n.plantedAtHint),
            subtitle: Text(cycle.plantedAt),
          ),
          ListTile(
            title: Text(l10n.expectedHarvestHint),
            subtitle: Text(cycle.expectedHarvestAt ?? '—'),
          ),
          ListTile(
            title: Text(l10n.plotName),
            subtitle: Text(cycle.plotName ?? '—'),
          ),
          ListTile(
            title: Text(l10n.area),
            subtitle: Text(cycle.area ?? '—'),
          ),
          ListTile(
            title: Text(l10n.location),
            subtitle: Text(cycle.location ?? '—'),
          ),
          ListTile(
            title: Text(l10n.notes),
            subtitle: Text(cycle.notes ?? '—'),
          ),
        ],
        const Divider(height: 32),
        Text(l10n.cycleSummary, style: Theme.of(context).textTheme.titleLarge),
        if (_summary != null) ...[
          ListTile(
            title: Text(l10n.totalExpenses),
            subtitle: Text(_summary!.totalExpenses),
          ),
          ListTile(
            title: Text(l10n.totalSaleIncome),
            subtitle: Text(_summary!.totalSaleIncome),
          ),
          ListTile(
            title: Text(l10n.cycleResult),
            subtitle: Text(_summary!.result),
          ),
        ],
        const Divider(height: 32),
        Text(l10n.expenses, style: Theme.of(context).textTheme.titleLarge),
        if (_expenses.isEmpty)
          Text(l10n.noExpenses)
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: [
                DataColumn(label: Text(l10n.rowNumber)),
                DataColumn(label: Text(l10n.dateLabel)),
                DataColumn(label: Text(l10n.expenseCategory)),
                DataColumn(label: Text(l10n.amount)),
                DataColumn(label: Text(l10n.note)),
                if (canWrite) DataColumn(label: Text(l10n.actions)),
              ],
              rows: [
                for (var i = 0; i < _expenses.length; i++)
                  _expenseRow(_expenses[i], i + 1, canWrite, l10n),
              ],
            ),
          ),
        if (canWrite) ...[
          FormFieldColumn(
            children: [
              TextField(
                controller: _spentAt,
                decoration: InputDecoration(labelText: l10n.spentAtHint),
              ),
              DropdownButtonFormField<ExpenseCategory>(
                // ignore: deprecated_member_use
                value: _expenseCategory,
                decoration: InputDecoration(labelText: l10n.expenseCategory),
                items: ExpenseCategory.values
                    .map(
                      (c) => DropdownMenuItem(
                        value: c,
                        child: Text(_categoryLabel(l10n, c)),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _expenseCategory = v);
                },
              ),
              TextField(
                controller: _expenseAmount,
                decoration: InputDecoration(labelText: l10n.amount),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              TextField(
                controller: _expenseNote,
                decoration: InputDecoration(labelText: l10n.note),
              ),
            ],
          ),
          const SizedBox(height: FormFieldColumn.gap),
          FilledButton(
            onPressed: _saveExpense,
            child: Text(
              _editingExpenseId != null
                  ? l10n.updateExpenseEntry
                  : l10n.addExpense,
            ),
          ),
          if (_editingExpenseId != null)
            TextButton(
              onPressed: () => setState(_resetExpenseForm),
              child: Text(l10n.cancelEdit),
            ),
        ],
        const Divider(height: 32),
        Text(l10n.harvests, style: Theme.of(context).textTheme.titleLarge),
        if (_harvests.isEmpty)
          Text(l10n.noHarvests)
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: [
                DataColumn(label: Text(l10n.rowNumber)),
                DataColumn(label: Text(l10n.dateLabel)),
                DataColumn(label: Text(l10n.quantity)),
                DataColumn(label: Text(l10n.saleAmountColumn)),
                DataColumn(label: Text(l10n.note)),
                if (canWrite) DataColumn(label: Text(l10n.actions)),
              ],
              rows: [
                for (var i = 0; i < _harvests.length; i++)
                  _harvestRow(_harvests[i], i + 1, canWrite, l10n),
              ],
            ),
          ),
        if (canWrite) ...[
          FormFieldColumn(
            children: [
              TextField(
                controller: _harvestedAt,
                decoration: InputDecoration(labelText: l10n.harvestedAtHint),
              ),
              TextField(
                controller: _harvestQty,
                decoration: InputDecoration(labelText: l10n.quantity),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              TextField(
                controller: _harvestUnit,
                decoration: InputDecoration(labelText: l10n.unit),
              ),
              TextField(
                controller: _saleAmount,
                decoration: InputDecoration(labelText: l10n.saleAmountOptional),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              TextField(
                controller: _harvestNote,
                decoration: InputDecoration(labelText: l10n.note),
              ),
            ],
          ),
          const SizedBox(height: FormFieldColumn.gap),
          FilledButton(
            onPressed: _saveHarvest,
            child: Text(
              _editingHarvestId != null
                  ? l10n.updateHarvestEntry
                  : l10n.addHarvest,
            ),
          ),
          if (_editingHarvestId != null)
            TextButton(
              onPressed: () => setState(_resetHarvestForm),
              child: Text(l10n.cancelEdit),
            ),
        ] else
          Text(l10n.cropCycleArchivedReadOnly),
      ],
    );
  }
}
