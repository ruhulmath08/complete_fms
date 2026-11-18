import 'package:mobile/data/models/common/json_parsers.dart';

class CycleSummaryModel {
  const CycleSummaryModel({
    required this.cropCycleId,
    required this.totalExpenses,
    required this.totalSaleIncome,
    required this.result,
  });

  factory CycleSummaryModel.fromJson(Map<String, dynamic> json) =>
      CycleSummaryModel(
        cropCycleId: requireString(json['crop_cycle_id'], 'crop_cycle_id'),
        totalExpenses:
            requireDecimalString(json['total_expenses'], 'total_expenses'),
        totalSaleIncome: requireDecimalString(
          json['total_sale_income'],
          'total_sale_income',
        ),
        result: requireDecimalString(json['result'], 'result'),
      );

  final String cropCycleId;
  final String totalExpenses;
  final String totalSaleIncome;
  final String result;

  Map<String, dynamic> toJson() => {
        'crop_cycle_id': cropCycleId,
        'total_expenses': totalExpenses,
        'total_sale_income': totalSaleIncome,
        'result': result,
      };
}
