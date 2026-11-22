import 'package:mobile/domain/entities/common/acquisition_source_entity.dart';
import 'package:mobile/domain/entities/poultry/poultry_type_entity.dart';

class PoultryGroupEntity {
  const PoultryGroupEntity({
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
  final PoultryTypeEntity poultryType;
  final String name;
  final int birdCount;
  final String? dateAcquired;
  final AcquisitionSourceEntity acquiredBy;
  final String? purchaseDate;
  final String? purchasePrice;
  final String? notes;
  final bool isArchived;
  final String createdAt;
  final String updatedAt;

  bool get eggsEligible =>
      poultryType == PoultryTypeEntity.duck ||
      poultryType == PoultryTypeEntity.layer ||
      poultryType == PoultryTypeEntity.local;
}
