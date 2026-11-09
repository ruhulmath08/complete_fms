import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/entities/crop.dart';
import '../../../domain/failures.dart';
import '../../../domain/usecases/crops_usecases.dart';
import '../../../infrastructure/di/injection.dart';
import '../../../l10n/app_localizations.dart';
import '../widgets/crop_cycle_form_fields.dart';

String _todayDate() {
  final now = DateTime.now();
  final m = now.month.toString().padLeft(2, '0');
  final d = now.day.toString().padLeft(2, '0');
  return '${now.year}-$m-$d';
}

class CropCycleCreatePage extends StatefulWidget {
  const CropCycleCreatePage({super.key});

  @override
  State<CropCycleCreatePage> createState() => _CropCycleCreatePageState();
}

class _CropCycleCreatePageState extends State<CropCycleCreatePage> {
  final _plantedAt = TextEditingController(text: _todayDate());
  final _expectedHarvestAt = TextEditingController();
  final _plotName = TextEditingController();
  final _area = TextEditingController();
  final _location = TextEditingController();
  final _notes = TextEditingController();

  List<CropName> _cropNames = const [];
  String? _cropNameId;
  bool _loadingNames = true;
  String? _error;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadNames();
  }

  @override
  void dispose() {
    _plantedAt.dispose();
    _expectedHarvestAt.dispose();
    _plotName.dispose();
    _area.dispose();
    _location.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _loadNames() async {
    setState(() {
      _loadingNames = true;
      _error = null;
    });
    try {
      final page = await getIt<ListCropNames>()(includeArchived: false);
      if (!mounted) return;
      setState(() {
        _cropNames = page.items;
        _cropNameId = page.items.isNotEmpty ? page.items.first.id : null;
        _loadingNames = false;
      });
    } on AppFailure catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loadingNames = false;
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
      final cycle = await getIt<CreateCropCycle>()(
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
      context.go('/crops/cycles/${cycle.id}');
    } on AppFailure catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_loadingNames) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          l10n.addCropCycle,
          style: Theme.of(context).textTheme.headlineSmall,
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
        if (_cropNames.isEmpty)
          Text(l10n.noActiveCropNames)
        else ...[
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
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: Text(_saving ? l10n.saving : l10n.createCropCycle),
          ),
        ],
      ],
    );
  }
}
