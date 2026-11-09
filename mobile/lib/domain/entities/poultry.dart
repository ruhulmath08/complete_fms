import 'cow.dart' show AcquisitionSource;

export 'cow.dart' show AcquisitionSource, PagedResult;

enum PoultryType { broiler, duck, layer, local }

class PoultryGroup {
  const PoultryGroup({
    required this.id,
    required this.poultryType,
    required this.name,
    required this.birdCount,
    required this.acquiredBy,
    required this.isArchived,
    required this.createdAt,
    required this.updatedAt,
    this.dateAcquired,
    this.purchaseDate,
    this.purchasePrice,
    this.notes,
  });

  final String id;
  final PoultryType poultryType;
  final String name;
  final int birdCount;
  final String? dateAcquired;
  final AcquisitionSource acquiredBy;
  final String? purchaseDate;
  final String? purchasePrice;
  final String? notes;
  final bool isArchived;
  final String createdAt;
  final String updatedAt;

  bool get eggsEligible =>
      poultryType == PoultryType.duck ||
      poultryType == PoultryType.layer ||
      poultryType == PoultryType.local;
}

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

class PoultryGroupWriteParams {
  const PoultryGroupWriteParams({
    required this.poultryType,
    required this.name,
    required this.birdCount,
    required this.acquiredBy,
    this.dateAcquired,
    this.purchaseDate,
    this.purchasePrice,
    this.notes,
  });

  final PoultryType poultryType;
  final String name;
  final int birdCount;
  final AcquisitionSource acquiredBy;
  final String? dateAcquired;
  final String? purchaseDate;
  final String? purchasePrice;
  final String? notes;
}
