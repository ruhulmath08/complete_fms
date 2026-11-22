import 'package:mobile/domain/entities/common/acquisition_source_entity.dart';
import 'package:mobile/domain/entities/cow/cow_gender_entity.dart';
import 'package:mobile/domain/entities/cow/cow_purpose_entity.dart';

class CowEntity {
  const CowEntity({
    required this.id,
    required this.tagNumber,
    required this.purpose,
    required this.gender,
    required this.acquiredBy,
    required this.isArchived,
    required this.createdAt,
    required this.updatedAt,
    this.name,
    this.breed,
    this.dateOfBirth,
    this.color,
    this.weight,
    this.age,
    this.purchaseDate,
    this.purchasePrice,
    this.notes,
    this.imageUrl,
  });

  final String id;
  final String tagNumber;
  final String? name;
  final String? breed;
  final String? dateOfBirth;
  final CowPurposeEntity purpose;
  final CowGenderEntity gender;
  final String? color;
  final String? weight;
  final int? age;
  final AcquisitionSourceEntity acquiredBy;
  final String? purchaseDate;
  final String? purchasePrice;
  final String? notes;
  final String? imageUrl;
  final bool isArchived;
  final String createdAt;
  final String updatedAt;

  bool get milkEligible =>
      purpose == CowPurposeEntity.milk || purpose == CowPurposeEntity.both;
}
