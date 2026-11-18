import 'package:mobile/data/models/common/json_parsers.dart';
import 'package:mobile/data/models/ledger/ledger_series_point_model.dart';

class LedgerSeriesModel {
  const LedgerSeriesModel({
    required this.to,
    required this.grain,
    required this.points,
    this.from,
  });

  factory LedgerSeriesModel.fromJson(Map<String, dynamic> json) {
    final rawPoints = json['points'] as List<dynamic>? ?? const [];
    return LedgerSeriesModel(
      from: optionalString(json['from']),
      to: requireString(json['to'], 'to'),
      grain: requireString(json['grain'], 'grain'),
      points: rawPoints
          .map(
            (e) =>
                LedgerSeriesPointModel.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  final String? from;
  final String to;
  final String grain;
  final List<LedgerSeriesPointModel> points;

  Map<String, dynamic> toJson() => {
        'from': from,
        'to': to,
        'grain': grain,
        'points': points.map((p) => p.toJson()).toList(),
      };
}
