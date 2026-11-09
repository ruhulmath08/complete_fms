import 'package:flutter/material.dart';
import '../../../domain/entities/cow.dart';
import '../../../l10n/app_localizations.dart';

class CowFormFields extends StatelessWidget {
  const CowFormFields({
    super.key,
    required this.tagNumber,
    required this.name,
    required this.breed,
    required this.dateOfBirth,
    required this.color,
    required this.weight,
    required this.age,
    required this.purchaseDate,
    required this.purchasePrice,
    required this.notes,
    required this.purpose,
    required this.gender,
    required this.acquiredBy,
    required this.onPurposeChanged,
    required this.onGenderChanged,
    required this.onAcquiredByChanged,
  });

  final TextEditingController tagNumber;
  final TextEditingController name;
  final TextEditingController breed;
  final TextEditingController dateOfBirth;
  final TextEditingController color;
  final TextEditingController weight;
  final TextEditingController age;
  final TextEditingController purchaseDate;
  final TextEditingController purchasePrice;
  final TextEditingController notes;
  final CowPurpose purpose;
  final CowGender gender;
  final AcquisitionSource acquiredBy;
  final ValueChanged<CowPurpose> onPurposeChanged;
  final ValueChanged<CowGender> onGenderChanged;
  final ValueChanged<AcquisitionSource> onAcquiredByChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        TextField(
          controller: tagNumber,
          decoration: InputDecoration(labelText: l10n.tagNumber),
        ),
        TextField(
          controller: name,
          decoration: InputDecoration(labelText: l10n.cowName),
        ),
        DropdownButtonFormField<CowPurpose>(
          // ignore: deprecated_member_use
          value: purpose,
          decoration: InputDecoration(labelText: l10n.purpose),
          items: CowPurpose.values
              .map((e) => DropdownMenuItem(value: e, child: Text(e.name)))
              .toList(),
          onChanged: (v) {
            if (v != null) onPurposeChanged(v);
          },
        ),
        DropdownButtonFormField<CowGender>(
          // ignore: deprecated_member_use
          value: gender,
          decoration: InputDecoration(labelText: l10n.gender),
          items: CowGender.values
              .map((e) => DropdownMenuItem(value: e, child: Text(e.name)))
              .toList(),
          onChanged: (v) {
            if (v != null) onGenderChanged(v);
          },
        ),
        TextField(
          controller: breed,
          decoration: InputDecoration(labelText: l10n.breed),
        ),
        TextField(
          controller: color,
          decoration: InputDecoration(labelText: l10n.color),
        ),
        TextField(
          controller: dateOfBirth,
          decoration: InputDecoration(labelText: l10n.dateOfBirthHint),
        ),
        TextField(
          controller: age,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: l10n.ageYears),
        ),
        TextField(
          controller: weight,
          decoration: InputDecoration(labelText: l10n.weight),
        ),
        DropdownButtonFormField<AcquisitionSource>(
          // ignore: deprecated_member_use
          value: acquiredBy,
          decoration: InputDecoration(labelText: l10n.acquiredBy),
          items: [
            DropdownMenuItem(
              value: AcquisitionSource.bornOnFarm,
              child: Text(l10n.bornOnFarm),
            ),
            DropdownMenuItem(
              value: AcquisitionSource.purchased,
              child: Text(l10n.purchased),
            ),
          ],
          onChanged: (v) {
            if (v != null) onAcquiredByChanged(v);
          },
        ),
        if (acquiredBy == AcquisitionSource.purchased) ...[
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

CowWriteParams buildCowWriteParams({
  required TextEditingController tagNumber,
  required TextEditingController name,
  required TextEditingController breed,
  required TextEditingController dateOfBirth,
  required TextEditingController color,
  required TextEditingController weight,
  required TextEditingController age,
  required TextEditingController purchaseDate,
  required TextEditingController purchasePrice,
  required TextEditingController notes,
  required CowPurpose purpose,
  required CowGender gender,
  required AcquisitionSource acquiredBy,
}) {
  String? emptyToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  return CowWriteParams(
    tagNumber: tagNumber.text.trim(),
    purpose: purpose,
    gender: gender,
    acquiredBy: acquiredBy,
    name: emptyToNull(name.text),
    breed: emptyToNull(breed.text),
    dateOfBirth: emptyToNull(dateOfBirth.text),
    color: emptyToNull(color.text),
    weight: emptyToNull(weight.text),
    age: age.text.trim().isEmpty ? null : int.tryParse(age.text.trim()),
    purchaseDate: acquiredBy == AcquisitionSource.purchased
        ? emptyToNull(purchaseDate.text)
        : null,
    purchasePrice: acquiredBy == AcquisitionSource.purchased
        ? emptyToNull(purchasePrice.text)
        : null,
    notes: emptyToNull(notes.text),
  );
}
