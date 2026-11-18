class CropCycle {
  const CropCycle({
    required this.id,
    required this.cropNameId,
    required this.plantedAt,
    required this.isArchived,
    required this.createdAt,
    required this.updatedAt,
    this.plotName,
    this.area,
    this.location,
    this.expectedHarvestAt,
    this.notes,
  });

  final String id;
  final String cropNameId;
  final String? plotName;
  final String? area;
  final String? location;
  final String plantedAt;
  final String? expectedHarvestAt;
  final String? notes;
  final bool isArchived;
  final String createdAt;
  final String updatedAt;
}
