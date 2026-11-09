import 'package:flutter/material.dart';
import '../../../domain/entities/crop.dart';
import '../../../l10n/app_localizations.dart';

class CropCycleFormFields extends StatelessWidget {
  const CropCycleFormFields({
    super.key,
    required this.cropNames,
    required this.cropNameId,
    required this.onCropNameChanged,
    required this.plantedAt,
    required this.expectedHarvestAt,
    required this.plotName,
    required this.area,
    required this.location,
    required this.notes,
  });

  final List<CropName> cropNames;
  final String? cropNameId;
  final ValueChanged<String?> onCropNameChanged;
  final TextEditingController plantedAt;
  final TextEditingController expectedHarvestAt;
  final TextEditingController plotName;
  final TextEditingController area;
  final TextEditingController location;
  final TextEditingController notes;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        DropdownButtonFormField<String>(
          // ignore: deprecated_member_use
          value: cropNameId,
          decoration: InputDecoration(labelText: l10n.cropLabel),
          items: cropNames
              .map(
                (name) => DropdownMenuItem(
                  value: name.id,
                  child: Text(name.name),
                ),
              )
              .toList(),
          onChanged: onCropNameChanged,
        ),
        TextField(
          controller: plantedAt,
          decoration: InputDecoration(labelText: l10n.plantedAtHint),
        ),
        TextField(
          controller: expectedHarvestAt,
          decoration: InputDecoration(labelText: l10n.expectedHarvestHint),
        ),
        TextField(
          controller: plotName,
          decoration: InputDecoration(labelText: l10n.plotName),
        ),
        TextField(
          controller: area,
          decoration: InputDecoration(labelText: l10n.area),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        TextField(
          controller: location,
          decoration: InputDecoration(labelText: l10n.location),
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

CropCycleWriteParams buildCropCycleWriteParams({
  required String cropNameId,
  required TextEditingController plantedAt,
  required TextEditingController expectedHarvestAt,
  required TextEditingController plotName,
  required TextEditingController area,
  required TextEditingController location,
  required TextEditingController notes,
}) {
  String? emptyOrNull(TextEditingController c) {
    final value = c.text.trim();
    return value.isEmpty ? null : value;
  }

  return CropCycleWriteParams(
    cropNameId: cropNameId,
    plantedAt: plantedAt.text.trim(),
    plotName: emptyOrNull(plotName),
    area: emptyOrNull(area),
    location: emptyOrNull(location),
    expectedHarvestAt: emptyOrNull(expectedHarvestAt),
    notes: emptyOrNull(notes),
  );
}
