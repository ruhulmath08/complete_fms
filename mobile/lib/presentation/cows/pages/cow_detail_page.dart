import 'package:flutter/material.dart';
import '../../../domain/entities/cow.dart';
import '../../../domain/failures.dart';
import '../../../domain/usecases/cows_usecases.dart';
import '../../../infrastructure/di/injection.dart';
import '../../../infrastructure/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../shared/widgets/form_field_column.dart';
import '../../shared/widgets/offset_pagination_controls.dart';
import '../widgets/cow_form_fields.dart';
import '../widgets/cow_image_panel.dart';

const _pageSize = 10;

String rowTotal(String quantity, String unitPrice, String? apiTotal) {
  if (apiTotal != null && apiTotal.isNotEmpty) return apiTotal;
  final qty = double.tryParse(quantity);
  final price = double.tryParse(unitPrice);
  if (qty == null || price == null) return '—';
  return (qty * price).toStringAsFixed(2);
}

String formatHistoryDate(String iso) {
  final parsed = DateTime.tryParse(iso);
  if (parsed == null) return iso;
  final local = parsed.toLocal();
  return '${local.year}-${_two(local.month)}-${_two(local.day)} '
      '${_two(local.hour)}:${_two(local.minute)}';
}

String _two(int n) => n.toString().padLeft(2, '0');

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
  int _milkOffset = 0;
  int _milkTotal = 0;
  int _feedingOffset = 0;
  int _feedingTotal = 0;
  String? _editingMilkId;
  String? _editingFeedingId;
  bool _loading = true;
  bool _editing = false;
  bool _saving = false;
  String? _error;
  String? _imagePath;

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

  final _milkProducedAt = TextEditingController();
  final _milkQty = TextEditingController();
  final _milkUnit = TextEditingController(text: 'L');
  final _milkPrice = TextEditingController(text: '0');
  final _milkNote = TextEditingController();
  final _feedFedAt = TextEditingController();
  final _feedName = TextEditingController();
  final _feedQty = TextEditingController();
  final _feedUnit = TextEditingController(text: 'kg');
  final _feedUnitCost = TextEditingController(text: '0');
  final _feedNote = TextEditingController();

  @override
  void initState() {
    super.initState();
    _resetMilkForm();
    _resetFeedingForm();
    _load();
  }

  @override
  void dispose() {
    for (final c in [
      _name,
      _breed,
      _dateOfBirth,
      _color,
      _weight,
      _age,
      _purchaseDate,
      _purchasePrice,
      _notes,
      _milkProducedAt,
      _milkQty,
      _milkUnit,
      _milkPrice,
      _milkNote,
      _feedFedAt,
      _feedName,
      _feedQty,
      _feedUnit,
      _feedUnitCost,
      _feedNote,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _hydrateForm(Cow cow) {
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

  String _cowPhotoSemantics(Cow cow, AppLocalizations l10n) {
    final name = cow.name;
    if (name != null && name.isNotEmpty) {
      return l10n.cowPhotoAlt(name, cow.tagNumber);
    }
    return l10n.cowPhotoAltNoName(cow.tagNumber);
  }

  void _resetMilkForm() {
    _editingMilkId = null;
    _milkProducedAt.text = DateTime.now().toUtc().toIso8601String();
    _milkQty.clear();
    _milkUnit.text = 'L';
    _milkPrice.text = '0';
    _milkNote.clear();
  }

  void _resetFeedingForm() {
    _editingFeedingId = null;
    _feedFedAt.text = DateTime.now().toUtc().toIso8601String();
    _feedName.clear();
    _feedQty.clear();
    _feedUnit.text = 'kg';
    _feedUnitCost.text = '0';
    _feedNote.clear();
  }

  void _startEditMilk(MilkProduction row) {
    setState(() {
      _editingMilkId = row.id;
      _milkProducedAt.text = row.producedAt;
      _milkQty.text = row.quantity;
      _milkUnit.text = row.unit;
      _milkPrice.text = row.pricePerUnit;
      _milkNote.text = row.note ?? '';
    });
  }

  void _startEditFeeding(CowFeeding row) {
    setState(() {
      _editingFeedingId = row.id;
      _feedFedAt.text = row.fedAt;
      _feedName.text = row.feedName;
      _feedQty.text = row.quantity;
      _feedUnit.text = row.unit;
      _feedUnitCost.text = row.unitCost;
      _feedNote.text = row.note ?? '';
    });
  }

  Future<void> _loadMilk() async {
    if (_cow != null && !_cow!.milkEligible) return;
    final page = await getIt<ListMilkProductions>()(
      widget.cowId,
      limit: _pageSize,
      offset: _milkOffset,
    );
    if (!mounted) return;
    setState(() {
      _milk = page.items;
      _milkTotal = page.total;
    });
  }

  Future<void> _loadFeedings() async {
    final page = await getIt<ListCowFeedings>()(
      widget.cowId,
      limit: _pageSize,
      offset: _feedingOffset,
    );
    if (!mounted) return;
    setState(() {
      _feedings = page.items;
      _feedingTotal = page.total;
    });
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final cow = await getIt<GetCow>()(widget.cowId);
      if (!mounted) return;
      _hydrateForm(cow);
      setState(() {
        _cow = cow;
        _loading = false;
        _imagePath = null;
      });
      await Future.wait([_loadMilk(), _loadFeedings()]);
    } on AppFailure catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    }
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final params = buildCowWriteParams(
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
    );
    if (params == null) {
      setState(() => _error = l10n.nameBreedRequired);
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      var cow = await getIt<UpdateCow>()(widget.cowId, params);
      final imagePath = _imagePath;
      if (imagePath != null) {
        cow = await getIt<UploadCowImage>()(widget.cowId, imagePath);
      }
      if (!mounted) return;
      setState(() {
        _cow = cow;
        _editing = false;
        _imagePath = null;
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

  Future<void> _saveMilk() async {
    setState(() => _error = null);
    final note = _milkNote.text.trim();
    try {
      if (_editingMilkId != null) {
        await getIt<UpdateMilkProduction>()(
          cowId: widget.cowId,
          milkId: _editingMilkId!,
          producedAt: _milkProducedAt.text.trim(),
          quantity: _milkQty.text.trim(),
          unit: _milkUnit.text.trim(),
          pricePerUnit: _milkPrice.text.trim(),
          note: note.isEmpty ? null : note,
        );
      } else {
        await getIt<AddMilkProduction>()(
          cowId: widget.cowId,
          producedAt: _milkProducedAt.text.trim(),
          quantity: _milkQty.text.trim(),
          unit: _milkUnit.text.trim(),
          pricePerUnit: _milkPrice.text.trim(),
          note: note.isEmpty ? null : note,
        );
      }
      setState(() {
        _milkOffset = 0;
        _resetMilkForm();
      });
      await _loadMilk();
    } on AppFailure catch (e) {
      setState(() => _error = e.message);
    }
  }

  Future<void> _deleteMilk(MilkProduction row) async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(l10n.deleteMilkConfirm),
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
      await getIt<DeleteMilkProduction>()(widget.cowId, row.id);
      if (_editingMilkId == row.id) _resetMilkForm();
      await _loadMilk();
    } on AppFailure catch (e) {
      setState(() => _error = e.message);
    }
  }

  Future<void> _saveFeeding() async {
    setState(() => _error = null);
    final note = _feedNote.text.trim();
    try {
      if (_editingFeedingId != null) {
        await getIt<UpdateCowFeeding>()(
          cowId: widget.cowId,
          feedingId: _editingFeedingId!,
          fedAt: _feedFedAt.text.trim(),
          feedName: _feedName.text.trim(),
          quantity: _feedQty.text.trim(),
          unit: _feedUnit.text.trim(),
          unitCost: _feedUnitCost.text.trim(),
          note: note.isEmpty ? null : note,
        );
      } else {
        await getIt<AddCowFeeding>()(
          cowId: widget.cowId,
          fedAt: _feedFedAt.text.trim(),
          feedName: _feedName.text.trim(),
          quantity: _feedQty.text.trim(),
          unit: _feedUnit.text.trim(),
          unitCost: _feedUnitCost.text.trim(),
          note: note.isEmpty ? null : note,
        );
      }
      setState(() {
        _feedingOffset = 0;
        _resetFeedingForm();
      });
      await _loadFeedings();
    } on AppFailure catch (e) {
      setState(() => _error = e.message);
    }
  }

  Future<void> _deleteFeeding(CowFeeding row) async {
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
      await getIt<DeleteCowFeeding>()(widget.cowId, row.id);
      if (_editingFeedingId == row.id) _resetFeedingForm();
      await _loadFeedings();
    } on AppFailure catch (e) {
      setState(() => _error = e.message);
    }
  }

  String _paginationSummaryText(AppLocalizations l10n, int offset, int total) {
    final page = (offset ~/ _pageSize) + 1;
    final totalPages = (total / _pageSize).ceil().clamp(1, 1 << 30);
    return l10n.paginationSummary(page, totalPages, total);
  }

  Widget _buildMilkSection(Cow cow, bool canWrite, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.milkProduction, style: Theme.of(context).textTheme.titleLarge),
        if (!cow.milkEligible)
          Text(l10n.milkNotForMeat)
        else ...[
          if (_milk.isEmpty)
            Text(l10n.noMilkEntries)
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
                  for (var i = 0; i < _milk.length; i++)
                    _milkRow(_milk[i], _milkOffset + i + 1, canWrite, l10n),
                ],
              ),
            ),
          OffsetPaginationControls(
            total: _milkTotal,
            limit: _pageSize,
            offset: _milkOffset,
            onOffsetChanged: (next) async {
              setState(() => _milkOffset = next);
              await _loadMilk();
            },
            semanticsLabel: l10n.milkPaginationLabel,
            summaryText: _paginationSummaryText(l10n, _milkOffset, _milkTotal),
            previousLabel: l10n.paginationPrevious,
            nextLabel: l10n.paginationNext,
          ),
          if (canWrite) ...[
            FormFieldColumn(
              children: [
                TextField(
                  controller: _milkProducedAt,
                  decoration: InputDecoration(labelText: l10n.producedAtHint),
                ),
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
              ],
            ),
            const SizedBox(height: FormFieldColumn.gap),
            FilledButton(
              onPressed: _saveMilk,
              child: Text(
                _editingMilkId != null ? l10n.updateMilkEntry : l10n.addMilk,
              ),
            ),
            if (_editingMilkId != null)
              TextButton(
                onPressed: () => setState(_resetMilkForm),
                child: Text(l10n.cancelEdit),
              ),
          ],
        ],
      ],
    );
  }

  DataRow _milkRow(
    MilkProduction row,
    int index,
    bool canWrite,
    AppLocalizations l10n,
  ) {
    return DataRow(
      cells: [
        DataCell(Text('$index')),
        DataCell(Text(formatHistoryDate(row.producedAt))),
        DataCell(Text('${row.quantity} ${row.unit}')),
        DataCell(Text(row.pricePerUnit)),
        DataCell(Text(rowTotal(row.quantity, row.pricePerUnit, row.total))),
        DataCell(Text(row.note ?? '—')),
        if (canWrite)
          DataCell(
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: l10n.editEntry,
                  onPressed: () => _startEditMilk(row),
                  color: AppTokens.of(context).primary,
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  tooltip: l10n.delete,
                  onPressed: () => _deleteMilk(row),
                  color: AppTokens.of(context).danger,
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildFeedingSection(bool canWrite, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
                DataColumn(label: Text(l10n.unitCost)),
                DataColumn(label: Text(l10n.total)),
                DataColumn(label: Text(l10n.note)),
                if (canWrite) DataColumn(label: Text(l10n.actions)),
              ],
              rows: [
                for (var i = 0; i < _feedings.length; i++)
                  _feedingRow(_feedings[i], _feedingOffset + i + 1, canWrite, l10n),
              ],
            ),
          ),
        OffsetPaginationControls(
          total: _feedingTotal,
          limit: _pageSize,
          offset: _feedingOffset,
          onOffsetChanged: (next) async {
            setState(() => _feedingOffset = next);
            await _loadFeedings();
          },
          semanticsLabel: l10n.feedingPaginationLabel,
          summaryText:
              _paginationSummaryText(l10n, _feedingOffset, _feedingTotal),
          previousLabel: l10n.paginationPrevious,
          nextLabel: l10n.paginationNext,
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
                controller: _feedUnitCost,
                decoration: InputDecoration(
                  labelText: l10n.unitCost,
                ),
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
              _editingFeedingId != null ? l10n.updateFeedingEntry : l10n.addFeeding,
            ),
          ),
          if (_editingFeedingId != null)
            TextButton(
              onPressed: () => setState(_resetFeedingForm),
              child: Text(l10n.cancelEdit),
            ),
        ] else
          Text(l10n.archivedReadOnly),
      ],
    );
  }

  DataRow _feedingRow(
    CowFeeding row,
    int index,
    bool canWrite,
    AppLocalizations l10n,
  ) {
    return DataRow(
      cells: [
        DataCell(Text('$index')),
        DataCell(Text(formatHistoryDate(row.fedAt))),
        DataCell(Text(row.feedName)),
        DataCell(Text('${row.quantity} ${row.unit}')),
        DataCell(Text(row.unitCost)),
        DataCell(Text(rowTotal(row.quantity, row.unitCost, row.total))),
        DataCell(Text(row.note ?? '—')),
        if (canWrite)
          DataCell(
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: l10n.editEntry,
                  onPressed: () => _startEditFeeding(row),
                  color: AppTokens.of(context).primary,
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  tooltip: l10n.delete,
                  onPressed: () => _deleteFeeding(row),
                  color: AppTokens.of(context).danger,
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildDetailChrome(Cow cow, AppLocalizations l10n, bool canWrite) {
    final tokens = AppTokens.of(context);
    final photoLabel = _cowPhotoSemantics(cow, l10n);
    final image = CowImagePanel(
      cowId: cow.id,
      hasRemoteImage: cow.imageUrl != null && cow.imageUrl!.isNotEmpty,
      localPath: _editing ? _imagePath : null,
      canPick: _editing && canWrite,
      onLocalPathChanged: (path) => setState(() => _imagePath = path),
      imageWidth: 148,
      imageHeight: 186,
      semanticsLabel: photoLabel,
    );

    final info = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(title: Text(l10n.breed), subtitle: Text(cow.breed ?? '—')),
        ListTile(
          title: Text(l10n.weightKg),
          subtitle: Text(cow.weight ?? '—'),
        ),
        ListTile(title: Text(l10n.color), subtitle: Text(cow.color ?? '—')),
        ListTile(
          title: Text(l10n.notes),
          subtitle: Text(cow.notes ?? '—'),
        ),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final stackNarrow = constraints.maxWidth < 520;
        if (stackNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              image,
              SizedBox(height: tokens.space3),
              info,
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            image,
            SizedBox(width: tokens.space4),
            Expanded(child: info),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tokens = AppTokens.of(context);
    if (_loading) return const Center(child: CircularProgressIndicator());
    final cow = _cow;
    if (cow == null) {
      return Center(child: Text(_error ?? l10n.genericError));
    }
    final canWrite = !cow.isArchived;

    return ListView(
      padding: EdgeInsets.all(tokens.space4),
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
        SizedBox(height: tokens.space3),
        if (_error != null)
          Padding(
            padding: EdgeInsets.only(bottom: tokens.space2),
            child: Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        if (canWrite)
          Row(
            children: [
              TextButton(
                onPressed: () => setState(() {
                  _editing = !_editing;
                  _imagePath = null;
                }),
                child: Text(_editing ? l10n.cancel : l10n.edit),
              ),
              TextButton(onPressed: _archive, child: Text(l10n.archiveCow)),
            ],
          ),
        if (_editing && canWrite) ...[
          CowFormFields(
            displayTag: cow.tagNumber,
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
          CowImagePanel(
            cowId: cow.id,
            hasRemoteImage: cow.imageUrl != null && cow.imageUrl!.isNotEmpty,
            localPath: _imagePath,
            canPick: true,
            onLocalPathChanged: (path) => setState(() => _imagePath = path),
            semanticsLabel: _cowPhotoSemantics(cow, l10n),
          ),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: Text(_saving ? l10n.saving : l10n.save),
          ),
        ] else
          _buildDetailChrome(cow, l10n, canWrite),
        const Divider(height: 32),
        _buildMilkSection(cow, canWrite, l10n),
        const Divider(height: 32),
        _buildFeedingSection(canWrite, l10n),
      ],
    );
  }
}
