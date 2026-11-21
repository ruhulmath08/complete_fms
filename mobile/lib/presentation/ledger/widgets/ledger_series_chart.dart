import 'package:material_ui/material_ui.dart';

import 'package:mobile/infrastructure/theme/app_theme.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/presentation/shared/widgets/series_chart.dart';
import 'package:mobile/domain/entities/ledger/ledger_series_entity.dart';

/// Income / expenses / net over the selected range (numeric totals stay on the page).
class LedgerSeriesChart extends StatelessWidget {
  const LedgerSeriesChart({super.key, required this.series});

  final LedgerSeriesEntity series;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tokens = AppTokens.of(context);
    final points = series.points;
    return SeriesChart(
      title: l10n.ledgerChartTitle,
      semanticsLabel: l10n.ledgerChartSemantics,
      emptyMessage: l10n.ledgerChartEmpty,
      series: [
        ChartSeries(
          key: 'income',
          label: l10n.ledgerIncome,
          color: tokens.primary,
          points: [
            for (final p in points)
              ChartPoint(p.bucketStart, toChartNumber(p.income)),
          ],
        ),
        ChartSeries(
          key: 'expenses',
          label: l10n.ledgerExpense,
          color: tokens.danger,
          points: [
            for (final p in points)
              ChartPoint(p.bucketStart, toChartNumber(p.expenses)),
          ],
        ),
        ChartSeries(
          key: 'net',
          label: l10n.net,
          color: tokens.accent,
          points: [
            for (final p in points)
              ChartPoint(p.bucketStart, toChartNumber(p.net)),
          ],
        ),
      ],
    );
  }
}
