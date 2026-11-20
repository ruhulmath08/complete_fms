class MilkProductionEntity {
  const MilkProductionEntity({
    required this.id,
    required this.cowId,
    required this.producedAt,
    required this.quantity,
    required this.unit,
    required this.pricePerUnit,
    required this.createdAt,
    this.note,
    this.total,
  });

  final String id;
  final String cowId;
  final String producedAt;
  final String quantity;
  final String unit;
  final String pricePerUnit;
  final String? note;
  final String createdAt;
  final String? total;
}
