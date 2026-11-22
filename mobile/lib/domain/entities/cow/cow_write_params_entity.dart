import 'package:mobile/domain/entities/common/acquisition_source_entity.dart';
import 'package:mobile/domain/entities/cow/cow_gender_entity.dart';
import 'package:mobile/domain/entities/cow/cow_purpose_entity.dart';

class CowWriteParamsEntity {
  const CowWriteParamsEntity({
    required this.purpose,
    required this.gender,
    required this.acquiredBy,
    required this.name,
    required this.breed,
    this.dateOfBirth,
    this.color,
    this.weight,
    this.age,
    this.purchaseDate,
    this.purchasePrice,
    this.notes,
  });

  final CowPurposeEntity purpose;
  final CowGenderEntity gender;
  final AcquisitionSourceEntity acquiredBy;
  final String name;
  final String breed;
  final String? dateOfBirth;
  final String? color;
  final String? weight;
  final int? age;
  final String? purchaseDate;
  final String? purchasePrice;
  final String? notes;
}
