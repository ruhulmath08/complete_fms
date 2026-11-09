import 'package:flutter/material.dart';
import '../../../domain/entities/crop.dart';
import '../../../domain/failures.dart';
import '../../../domain/usecases/crops_usecases.dart';
import '../../../infrastructure/di/injection.dart';
import '../../../l10n/app_localizations.dart';
import '../widgets/crop_name_form_fields.dart';

class CropNameDetailPage extends StatefulWidget {
  const CropNameDetailPage({super.key, required this.cropNameId});

  final String cropNameId;

  @override
  State<CropNameDetailPage> createState() => _CropNameDetailPageState();
}

class _CropNameDetailPageState extends State<CropNameDetailPage> {
  CropName? _cropName;
  bool _loading = true;
  bool _editing = false;
  bool _saving = false;
  String? _error;

  final _name = TextEditingController();
  final _notes = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _name.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _hydrate(CropName cropName) {
    _name.text = cropName.name;
    _notes.text = cropName.notes ?? '';
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final cropName = await getIt<GetCropName>()(widget.cropNameId);
      if (!mounted) return;
      _hydrate(cropName);
      setState(() {
        _cropName = cropName;
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
      final cropName = await getIt<UpdateCropName>()(
        widget.cropNameId,
        buildCropNameWriteParams(name: _name, notes: _notes),
      );
      if (!mounted) return;
      setState(() {
        _cropName = cropName;
        _editing = false;
      });
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
        title: Text(l10n.archiveCropName),
        content: Text(l10n.archiveCropNameConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.archiveCropName),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await getIt<ArchiveCropName>()(widget.cropNameId);
      await _load();
    } on AppFailure catch (e) {
      setState(() => _error = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_loading) return const Center(child: CircularProgressIndicator());
    final cropName = _cropName;
    if (cropName == null) {
      return Center(child: Text(_error ?? l10n.genericError));
    }
    final canWrite = !cropName.isArchived;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(cropName.name, style: Theme.of(context).textTheme.headlineSmall),
        Text(
          cropName.isArchived
              ? '${l10n.cropNamesTitle} · ${l10n.archived}'
              : l10n.cropNamesTitle,
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
                child: Text(l10n.archiveCropName),
              ),
            ],
          )
        else
          Text(l10n.cropNameArchivedReadOnly),
        if (_editing && canWrite) ...[
          CropNameFormFields(name: _name, notes: _notes),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: Text(_saving ? l10n.saving : l10n.save),
          ),
        ] else ...[
          ListTile(
            title: Text(l10n.cropNameLabel),
            subtitle: Text(cropName.name),
          ),
          ListTile(
            title: Text(l10n.notes),
            subtitle: Text(cropName.notes ?? '—'),
          ),
        ],
      ],
    );
  }
}
