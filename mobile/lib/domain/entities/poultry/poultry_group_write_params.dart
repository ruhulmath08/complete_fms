import 'package:mobile/domain/entities/common/acquisition_source.dart';
import 'package:mobile/domain/entities/poultry/poultry_type.dart';

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
