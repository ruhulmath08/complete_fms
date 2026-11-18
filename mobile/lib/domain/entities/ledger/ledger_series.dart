import 'package:mobile/domain/entities/ledger/ledger_series_point.dart';

class LedgerSeries {
  const LedgerSeries({
    required this.to,
    required this.grain,
    required this.points,
    this.from,
  });

  final String? from;
  final String to;
  final String grain;
  final List<LedgerSeriesPoint> points;
}
