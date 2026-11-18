import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

import 'package:mobile/domain/failures.dart';
import 'package:mobile/domain/use_cases/ledger/ledger_usecases.dart';
import 'package:mobile/infrastructure/di/injection.dart';
import 'package:mobile/infrastructure/router/app_routes.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/presentation/ledger/widgets/ledger_entry_form_fields.dart';
import 'package:mobile/domain/entities/ledger/ledger_entry_category.dart';
import 'package:mobile/domain/entities/ledger/ledger_entry_type.dart';

String _todayDate() {
  final now = DateTime.now();
  final m = now.month.toString().padLeft(2, '0');
  final d = now.day.toString().padLeft(2, '0');
  return '${now.year}-$m-$d';
}

class LedgerCreatePage extends StatefulWidget {
  const LedgerCreatePage({super.key});

  @override
  State<LedgerCreatePage> createState() => _LedgerCreatePageState();
}

class _LedgerCreatePageState extends State<LedgerCreatePage> {
  final _occurredAt = TextEditingController(text: _todayDate());
  final _amount = TextEditingController();
  final _unit = TextEditingController();
  final _note = TextEditingController();
  LedgerEntryType _entryType = LedgerEntryType.expense;
  LedgerEntryCategory _category = LedgerEntryCategory.other;
  String? _error;
  bool _saving = false;

  @override
  void dispose() {
    _occurredAt.dispose();
    _amount.dispose();
    _unit.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final entry = await getIt<CreateLedgerEntry>()(
        buildLedgerEntryWriteParams(
          occurredAt: _occurredAt,
          amount: _amount,
          unit: _unit,
          note: _note,
          entryType: _entryType,
          category: _category,
        ),
      );
      if (!mounted) return;
      context.go(AppRoutes.ledgerEntry(entry.id));
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
          l10n.addLedgerEntry,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(l10n.ledgerCropGuidance),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        const SizedBox(height: 12),
        LedgerEntryFormFields(
          occurredAt: _occurredAt,
          amount: _amount,
          unit: _unit,
          note: _note,
          entryType: _entryType,
          category: _category,
          onEntryTypeChanged: (v) => setState(() => _entryType = v),
          onCategoryChanged: (v) => setState(() => _category = v),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: Text(_saving ? l10n.saving : l10n.createLedgerEntry),
        ),
      ],
    );
  }
}
