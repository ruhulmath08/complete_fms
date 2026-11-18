import 'package:mobile/data/models/common/json_parsers.dart';

class CowModel {
  const CowModel({
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

  factory CowModel.fromJson(Map<String, dynamic> json) => CowModel(
        id: requireString(json['id'], 'id'),
        tagNumber: requireString(json['tag_number'], 'tag_number'),
        name: optionalString(json['name']),
        breed: optionalString(json['breed']),
        dateOfBirth: optionalString(json['date_of_birth']),
        purpose: requireString(json['purpose'], 'purpose'),
        gender: requireString(json['gender'], 'gender'),
        color: optionalString(json['color']),
        weight: optionalDecimalString(json['weight']),
        age: json['age'] == null ? null : requireInt(json['age'], 'age'),
        acquiredBy: requireString(json['acquired_by'], 'acquired_by'),
        purchaseDate: optionalString(json['purchase_date']),
        purchasePrice: optionalDecimalString(json['purchase_price']),
        notes: optionalString(json['notes']),
        imageUrl: optionalString(json['image_url']),
        isArchived: requireBool(json['is_archived'], 'is_archived'),
        createdAt: requireString(json['created_at'], 'created_at'),
        updatedAt: requireString(json['updated_at'], 'updated_at'),
      );

  final String id;
  final String tagNumber;
  final String? name;
  final String? breed;
  final String? dateOfBirth;
  final String purpose;
  final String gender;
  final String? color;
  final String? weight;
  final int? age;
  final String acquiredBy;
  final String? purchaseDate;
  final String? purchasePrice;
  final String? notes;
  final String? imageUrl;
  final bool isArchived;
  final String createdAt;
  final String updatedAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'tag_number': tagNumber,
        'name': name,
        'breed': breed,
        'date_of_birth': dateOfBirth,
        'purpose': purpose,
        'gender': gender,
        'color': color,
        'weight': weight,
        'age': age,
        'acquired_by': acquiredBy,
        'purchase_date': purchaseDate,
        'purchase_price': purchasePrice,
        'notes': notes,
        'image_url': imageUrl,
        'is_archived': isArchived,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };
}
