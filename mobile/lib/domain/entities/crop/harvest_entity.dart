class HarvestEntity {
  const HarvestEntity({
    required this.id,
    required this.cropCycleId,
    required this.harvestedAt,
    required this.quantity,
    required this.unit,
    required this.createdAt,
    this.saleAmount,
    this.note,
  });

  final String id;
  final String cropCycleId;
  final String harvestedAt;
  final String quantity;
  final String unit;
  final String? saleAmount;
  final String? note;
  final String createdAt;
}
