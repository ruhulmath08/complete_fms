import 'package:flutter/material.dart';
import '../../../domain/entities/crop.dart';
import '../../../l10n/app_localizations.dart';
import '../../shared/widgets/form_field_column.dart';

class CropNameFormFields extends StatelessWidget {
  const CropNameFormFields({
    super.key,
    required this.name,
    required this.notes,
  });

  final TextEditingController name;
  final TextEditingController notes;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return FormFieldColumn(
      children: [
        TextField(
          controller: name,
          decoration: InputDecoration(labelText: l10n.cropNameLabel),
        ),
        TextField(
          controller: notes,
          decoration: InputDecoration(labelText: l10n.notes),
          maxLines: 3,
        ),
      ],
    );
  }
}

CropNameWriteParams buildCropNameWriteParams({
  required TextEditingController name,
  required TextEditingController notes,
}) {
  final notesText = notes.text.trim();
  return CropNameWriteParams(
    name: name.text.trim(),
    notes: notesText.isEmpty ? null : notesText,
  );
}
