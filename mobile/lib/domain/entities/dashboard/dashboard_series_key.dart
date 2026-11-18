enum DashboardSeriesKey {
  eggProduction('egg_production'),
  henHeadcount('hen_headcount'),
  milk('milk'),
  cowProduction('cow_production'),
  expensesCost('expenses_cost'),
  income('income');

  const DashboardSeriesKey(this.apiKey);

  final String apiKey;
}
