import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/date_ranges.dart';
import '../../../domain/entities/ledger.dart';
import '../../../domain/failures.dart';
import '../../../domain/usecases/ledger_usecases.dart';
import '../../../infrastructure/di/injection.dart';
import '../../../infrastructure/router/app_routes.dart';
import '../../../infrastructure/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../shared/widgets/async_state_views.dart';
import '../../shared/widgets/entity_list_card.dart';
import '../../shared/widgets/form_field_column.dart';
import '../widgets/ledger_entry_form_fields.dart';
import '../widgets/ledger_series_chart.dart';

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
  LedgerSeries? _series;

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
      // Series are never requested past today (backend rejects future dates).
      final range = normalizeRange(from, to);
      final series = await getIt<GetLedgerSeries>()(
        from: range.from,
        to: range.to,
        grain: grainForRange(range.from, range.to).apiValue,
      );
      if (!mounted) return;
      setState(() {
        _items = page.items;
        _totals = totals;
        _series = series;
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
    final tokens = AppTokens.of(context);
    final totals = _totals;
    final series = _series;
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: EdgeInsets.all(tokens.space4),
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
                  await context.push(AppRoutes.ledgerNew);
                  _load();
                },
                child: Text(l10n.addLedgerEntry),
              ),
            ],
          ),
          SizedBox(height: tokens.space2),
          Text(
            l10n.ledgerCropGuidance,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          FormFieldColumn(
            children: [
              TextField(
                controller: _from,
                decoration: InputDecoration(labelText: l10n.dateFrom),
              ),
              TextField(
                controller: _to,
                decoration: InputDecoration(labelText: l10n.dateTo),
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: _load,
              child: Text(l10n.applyDateRange),
            ),
          ),
          if (series != null) ...[
            LedgerSeriesChart(series: series),
            SizedBox(height: tokens.space3),
          ],
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
            SizedBox(height: tokens.space2),
          ],
          if (_error != null) ErrorView(message: _error!),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: LoadingView(),
            )
          else if (_items.isEmpty)
            Padding(
              padding: EdgeInsets.all(tokens.space4),
              child: Center(child: Text(l10n.noLedgerEntries)),
            )
          else
            for (final entry in _items) ...[
              EntityListCard(
                title:
                    '${ledgerEntryTypeLabel(l10n, entry.entryType)} · ${entry.amount}',
                subtitle:
                    '${entry.occurredAt} · ${ledgerCategoryLabel(l10n, entry.category)}'
                    '${entry.isArchived ? ' · ${l10n.archived}' : ''}',
                onTap: () async {
                  await context.push(AppRoutes.ledgerEntry(entry.id));
                  _load();
                },
              ),
              SizedBox(height: tokens.space2),
            ],
        ],
      ),
    );
  }
}
