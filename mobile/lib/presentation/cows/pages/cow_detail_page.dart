import 'package:flutter/material.dart';
import '../../../domain/entities/cow.dart';
import '../../../domain/failures.dart';
import '../../../domain/usecases/cows_usecases.dart';
import '../../../infrastructure/di/injection.dart';
import '../../../l10n/app_localizations.dart';
import '../widgets/cow_form_fields.dart';

class CowDetailPage extends StatefulWidget {
  const CowDetailPage({super.key, required this.cowId});

  final String cowId;

  @override
  State<CowDetailPage> createState() => _CowDetailPageState();
}

class _CowDetailPageState extends State<CowDetailPage> {
  Cow? _cow;
  List<MilkProduction> _milk = const [];
  List<CowFeeding> _feedings = const [];
  bool _loading = true;
  bool _editing = false;
  bool _saving = false;
  String? _error;

  final _tagNumber = TextEditingController();
  final _name = TextEditingController();
  final _breed = TextEditingController();
  final _dateOfBirth = TextEditingController();
  final _color = TextEditingController();
  final _weight = TextEditingController();
  final _age = TextEditingController();
  final _purchaseDate = TextEditingController();
  final _purchasePrice = TextEditingController();
  final _notes = TextEditingController();
  CowPurpose _purpose = CowPurpose.milk;
  CowGender _gender = CowGender.female;
  AcquisitionSource _acquiredBy = AcquisitionSource.bornOnFarm;

  final _milkQty = TextEditingController();
  final _milkUnit = TextEditingController(text: 'L');
  final _milkPrice = TextEditingController(text: '0');
  final _milkNote = TextEditingController();
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
      _tagNumber,
      _name,
      _breed,
      _dateOfBirth,
      _color,
      _weight,
      _age,
      _purchaseDate,
      _purchasePrice,
      _notes,
      _milkQty,
      _milkUnit,
      _milkPrice,
      _milkNote,
      _feedName,
      _feedQty,
      _feedUnit,
      _feedNote,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _hydrateForm(Cow cow) {
    _tagNumber.text = cow.tagNumber;
    _name.text = cow.name ?? '';
    _breed.text = cow.breed ?? '';
    _dateOfBirth.text = cow.dateOfBirth ?? '';
    _color.text = cow.color ?? '';
    _weight.text = cow.weight ?? '';
    _age.text = cow.age?.toString() ?? '';
    _purchaseDate.text = cow.purchaseDate ?? '';
    _purchasePrice.text = cow.purchasePrice ?? '';
    _notes.text = cow.notes ?? '';
    _purpose = cow.purpose;
    _gender = cow.gender;
    _acquiredBy = cow.acquiredBy;
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final cow = await getIt<GetCow>()(widget.cowId);
      final milk = cow.milkEligible
          ? await getIt<ListMilkProductions>()(widget.cowId)
          : null;
      final feedings = await getIt<ListCowFeedings>()(widget.cowId);
      if (!mounted) return;
      _hydrateForm(cow);
      setState(() {
        _cow = cow;
        _milk = milk?.items ?? const [];
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
      final cow = await getIt<UpdateCow>()(
        widget.cowId,
        buildCowWriteParams(
          tagNumber: _tagNumber,
          name: _name,
          breed: _breed,
          dateOfBirth: _dateOfBirth,
          color: _color,
          weight: _weight,
          age: _age,
          purchaseDate: _purchaseDate,
          purchasePrice: _purchasePrice,
          notes: _notes,
          purpose: _purpose,
          gender: _gender,
          acquiredBy: _acquiredBy,
        ),
      );
      if (!mounted) return;
      setState(() {
        _cow = cow;
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
        title: Text(l10n.archiveCow),
        content: Text(l10n.archiveCowConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.archiveCow),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await getIt<ArchiveCow>()(widget.cowId);
      await _load();
    } on AppFailure catch (e) {
      setState(() => _error = e.message);
    }
  }

  Future<void> _addMilk() async {
    setState(() => _error = null);
    try {
      await getIt<AddMilkProduction>()(
        cowId: widget.cowId,
        producedAt: DateTime.now().toUtc().toIso8601String(),
        quantity: _milkQty.text.trim(),
        unit: _milkUnit.text.trim(),
        pricePerUnit: _milkPrice.text.trim(),
        note: _milkNote.text.trim().isEmpty ? null : _milkNote.text.trim(),
      );
      _milkQty.clear();
      _milkNote.clear();
      await _load();
    } on AppFailure catch (e) {
      setState(() => _error = e.message);
    }
  }

  Future<void> _addFeeding() async {
    setState(() => _error = null);
    try {
      await getIt<AddCowFeeding>()(
        cowId: widget.cowId,
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
    final cow = _cow;
    if (cow == null) {
      return Center(child: Text(_error ?? l10n.genericError));
    }
    final canWrite = !cow.isArchived;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          cow.name == null || cow.name!.isEmpty
              ? cow.tagNumber
              : '${cow.tagNumber} · ${cow.name}',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        Text(
          '${cow.purpose.name} · ${cow.gender.name}'
          '${cow.isArchived ? ' · ${l10n.archived}' : ''}',
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
              TextButton(onPressed: _archive, child: Text(l10n.archiveCow)),
            ],
          ),
        if (_editing && canWrite) ...[
          CowFormFields(
            tagNumber: _tagNumber,
            name: _name,
            breed: _breed,
            dateOfBirth: _dateOfBirth,
            color: _color,
            weight: _weight,
            age: _age,
            purchaseDate: _purchaseDate,
            purchasePrice: _purchasePrice,
            notes: _notes,
            purpose: _purpose,
            gender: _gender,
            acquiredBy: _acquiredBy,
            onPurposeChanged: (v) => setState(() => _purpose = v),
            onGenderChanged: (v) => setState(() => _gender = v),
            onAcquiredByChanged: (v) => setState(() => _acquiredBy = v),
          ),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: Text(_saving ? l10n.saving : l10n.save),
          ),
        ] else ...[
          ListTile(title: Text(l10n.breed), subtitle: Text(cow.breed ?? '—')),
          ListTile(title: Text(l10n.color), subtitle: Text(cow.color ?? '—')),
          ListTile(
            title: Text(l10n.notes),
            subtitle: Text(cow.notes ?? '—'),
          ),
        ],
        const Divider(height: 32),
        Text(l10n.milkProduction, style: Theme.of(context).textTheme.titleLarge),
        if (!cow.milkEligible)
          Text(l10n.milkNotForMeat)
        else ...[
          ..._milk.map(
            (row) => ListTile(
              title: Text('${row.quantity} ${row.unit}'),
              subtitle: Text(row.producedAt),
            ),
          ),
          if (_milk.isEmpty) Text(l10n.noMilkEntries),
          if (canWrite) ...[
            TextField(
              controller: _milkQty,
              decoration: InputDecoration(labelText: l10n.quantity),
            ),
            TextField(
              controller: _milkUnit,
              decoration: InputDecoration(labelText: l10n.unit),
            ),
            TextField(
              controller: _milkPrice,
              decoration: InputDecoration(labelText: l10n.pricePerUnit),
            ),
            TextField(
              controller: _milkNote,
              decoration: InputDecoration(labelText: l10n.note),
            ),
            FilledButton(onPressed: _addMilk, child: Text(l10n.addMilk)),
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
          Text(l10n.archivedReadOnly),
      ],
    );
  }
}
