class CowFeedingEntity {
  const CowFeedingEntity({
    required this.id,
    required this.cowId,
    required this.fedAt,
    required this.feedName,
    required this.quantity,
    required this.unit,
    required this.unitCost,
    required this.createdAt,
    this.note,
    this.total,
  });

  final String id;
  final String cowId;
  final String fedAt;
  final String feedName;
  final String quantity;
  final String unit;
  final String unitCost;
  final String? note;
  final String createdAt;
  final String? total;
}
