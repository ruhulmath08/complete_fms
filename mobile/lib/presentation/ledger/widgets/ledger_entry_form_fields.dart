import 'package:material_ui/material_ui.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/presentation/shared/widgets/form_field_column.dart';
import 'package:mobile/domain/entities/ledger/ledger_entry_category_entity.dart';
import 'package:mobile/domain/entities/ledger/ledger_entry_type_entity.dart';
import 'package:mobile/domain/entities/ledger/ledger_entry_write_params_entity.dart';

String ledgerEntryTypeLabel(AppLocalizations l10n, LedgerEntryTypeEntity type) {
  return switch (type) {
    LedgerEntryTypeEntity.income => l10n.ledgerIncome,
    LedgerEntryTypeEntity.expense => l10n.ledgerExpense,
  };
}

String ledgerCategoryLabel(AppLocalizations l10n, LedgerEntryCategoryEntity category) {
  return switch (category) {
    LedgerEntryCategoryEntity.labour => l10n.ledgerLabour,
    LedgerEntryCategoryEntity.feedOrSupplies => l10n.ledgerFeedOrSupplies,
    LedgerEntryCategoryEntity.utilities => l10n.ledgerUtilities,
    LedgerEntryCategoryEntity.transport => l10n.ledgerTransport,
    LedgerEntryCategoryEntity.equipment => l10n.ledgerEquipment,
    LedgerEntryCategoryEntity.livestockSale => l10n.ledgerLivestockSale,
    LedgerEntryCategoryEntity.productSale => l10n.ledgerProductSale,
    LedgerEntryCategoryEntity.subsidy => l10n.ledgerSubsidy,
    LedgerEntryCategoryEntity.other => l10n.ledgerOther,
  };
}

class LedgerEntryFormFields extends StatelessWidget {
  const LedgerEntryFormFields({
    super.key,
    required this.occurredAt,
    required this.amount,
    required this.unit,
    required this.note,
    required this.entryType,
    required this.category,
    required this.onEntryTypeChanged,
    required this.onCategoryChanged,
  });

  final TextEditingController occurredAt;
  final TextEditingController amount;
  final TextEditingController unit;
  final TextEditingController note;
  final LedgerEntryTypeEntity entryType;
  final LedgerEntryCategoryEntity category;
  final ValueChanged<LedgerEntryTypeEntity> onEntryTypeChanged;
  final ValueChanged<LedgerEntryCategoryEntity> onCategoryChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return FormFieldColumn(
      children: [
        DropdownButtonFormField<LedgerEntryTypeEntity>(
          // ignore: deprecated_member_use
          value: entryType,
          decoration: InputDecoration(labelText: l10n.ledgerEntryType),
          items: LedgerEntryTypeEntity.values
              .map(
                (t) => DropdownMenuItem(
                  value: t,
                  child: Text(ledgerEntryTypeLabel(l10n, t)),
                ),
              )
              .toList(),
          onChanged: (v) {
            if (v != null) onEntryTypeChanged(v);
          },
        ),
        TextField(
          controller: occurredAt,
          decoration: InputDecoration(labelText: l10n.occurredAtHint),
        ),
        DropdownButtonFormField<LedgerEntryCategoryEntity>(
          // ignore: deprecated_member_use
          value: category,
          decoration: InputDecoration(labelText: l10n.ledgerCategory),
          items: LedgerEntryCategoryEntity.values
              .map(
                (c) => DropdownMenuItem(
                  value: c,
                  child: Text(ledgerCategoryLabel(l10n, c)),
                ),
              )
              .toList(),
          onChanged: (v) {
            if (v != null) onCategoryChanged(v);
          },
        ),
        TextField(
          controller: amount,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(labelText: l10n.amount),
        ),
        TextField(
          controller: unit,
          decoration: InputDecoration(labelText: l10n.unitOptional),
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

LedgerEntryWriteParamsEntity buildLedgerEntryWriteParams({
  required TextEditingController occurredAt,
  required TextEditingController amount,
  required TextEditingController unit,
  required TextEditingController note,
  required LedgerEntryTypeEntity entryType,
  required LedgerEntryCategoryEntity category,
}) {
  final unitText = unit.text.trim();
  final noteText = note.text.trim();
  return LedgerEntryWriteParamsEntity(
    entryType: entryType,
    occurredAt: occurredAt.text.trim(),
    category: category,
    amount: amount.text.trim(),
    unit: unitText.isEmpty ? null : unitText,
    note: noteText.isEmpty ? null : noteText,
  );
}
