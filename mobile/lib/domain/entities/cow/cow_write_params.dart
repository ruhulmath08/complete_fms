import 'package:mobile/domain/entities/common/acquisition_source.dart';
import 'package:mobile/domain/entities/cow/cow_gender.dart';
import 'package:mobile/domain/entities/cow/cow_purpose.dart';

class CowWriteParams {
  const CowWriteParams({
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

  final CowPurpose purpose;
  final CowGender gender;
  final AcquisitionSource acquiredBy;
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
