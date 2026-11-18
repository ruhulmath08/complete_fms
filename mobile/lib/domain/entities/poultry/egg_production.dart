class EggProduction {
  const EggProduction({
    required this.id,
    required this.poultryGroupId,
    required this.producedAt,
    required this.quantity,
    required this.unit,
    required this.pricePerUnit,
    required this.createdAt,
    this.note,
  });

  final String id;
  final String poultryGroupId;
  final String producedAt;
  final String quantity;
  final String unit;
  final String pricePerUnit;
  final String? note;
  final String createdAt;
}
