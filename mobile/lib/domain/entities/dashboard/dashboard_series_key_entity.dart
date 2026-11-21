enum DashboardSeriesKeyEntity {
  eggProduction('egg_production'),
  henHeadcount('hen_headcount'),
  milk('milk'),
  cowProduction('cow_production'),
  expensesCost('expenses_cost'),
  income('income');

  const DashboardSeriesKeyEntity(this.apiKey);

  final String apiKey;
}
