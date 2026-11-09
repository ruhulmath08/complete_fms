import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/entities/ledger.dart';
import '../../../domain/failures.dart';
import '../../../domain/usecases/ledger_usecases.dart';
import '../../../infrastructure/di/injection.dart';
import '../../../l10n/app_localizations.dart';
import '../widgets/ledger_entry_form_fields.dart';

String _isoDate(DateTime d) {
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '${d.year}-$m-$day';
}

({String from, String to}) _monthBounds() {
  final now = DateTime.now();
  final from = DateTime(now.year, now.month, 1);
  final to = DateTime(now.year, now.month + 1, 0);
  return (from: _isoDate(from), to: _isoDate(to));
}

class LedgerListPage extends StatefulWidget {
  const LedgerListPage({super.key});

  @override
  State<LedgerListPage> createState() => _LedgerListPageState();
}

class _LedgerListPageState extends State<LedgerListPage> {
  late final TextEditingController _from;
  late final TextEditingController _to;
  bool _includeArchived = false;
  bool _loading = true;
  String? _error;
  List<LedgerEntry> _items = const [];
  PeriodTotals? _totals;

  @override
  void initState() {
    super.initState();
    final bounds = _monthBounds();
    _from = TextEditingController(text: bounds.from);
    _to = TextEditingController(text: bounds.to);
    _load();
  }

  @override
  void dispose() {
    _from.dispose();
    _to.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final from = _from.text.trim();
      final to = _to.text.trim();
      final page = await getIt<ListLedgerEntries>()(
        includeArchived: _includeArchived,
        from: from,
        to: to,
      );
      final totals = await getIt<GetPeriodTotals>()(from: from, to: to);
      if (!mounted) return;
      setState(() {
        _items = page.items;
        _totals = totals;
        _loading = false;
      });
    } on AppFailure catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final totals = _totals;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.ledgerTitle,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              FilledButton(
                onPressed: () async {
                  await context.push('/ledger/new');
                  _load();
                },
                child: Text(l10n.addLedgerEntry),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(l10n.ledgerCropGuidance, style: Theme.of(context).textTheme.bodySmall),
          TextField(
            controller: _from,
            decoration: InputDecoration(labelText: l10n.dateFrom),
          ),
          TextField(
            controller: _to,
            decoration: InputDecoration(labelText: l10n.dateTo),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(onPressed: _load, child: Text(l10n.applyDateRange)),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.includeArchived),
            value: _includeArchived,
            onChanged: (value) {
              setState(() => _includeArchived = value);
              _load();
            },
          ),
          if (totals != null) ...[
            Text('${l10n.totalIncome}: ${totals.totalIncome}'),
            Text('${l10n.totalExpenses}: ${totals.totalExpenses}'),
            Text('${l10n.net}: ${totals.net}'),
            const SizedBox(height: 8),
          ],
          if (_error != null)
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          if (_loading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_items.isEmpty)
            Expanded(child: Center(child: Text(l10n.noLedgerEntries)))
          else
            Expanded(
              child: RefreshIndicator(
                onRefresh: _load,
                child: ListView.separated(
                  itemCount: _items.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final entry = _items[index];
                    return ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                      ),
                      title: Text(
                        '${ledgerEntryTypeLabel(l10n, entry.entryType)} · ${entry.amount}',
                      ),
                      subtitle: Text(
                        '${entry.occurredAt} · ${ledgerCategoryLabel(l10n, entry.category)}'
                        '${entry.isArchived ? ' · ${l10n.archived}' : ''}',
                      ),
                      onTap: () async {
                        await context.push('/ledger/${entry.id}');
                        _load();
                      },
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
