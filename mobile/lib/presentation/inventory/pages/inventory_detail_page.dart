import 'package:flutter/material.dart';
import '../../../domain/entities/inventory.dart';
import '../../../domain/failures.dart';
import '../../../domain/usecases/inventory_usecases.dart';
import '../../../infrastructure/di/injection.dart';
import '../../../l10n/app_localizations.dart';
import '../widgets/inventory_item_form_fields.dart';

String _todayDate() {
  final now = DateTime.now();
  final m = now.month.toString().padLeft(2, '0');
  final d = now.day.toString().padLeft(2, '0');
  return '${now.year}-$m-$d';
}

class InventoryDetailPage extends StatefulWidget {
  const InventoryDetailPage({super.key, required this.itemId});

  final String itemId;

  @override
  State<InventoryDetailPage> createState() => _InventoryDetailPageState();
}

class _InventoryDetailPageState extends State<InventoryDetailPage> {
  InventoryItem? _item;
  List<StockUpdate> _updates = const [];
  bool _loading = true;
  bool _editing = false;
  bool _saving = false;
  String? _error;

  final _name = TextEditingController();
  final _quantity = TextEditingController();
  final _unit = TextEditingController();
  final _pricePerUnit = TextEditingController();
  final _note = TextEditingController();
  InventoryCategory _category = InventoryCategory.feed;

  final _occurredAt = TextEditingController(text: _todayDate());
  final _quantityChange = TextEditingController();
  final _reason = TextEditingController();
  StockChangeType _changeType = StockChangeType.add;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final c in [
      _name,
      _quantity,
      _unit,
      _pricePerUnit,
      _note,
      _occurredAt,
      _quantityChange,
      _reason,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _hydrate(InventoryItem item) {
    _name.text = item.name;
    _quantity.text = item.quantity;
    _unit.text = item.unit;
    _pricePerUnit.text = item.pricePerUnit;
    _note.text = item.note ?? '';
    _category = item.category;
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final item = await getIt<GetInventoryItem>()(widget.itemId);
      final updates = await getIt<ListStockUpdates>()(widget.itemId);
      if (!mounted) return;
      _hydrate(item);
      setState(() {
        _item = item;
        _updates = updates.items;
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
      await getIt<UpdateInventoryItem>()(
        widget.itemId,
        buildInventoryItemUpdateParams(
          name: _name,
          unit: _unit,
          pricePerUnit: _pricePerUnit,
          note: _note,
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
        title: Text(l10n.archiveInventoryItem),
        content: Text(l10n.archiveInventoryItemConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.archiveInventoryItem),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await getIt<ArchiveInventoryItem>()(widget.itemId);
      await _load();
    } on AppFailure catch (e) {
      setState(() => _error = e.message);
    }
  }

  Future<void> _addStock() async {
    setState(() => _error = null);
    try {
      await getIt<AddStockUpdate>()(
        itemId: widget.itemId,
        occurredAt: _occurredAt.text.trim(),
        changeType: _changeType,
        quantityChange: _quantityChange.text.trim(),
        reason: _reason.text.trim().isEmpty ? null : _reason.text.trim(),
      );
      _quantityChange.clear();
      _reason.clear();
      await _load();
    } on AppFailure catch (e) {
      setState(() => _error = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_loading) return const Center(child: CircularProgressIndicator());
    final item = _item;
    if (item == null) {
      return Center(child: Text(_error ?? l10n.genericError));
    }
    final canWrite = !item.isArchived;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(item.name, style: Theme.of(context).textTheme.headlineSmall),
        Text(
          '${inventoryCategoryLabel(l10n, item.category)} · '
          '${item.quantity} ${item.unit}'
          '${item.isArchived ? ' · ${l10n.archived}' : ''}',
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
                child: Text(l10n.archiveInventoryItem),
              ),
            ],
          ),
        if (_editing && canWrite) ...[
          InventoryItemFormFields(
            includeQuantity: false,
            name: _name,
            quantity: _quantity,
            unit: _unit,
            pricePerUnit: _pricePerUnit,
            note: _note,
            category: _category,
            onCategoryChanged: (v) => setState(() => _category = v),
          ),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: Text(_saving ? l10n.saving : l10n.save),
          ),
        ] else ...[
          ListTile(
            title: Text(l10n.inventoryCategory),
            subtitle: Text(inventoryCategoryLabel(l10n, item.category)),
          ),
          ListTile(
            title: Text(l10n.quantity),
            subtitle: Text('${item.quantity} ${item.unit}'),
          ),
          ListTile(
            title: Text(l10n.pricePerUnit),
            subtitle: Text(item.pricePerUnit),
          ),
          ListTile(
            title: Text(l10n.totalPrice),
            subtitle: Text(item.totalPrice),
          ),
          ListTile(
            title: Text(l10n.note),
            subtitle: Text(item.note ?? '—'),
          ),
        ],
        const Divider(height: 32),
        Text(l10n.stockUpdates, style: Theme.of(context).textTheme.titleLarge),
        ..._updates.map(
          (row) => ListTile(
            title: Text(
              '${row.changeType.name}: ${row.quantityChange}',
            ),
            subtitle: Text(row.occurredAt),
          ),
        ),
        if (_updates.isEmpty) Text(l10n.noStockUpdates),
        if (canWrite) ...[
          TextField(
            controller: _occurredAt,
            decoration: InputDecoration(labelText: l10n.occurredAtHint),
          ),
          DropdownButtonFormField<StockChangeType>(
            // ignore: deprecated_member_use
            value: _changeType,
            decoration: InputDecoration(labelText: l10n.stockChangeType),
            items: [
              DropdownMenuItem(
                value: StockChangeType.add,
                child: Text(l10n.stockAdd),
              ),
              DropdownMenuItem(
                value: StockChangeType.use,
                child: Text(l10n.stockUse),
              ),
            ],
            onChanged: (v) {
              if (v != null) setState(() => _changeType = v);
            },
          ),
          TextField(
            controller: _quantityChange,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: l10n.quantityChange),
          ),
          TextField(
            controller: _reason,
            decoration: InputDecoration(labelText: l10n.reason),
          ),
          FilledButton(onPressed: _addStock, child: Text(l10n.addStockUpdate)),
        ] else
          Text(l10n.inventoryArchivedReadOnly),
      ],
    );
  }
}
