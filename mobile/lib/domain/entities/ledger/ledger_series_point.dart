class LedgerSeriesPoint {
  const LedgerSeriesPoint({
    required this.bucketStart,
    required this.income,
    required this.expenses,
    required this.net,
  });

  final String bucketStart;
  final String income;
  final String expenses;
  final String net;
}
