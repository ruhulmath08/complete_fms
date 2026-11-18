import 'package:mobile/domain/entities/common/acquisition_source.dart';
import 'package:mobile/domain/entities/poultry/poultry_type.dart';

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
