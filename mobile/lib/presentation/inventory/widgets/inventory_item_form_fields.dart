import 'package:flutter/material.dart';
import '../../../domain/entities/inventory.dart';
import '../../../l10n/app_localizations.dart';
import '../../shared/widgets/form_field_column.dart';

String inventoryCategoryLabel(AppLocalizations l10n, InventoryCategory category) {
  return switch (category) {
    InventoryCategory.feed => l10n.inventoryFeed,
    InventoryCategory.fertilizer => l10n.inventoryFertilizer,
    InventoryCategory.pesticide => l10n.inventoryPesticide,
    InventoryCategory.seed => l10n.inventorySeed,
    InventoryCategory.medicine => l10n.inventoryMedicine,
    InventoryCategory.equipment => l10n.inventoryEquipment,
    InventoryCategory.fuel => l10n.inventoryFuel,
    InventoryCategory.other => l10n.inventoryOther,
  };
}

class InventoryItemFormFields extends StatelessWidget {
  const InventoryItemFormFields({
    super.key,
    required this.includeQuantity,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.pricePerUnit,
    required this.note,
    required this.category,
    required this.onCategoryChanged,
  });

  final bool includeQuantity;
  final TextEditingController name;
  final TextEditingController quantity;
  final TextEditingController unit;
  final TextEditingController pricePerUnit;
  final TextEditingController note;
  final InventoryCategory category;
  final ValueChanged<InventoryCategory> onCategoryChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return FormFieldColumn(
      children: [
        TextField(
          controller: name,
          decoration: InputDecoration(labelText: l10n.inventoryItemName),
        ),
        DropdownButtonFormField<InventoryCategory>(
          // ignore: deprecated_member_use
          value: category,
          decoration: InputDecoration(labelText: l10n.inventoryCategory),
          items: InventoryCategory.values
              .map(
                (c) => DropdownMenuItem(
                  value: c,
                  child: Text(inventoryCategoryLabel(l10n, c)),
                ),
              )
              .toList(),
          onChanged: (v) {
            if (v != null) onCategoryChanged(v);
          },
        ),
        if (includeQuantity)
          TextField(
            controller: quantity,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: l10n.quantity),
          ),
        TextField(
          controller: unit,
          decoration: InputDecoration(labelText: l10n.unit),
        ),
        TextField(
          controller: pricePerUnit,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(labelText: l10n.pricePerUnit),
        ),
        TextField(
          controller: note,
          decoration: InputDecoration(labelText: l10n.note),
          maxLines: 3,
        ),
      ],
    );
  }
}

InventoryItemCreateParams buildInventoryItemCreateParams({
  required TextEditingController name,
  required TextEditingController quantity,
  required TextEditingController unit,
  required TextEditingController pricePerUnit,
  required TextEditingController note,
  required InventoryCategory category,
}) {
  final noteText = note.text.trim();
  return InventoryItemCreateParams(
    name: name.text.trim(),
    category: category,
    quantity: quantity.text.trim(),
    unit: unit.text.trim(),
    pricePerUnit: pricePerUnit.text.trim(),
    note: noteText.isEmpty ? null : noteText,
  );
}

InventoryItemUpdateParams buildInventoryItemUpdateParams({
  required TextEditingController name,
  required TextEditingController unit,
  required TextEditingController pricePerUnit,
  required TextEditingController note,
  required InventoryCategory category,
}) {
  final noteText = note.text.trim();
  return InventoryItemUpdateParams(
    name: name.text.trim(),
    category: category,
    unit: unit.text.trim(),
    pricePerUnit: pricePerUnit.text.trim(),
    note: noteText.isEmpty ? null : noteText,
  );
}
