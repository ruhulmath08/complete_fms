import 'package:flutter/material.dart';
import '../../../domain/entities/ledger.dart';
import '../../../l10n/app_localizations.dart';

String ledgerEntryTypeLabel(AppLocalizations l10n, LedgerEntryType type) {
  return switch (type) {
    LedgerEntryType.income => l10n.ledgerIncome,
    LedgerEntryType.expense => l10n.ledgerExpense,
  };
}

String ledgerCategoryLabel(AppLocalizations l10n, LedgerEntryCategory category) {
  return switch (category) {
    LedgerEntryCategory.labour => l10n.ledgerLabour,
    LedgerEntryCategory.feedOrSupplies => l10n.ledgerFeedOrSupplies,
    LedgerEntryCategory.utilities => l10n.ledgerUtilities,
    LedgerEntryCategory.transport => l10n.ledgerTransport,
    LedgerEntryCategory.equipment => l10n.ledgerEquipment,
    LedgerEntryCategory.livestockSale => l10n.ledgerLivestockSale,
    LedgerEntryCategory.productSale => l10n.ledgerProductSale,
    LedgerEntryCategory.subsidy => l10n.ledgerSubsidy,
    LedgerEntryCategory.other => l10n.ledgerOther,
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
  final LedgerEntryType entryType;
  final LedgerEntryCategory category;
  final ValueChanged<LedgerEntryType> onEntryTypeChanged;
  final ValueChanged<LedgerEntryCategory> onCategoryChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        DropdownButtonFormField<LedgerEntryType>(
          // ignore: deprecated_member_use
          value: entryType,
          decoration: InputDecoration(labelText: l10n.ledgerEntryType),
          items: LedgerEntryType.values
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
        DropdownButtonFormField<LedgerEntryCategory>(
          // ignore: deprecated_member_use
          value: category,
          decoration: InputDecoration(labelText: l10n.ledgerCategory),
          items: LedgerEntryCategory.values
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

LedgerEntryWriteParams buildLedgerEntryWriteParams({
  required TextEditingController occurredAt,
  required TextEditingController amount,
  required TextEditingController unit,
  required TextEditingController note,
  required LedgerEntryType entryType,
  required LedgerEntryCategory category,
}) {
  final unitText = unit.text.trim();
  final noteText = note.text.trim();
  return LedgerEntryWriteParams(
    entryType: entryType,
    occurredAt: occurredAt.text.trim(),
    category: category,
    amount: amount.text.trim(),
    unit: unitText.isEmpty ? null : unitText,
    note: noteText.isEmpty ? null : noteText,
  );
}
