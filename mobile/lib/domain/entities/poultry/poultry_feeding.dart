class PoultryFeeding {
  const PoultryFeeding({
    required this.id,
    required this.poultryGroupId,
    required this.fedAt,
    required this.feedName,
    required this.quantity,
    required this.unit,
    required this.createdAt,
    this.note,
  });

  final String id;
  final String poultryGroupId;
  final String fedAt;
  final String feedName;
  final String quantity;
  final String unit;
  final String? note;
  final String createdAt;
}
