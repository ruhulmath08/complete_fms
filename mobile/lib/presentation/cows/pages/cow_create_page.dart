import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/entities/cow.dart';
import '../../../domain/failures.dart';
import '../../../domain/usecases/cows_usecases.dart';
import '../../../infrastructure/di/injection.dart';
import '../../../infrastructure/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../widgets/cow_form_fields.dart';
import '../widgets/cow_image_panel.dart';

class CowCreatePage extends StatefulWidget {
  const CowCreatePage({super.key});

  @override
  State<CowCreatePage> createState() => _CowCreatePageState();
}

class _CowCreatePageState extends State<CowCreatePage> {
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
  String? _imagePath;
  String? _error;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _breed.dispose();
    _dateOfBirth.dispose();
    _color.dispose();
    _weight.dispose();
    _age.dispose();
    _purchaseDate.dispose();
    _purchasePrice.dispose();
    _notes.dispose();
    super.dispose();
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
      var cow = await getIt<CreateCow>()(params);
      final imagePath = _imagePath;
      if (imagePath != null) {
        cow = await getIt<UploadCowImage>()(cow.id, imagePath);
      }
      if (!mounted) return;
      context.go('/cows/${cow.id}');
    } on AppFailure catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tokens = AppTokens.of(context);
    return ListView(
      padding: EdgeInsets.all(tokens.space4),
      children: [
        Text(l10n.addCow, style: Theme.of(context).textTheme.headlineSmall),
        if (_error != null)
          Padding(
            padding: EdgeInsets.only(top: tokens.space2),
            child: Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        SizedBox(height: tokens.space3),
        CowImagePanel(
          localPath: _imagePath,
          onLocalPathChanged: (path) => setState(() => _imagePath = path),
        ),
        SizedBox(height: tokens.space3),
        CowFormFields(
          isCreate: true,
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
        SizedBox(height: tokens.space4),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: Text(_saving ? l10n.saving : l10n.createCow),
        ),
      ],
    );
  }
}
