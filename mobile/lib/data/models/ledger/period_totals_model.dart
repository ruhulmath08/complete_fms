import 'package:mobile/data/models/common/json_parsers.dart';

class PeriodTotalsModel {
  const PeriodTotalsModel({
    required this.from,
    required this.to,
    required this.totalIncome,
    required this.totalExpenses,
    required this.net,
  });

  factory PeriodTotalsModel.fromJson(Map<String, dynamic> json) =>
      PeriodTotalsModel(
        from: requireString(json['from'], 'from'),
        to: requireString(json['to'], 'to'),
        totalIncome: requireDecimalString(json['total_income'], 'total_income'),
        totalExpenses:
            requireDecimalString(json['total_expenses'], 'total_expenses'),
        net: requireDecimalString(json['net'], 'net'),
      );

  final String from;
  final String to;
  final String totalIncome;
  final String totalExpenses;
  final String net;

  Map<String, dynamic> toJson() => {
        'from': from,
        'to': to,
        'total_income': totalIncome,
        'total_expenses': totalExpenses,
        'net': net,
      };
}
