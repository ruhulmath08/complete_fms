import 'package:mobile/domain/entities/ledger/ledger_series_point_entity.dart';

class LedgerSeriesEntity {
  const LedgerSeriesEntity({
    required this.to,
    required this.grain,
    required this.points,
    this.from,
  });

  final String? from;
  final String to;
  final String grain;
  final List<LedgerSeriesPointEntity> points;
}
