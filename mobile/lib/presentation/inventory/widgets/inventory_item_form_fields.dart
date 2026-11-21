import 'package:material_ui/material_ui.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/presentation/shared/widgets/form_field_column.dart';
import 'package:mobile/domain/entities/inventory/inventory_category_entity.dart';
import 'package:mobile/domain/entities/inventory/inventory_item_create_params_entity.dart';
import 'package:mobile/domain/entities/inventory/inventory_item_update_params_entity.dart';

String inventoryCategoryLabel(AppLocalizations l10n, InventoryCategoryEntity category) {
  return switch (category) {
    InventoryCategoryEntity.feed => l10n.inventoryFeed,
    InventoryCategoryEntity.fertilizer => l10n.inventoryFertilizer,
    InventoryCategoryEntity.pesticide => l10n.inventoryPesticide,
    InventoryCategoryEntity.seed => l10n.inventorySeed,
    InventoryCategoryEntity.medicine => l10n.inventoryMedicine,
    InventoryCategoryEntity.equipment => l10n.inventoryEquipment,
    InventoryCategoryEntity.fuel => l10n.inventoryFuel,
    InventoryCategoryEntity.other => l10n.inventoryOther,
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
  final InventoryCategoryEntity category;
  final ValueChanged<InventoryCategoryEntity> onCategoryChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return FormFieldColumn(
      children: [
        TextField(
          controller: name,
          decoration: InputDecoration(labelText: l10n.inventoryItemName),
        ),
        DropdownButtonFormField<InventoryCategoryEntity>(
          // ignore: deprecated_member_use
          value: category,
          decoration: InputDecoration(labelText: l10n.inventoryCategory),
          items: InventoryCategoryEntity.values
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

InventoryItemCreateParamsEntity buildInventoryItemCreateParams({
  required TextEditingController name,
  required TextEditingController quantity,
  required TextEditingController unit,
  required TextEditingController pricePerUnit,
  required TextEditingController note,
  required InventoryCategoryEntity category,
}) {
  final noteText = note.text.trim();
  return InventoryItemCreateParamsEntity(
    name: name.text.trim(),
    category: category,
    quantity: quantity.text.trim(),
    unit: unit.text.trim(),
    pricePerUnit: pricePerUnit.text.trim(),
    note: noteText.isEmpty ? null : noteText,
  );
}

InventoryItemUpdateParamsEntity buildInventoryItemUpdateParams({
  required TextEditingController name,
  required TextEditingController unit,
  required TextEditingController pricePerUnit,
  required TextEditingController note,
  required InventoryCategoryEntity category,
}) {
  final noteText = note.text.trim();
  return InventoryItemUpdateParamsEntity(
    name: name.text.trim(),
    category: category,
    unit: unit.text.trim(),
    pricePerUnit: pricePerUnit.text.trim(),
    note: noteText.isEmpty ? null : noteText,
  );
}
