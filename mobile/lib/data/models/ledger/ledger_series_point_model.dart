import 'package:mobile/data/models/common/json_parsers.dart';

class LedgerSeriesPointModel {
  const LedgerSeriesPointModel({
    required this.bucketStart,
    required this.income,
    required this.expenses,
    required this.net,
  });

  factory LedgerSeriesPointModel.fromJson(Map<String, dynamic> json) =>
      LedgerSeriesPointModel(
        bucketStart: requireString(json['bucket_start'], 'bucket_start'),
        income: requireDecimalString(json['income'], 'income'),
        expenses: requireDecimalString(json['expenses'], 'expenses'),
        net: requireDecimalString(json['net'], 'net'),
      );

  final String bucketStart;
  final String income;
  final String expenses;
  final String net;

  Map<String, dynamic> toJson() => {
        'bucket_start': bucketStart,
        'income': income,
        'expenses': expenses,
        'net': net,
      };
}
