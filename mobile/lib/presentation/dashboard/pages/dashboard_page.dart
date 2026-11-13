import 'package:flutter/material.dart';

import '../../../domain/date_ranges.dart';
import '../../../domain/entities/dashboard.dart';
import '../../../domain/failures.dart';
import '../../../domain/usecases/dashboard_usecases.dart';
import '../../../infrastructure/di/injection.dart';
import '../../../infrastructure/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../shared/widgets/async_state_views.dart';
import '../../shared/widgets/language_selector.dart';
import '../../shared/widgets/series_chart.dart';

/// Post-login landing page: six aggregate charts over a selectable period.
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  PeriodKind? _period = PeriodKind.week;
  late PeriodRange _range;
  final _from = TextEditingController();
  final _to = TextEditingController();
  bool _loading = true;
  String? _error;
  DashboardAggregates? _data;
  int _requestId = 0;

  @override
  void initState() {
    super.initState();
    _applyPeriod(PeriodKind.week, load: false);
    _load();
  }

  @override
  void dispose() {
    _from.dispose();
    _to.dispose();
    super.dispose();
  }

  void _applyPeriod(PeriodKind period, {bool load = true}) {
    final range = periodRange(period);
    setState(() {
      _period = period;
      _range = range;
      _from.text = range.from;
      _to.text = range.to;
    });
    if (load) _load();
  }

  void _applyCustom() {
    final normalized = normalizeRange(_from.text.trim(), _to.text.trim());
    final range = PeriodRange(
      from: normalized.from,
      to: normalized.to,
      grain: grainForRange(normalized.from, normalized.to),
    );
    setState(() {
      _period = null;
      _range = range;
      _from.text = range.from;
      _to.text = range.to;
    });
    _load();
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final today = DateTime.now();
    final lastDate = DateTime(today.year, today.month, today.day);
    var initial = DateTime.tryParse(controller.text.trim()) ?? lastDate;
    if (initial.isAfter(lastDate)) initial = lastDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: lastDate,
    );
    if (picked == null) return;
    setState(() => controller.text = toIsoDate(picked));
  }

  Future<void> _load() async {
    final requestId = ++_requestId;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await getIt<GetDashboardAggregates>()(
        from: _range.from,
        to: _range.to,
        grain: _range.grain.apiValue,
      );
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _data = data;
        _loading = false;
      });
    } on AppFailure catch (e) {
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    }
  }

  String _periodLabel(AppLocalizations l10n, PeriodKind period) =>
      switch (period) {
        PeriodKind.day => l10n.periodDay,
        PeriodKind.week => l10n.periodWeek,
        PeriodKind.month => l10n.periodMonth,
        PeriodKind.year => l10n.periodYear,
      };

  ({String title, String semantics, Color color}) _chartMeta(
    AppLocalizations l10n,
    AppTokens tokens,
    DashboardSeriesKey key,
  ) =>
      switch (key) {
        DashboardSeriesKey.eggProduction => (
            title: l10n.chartEggProduction,
            semantics: l10n.chartEggProductionSemantics,
            color: tokens.accent,
          ),
        DashboardSeriesKey.henHeadcount => (
            title: l10n.chartHenHeadcount,
            semantics: l10n.chartHenHeadcountSemantics,
            color: const Color(0xFF6B4F2A),
          ),
        DashboardSeriesKey.milk => (
            title: l10n.chartMilk,
            semantics: l10n.chartMilkSemantics,
            color: const Color(0xFF3B6EA5),
          ),
        DashboardSeriesKey.cowProduction => (
            title: l10n.chartCowProduction,
            semantics: l10n.chartCowProductionSemantics,
            color: tokens.primary,
          ),
        DashboardSeriesKey.expensesCost => (
            title: l10n.chartExpensesCost,
            semantics: l10n.chartExpensesCostSemantics,
            color: tokens.danger,
          ),
        DashboardSeriesKey.income => (
            title: l10n.chartIncome,
            semantics: l10n.chartIncomeSemantics,
            color: const Color(0xFF1F7A5A),
          ),
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tokens = AppTokens.of(context);
    final data = _data;
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: EdgeInsets.all(tokens.space4),
        children: [
          Text(
            l10n.dashboardTitle,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          SizedBox(height: tokens.space1),
          Text(
            data != null && data.timezone.isNotEmpty
                ? '${l10n.dashboardSubtitle} (${data.timezone})'
                : l10n.dashboardSubtitle,
            style: TextStyle(color: tokens.muted),
          ),
          SizedBox(height: tokens.space3),
          Wrap(
            spacing: tokens.space2,
            children: [
              for (final p in PeriodKind.values)
                ChoiceChip(
                  key: ValueKey('period-${p.name}'),
                  label: Text(_periodLabel(l10n, p)),
                  selected: _period == p,
                  onSelected: (_) => _applyPeriod(p),
                ),
            ],
          ),
          SizedBox(height: tokens.space3),
          Row(
            children: [
              Expanded(
                child: TextField(
                  key: const ValueKey('dashboard-from'),
                  controller: _from,
                  readOnly: true,
                  onTap: () => _pickDate(_from),
                  decoration: InputDecoration(
                    labelText: l10n.dashboardFrom,
                    suffixIcon: const Icon(Icons.calendar_today_outlined),
                  ),
                ),
              ),
              SizedBox(width: tokens.space3),
              Expanded(
                child: TextField(
                  key: const ValueKey('dashboard-to'),
                  controller: _to,
                  readOnly: true,
                  onTap: () => _pickDate(_to),
                  decoration: InputDecoration(
                    labelText: l10n.dashboardTo,
                    suffixIcon: const Icon(Icons.calendar_today_outlined),
                  ),
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              key: const ValueKey('dashboard-apply'),
              onPressed: _applyCustom,
              child: Text(l10n.applyDateRange),
            ),
          ),
          if (_error != null) ErrorView(message: _error!),
          if (_loading && data == null)
            const Padding(
              padding: EdgeInsets.all(24),
              child: LoadingView(),
            )
          else if (data != null)
            for (final key in DashboardSeriesKey.values) ...[
              Builder(
                builder: (context) {
                  final meta = _chartMeta(l10n, tokens, key);
                  return SeriesChart(
                    title: meta.title,
                    semanticsLabel: meta.semantics,
                    emptyMessage: l10n.dashboardChartEmpty,
                    series: [
                      ChartSeries(
                        key: key.apiKey,
                        label: meta.title,
                        color: meta.color,
                        points: [
                          for (final p in data.pointsFor(key))
                            ChartPoint(p.bucketStart, toChartNumber(p.value)),
                        ],
                      ),
                    ],
                  );
                },
              ),
              SizedBox(height: tokens.space4),
            ],
          const Divider(height: 32),
          const LanguageSelector(),
        ],
      ),
    );
  }
}
