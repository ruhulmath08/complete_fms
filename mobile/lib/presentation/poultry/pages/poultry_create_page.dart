import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/poultry.dart';
import '../../../domain/failures.dart';
import '../../../domain/usecases/poultry_usecases.dart';
import '../../../infrastructure/di/injection.dart';
import '../../../infrastructure/router/app_routes.dart';
import '../../../l10n/app_localizations.dart';
import '../widgets/poultry_group_form_fields.dart';

class PoultryCreatePage extends StatefulWidget {
  const PoultryCreatePage({super.key});

  @override
  State<PoultryCreatePage> createState() => _PoultryCreatePageState();
}

class _PoultryCreatePageState extends State<PoultryCreatePage> {
  final _name = TextEditingController();
  final _birdCount = TextEditingController(text: '0');
  final _dateAcquired = TextEditingController();
  final _purchaseDate = TextEditingController();
  final _purchasePrice = TextEditingController();
  final _notes = TextEditingController();

  PoultryType _poultryType = PoultryType.layer;
  AcquisitionSource _acquiredBy = AcquisitionSource.bornOnFarm;
  String? _error;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _birdCount.dispose();
    _dateAcquired.dispose();
    _purchaseDate.dispose();
    _purchasePrice.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final group = await getIt<CreatePoultryGroup>()(
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
      context.go(AppRoutes.poultryGroup(group.id));
    } on AppFailure catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          l10n.addPoultryGroup,
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
        const SizedBox(height: 16),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: Text(_saving ? l10n.saving : l10n.createPoultryGroup),
        ),
      ],
    );
  }
}
