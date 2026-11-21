class CycleSummaryEntity {
  const CycleSummaryEntity({
    required this.cropCycleId,
    required this.totalExpenses,
    required this.totalSaleIncome,
    required this.result,
  });

  final String cropCycleId;
  final String totalExpenses;
  final String totalSaleIncome;
  final String result;
}
