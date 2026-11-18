import 'package:mobile/data/models/common/json_parsers.dart';

class DashboardSeriesPointModel {
  const DashboardSeriesPointModel({
    required this.bucketStart,
    required this.value,
  });

  factory DashboardSeriesPointModel.fromJson(Map<String, dynamic> json) =>
      DashboardSeriesPointModel(
        bucketStart: requireString(json['bucket_start'], 'bucket_start'),
        value: requireDecimalString(json['value'], 'value'),
      );

  final String bucketStart;
  final String value;

  Map<String, dynamic> toJson() => {
        'bucket_start': bucketStart,
        'value': value,
      };
}
