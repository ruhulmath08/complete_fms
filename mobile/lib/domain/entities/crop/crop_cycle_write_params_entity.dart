class CropCycleWriteParamsEntity {
  const CropCycleWriteParamsEntity({
    required this.cropNameId,
    required this.plantedAt,
    this.plotName,
    this.area,
    this.location,
    this.expectedHarvestAt,
    this.notes,
  });

  final String cropNameId;
  final String plantedAt;
  final String? plotName;
  final String? area;
  final String? location;
  final String? expectedHarvestAt;
  final String? notes;
}
