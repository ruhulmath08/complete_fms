import 'package:mobile/data/models/dashboard/dashboard_series_point_model.dart';

class DashboardSeriesBundleModel {
  const DashboardSeriesBundleModel({
    required this.eggProduction,
    required this.henHeadcount,
    required this.milk,
    required this.cowProduction,
    required this.expensesCost,
    required this.income,
  });

  factory DashboardSeriesBundleModel.fromJson(Map<String, dynamic> json) {
    List<DashboardSeriesPointModel> points(String key) {
      final raw = json[key] as List<dynamic>? ?? const [];
      return raw
          .map(
            (e) =>
                DashboardSeriesPointModel.fromJson(e as Map<String, dynamic>),
          )
          .toList();
    }

    return DashboardSeriesBundleModel(
      eggProduction: points('egg_production'),
      henHeadcount: points('hen_headcount'),
      milk: points('milk'),
      cowProduction: points('cow_production'),
      expensesCost: points('expenses_cost'),
      income: points('income'),
    );
  }

  final List<DashboardSeriesPointModel> eggProduction;
  final List<DashboardSeriesPointModel> henHeadcount;
  final List<DashboardSeriesPointModel> milk;
  final List<DashboardSeriesPointModel> cowProduction;
  final List<DashboardSeriesPointModel> expensesCost;
  final List<DashboardSeriesPointModel> income;

  Map<String, dynamic> toJson() => {
        'egg_production': eggProduction.map((e) => e.toJson()).toList(),
        'hen_headcount': henHeadcount.map((e) => e.toJson()).toList(),
        'milk': milk.map((e) => e.toJson()).toList(),
        'cow_production': cowProduction.map((e) => e.toJson()).toList(),
        'expenses_cost': expensesCost.map((e) => e.toJson()).toList(),
        'income': income.map((e) => e.toJson()).toList(),
      };
}
