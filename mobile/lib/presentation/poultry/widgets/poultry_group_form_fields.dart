import 'package:material_ui/material_ui.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/presentation/shared/widgets/form_field_column.dart';
import 'package:mobile/domain/entities/common/acquisition_source_entity.dart';
import 'package:mobile/domain/entities/poultry/poultry_group_write_params_entity.dart';
import 'package:mobile/domain/entities/poultry/poultry_type_entity.dart';

class PoultryGroupFormFields extends StatelessWidget {
  const PoultryGroupFormFields({
    super.key,
    required this.name,
    required this.birdCount,
    required this.dateAcquired,
    required this.purchaseDate,
    required this.purchasePrice,
    required this.notes,
    required this.poultryType,
    required this.acquiredBy,
    required this.onPoultryTypeChanged,
    required this.onAcquiredByChanged,
  });

  final TextEditingController name;
  final TextEditingController birdCount;
  final TextEditingController dateAcquired;
  final TextEditingController purchaseDate;
  final TextEditingController purchasePrice;
  final TextEditingController notes;
  final PoultryTypeEntity poultryType;
  final AcquisitionSourceEntity acquiredBy;
  final ValueChanged<PoultryTypeEntity> onPoultryTypeChanged;
  final ValueChanged<AcquisitionSourceEntity> onAcquiredByChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return FormFieldColumn(
      children: [
        TextField(
          controller: name,
          decoration: InputDecoration(labelText: l10n.poultryGroupName),
        ),
        DropdownButtonFormField<PoultryTypeEntity>(
          // ignore: deprecated_member_use
          value: poultryType,
          decoration: InputDecoration(labelText: l10n.poultryType),
          items: PoultryTypeEntity.values
              .map((e) => DropdownMenuItem(value: e, child: Text(e.name)))
              .toList(),
          onChanged: (v) {
            if (v != null) onPoultryTypeChanged(v);
          },
        ),
        TextField(
          controller: birdCount,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: l10n.birdCount),
        ),
        TextField(
          controller: dateAcquired,
          decoration: InputDecoration(labelText: l10n.dateAcquiredHint),
        ),
        DropdownButtonFormField<AcquisitionSourceEntity>(
          // ignore: deprecated_member_use
          value: acquiredBy,
          decoration: InputDecoration(labelText: l10n.acquiredBy),
          items: [
            DropdownMenuItem(
              value: AcquisitionSourceEntity.bornOnFarm,
              child: Text(l10n.bornOnFarm),
            ),
            DropdownMenuItem(
              value: AcquisitionSourceEntity.purchased,
              child: Text(l10n.purchased),
            ),
          ],
          onChanged: (v) {
            if (v != null) onAcquiredByChanged(v);
          },
        ),
        if (acquiredBy == AcquisitionSourceEntity.purchased) ...[
          TextField(
            controller: purchaseDate,
            decoration: InputDecoration(labelText: l10n.purchaseDateHint),
          ),
          TextField(
            controller: purchasePrice,
            decoration: InputDecoration(labelText: l10n.purchasePrice),
          ),
        ],
        TextField(
          controller: notes,
          maxLines: 3,
          decoration: InputDecoration(labelText: l10n.notes),
        ),
      ],
    );
  }
}

PoultryGroupWriteParamsEntity buildPoultryGroupWriteParams({
  required TextEditingController name,
  required TextEditingController birdCount,
  required TextEditingController dateAcquired,
  required TextEditingController purchaseDate,
  required TextEditingController purchasePrice,
  required TextEditingController notes,
  required PoultryTypeEntity poultryType,
  required AcquisitionSourceEntity acquiredBy,
}) {
  String? emptyToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  return PoultryGroupWriteParamsEntity(
    poultryType: poultryType,
    name: name.text.trim(),
    birdCount: int.tryParse(birdCount.text.trim()) ?? 0,
    acquiredBy: acquiredBy,
    dateAcquired: emptyToNull(dateAcquired.text),
    purchaseDate: acquiredBy == AcquisitionSourceEntity.purchased
        ? emptyToNull(purchaseDate.text)
        : null,
    purchasePrice: acquiredBy == AcquisitionSourceEntity.purchased
        ? emptyToNull(purchasePrice.text)
        : null,
    notes: emptyToNull(notes.text),
  );
}
