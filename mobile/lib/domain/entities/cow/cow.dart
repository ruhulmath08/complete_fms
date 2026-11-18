import 'package:mobile/domain/entities/common/acquisition_source.dart';
import 'package:mobile/domain/entities/cow/cow_gender.dart';
import 'package:mobile/domain/entities/cow/cow_purpose.dart';

class Cow {
  const Cow({
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
  final CowPurpose purpose;
  final CowGender gender;
  final String? color;
  final String? weight;
  final int? age;
  final AcquisitionSource acquiredBy;
  final String? purchaseDate;
  final String? purchasePrice;
  final String? notes;
  final String? imageUrl;
  final bool isArchived;
  final String createdAt;
  final String updatedAt;

  bool get milkEligible =>
      purpose == CowPurpose.milk || purpose == CowPurpose.both;
}
