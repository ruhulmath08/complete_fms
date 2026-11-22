import 'package:mobile/domain/entities/common/acquisition_source_entity.dart';
import 'package:mobile/domain/entities/poultry/poultry_type_entity.dart';

class PoultryGroupWriteParamsEntity {
  const PoultryGroupWriteParamsEntity({
    required this.poultryType,
    required this.name,
    required this.birdCount,
    required this.acquiredBy,
    this.dateAcquired,
    this.purchaseDate,
    this.purchasePrice,
    this.notes,
  });

  final PoultryTypeEntity poultryType;
  final String name;
  final int birdCount;
  final AcquisitionSourceEntity acquiredBy;
  final String? dateAcquired;
  final String? purchaseDate;
  final String? purchasePrice;
  final String? notes;
}
