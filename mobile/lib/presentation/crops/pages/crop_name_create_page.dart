import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/failures.dart';
import '../../../domain/usecases/crops_usecases.dart';
import '../../../infrastructure/di/injection.dart';
import '../../../infrastructure/router/app_routes.dart';
import '../../../l10n/app_localizations.dart';
import '../widgets/crop_name_form_fields.dart';

class CropNameCreatePage extends StatefulWidget {
  const CropNameCreatePage({super.key});

  @override
  State<CropNameCreatePage> createState() => _CropNameCreatePageState();
}

class _CropNameCreatePageState extends State<CropNameCreatePage> {
  final _name = TextEditingController();
  final _notes = TextEditingController();
  String? _error;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final cropName = await getIt<CreateCropName>()(
        buildCropNameWriteParams(name: _name, notes: _notes),
      );
      if (!mounted) return;
      context.go(AppRoutes.cropName(cropName.id));
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
          l10n.addCropName,
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
        CropNameFormFields(name: _name, notes: _notes),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: Text(_saving ? l10n.saving : l10n.createCropName),
        ),
      ],
    );
  }
}
