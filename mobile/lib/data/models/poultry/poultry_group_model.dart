import 'package:mobile/data/models/common/json_parsers.dart';

class PoultryGroupModel {
  const PoultryGroupModel({
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

  factory PoultryGroupModel.fromJson(Map<String, dynamic> json) =>
      PoultryGroupModel(
        id: requireString(json['id'], 'id'),
        poultryType: requireString(json['poultry_type'], 'poultry_type'),
        name: requireString(json['name'], 'name'),
        birdCount: requireInt(json['bird_count'], 'bird_count'),
        dateAcquired: optionalString(json['date_acquired']),
        acquiredBy: requireString(json['acquired_by'], 'acquired_by'),
        purchaseDate: optionalString(json['purchase_date']),
        purchasePrice: optionalDecimalString(json['purchase_price']),
        notes: optionalString(json['notes']),
        isArchived: requireBool(json['is_archived'], 'is_archived'),
        createdAt: requireString(json['created_at'], 'created_at'),
        updatedAt: requireString(json['updated_at'], 'updated_at'),
      );

  final String id;
  final String poultryType;
  final String name;
  final int birdCount;
  final String? dateAcquired;
  final String acquiredBy;
  final String? purchaseDate;
  final String? purchasePrice;
  final String? notes;
  final bool isArchived;
  final String createdAt;
  final String updatedAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'poultry_type': poultryType,
        'name': name,
        'bird_count': birdCount,
        'date_acquired': dateAcquired,
        'acquired_by': acquiredBy,
        'purchase_date': purchaseDate,
        'purchase_price': purchasePrice,
        'notes': notes,
        'is_archived': isArchived,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };
}
